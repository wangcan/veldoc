# liupin-custom-service 打包与部署操作文档

> 本文档针对 `liupin-custom-service`（字帖/毛笔定制服务）模块的构建、本地运行、热部署与上线发布操作。模块路径：`liupin-service/liupin-custom-service/`，服务端口 `9097`，服务名 `liupin-custom-service`。

---

## 一、环境准备

### 1.1 基础环境要求

| 软件组件 | 版本要求 | 说明 |
|---------|---------|------|
| JDK | 1.8 | `maven.compiler.source/target=1.8` |
| Maven | 3.6+ | 项目构建工具 |
| Git | - | 版本控制 |
| MySQL | 5.7+ | 三个库：`lpt_custom` / `shop` / `lpt_user_center` |
| Redis | 5.0+ | 缓存 |
| Nacos | 2.x | 服务注册与配置中心 |
| 腾讯云 COS | - | 字体 / 定制图 / 会员图存储 |

依赖的外部服务：微信支付、聚水潭 ERP、淘宝开放平台、毛笔工厂系统、中间商城、平板 PHP（sidecar）、`liupin-mall-service` / `liupin-marketing-service` / `liupin-usercenter-service`。

### 1.2 多环境配置

配置文件位于 `src/main/resources/`，使用 **bootstrap** 系列文件（Nacos 启动配置）：

| 配置文件 | 说明 |
|---------|------|
| `bootstrap.yaml` | 主启动配置（端口 9097、`spring.profiles.active=test`、Actuator、Feign 压缩、COS、聚水坦、淘宝等公共项） |
| `bootstrap-dev.yaml` | 开发环境（Nacos/Redis 本地 `127.0.0.1`） |
| `bootstrap-test.yaml` | 测试环境（Redis `192.168.203.1`，含微信小程序配置） |
| `bootstrap-pro.yaml` | 生产环境（Nacos `172.17.64.13`、Redis `172.17.0.8:6380 db3`） |
| `log4j2.xml` | 日志配置 |
| `mybatis-config.xml` | MyBatis 全局配置 |
| `apiclient_cert.p12` | 微信支付证书 |

> **注意**：本模块仅提供 `dev` / `test` / `pro` 三个 profile，**无 `uat` 环境**。`bootstrap.yaml` 默认 `active: test`。

**切换环境方式**：

修改 `bootstrap.yaml`：
```yaml
spring:
  profiles:
    active: pro   # 可选: dev, test, pro
```

或通过启动参数指定：
```bash
java -jar liupin-custom-service.jar --spring.profiles.active=pro
```

---

## 二、项目构建

### 2.1 Maven 常用命令

#### 编译
```bash
# 仅编译本模块（在模块目录下）
cd liupin-service/liupin-custom-service
mvn clean compile -DskipTests
```

#### 打包（生成可执行 fat jar）
```bash
# 在模块目录下打包
cd liupin-service/liupin-custom-service
mvn clean package -DskipTests
```

> 父 `pom.xml` 默认 `<sikpTests>true</sikpTests>`（原拼写），且本模块 `maven-surefire-plugin` 设置 `<skip>false</skip>`，即**本模块会执行测试**。如需跳过测试加 `-DskipTests`。

#### 从根目录构建本模块及其依赖
```bash
# 在项目根目录 /data/java/liupin-parent 下
mvn clean package -DskipTests -pl liupin-service/liupin-custom-service -am
```

参数说明：

| 参数 | 说明 |
|------|------|
| `-DskipTests` | 跳过测试执行（仍编译测试代码） |
| `-Dmaven.test.skip=true` | 跳过测试编译与执行 |
| `-pl <模块>` | 指定模块 |
| `-am` | 同时构建所依赖的模块（如 `liupin-common`、`liupin-module-dependency`、starter 等） |
| `-U` | 强制更新 SNAPSHOT 依赖 |

> 首次构建需先安装本地私有依赖（如 `liupin-common`、`tencent-spring-boot-starter`、`jushuitan`、淘宝 SDK 等），建议先在根目录执行一次 `mvn clean install -DskipTests`。

### 2.2 打包产物

打包成功后生成 Spring Boot 可执行 fat jar：

```
liupin-service/liupin-custom-service/target/liupin-custom-service.jar          # 可执行 fat jar（约 150MB+）
liupin-service/liupin-custom-service/target/liupin-custom-service.jar.original # 原始 jar（repackage 前的产物）
```

`finalName` 由 `pom.xml` `<build><finalName>liupin-custom-service</finalName>` 指定。

### 2.3 构建时附加的发布插件

`pom.xml` 中绑定了自定义发布插件（`package` 阶段）：

```xml
<plugin>
    <groupId>com.liupin</groupId>
    <artifactId>liupin-publish-plugin</artifactId>
    <executions>
        <execution>
            <goals><goal>publishProjectMojo</goal></goals>
            <phase>package</phase>
            <configuration>
                <options>
                    <option>${basedir}</option>
                    <option>liupin-custom-service</option>
                </options>
            </configuration>
        </execution>
    </executions>
</plugin>
```

> ⚠️ **当前不会自动发布**：`liupin-publish-plugin` 的 `PublishProjectMojo` 中硬编码的 `serviceList` **未包含** `liupin-custom-service`（仅含 file/marketing/usercenter/smartpen/evaluation/stroke/community/message），且其 `getYaml()` 方法实现恒返回 `null`。因此在 `package` 阶段该插件对本模块**不会执行任何远程上传/启动动作**，仅打 jar。本模块上线需采用**手动部署**（见第四节）。

---

## 三、本地开发运行

### 3.1 IDEA 运行

1. 导入项目根目录，等待 Maven 导入依赖。
2. 找到启动类 `com.liupin.custom.CustomApp`，右键 → Run。
3. 如需切换环境，在 Run → Edit Configurations 中配置：
   - VM Options：`-Xms256m -Xmx768m`
   - Program Arguments：`--spring.profiles.active=dev`
4. 本地需可访问 Nacos / Redis / MySQL（`bootstrap-dev.yaml` 默认指向 `127.0.0.1`）。

### 3.2 命令行运行

```bash
cd liupin-service/liupin-custom-service

# 方式1：Maven 运行
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"

# 方式2：运行 fat jar
java -jar target/liupin-custom-service.jar

# 指定环境
java -jar target/liupin-custom-service.jar --spring.profiles.active=dev

# 指定端口
java -jar target/liupin-custom-service.jar --server.port=9097

# 指定 JVM 参数
java -Xms512m -Xmx1024m -jar target/liupin-custom-service.jar
```

启动成功后服务注册到 Nacos，健康检查：`http://localhost:9097/actuator/health`。

### 3.3 热部署

> 本模块 `pom.xml` **未引入** `spring-boot-devtools`，默认不支持自动热部署。可选方案：

#### 方案 A：引入 spring-boot-devtools（推荐用于本地）

在 `liupin-custom-service/pom.xml` 增加：
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>true</optional>
</dependency>
```
IDEA 配置：
- Settings → Build, Execution, Deployment → Compiler → 勾选 `Build project automatically`。
- `Ctrl+Shift+A` → Registry → 勾选 `compiler.automake.allow.when.app.running`（新版 IDEA：Settings → Advanced Settings → 勾选相关项）。
- 修改代码后 `Ctrl+F9`（Build Project）触发重启。

#### 方案 B：JRebel（商业，支持类结构变更）
- 安装 IDEA JRebel 插件并激活。
- 用 JRebel 启动 `CustomApp`，修改代码后 `Ctrl+Shift+F9` 热加载。

#### 方案 C：IDEA 热交换（仅方法体内修改）
- Debug 模式启动，修改方法体后 `Ctrl+F9`，JVM 利用 HotSwap 加载（不支持新增/删除方法与字段）。

### 3.4 远程调试

```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
  -jar target/liupin-custom-service.jar
```
IDEA：Run → Edit Configurations → Remote JVM Debug，Host=服务器 IP，Port=5005。

---

## 四、上线发布（手动部署）

由于自动发布插件当前对本模块不生效，采用手动部署。

### 4.1 本地打包

```bash
cd /data/java/liupin-parent/liupin-service/liupin-custom-service
mvn clean package -DskipTests
# 产物：target/liupin-custom-service.jar
```

### 4.2 上传 JAR 到服务器

服务器部署目录：`/usr/local/liupin/liupin-service/liupin-custom-service/`

```bash
# 上传到部署目录的 bak 子目录
scp target/liupin-custom-service.jar \
  root@<server_ip>:/usr/local/liupin/liupin-service/liupin-custom-service/bak/
```

### 4.3 登录服务器启动

```bash
ssh root@<server_ip>

SVC=/usr/local/liupin/liupin-service/liupin-custom-service

# 备份并替换
cp $SVC/liupin-custom-service.jar $SVC/bak/liupin-custom-service.jar.$(date +%Y%m%d_%H%M%S)
cp $SVC/bak/liupin-custom-service.jar $SVC/liupin-custom-service.jar

# 停止旧服务
ps -ef | grep liupin-custom-service | grep -v grep | awk '{print $2}' | xargs -r kill -15
# 等待退出，必要时强制
ps -ef | grep liupin-custom-service | grep -v grep | awk '{print $2}' | xargs -r kill -9

# 启动新服务（生产环境）
cd $SVC
nohup java -Xms512m -Xmx1024m \
  -jar liupin-custom-service.jar \
  --spring.profiles.active=pro \
  > logs/liupin-custom-service.log 2>&1 &

# 查看日志
tail -f logs/liupin-custom-service.log
```

> 字体文件路径在生产配置中为绝对路径：`/usr/local/liupin/liupin-service/liupin-custom-service/楷体.ttf`（及 `simhei.ttf`、`lishu.ttf`），定制图生成目录 `customPath/`。部署目录需保留这些字体文件。

### 4.4 使用服务器启动脚本（若已部署）

服务器上若存在 `/usr/local/liupin/liupin-service/liupin-custom-service/run-server.sh`：

```bash
./run-server.sh start   liupin-custom-service   # 启动
./run-server.sh stop    liupin-custom-service   # 停止
./run-server.sh restart liupin-custom-service   # 重启
./run-server.sh status  liupin-custom-service   # 状态
./run-server.sh remote_start liupin-custom-service  # 发布插件远程调用入口
```

### 4.5 验证

```bash
# 健康检查
curl http://localhost:9097/actuator/health

# 确认已注册到 Nacos（Nacos 控制台服务列表中应出现 liupin-custom-service）

# 抽测接口（示例）
curl 'http://localhost:9097/api/homePage' -i
```

---

## 五、Docker 部署（可选）

### 5.1 Dockerfile

在 `liupin-service/liupin-custom-service/` 下创建 `Dockerfile`：

```dockerfile
FROM openjdk:8-jdk-alpine
LABEL maintainer="liupin team"

RUN apk add --no-cache tzdata fontconfig ttf-dejavu \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app
COPY target/liupin-custom-service.jar app.jar
# 字体文件需一并放置（楷体/simhei/lishu）或挂载
EXPOSE 9097
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
```

### 5.2 构建与运行

```bash
docker build -t liupin/custom-service:1.0.0 .

docker run -d --name custom-service \
  -p 9097:9097 \
  -e SPRING_PROFILES_ACTIVE=pro \
  -e TZ=Asia/Shanghai \
  -v /usr/local/liupin/liupin-service/liupin-custom-service/logs:/app/logs \
  -v /usr/local/liupin/liupin-service/liupin-custom-service:/app/fonts \
  liupin/custom-service:1.0.0

docker logs -f custom-service
```

---

## 六、日志管理

- 框架：Log4j2（`src/main/resources/log4j2.xml`，配合 Disruptor 异步日志）。
- 日志位置：`/usr/local/liupin/liupin-service/liupin-custom-service/logs/`（或启动时指定的 `logs/` 目录）。

```bash
# 实时日志
tail -f logs/liupin-custom-service.log

# 搜索异常
grep "ERROR\|Exception" logs/liupin-custom-service.log

# 历史归档
zcat liupin-custom-service.log.2026-09-07.gz | grep "Exception"
```

**动态调整日志级别**（Actuator，端口 9097）：
```bash
curl http://localhost:9097/actuator/loggers/com.liupin
curl -X POST http://localhost:9097/actuator/loggers/com.liupin \
  -H "Content-Type: application/json" -d '{"configuredLevel":"DEBUG"}'
```

---

## 七、监控与管理

### 7.1 Actuator 端点
本模块暴露所有 Actuator 端点（`management.endpoints.web.exposure.include: "*"`，健康明细开启）：
```bash
curl http://localhost:9097/actuator/health
curl http://localhost:9097/actuator/info
curl http://localhost:9097/actuator
```

### 7.2 Spring Boot Admin
作为 `spring-boot-admin-starter-client` 上报到监控平台（账号 `admin` / `liupintang`），可在 Admin 面板查看健康状态、JVM、配置、日志级别。

### 7.3 Nacos 控制台
查看 `liupin-custom-service` 服务实例、健康状态与配置。

---

## 八、故障排查

| 现象 | 排查 |
|------|------|
| 启动失败：端口占用 | `netstat -tlnp \| grep 9097`，杀掉占用进程 |
| 启动失败：Nacos 连不上 | 检查 `bootstrap-{env}.yaml` 中 `spring.cloud.nacos.server-addr` / `username` / `password` 与网络连通 |
| 启动失败：数据库 | 检查三数据源（custom/shop/usercenter）连接，`telnet <mysql_host> 3306` |
| 启动失败：字体文件 | 定制画图依赖 `font.path`（楷体/simhei/lishu），确认文件存在于部署目录 |
| 微信支付回调不通 | 确认网关 `wx.pay.callbackUrl`（`/customService/api/order/wxPayCallback`）外网可达，证书 `apiclient_cert.p12` 在 classpath |
| OOM | `jmap -heap <pid>`；`jmap -dump:format=b,file=heap.hprof <pid>` 后用 MAT 分析 |
| CPU 飙高 | `top -Hp <pid>` 找高 CPU 线程 → `jstack <pid> > t.txt` 分析 |

---

## 九、常用命令速查

```bash
# 构建
cd liupin-service/liupin-custom-service
mvn clean package -DskipTests

# 本地运行
java -jar target/liupin-custom-service.jar --spring.profiles.active=dev

# 仅构建本模块及依赖（从根目录）
mvn clean package -DskipTests -pl liupin-service/liupin-custom-service -am

# 进程管理
ps -ef | grep liupin-custom-service
kill -15 <pid>      # 优雅停止
kill -9  <pid>      # 强制停止

# 端口
netstat -tlnp | grep 9097

# 日志
tail -f logs/liupin-custom-service.log
```

---

## 十、发布检查清单

### 发布前
- [ ] 代码已合并到发布分支
- [ ] `mvn clean package -DskipTests` 成功
- [ ] `bootstrap-pro.yaml` 中 Nacos / Redis / 三数据源 / 微信支付 / 聚水坦 / 淘宝 / COS 等配置正确
- [ ] 依赖服务（mall/marketing/usercenter/tablet-php-sidecar）可用
- [ ] 字体文件（楷体/simhei/lishu）已就位于部署目录
- [ ] 回滚方案：保留上一版本 jar 备份

### 发布后
- [ ] 进程存在、端口 9097 监听
- [ ] `/actuator/health` 返回 UP
- [ ] Nacos 服务列表中实例在线
- [ ] 微信支付回调可达
- [ ] 日志无 ERROR

---

**文档版本**：v1.0
**更新时间**：2026-09-07
**维护团队**：留品技术团队
