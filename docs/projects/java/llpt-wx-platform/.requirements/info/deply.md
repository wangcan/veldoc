# lpt-wx-platform 启动 / 热部署 / 打包手册

> 适用项目：`lpt-wx-platform`（wx-platform，Spring Boot 2.7.2 / JDK 1.8 / Gradle 7.5.1）
> 产物 jar：`build/libs/wx-platform-0.0.1-SNAPSHOT.jar`
> 服务端口：`9610`

---

## 一、环境准备

### 1.1 必备软件

| 组件 | 版本要求 | 说明 |
| --- | --- | --- |
| JDK | 1.8 | `sourceCompatibility = '1.8'`，务必使用 JDK 8 |
| Gradle | 7.5.1 | **无需单独安装**，使用项目自带 `gradlew` wrapper（`gradle-wrapper.properties` 指向阿里云镜像 `gradle-7.5.1-bin.zip`） |
| MySQL | 5.7+ | 见对应 profile 的 `spring.datasource.url` |
| Redis | 5.0+ | 通过 Redisson 连接，配置在 `spring.redisson.*` |
| Elasticsearch | 7.6.2 | 数据分析用，配置在 `spring.elasticsearch.rest.uris` |
| RocketMQ | 4.3+ | NameServer 地址 `rocketmq.name-server-addr` |
| XXL-Job Admin | 对应版本 | 调度中心地址 `xxl.job.admin-addresses` |

> 依赖的 `com.liupin:xxl-job-spring-boot-starter:1.0-SNAPSHOT` 需在 `mavenLocal()` 中存在；如缺失，需先将其安装到本地 Maven 仓库（`~/.m2/repository`）。

### 1.2 验证环境

```bash
java -version          # 确认 1.8
./gradlew -v           # 确认 wrapper 可用、Gradle 7.5.1
```

### 1.3 选择 profile

项目通过 `spring.profiles.active` 切换环境，可选 `dev` / `test` / `pro`：

- 默认值：`test`（`src/main/resources/application.yml`）
- 切换方式见下文各启动方式

各 profile 中间件地址差异详见 [intro.md 第 8 节](intro.md#8-环境配置profile)。

---

## 二、本地启动（开发）

### 2.1 方式一：Gradle bootRun（推荐命令行启动）

```bash
# 默认 test profile
./gradlew bootRun

# 指定 profile（覆盖 application.yml 中的默认值）
./gradlew bootRun --args='--spring.profiles.active=dev'
```

启动成功后访问：`http://localhost:9610`，API 文档：`http://localhost:9610/api/docs`（dev/test 开启，pro 关闭）。

### 2.2 方式二：IDE 启动（IntelliJ IDEA / Eclipse）

1. 导入为 Gradle 项目。
2. 运行主类 `com.liupin.wxplatform.WxPlatformApplication`。
3. **激活 profile**（二选一）：
   - VM 参数：`-Dspring.profiles.active=dev`
   - 程序参数（Program arguments）：`--spring.profiles.active=dev`
4. （IDEA 建议打开 `Build project automatically`，配合热部署，见第三节）。

### 2.3 方式三：打包后本地运行 jar

```bash
./gradlew bootJar
java -jar build/libs/wx-platform-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

> 注意：`build/libs/` 下有两个文件：
> - `wx-platform-0.0.1-SNAPSHOT.jar`（fat jar，约 120MB，**可独立运行，使用此文件**）
> - `wx-platform-0.0.1-SNAPSHOT-plain.jar`（仅含本项目类，不可独立运行，请勿直接使用）

### 2.4 启动验证清单

- [ ] 控制台无 `BeanCreationException`，出现 `Started WxPlatformApplication in X seconds`
- [ ] MySQL / Redis / ES / RocketMQ / XXL-Job 连接日志正常
- [ ] `curl http://localhost:9610/api/docs` 可返回 API 文档（dev/test）
- [ ] `POST http://localhost:9610/api/login` 可登录获取 token

---

## 三、热部署（开发期）

项目已集成 **Spring Boot DevTools**（`build.gradle` 中 `runtimeOnly 'org.springframework.boot:spring-boot-devtools'`），支持开发期类路径变更后自动重启。

### 3.1 原理

- DevTools 在开发时禁用缓存、引入 LiveReload，并监听 classpath 变化。
- 检测到编译后的类文件变化 → 触发应用**重启**（restart，比完整冷启动快，使用双类加载器）。
- 仅在**非打包运行**（即 IDE 运行或 `bootRun`）时生效；`java -jar` 运行 fat jar 时 DevTools **自动失效**（生产环境不会热加载）。

### 3.2 IDEA 配置（推荐）

1. `Settings → Build, Execution, Deployment → Compiler` → 勾选 **Build project automatically**。
2. 按 `Ctrl+Shift+A` 搜索 `Registry` → 勾选 `compiler.automake.allow.when.app.running`（新版 IDEA 在 `Settings → Advanced Settings` 中勾选 `Allow auto-make to start even if developed application is currently running`）。
3. 修改 Java 文件后，触发编译（`Build → Recompile` 或快捷键 `Ctrl+F9`），DevTools 即检测到变化并重启。
4. （可选）安装 LiveReload 浏览器插件以实现前端资源热刷新。

### 3.3 触发热重启的几种方式

- IDEA：`Ctrl+F9`（Build Project）。
- 命令行 `bootRun` 模式下：在另一终端执行 `./gradlew compileJava`，编译输出到 classpath 即触发重启。
- 修改 `src/main/resources/` 下 `application*.yml` 等资源文件并重新编译也会触发。

### 3.4 自定义热部署（可选）

如需避免频繁重启或限定触发文件，可在 `application.yml` 中添加：

```yaml
spring:
  devtools:
    restart:
      enabled: true                 # 关闭可设为 false
      additional-paths: src/main/java
      exclude: static/**,public/**  # 排除目录
    livereload:
      enabled: true
```

> 生产环境严禁使用热部署。DevTools 仅作为 `runtimeOnly` 依赖，打出的 fat jar 中其重启逻辑不会启用。

---

## 四、打包

### 4.1 构建 fat jar

```bash
# 清理并打包
./gradlew clean bootJar
```

产物：

```
build/libs/
├── wx-platform-0.0.1-SNAPSHOT.jar          # ← 部署用此文件（可执行 fat jar）
└── wx-platform-0.0.1-SNAPSHOT-plain.jar    # 仅本项目类，不可独立运行
```

`bootJar` 由 Spring Boot Gradle 插件提供，会把所有依赖打入 jar 并设置 `Main-Class: com.liupin.wxplatform.WxPlatformApplication`。

### 4.2 仅编译（不打包）

```bash
./gradlew compileJava       # 编译主代码
./gradlew build -x test     # 完整构建但跳过测试
./gradlew test              # 仅运行测试（JUnit 5）
```

### 4.3 依赖本地 jar

`libs/` 目录下的 ZXing（`core-3.4.1.jar`、`javase-3.4.1.jar`）通过 `build.gradle` 的 `implementation fileTree(include: ['*.jar'], dir: 'libs')` 引入，打包时会一并打入 fat jar，部署时无需额外携带。

---

## 五、部署到服务器

项目提供两种部署方式：**一键 Gradle 远程部署** 与 **手动部署**。

### 5.1 方式一：Gradle 一键远程部署（deploy 任务）

`build.gradle` 内置 `deploy` 任务（依赖 `bootJar`，使用 `org.hidetake.ssh` 插件）：

```bash
./gradlew clean deploy
```

执行流程：
1. 先执行 `bootJar` 打包出 `build/libs/wx-platform-0.0.1-SNAPSHOT.jar`。
2. 通过 SSH 上传 jar 与 `run-server.sh` 到远程主机：
   - 目标主机：`192.168.203.5`（root，`knownHosts = allowAnyHosts`）
   - 目标目录：`/usr/local/liupin/liupin-service/liupin-wx-service/`
3. 远程执行 `sh $appdir/run-server.sh remote_start wx-platform-0.0.1-SNAPSHOT.jar`（先停止旧进程再启动新进程）。

> **安全提示**：`build.gradle` 中硬编码了服务器 IP、账号与明文密码（`password = '123456'`）。正式环境建议改用 SSH 密钥认证或从环境变量/外部 gradle.properties 读取，避免敏感信息入库。如需切换部署目标，修改 `deploy` 任务中的 `host / user / password` 与 `appdir`。

### 5.2 方式二：手动部署

1. 本地打包：

   ```bash
   ./gradlew clean bootJar
   ```

2. 上传产物到服务器（任选）：

   ```bash
   scp build/libs/wx-platform-0.0.1-SNAPSHOT.jar run-server.sh \
       root@<server>:/usr/local/liupin/liupin-service/liupin-wx-service/
   ```

3. 在服务器上执行启停脚本：

   ```bash
   cd /usr/local/liupin/liupin-service/liupin-wx-service
   sh run-server.sh remote_start wx-platform-0.0.1-SNAPSHOT.jar
   ```

### 5.3 run-server.sh 脚本说明

`run-server.sh` 提供三个子命令，固定以 `test` profile 启动，JVM 内存 `-Xms256m -Xmx256m`，日志输出到同目录 `project.log`：

| 命令 | 作用 |
| --- | --- |
| `start` | 检查进程是否已存在，不存在则 `nohup java -jar ... --spring.profiles.active=test` 启动 |
| `stop` | 查找 java 进程并 `kill`，若未停止则 `kill -9` 强杀 |
| `remote_start` | 先 `stop` 再 `start`，用于重启发布 |

核心启动命令（脚本内部）：

```bash
nohup java -Xms256m -Xmx256m -jar ${dir_path}/wx-platform-0.0.1-SNAPSHOT.jar \
    --spring.profiles.active=test >> ${dir_path}/project.log 2>&1 &
```

> 如需以 `pro` 环境部署或调整 JVM 内存，需修改 `run-server.sh` 中对应参数，或部署后用自定义命令启动：
>
> ```bash
> nohup java -Xms512m -Xmx512m -jar wx-platform-0.0.1-SNAPSHOT.jar \
>     --spring.profiles.active=pro >> project.log 2>&1 &
> ```

### 5.4 部署后验证

```bash
# 1. 进程存在
ps -ef | grep wx-platform-0.0.1-SNAPSHOT.jar | grep -v grep
# 2. 端口监听
netstat -tlnp | grep 9610   # 或 ss -tlnp | grep 9610
# 3. 健康检查（无专用 actuator，可用登录接口探活）
curl -X POST http://<server>:9610/api/login -H 'Content-Type: application/json' -d '{"userName":"x","password":"x"}'
# 4. 查看日志
tail -f /usr/local/liupin/liupin-service/liupin-wx-service/project.log
```

---

## 六、常用命令速查

| 场景 | 命令 |
| --- | --- |
| 本地启动（默认 test） | `./gradlew bootRun` |
| 本地启动（指定 dev） | `./gradlew bootRun --args='--spring.profiles.active=dev'` |
| 打包 | `./gradlew clean bootJar` |
| 跳过测试构建 | `./gradlew build -x test` |
| 运行测试 | `./gradlew test` |
| 一键远程部署 | `./gradlew clean deploy` |
| 服务器启动 | `sh run-server.sh start` |
| 服务器停止 | `sh run-server.sh stop` |
| 服务器重启发布 | `sh run-server.sh remote_start` |
| 手动运行 jar | `java -jar wx-platform-0.0.1-SNAPSHOT.jar --spring.profiles.active=pro` |

---

## 七、注意事项与排错

1. **JDK 版本**：必须 JDK 8，高版本 JDK 会导致部分依赖（如反射、sun.* 内部类）报错。
2. **xxl-job-spring-boot-starter**：`com.liupin:xxl-job-spring-boot-starter:1.0-SNAPSHOT` 来自本地 Maven 仓库，新机器构建前需先安装，否则依赖解析失败。
3. **Gradle wrapper 镜像**：`gradle-wrapper.properties` 使用阿里云镜像下载 Gradle 7.5.1，内网无外网时需提前准备或替换为可访问地址。
4. **fat jar 选择**：部署只用 `wx-platform-0.0.1-SNAPSHOT.jar`，勿误用 `-plain.jar`。
5. **profile 一致性**：`run-server.sh` 固定 `--spring.profiles.active=test`，生产部署务必改为 `pro`，否则会连到测试中间件。
6. **端口**：默认 `9610`，被占用时通过 `--server.port=xxxx` 或修改 `application.yml` 调整。
7. **热部署仅限开发**：生产严禁依赖 DevTools；`java -jar` 运行 fat jar 时 DevTools 不生效。
8. **明文密码**：`build.gradle` 的 `deploy` 任务与各 `application-*.yml` 含明文密码/密钥，提交与分发需注意安全，建议外部化配置。

---

相关文档：项目整体说明见 [intro.md](intro.md)。
