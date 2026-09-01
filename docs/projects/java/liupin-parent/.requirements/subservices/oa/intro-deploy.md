# liupin-oa-service 模块部署文档

## 1. 环境要求

### 1.1 基础环境
- **JDK**: 1.8 或以上版本
- **Maven**: 3.6.0 或以上版本
- **MySQL**: 5.7 或以上版本
- **Redis**: 3.0 或以上版本
- **Nacos**: 2.0 或以上版本

### 1.2 网络要求
- 服务默认端口: `10011`
- Nacos 服务端口: `8848`
- MySQL 数据库端口: `3306`
- Redis 端口: `6379`

## 2. 项目结构

```
liupin-oa-service/
├── pom.xml                    # Maven 项目配置文件
├── src/
│   ├── main/
│   │   ├── java/              # Java 源代码
│   │   └── resources/         # 资源文件
│   │       ├── bootstrap.yaml           # 主配置文件
│   │       ├── bootstrap-dev.yaml       # 开发环境配置
│   │       ├── bootstrap-pro.yaml       # 生产环境配置
│   │       ├── mapper/                  # MyBatis 映射文件
│   │       └── templates/               # Thymeleaf 模板文件
│   └── test/                  # 测试代码
└── target/                    # 编译输出目录
```

## 3. 打包命令

### 3.1 开发环境打包

```bash
# 进入模块目录
cd /data/java/liupin-parent/liupin-service/liupin-oa-service

# 清理并打包（跳过测试）
mvn clean package -DskipTests

# 清理并打包（执行测试）
mvn clean package
```

### 3.2 生产环境打包

```bash
# 指定生产环境配置打包
mvn clean package -DskipTests -Ppro

# 或者指定环境变量
mvn clean package -DskipTests -Dspring.profiles.active=pro
```

### 3.3 仅编译（不打包）

```bash
mvn clean compile
```

### 3.4 安装到本地仓库

```bash
mvn clean install -DskipTests
```

### 3.5 从父项目打包

```bash
# 在父项目根目录执行
cd /data/java/liupin-parent

# 仅打包 oa 模块
mvn clean package -DskipTests -pl liupin-service/liupin-oa-service -am

# 参数说明:
# -pl: 指定模块路径
# -am: 同时构建依赖的模块
```

## 4. 运行命令

### 4.1 开发环境运行

```bash
# 方式一：使用 Maven 插件运行（支持热部署）
mvn spring-boot:run

# 方式二：指定环境运行
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 方式三：直接运行 jar 包
java -jar target/liupin-oa-service.jar

# 方式四：指定环境运行 jar 包
java -jar target/liupin-oa-service.jar --spring.profiles.active=dev
```

### 4.2 生产环境运行

```bash
# 后台运行
nohup java -jar target/liupin-oa-service.jar --spring.profiles.active=pro > oa-service.log 2>&1 &

# 指定 JVM 参数运行
java -Xms512m -Xmx1024m -jar target/liupin-oa-service.jar --spring.profiles.active=pro

# 指定端口运行
java -jar target/liupin-oa-service.jar --server.port=10012 --spring.profiles.active=pro
```

### 4.3 停止服务

```bash
# 查找进程
ps -ef | grep liupin-oa-service

# 停止进程（优雅停止）
kill -15 <PID>

# 强制停止
kill -9 <PID>
```

## 5. 热部署

### 5.1 开发环境热部署（IDEA）

项目已集成 `spring-boot-devtools`，支持热部署。

#### 配置步骤：

1. **IDEA 配置**
   - 打开 `File` -> `Settings` -> `Build, Execution, Deployment` -> `Compiler`
   - 勾选 `Build project automatically`

2. **开启运行时编译**
   - Windows/Linux: 按 `Ctrl + Shift + A`，输入 `Registry`
   - macOS: 按 `Cmd + Shift + A`，输入 `Registry`
   - 勾选 `compiler.automake.allow.when.app.running`

3. **触发热部署**
   - 修改 Java 文件后，按 `Ctrl + F9` (Windows/Linux) 或 `Cmd + F9` (macOS)
   - 或者点击菜单 `Build` -> `Build Project`

#### 热部署触发条件：
- Java 类文件修改并编译
- 配置文件修改（需重启）
- 静态资源文件修改（需刷新浏览器）
- Thymeleaf 模板修改（配置已关闭缓存，即时生效）

### 5.2 Maven 热部署

```bash
# 使用 spring-boot:run 运行（自动启用热部署）
mvn spring-boot:run

# 修改代码后，重新编译触发重启
mvn compile
```

### 5.3 远程热部署

在生产环境可开启远程调试：

```bash
# 启动时添加调试参数
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
     -jar target/liupin-oa-service.jar --spring.profiles.active=pro

# 然后在 IDEA 中配置 Remote Debug
# Host: 服务器IP
# Port: 5005
```

### 5.4 热部署配置说明

`bootstrap.yaml` 中的相关配置：

```yaml
spring:
  devtools:
    restart:
      enabled: true           # 启用热部署
      additional-paths:       # 监控额外路径
        - src/main/java
      exclude:                # 排除监控路径
        - static/**
        - public/**
  thymeleaf:
    cache: false              # 关闭模板缓存，修改即时生效
```

## 6. Docker 部署

### 6.1 创建 Dockerfile

```dockerfile
FROM openjdk:8-jdk-alpine

# 设置工作目录
WORKDIR /app

# 复制 jar 包
COPY target/liupin-oa-service.jar app.jar

# 暴露端口
EXPOSE 10011

# 启动命令
ENTRYPOINT ["java", "-Xms512m", "-Xmx1024m", "-jar", "app.jar"]
```

### 6.2 构建镜像

```bash
# 构建镜像
docker build -t liupin-oa-service:1.0 .

# 查看镜像
docker images | grep liupin-oa-service
```

### 6.3 运行容器

```bash
# 运行容器
docker run -d \
  --name oa-service \
  -p 10011:10011 \
  -e SPRING_PROFILES_ACTIVE=pro \
  -e TZ=Asia/Shanghai \
  liupin-oa-service:1.0

# 查看日志
docker logs -f oa-service

# 停止容器
docker stop oa-service

# 启动容器
docker start oa-service
```

### 6.4 Docker Compose 部署

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  oa-service:
    image: liupin-oa-service:1.0
    container_name: oa-service
    ports:
      - "10011:10011"
    environment:
      - SPRING_PROFILES_ACTIVE=pro
      - TZ=Asia/Shanghai
    networks:
      - liupin-network
    depends_on:
      - mysql
      - redis
      - nacos

networks:
  liupin-network:
    external: true
```

运行：

```bash
docker-compose up -d
```

## 7. 配置管理

### 7.1 配置文件说明

| 文件名 | 说明 | 使用环境 |
|--------|------|----------|
| bootstrap.yaml | 主配置文件，定义通用配置 | 所有环境 |
| bootstrap-dev.yaml | 开发环境配置 | 开发环境 |
| bootstrap-pro.yaml | 生产环境配置 | 生产环境 |

### 7.2 配置切换

```bash
# 方式一：命令行参数
java -jar target/liupin-oa-service.jar --spring.profiles.active=pro

# 方式二：环境变量
export SPRING_PROFILES_ACTIVE=pro
java -jar target/liupin-oa-service.jar

# 方式三：JVM 参数
java -Dspring.profiles.active=pro -jar target/liupin-oa-service.jar
```

### 7.3 Nacos 配置中心

项目使用 Nacos 作为配置中心，可动态管理配置：

1. **配置文件管理**: 在 Nacos 控制台创建配置
2. **Data ID**: `liupin-oa-service-dev.yaml` 或 `liupin-oa-service-pro.yaml`
3. **Group**: `DEFAULT_GROUP`
4. **动态刷新**: 修改配置后，应用自动获取最新配置

## 8. 日志管理

### 8.1 日志配置

项目使用 Log4j2 作为日志框架，配置文件位于 `resources/log4j2.xml`。

### 8.2 日志级别设置

```bash
# 启动时指定日志级别
java -jar target/liupin-oa-service.jar \
  --logging.level.com.liupin=DEBUG \
  --logging.level.org.springframework=INFO
```

### 8.3 日志查看

```bash
# 实时查看日志
tail -f logs/liupin-oa-service.log

# 查看最近 100 行日志
tail -n 100 logs/liupin-oa-service.log

# 搜索日志
grep "ERROR" logs/liupin-oa-service.log
```

## 9. 健康检查与监控

### 9.1 Actuator 端点

项目集成了 Spring Boot Actuator，提供监控端点：

| 端点 | 说明 | URL |
|------|------|-----|
| health | 健康检查 | http://localhost:10011/actuator/health |
| info | 应用信息 | http://localhost:10011/actuator/info |
| metrics | 指标信息 | http://localhost:10011/actuator/metrics |
| env | 环境变量 | http://localhost:10011/actuator/env |
| loggers | 日志配置 | http://localhost:10011/actuator/loggers |

### 9.2 健康检查命令

```bash
# 使用 curl 检查健康状态
curl http://localhost:10011/actuator/health

# 返回示例
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "redis": {"status": "UP"},
    "diskSpace": {"status": "UP"}
  }
}
```

### 9.3 Spring Boot Admin

项目已集成 Spring Boot Admin Client，可在 Admin Server 查看应用监控信息。

## 10. 常见问题排查

### 10.1 端口占用

```bash
# 查看端口占用
netstat -tulnp | grep 10011

# 或者使用 lsof
lsof -i:10011

# 停止占用端口的进程
kill -9 <PID>
```

### 10.2 连接 Nacos 失败

```bash
# 检查 Nacos 服务状态
curl http://127.0.0.1:8848/nacos/v1/ns/service/list

# 检查网络连接
telnet 127.0.0.1 8848
```

### 10.3 数据库连接失败

```bash
# 测试数据库连接
mysql -h <host> -P <port> -u <username> -p<password>

# 检查数据库连接池状态
curl http://localhost:10011/actuator/health | jq '.components.db'
```

### 10.4 内存溢出

```bash
# 增加 JVM 内存
java -Xms1024m -Xmx2048m -jar target/liupin-oa-service.jar

# 生成堆转储文件（OOM 时）
java -XX:+HeapDumpOnOutOfMemoryError \
     -XX:HeapDumpPath=/logs/heapdump.hprof \
     -jar target/liupin-oa-service.jar
```

## 11. 性能优化建议

### 11.1 JVM 参数优化

```bash
java -Xms512m \
     -Xmx1024m \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -XX:+HeapDumpOnOutOfMemoryError \
     -jar target/liupin-oa-service.jar
```

### 11.2 连接池优化

在配置文件中调整连接池参数：

```yaml
spring:
  datasource:
    max-active: 50
    initial-size: 5
    max-wait: 10000
    min-idle: 5
```

### 11.3 Redis 连接池优化

```yaml
spring:
  redis:
    lettuce:
      pool:
        max-active: 20
        max-idle: 10
        min-idle: 5
```

## 12. 备份与回滚

### 12.1 备份

```bash
# 备份 jar 包
cp target/liupin-oa-service.jar target/liupin-oa-service-$(date +%Y%m%d).jar

# 备份配置文件
tar -czf config-backup-$(date +%Y%m%d).tar.gz src/resources/
```

### 12.2 回滚

```bash
# 停止服务
kill -15 <PID>

# 回滚 jar 包
cp target/liupin-oa-service-20240101.jar target/liupin-oa-service.jar

# 重启服务
java -jar target/liupin-oa-service.jar --spring.profiles.active=pro &
```

## 13. 快速部署脚本

创建一键部署脚本 `deploy.sh`：

```bash
#!/bin/bash

APP_NAME="liupin-oa-service"
JAR_NAME="liupin-oa-service.jar"
LOG_FILE="oa-service.log"
PROFILE="pro"

echo "开始部署 ${APP_NAME}..."

# 停止旧服务
PID=$(ps -ef | grep ${JAR_NAME} | grep -v grep | awk '{print $2}')
if [ -n "${PID}" ]; then
    echo "停止旧服务, PID: ${PID}"
    kill -15 ${PID}
    sleep 5
fi

# 备份旧 jar 包
if [ -f "target/${JAR_NAME}" ]; then
    echo "备份旧 jar 包..."
    cp target/${JAR_NAME} target/${JAR_NAME}.bak.$(date +%Y%m%d%H%M%S)
fi

# 编译打包
echo "编译打包..."
mvn clean package -DskipTests

# 启动新服务
echo "启动新服务..."
nohup java -Xms512m -Xmx1024m -jar target/${JAR_NAME} \
    --spring.profiles.active=${PROFILE} > ${LOG_FILE} 2>&1 &

# 检查启动状态
sleep 10
NEW_PID=$(ps -ef | grep ${JAR_NAME} | grep -v grep | awk '{print $2}')
if [ -n "${NEW_PID}" ]; then
    echo "部署成功, PID: ${NEW_PID}"
    echo "查看日志: tail -f ${LOG_FILE}"
else
    echo "部署失败, 请检查日志"
    exit 1
fi
```

使用方法：

```bash
# 赋予执行权限
chmod +x deploy.sh

# 执行部署
./deploy.sh
```
