# lpt-gateway 项目管理文档

## 项目信息

- **项目名称**: liupin-api-gateway
- **项目类型**: Spring Boot 2.6.6 + Spring Cloud Gateway
- **构建工具**: Maven
- **Java 版本**: 1.8

---

## 一、开发环境热启动

### 1.1 使用 Maven + Spring Boot DevTools 热启动

项目已集成 `spring-boot-devtools`，支持代码修改后自动重启。

#### 基本启动命令

```bash
# 默认环境启动（使用 bootstrap.yml 中配置的 profiles.active）
mvn spring-boot:run

# 指定开发环境启动
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 指定测试环境启动
mvn spring-boot:run -Dspring-boot.run.profiles=test

# 指定生产环境启动
mvn spring-boot:run -Dspring-boot.run.profiles=pro

# 指定 Kubernetes 环境启动
mvn spring-boot:run -Dspring-boot.run.profiles=k8s
```

#### 完整参数示例

```bash
# 开发环境 + 指定端口
mvn spring-boot:run -Dspring-boot.run.profiles=dev -Dspring-boot.run.arguments=--server.port=9999

# 开发环境 + 调试模式
mvn spring-boot:run -Dspring-boot.run.profiles=dev -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### 1.2 热重载触发方式

DevTools 启动后，支持以下热重载方式：

#### 方式一：自动触发（推荐）

在 IDE 中启用自动编译，修改代码后自动触发重载：
- **IntelliJ IDEA**: Settings → Build, Execution, Deployment → Compiler → 勾选 "Build project automatically"
- **Eclipse**: 默认支持自动编译

#### 方式二：手动触发

在另一个终端窗口执行：
```bash
# 编译项目（DevTools 检测到 class 文件变化后自动重启）
mvn compile
```

#### 方式三：IDE 快捷键

- **IntelliJ IDEA**: `Ctrl+F9` (Windows/Linux) 或 `Cmd+F9` (Mac) → Build Project
- **Eclipse**: `Ctrl+B` → Build All

### 1.3 DevTools 配置优化

在 `application.yml` 或 `bootstrap.yml` 中可配置：

```yaml
spring:
  devtools:
    restart:
      enabled: true                          # 启用热重启
      exclude: static/**,public/**,templates/**  # 排除静态资源
      additional-paths: src/main/resources   # 监控额外路径
    livereload:
      enabled: true                          # 启用浏览器自动刷新
```

### 1.4 注意事项

1. **DevTools 仅在开发环境生效**，生产环境会自动禁用
2. **类加载机制**: DevTools 使用两个类加载器（baseClassLoader 和 restartClassLoader），重启速度快
3. **资源文件**: 默认监控 `src/main/resources` 目录下的文件变化
4. **日志级别**: 建议开发环境设置 `logging.level.org.springframework.boot.devtools=DEBUG`

---

## 二、项目打包命令

### 2.1 基本打包

```bash
# 清理并打包（跳过测试）
mvn clean package -DskipTests

# 清理并打包（执行测试）
mvn clean package

# 仅打包（不清理）
mvn package -DskipTests
```

### 2.2 指定环境打包

```bash
# 打包开发环境
mvn clean package -DskipTests -Dspring.profiles.active=dev

# 打包测试环境
mvn clean package -DskipTests -Dspring.profiles.active=test

# 打包生产环境
mvn clean package -DskipTests -Dspring.profiles.active=pro

# 打包 Kubernetes 环境
mvn clean package -DskipTests -Dspring.profiles.active=k8s
```

### 2.3 完整打包流程

```bash
# 1. 清理旧构建
mvn clean

# 2. 编译源代码
mvn compile

# 3. 运行测试（可选）
mvn test

# 4. 打包
mvn package -DskipTests

# 5. 安装到本地仓库（可选）
mvn install -DskipTests
```

### 2.4 打包产物

打包后的文件位于 `target/` 目录：
- **JAR 包**: `target/liupin-api-gateway.jar`
- **JAR 包带依赖**: `target/liupin-api-gateway.jar` (Spring Boot 打包插件已包含依赖)

### 2.5 运行打包后的 JAR

```bash
# 基本运行
java -jar target/liupin-api-gateway.jar

# 指定环境运行
java -jar target/liupin-api-gateway.jar --spring.profiles.active=dev

# 指定端口运行
java -jar target/liupin-api-gateway.jar --server.port=9999

# 后台运行
nohup java -jar target/liupin-api-gateway.jar --spring.profiles.active=pro > gateway.log 2>&1 &

# 带 JVM 参数运行
java -Xms512m -Xmx2048m -jar target/liupin-api-gateway.jar --spring.profiles.active=pro
```

---

## 三、环境配置说明

项目支持以下环境：

| 环境标识 | 配置文件 | 说明 |
|---------|---------|------|
| `dev` | `bootstrap-dev.yml` | 开发环境，连接本地 Nacos (127.0.0.1:8848) |
| `test` | `bootstrap-test.yml` | 测试环境（bootstrap.yml 默认激活） |
| `pro` | `bootstrap-pro.yml` | 生产环境 |
| `k8s` | `bootstrap-k8s.yml` | Kubernetes 环境 |

### 查看当前激活环境

```bash
# 启动日志中查看
# The following 1 profile is active: "dev"
```

---

## 四、常用开发命令速查

| 操作 | 命令 |
|-----|------|
| 开发环境热启动 | `mvn spring-boot:run -Dspring-boot.run.profiles=dev` |
| 测试环境热启动 | `mvn spring-boot:run -Dspring-boot.run.profiles=test` |
| 生产环境热启动 | `mvn spring-boot:run -Dspring-boot.run.profiles=pro` |
| 快速打包 | `mvn clean package -DskipTests` |
| 开发环境打包 | `mvn clean package -DskipTests -Dspring.profiles.active=dev` |
| 运行 JAR (dev) | `java -jar target/liupin-api-gateway.jar --spring.profiles.active=dev` |
| 清理项目 | `mvn clean` |
| 编译项目 | `mvn compile` |
| 触发热重载 | `mvn compile` (DevTools 运行时) |

---

## 五、IDE 热部署配置（可选）

### IntelliJ IDEA 配置

1. **启用自动编译**
   - File → Settings → Build, Execution, Deployment → Compiler
   - 勾选 "Build project automatically"

2. **允许运行时自动编译**
   - File → Settings → Build, Execution, Deployment → Build Tools → Maven → Runner
   - 或使用快捷键 `Ctrl+Shift+A` → 输入 "Registry" → 勾选 `compiler.automake.allow.when.app.running`

3. **配置热部署**
   - Run → Edit Configurations → 选择 Spring Boot 运行配置
   - 在 VM options 中添加: `-Dspring.profiles.active=dev`

### Eclipse 配置

- Eclipse 默认支持自动编译，修改代码后保存即可触发 DevTools 热重启

---

## 六、故障排查

### DevTools 不生效

检查项：
1. 确认 `spring-boot-devtools` 依赖存在
2. 确认不是生产环境（`spring.devtools.restart.enabled` 未被设置为 false）
3. 检查 IDE 是否启用了自动编译
4. 确认修改的文件在监控范围内

### 端口冲突

```bash
# 查看端口占用
lsof -i:8888
netstat -tunlp | grep 8888

# 指定其他端口启动
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=9999
```

### Nacos 连接失败

- 检查 Nacos 服务是否启动
- 检查配置文件中的 Nacos 地址、用户名、密码是否正确
- 开发环境 Nacos 地址: `127.0.0.1:8848` (需要在本地启动 Nacos)

---

## 七、项目依赖关键组件

- Spring Boot 2.6.6
- Spring Cloud Gateway 3.1.1
- Spring Cloud Alibaba Nacos (配置中心 + 服务发现)
- Spring Cloud LoadBalancer
- Resilience4j (熔断器)
- Redisson (Redis 客户端)
- JJWT (JWT 支持)
- Lombok
- Log4j2 (日志框架)

---

**文档更新时间**: 2026-08-06
