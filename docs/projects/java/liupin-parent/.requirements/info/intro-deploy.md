# 留品项目部署操作文档

## 一、环境准备

### 1.1 基础环境要求

| 软件组件 | 版本要求 | 说明 |
|---------|---------|------|
| JDK | 1.8+ | Java运行环境 |
| Maven | 3.6+ | 项目构建工具 |
| Git | - | 版本控制 |
| MySQL | 5.7+ | 数据库 |
| Redis | 5.0+ | 缓存 |
| Nacos | 2.x | 服务注册与配置中心 |
| RocketMQ | 4.7.1 | 消息队列 |

### 1.2 开发工具

- IntelliJ IDEA (推荐)
- Eclipse
- VS Code

### 1.3 配置文件说明

项目支持多环境配置，配置文件位于 `src/main/resources/` 目录：

| 配置文件 | 说明 |
|---------|------|
| `application.yaml` | 主配置文件 |
| `application-dev.yaml` | 开发环境配置 |
| `application-test.yaml` | 测试环境配置 |
| `application-uat.yaml` | UAT环境配置 |
| `application-pro.yaml` | 生产环境配置 |
| `bootstrap.yaml` | 启动配置（Nacos配置中心） |

**切换环境方式**：

修改 `application.yaml` 中的 `spring.profiles.active` 配置：

```yaml
spring:
  profiles:
    active: dev  # 可选: dev, test, uat, pro
```

或通过启动参数指定：

```bash
java -jar app.jar --spring.profiles.active=test
```

---

## 二、项目构建

### 2.1 Maven 常用命令

#### 2.1.1 编译项目

```bash
# 编译项目（不执行测试）
mvn clean compile -DskipTests

# 编译项目（执行测试）
mvn clean compile
```

#### 2.1.2 打包项目

```bash
# 打包整个项目（跳过测试）
mvn clean package -DskipTests

# 打包整个项目（执行测试）
mvn clean package

# 打包指定模块
cd liupin-service/liupin-usercenter-service
mvn clean package -DskipTests
```

#### 2.1.3 安装到本地仓库

```bash
# 安装到本地Maven仓库
mvn clean install -DskipTests

# 安装指定模块
cd liupin-common
mvn clean install -DskipTests
```

#### 2.1.4 编译跳过特定模块

```bash
# 跳过指定模块
mvn clean package -DskipTests -pl !liupin-service/liupin-user-sync
```

### 2.2 打包输出

打包成功后，生成的 JAR 文件位于各模块的 `target/` 目录：

```
liupin-service/liupin-usercenter-service/target/liupin-usercenter-service.jar
liupin-service/liupin-file-service/target/liupin-file-service.jar
liupin-api-gateway/target/liupin-api-gateway.jar
...
```

### 2.3 构建参数说明

| 参数 | 说明 |
|------|------|
| `-DskipTests` | 跳过测试 |
| `-Dmaven.test.skip=true` | 跳过测试编译和执行 |
| `-pl` | 指定模块 |
| `-am` | 同时构建依赖模块 |
| `-P prod` | 激活 prod profile |
| `-U` | 强制更新依赖 |

---

## 三、本地开发运行

### 3.1 IDEA 运行

1. **导入项目**
   - File → Open → 选择项目根目录
   - 等待 Maven 自动导入依赖

2. **配置启动类**
   - 找到启动类（如 `UserCenterApp.java`）
   - 右键 → Run 'UserCenterApp'
   - 或点击启动类旁边的绿色运行按钮

3. **配置启动参数**
   - Run → Edit Configurations
   - 添加 VM Options: `-Xms256m -Xmx512m`
   - 添加 Program Arguments: `--spring.profiles.active=dev`

### 3.2 命令行运行

```bash
# 进入模块目录
cd liupin-service/liupin-usercenter-service

# 方式1: 使用 Maven Spring Boot 插件运行
mvn spring-boot:run

# 方式2: 运行打包后的 JAR 文件
java -jar target/liupin-usercenter-service.jar

# 指定环境运行
java -jar target/liupin-usercenter-service.jar --spring.profiles.active=dev

# 指定端口运行
java -jar target/liupin-usercenter-service.jar --server.port=8081

# 指定 JVM 参数运行
java -Xms512m -Xmx1024m -jar target/liupin-usercenter-service.jar
```

### 3.3 热部署配置

#### 3.3.1 使用 spring-boot-devtools

**步骤1**: 添加依赖（已在父pom中管理）

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>true</optional>
</dependency>
```

**步骤2**: IDEA配置

- File → Settings → Build, Execution, Deployment → Compiler
- 勾选 `Build project automatically`

**步骤3**: IDEA注册表配置

- 按 `Ctrl + Shift + A` (Mac: `Cmd + Shift + A`)
- 输入 `Registry`
- 勾选 `compiler.automake.allow.when.app.running`

**步骤4**: 使用

- 修改代码后，按 `Ctrl + F9` (Build Project) 触发热部署
- 或等待自动编译触发

#### 3.3.2 使用 JRebel (商业工具)

JRebel 提供更强大的热部署能力，支持类结构修改。

**安装步骤**:
1. 安装 IDEA JRebel 插件
2. 激活 JRebel 许可证
3. 使用 JRebel 启动应用

**使用方式**:
- 修改代码后，按 `Ctrl + Shift + F9` (Recompile)
- 无需重启即可看到效果

### 3.4 远程调试

```bash
# 启动时添加调试参数
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
  -jar target/liupin-usercenter-service.jar
```

**IDEA配置**:
1. Run → Edit Configurations → Remote JVM Debug
2. 配置 Host 和 Port (5005)
3. 启动调试

---

## 四、自动化部署

### 4.1 自定义发布插件使用

项目提供了自定义的 Maven 发布插件 `liupin-publish-plugin`，支持一键自动化部署。

#### 4.1.1 插件功能

- 自动打包项目
- 通过 SSH 上传到服务器
- 远程执行启动脚本
- 支持多环境部署
- 支持多服务器并发部署

#### 4.1.2 配置发布环境

在服务模块的 `application.yaml` 中添加发布配置：

```yaml
publishProject:
  isPublish: true  # 是否启用插件发布
  environment: test  # 发布环境: dev, test, uat, pro
```

或

```yaml
publishProject:
  isPublish: true
  environment: pro
```

#### 4.1.3 执行发布命令

```bash
# 进入项目根目录
cd /data/java/liupin-parent

# 发布指定服务到测试环境
mvn liupin-publish:publishProjectMojo \
  -Doptions=/data/java/liupin-parent,liupin-usercenter-service

# 发布到生产环境（需先修改application.yaml中的environment）
mvn liupin-publish:publishProjectMojo \
  -Doptions=/data/java/liupin-parent,liupin-usercenter-service
```

#### 4.1.4 发布流程说明

插件执行以下步骤：

```
1. 检查 pom.xml 打包配置
2. 读取 application.yaml 中的 publishProject 配置
3. 验证是否启用发布 (isPublish=true)
4. 根据环境获取目标服务器列表
5. 构建 JAR 包
6. 通过 SSH 上传 JAR 包到服务器临时目录 (/tmp)
7. 移动 JAR 包到服务目录 (/usr/local/liupin/liupin-service/)
8. 执行远程启动脚本: /run-server.sh remote_start
```

#### 4.1.5 支持发布的服务列表

插件支持以下服务的自动化发布：

- liupin-file-service
- liupin-marketing-service
- liupin-usercenter-service
- liupin-smartpen-service
- liupin-evaluation-service
- liupin-community-service
- liupin-stroke-service
- liupin-message-service

### 4.2 传统部署方式

#### 4.2.1 手动上传部署

**步骤1**: 本地打包

```bash
mvn clean package -DskipTests
```

**步骤2**: 上传 JAR 包

```bash
# 使用 scp 上传
scp target/liupin-usercenter-service.jar user@server:/usr/local/liupin/liupin-service/
```

**步骤3**: 登录服务器启动

```bash
ssh user@server

# 停止旧服务
ps -ef | grep liupin-usercenter-service | grep -v grep | awk '{print $2}' | xargs kill -9

# 启动新服务
cd /usr/local/liupin/liupin-service/
nohup java -Xms512m -Xmx1024m -jar liupin-usercenter-service.jar \
  --spring.profiles.active=test > logs/usercenter.log 2>&1 &

# 查看日志
tail -f logs/usercenter.log
```

#### 4.2.2 使用启动脚本

项目在服务器上提供了启动脚本 `/run-server.sh`：

```bash
# 启动服务
./run-server.sh start liupin-usercenter-service

# 停止服务
./run-server.sh stop liupin-usercenter-service

# 重启服务
./run-server.sh restart liupin-usercenter-service

# 查看服务状态
./run-server.sh status liupin-usercenter-service

# 远程启动（发布插件使用）
./run-server.sh remote_start liupin-usercenter-service
```

---

## 五、Docker 部署

### 5.1 创建 Dockerfile

在各服务模块创建 `Dockerfile`：

```dockerfile
FROM openjdk:8-jdk-alpine

LABEL maintainer="liupin team"

# 设置时区
RUN apk add --no-cache tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone

# 创建工作目录
WORKDIR /app

# 复制 JAR 文件
COPY target/*.jar app.jar

# 暴露端口
EXPOSE 8080

# 设置 JVM 参数
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
```

### 5.2 构建镜像

```bash
# 构建镜像
docker build -t liupin/usercenter-service:1.0.0 .

# 构建时传递参数
docker build --build-arg JAR_FILE=target/liupin-usercenter-service.jar \
  -t liupin/usercenter-service:1.0.0 .
```

### 5.3 运行容器

```bash
# 运行容器
docker run -d \
  --name usercenter-service \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=test \
  -e TZ=Asia/Shanghai \
  liupin/usercenter-service:1.0.0

# 查看日志
docker logs -f usercenter-service

# 进入容器
docker exec -it usercenter-service sh
```

### 5.4 Docker Compose 部署

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  usercenter-service:
    image: liupin/usercenter-service:1.0.0
    container_name: usercenter-service
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=test
      - JAVA_OPTS=-Xms512m -Xmx1024m
    volumes:
      - ./logs:/app/logs
    networks:
      - liupin-network
    restart: unless-stopped

networks:
  liupin-network:
    external: true
```

启动：

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看日志
docker-compose logs -f usercenter-service
```

---

## 六、Kubernetes 部署

### 6.1 创建 Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: usercenter-service
  namespace: liupin
spec:
  replicas: 2
  selector:
    matchLabels:
      app: usercenter-service
  template:
    metadata:
      labels:
        app: usercenter-service
    spec:
      containers:
      - name: usercenter-service
        image: liupin/usercenter-service:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "test"
        - name: JAVA_OPTS
          value: "-Xms512m -Xmx1024m"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: usercenter-service
  namespace: liupin
spec:
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: usercenter-service
```

### 6.2 部署命令

```bash
# 创建命名空间
kubectl create namespace liupin

# 部署服务
kubectl apply -f usercenter-deployment.yaml

# 查看部署状态
kubectl get pods -n liupin

# 查看服务日志
kubectl logs -f deployment/usercenter-service -n liupin

# 扩容
kubectl scale deployment usercenter-service --replicas=3 -n liupin
```

---

## 七、日志管理

### 7.1 日志配置

项目使用 Log4j2 作为日志框架，配置文件位于 `src/main/resources/log4j2.xml`。

### 7.2 日志文件位置

```bash
# 默认日志位置
/usr/local/liupin/logs/{服务名}/

# 日志文件命名
{服务名}.log          # 当前日志
{服务名}.log.{日期}.gz  # 历史日志归档
```

### 7.3 日志查看命令

```bash
# 实时查看日志
tail -f /usr/local/liupin/logs/usercenter-service/usercenter.log

# 查看最近100行日志
tail -n 100 /usr/local/liupin/logs/usercenter-service/usercenter.log

# 搜索关键词
grep "ERROR" /usr/local/liupin/logs/usercenter-service/usercenter.log

# 查看历史日志
zcat usercenter.log.2026-08-30.gz | grep "Exception"
```

### 7.4 日志级别动态调整

通过 Actuator 端点动态调整日志级别：

```bash
# 查看当前日志级别
curl http://localhost:8080/actuator/loggers/com.liupin

# 修改日志级别
curl -X POST http://localhost:8080/actuator/loggers/com.liupin \
  -H "Content-Type: application/json" \
  -d '{"configuredLevel": "DEBUG"}'
```

---

## 八、监控与管理

### 8.1 Spring Boot Admin 监控

项目集成了 Spring Boot Admin 监控平台。

**访问地址**: `http://admin-server:9999`

**功能**:
- 查看所有服务状态
- 查看 JVM 信息
- 查看配置信息
- 查看日志级别
- 查看健康检查状态

### 8.2 Actuator 端点

各服务暴露了 Actuator 端点：

```bash
# 健康检查
curl http://localhost:8080/actuator/health

# 应用信息
curl http://localhost:8080/actuator/info

# 环境变量
curl http://localhost:8080/actuator/env

# 所有端点
curl http://localhost:8080/actuator
```

### 8.3 Nacos 控制台

**访问地址**: `http://nacos-server:8848/nacos`

**功能**:
- 服务列表查看
- 配置管理
- 服务健康状态
- 集群管理

---

## 九、故障排查

### 9.1 服务无法启动

**排查步骤**:

1. 检查端口占用

```bash
netstat -tlnp | grep 8080
```

2. 检查日志

```bash
tail -f logs/usercenter.log
```

3. 检查配置

```bash
# 检查 Nacos 连接
curl http://nacos-server:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=10

# 检查数据库连接
telnet mysql-server 3306

# 检查 Redis 连接
redis-cli -h redis-server ping
```

### 9.2 内存溢出

**排查步骤**:

1. 查看内存使用

```bash
jmap -heap <pid>
```

2. 生成堆转储

```bash
jmap -dump:format=b,file=heap.hprof <pid>
```

3. 分析堆转储（使用 MAT 或 VisualVM）

### 9.3 CPU 飙高

**排查步骤**:

1. 查找高CPU线程

```bash
# 查看进程CPU使用
top -p <pid>

# 查看线程CPU使用
top -Hp <pid>
```

2. 导出线程栈

```bash
jstack <pid> > thread_dump.txt
```

3. 分析线程栈，找到占用CPU的线程

---

## 十、性能优化建议

### 10.1 JVM 参数调优

```bash
# 推荐 JVM 参数
java -Xms1g -Xmx2g \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath=/tmp/heap_dump.hprof \
  -XX:+PrintGCDetails \
  -XX:+PrintGCDateStamps \
  -Xloggc:/tmp/gc.log \
  -jar app.jar
```

### 10.2 连接池优化

**数据库连接池 (Druid)**:

```yaml
spring:
  datasource:
    druid:
      initial-size: 5
      min-idle: 5
      max-active: 20
      max-wait: 60000
```

**Redis 连接池 (Lettuce)**:

```yaml
spring:
  redis:
    lettuce:
      pool:
        max-active: 20
        max-idle: 10
        min-idle: 5
```

### 10.3 数据库优化

- 合理使用索引
- 避免慢查询
- 使用分页查询
- 使用连接池
- 读写分离

---

## 十一、安全配置

### 11.1 敏感信息保护

敏感配置应放在 Nacos 配置中心，不要硬编码在代码中：

```yaml
spring:
  datasource:
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

### 11.2 启用 HTTPS

```yaml
server:
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: ${SSL_PASSWORD}
    key-store-type: PKCS12
```

### 11.3 访问控制

配置 API Gateway 的鉴权规则，限制敏感端点的访问。

---

## 十二、常用命令速查

### 12.1 Maven 命令

```bash
# 清理项目
mvn clean

# 编译项目
mvn compile

# 打包项目
mvn package -DskipTests

# 安装到本地仓库
mvn install -DskipTests

# 查看依赖树
mvn dependency:tree

# 检查依赖更新
mvn versions:display-dependency-updates

# 运行 Spring Boot 应用
mvn spring-boot:run
```

### 12.2 服务管理命令

```bash
# 查看服务进程
ps -ef | grep {服务名}

# 停止服务
kill -15 {pid}

# 强制停止服务
kill -9 {pid}

# 查看端口占用
netstat -tlnp | grep {端口}

# 查看日志
tail -f logs/{服务名}.log
```

### 12.3 Git 命令

```bash
# 拉取最新代码
git pull origin dev

# 查看分支
git branch -a

# 切换分支
git checkout dev

# 提交代码
git add .
git commit -m "提交说明"
git push origin dev
```

---

## 十三、发布检查清单

### 发布前检查

- [ ] 代码已合并到发布分支
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 配置文件已更新（数据库、Redis、Nacos等）
- [ ] 依赖的服务已确认可用
- [ ] 数据库变更脚本已准备
- [ ] 回滚方案已准备

### 发布后检查

- [ ] 服务启动成功
- [ ] 服务注册到 Nacos
- [ ] 健康检查通过
- [ ] 核心接口测试通过
- [ ] 日志无异常错误
- [ ] 监控指标正常
- [ ] 通知相关人员

---

**文档版本**: v1.0
**更新时间**: 2026-08-31
**维护团队**: 留品技术团队
