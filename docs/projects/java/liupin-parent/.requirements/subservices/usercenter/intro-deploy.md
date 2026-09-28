# liupin-usercenter-service 打包与部署文档

> 模块路径：`liupin-service/liupin-usercenter-service/`
> 主类：`com.liupin.usercenter.UserCenterApp`
> 默认端口：`9096`
> Spring Boot：`2.3.4.RELEASE` / Spring Cloud：`Hoxton.SR8` / JDK：`8`

## 1. 前置条件

### 1.1 必须使用 JDK 8
项目锁定 **Lombok 1.18.20**（根 `pom.xml` `<lombok.version>1.18.20</lombok.version>`），与 JDK 17+ 不兼容；在系统默认 JDK 25 下编译会报 `java.lang.ExceptionInInitializerError: com.sun.tools.javac.code.TypeTag :: UNKNOWN`。**任何 `mvn compile`/`mvn package` 之前都需切换到 JDK 8。**

```bash
# 推荐：SDKMAN 切换（aliased: sdk use java 8.0.432-zulu）
sdk-use-8
java -version          # 确认显示 1.8

# 无网络时 sdk use 会失败，直接激活已安装的 JDK 8（Bash 工具调用间 env 不持久，需同条命令执行）：
export JAVA_HOME=/root/.sdkman/candidates/java/8.0.432-zulu && export PATH=$JAVA_HOME/bin:$PATH && java -version

# 备用：本地 JDK 8 tarball
# tar -xzf /data/soft/source/jdk/jdk-8u261-linux-x64.tar.gz -C /opt
# export JAVA_HOME=/opt/jdk1.8.0_261 && export PATH=$JAVA_HOME/bin:$PATH
```

### 1.2 依赖
- Maven（多模块项目，需根 `liupin-parent` 已 `install` 到本地仓库，或用 `-am` 一并构建）
- MySQL（库 `lpt_user_center`）、Redis、Nacos（注册与配置中心）
- 本地默认 profile 连接：Nacos `172.17.16.118:8848`、MySQL `sh-cdb-pygnrd8o.sql.tencentcdb.com:58729`、Redis `172.17.16.122:8097`（见 `bootstrap-local.yaml`）

> 本文档命令仅用于**本地/测试**环境。生产库禁止直连或执行破坏性操作。

## 2. 编译与打包

### 2.1 仅编译当前模块（连同依赖模块）
```bash
cd /data/java/liupin-parent
sdk-use-8
mvn -pl liupin-service/liupin-usercenter-service -am compile
```

### 2.2 打包（生成可执行 fat jar）
`spring-boot-maven-plugin` 产出可执行 jar，`finalName` 为 `liupin-usercenter-service`，输出于 `target/liupin-usercenter-service.jar`：
```bash
cd /data/java/liupin-parent
sdk-use-8
mvn -pl liupin-service/liupin-usercenter-service -am clean package
# 产物：
ls -lh liupin-service/liupin-usercenter-service/target/liupin-usercenter-service.jar
```

### 2.3 离线构建
无外网时加 `-o`（离线），前提是所有依赖已在本地 `~/.m2`：
```bash
mvn -o -pl liupin-service/liupin-usercenter-service -am clean package
```

### 2.4 跳过测试加速
```bash
mvn -pl liupin-service/liupin-usercenter-service -am clean package -DskipTests
```

> 注意：`package` 阶段绑定了自定义 `liupin-publish-plugin`（见第 4 节）。其发布开关 `publishProject.isPublish` 当前为 `false`，故打包只生成 jar，不会自动 SCP 到远程。

## 3. 本地运行

### 3.1 Maven 直接运行（开发常用）
```bash
cd /data/java/liupin-parent/liupin-service/liupin-usercenter-service
sdk-use-8
mvn spring-boot:run -Dspring-boot.run.profiles=local
```
可用 profile：`local` / `dev` / `test` / `uat` / `pro`（对应 `bootstrap-<profile>.yaml`）。`bootstrap.yaml` 默认 `spring.profiles.active: test`。

### 3.2 运行打好的 jar
```bash
java -jar liupin-service/liupin-usercenter-service/target/liupin-usercenter-service.jar \
     --spring.profiles.active=local
```

### 3.3 指定端口/覆盖配置
```bash
java -jar target/liupin-usercenter-service.jar \
     --spring.profiles.active=local \
     --server.port=9096
```

### 3.4 Nacos 配置依赖
`bootstrap.yaml` 通过 Nacos 拉取共享配置 `wechatConfig.yaml`、`wechat-appconfig.yaml`（`refresh: true`）。本地启动需能连通 Nacos，否则微信相关配置缺失。MySQL/Redis 连接信息在各 `bootstrap-<profile>.yaml` 中。

## 4. 远程发布机制（liupin-publish-plugin）

`liupin-service/liupin-usercenter-service/pom.xml` 在 `package` 阶段绑定了 `com.liupin:liupin-publish-plugin` 的 `publishProjectMojo`（源码：`liupin-publish-plugin/.../PublishProjectMojo.java`）。

**工作机制**（当开关打开时）：
1. 读取 `bootstrap.yaml` 中 `publishProject` 配置：
   ```yaml
   publishProject:
     isPublish: false          # 总开关，true 才发布
     environment: ['test']     # 目标环境：test / dev / uat
   ```
2. 校验 `isPublish=true` 且 `environment` 非空。
3. 通过 SSH/SCP 将 `target/liupin-usercenter-service.jar` 上传到目标服务器
   `/usr/local/liupin/liupin-service/liupin-usercenter-service/bak/`。
4. 远程执行 `sh /usr/local/liupin/liupin-service/liupin-usercenter-service/run-server.sh remote_start` 重启服务。

**环境与服务器**（插件 `ConstantMap`）：
| environment | 用途 | 服务器 |
|-------------|------|--------|
| `test` | 测试 | `192.168.203.5` |
| `dev` | 开发 | `101.34.50.109` |
| `uat` | 预发布 | `119.91.77.115` |

> ⚠️ 当前 `bootstrap.yaml` 中 `isPublish: false`，自动发布处于关闭状态；且插件 `getYaml()` 在当前源码中实际返回 `null`（发布属性解析被短路），因此即便置 `isPublish=true` 也不会触发 SCP。实际发布以「打包后手动部署 jar + 服务器 `run-server.sh` 重启」为准。如需启用自动发布，需修复 `PublishProjectMojo.getYaml()` 的返回逻辑。

**手动部署到服务器**（参考插件流程）：
```bash
# 本地打包
cd /data/java/liupin-parent && sdk-use-8
mvn -pl liupin-service/liupin-usercenter-service -am clean package -DskipTests

# 上传（示例，按实际服务器替换）
scp liupin-service/liupin-usercenter-service/target/liupin-usercenter-service.jar \
    root@<server>:/usr/local/liupin/liupin-service/liupin-usercenter-service/bak/

# 远程重启
ssh root@<server> 'sh /usr/local/liupin/liupin-service/liupin-usercenter-service/run-server.sh remote_start'
```

## 5. 热部署 / 热更新

> 本模块 **未引入 `spring-boot-devtools`**（仅 `liupin-oa-service` 引入），因此没有内置的自动热重启能力。以下为可选方案。

### 5.1 方案 A：IDE 远程调试 + JVM 热替换（推荐用于调试期局部修改）
以调试模式启动，IDE 连接后可在不重启的情况下替换方法体（仅限方法体内修改，不支持新增/删除方法或字段）：
```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
     -jar target/liupin-usercenter-service.jar --spring.profiles.active=local
```
IDE（IDEA/Eclipse）中 `Attach to Process` 或 Remote JVM Debug 连接 `localhost:5005`，修改方法体后 `HotSwap` / `Reload Changed Classes`。

### 5.2 方案 B：引入 spring-boot-devtools（如需自动热重启）
在 `pom.xml` 依赖中追加（可选 scope）：
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>
```
随后 `mvn spring-boot:run` 启动，IDE 编译类（Build → Build Project）即触发应用重启；静态资源变更触发浏览器 LiveReload。**注意：devtools 与 Lombok 1.18.20 + JDK 8 兼容，但生产打包通常排除 devtools（`optional=true` 不会打进最终 jar）。**

### 5.3 方案 C：JRebel / HotSwapAgent
商业 JRebel 或开源 DCEVM + HotSwapAgent 可支持新增类/字段级别的热替换。需自行安装 DCEVM 增强 JDK，并配置 `-javaagent:/path/hotswap-agent.jar`。

### 5.4 常规快速迭代
- 改代码后 `mvn -pl liupin-service/liupin-usercenter-service compile`（增量编译），再 `mvn spring-boot:run` 重启；`spring-boot:run` 自身支持较快的冷启动。
- 前端联调时建议用 `--spring.profiles.active=local` + Nacos 本地配置。

## 6. 常见问题排查

| 现象 | 原因 | 解决 |
|------|------|------|
| 编译报 `TypeTag :: UNKNOWN` / `ExceptionInInitializerError` | 用了 JDK 17/25，Lombok 1.18.20 不兼容 | `sdk-use-8` 切到 JDK 8 |
| 切回 JDK 8 后仍大量 `cannot find symbol`（getter/setter 找不到） | 之前 JDK 25 构建留下的 `target/classes` 无 Lombok 生成方法，增量编译复用了脏类 | `mvn clean compile`（或 `clean install`）；可用 `javap -p <class>` 确认是否有 getter |
| 启动报 `BindingException: Invalid bound statement (not found)` | MyBatis Mapper 未被扫描 / 多数据源场景下 Mapper 与配置类未对齐 | 确认 `@MapperScan("com.liupin.usercenter.mapper")` 与 `mapper-locations: classpath:mapper/*.xml`；多数据源需为每个库建独立 `@MapperScan` + `SqlSessionFactory`（参考 OA 多数据源模式） |
| 启动连不上 Nacos / 微信配置缺失 | 本地无法访问 `172.17.16.118:8848` 或对应 profile 的 Nacos | 切换可达的 profile，或本地起 Nacos 并导入 `wechatConfig.yaml` 等共享配置 |
| 端口 9096 被占用 | 旧进程未退出 | `lsof -i:9096` 后 `kill`，或启动时 `--server.port=9097` 临时换端口 |
| 打包时触发意外远程发布 | `publishProject.isPublish=true` 且 `getYaml()` 已修复 | 保持 `bootstrap.yaml` 中 `isPublish: false` |

## 7. 关键文件速查

| 文件 | 作用 |
|------|------|
| `pom.xml` | 模块依赖、`spring-boot-maven-plugin`、`liupin-publish-plugin` 绑定 |
| `src/main/resources/bootstrap.yaml` | 端口、应用名、MyBatis、actuator、`publishProject` 开关、各类外部密钥 |
| `src/main/resources/bootstrap-{local,dev,test,uat,pro}.yaml` | 各环境 Nacos / MySQL / Redis 配置 |
| `src/main/resources/mybatis-config.xml` | MyBatis 全局配置 |
| `src/main/resources/mapper/*.xml` | 27 个 Mapper 映射文件 |
| `src/main/resources/log4j2.xml` | 日志配置 |
| `src/main/resources/db/db.sql` | 表 DDL（仅含 `sys_back_component` 等 3 张） |
