# 芋道 ruoyi-vue-pro 项目打包部署指南

## 一、项目构建

### 1.1 Maven 构建命令

```bash
# 编译项目（不运行测试）
mvn clean compile -DskipTests

# 编译项目（运行测试）
mvn clean compile

# 打包项目（跳过测试，推荐）
mvn clean package -DskipTests

# 打包项目（运行测试）
mvn clean package

# 安装到本地仓库（跳过测试）
mvn clean install -DskipTests

# 安装到本地仓库（运行测试）
mvn clean install
```

### 1.2 构建参数说明

| 参数 | 说明 |
|------|------|
| `-DskipTests` | 跳过测试，加快构建速度 |
| `-pl yudao-server` | 只构建指定模块 |
| `-am` | 同时构建依赖模块 |
| `-Dmaven.test.skip=true` | 跳过测试编译和执行 |
| `-Pprod` | 使用生产环境配置 |

### 1.3 构建输出

打包后的 JAR 文件位置：
```
yudao-server/target/yudao-server.jar
```

## 二、项目启动

### 2.1 开发环境启动

#### 方式一：使用 Maven 启动

```bash
# 使用 Maven 启动（指定 dev 环境）
mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles=dev

# 使用 Maven 启动（指定 local 环境）
mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles=local
```

#### 方式二：使用环境变量脚本启动

项目提供了 `scripts/start-with-env.sh` 脚本，可以自动加载环境变量：

```bash
# 添加执行权限
chmod +x scripts/start-with-env.sh

# 运行脚本
./scripts/start-with-env.sh
```

**注意**：需要先配置 `yudao-server/src/main/resources/.env` 文件（参考 `.env.example`）

#### 方式三：直接运行 JAR

```bash
# 编译打包
mvn clean package -DskipTests

# 启动项目（开发环境）
java -jar yudao-server/target/yudao-server.jar --spring.profiles.active=dev

# 启动项目（生产环境）
java -jar yudao-server/target/yudao-server.jar --spring.profiles.active=prod
```

### 2.2 JVM 参数配置

```bash
# 设置 JVM 堆内存
java -Xms512m -Xmx1024m -jar yudao-server.jar

# 开启 GC 日志
java -Xms512m -Xmx1024m \
  -XX:+PrintGCDetails -XX:+PrintGCDateStamps \
  -Xloggc:/logs/gc.log \
  -jar yudao-server.jar

# 开启堆内存溢出转储
java -Xms512m -Xmx1024m \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath=/logs/heapError \
  -jar yudao-server.jar
```

### 2.3 环境变量配置

项目支持通过环境变量配置数据库、Redis 等连接信息：

| 环境变量 | 说明 | 默认值 |
|---------|------|-------|
| `MYSQL_HOST` | MySQL 主机地址 | 127.0.0.1 |
| `MYSQL_PORT` | MySQL 端口 | 3306 |
| `MYSQL_DATABASE` | 数据库名称 | ruoyi-vue-pro |
| `MYSQL_USERNAME` | MySQL 用户名 | root |
| `MYSQL_PASSWORD` | MySQL 密码 | - |
| `REDIS_HOST` | Redis 主机地址 | 127.0.0.1 |
| `REDIS_PORT` | Redis 端口 | 6379 |
| `REDIS_DATABASE` | Redis 数据库索引 | 0 |
| `REDIS_PASSWORD` | Redis 密码 | - |

**使用示例**：

```bash
# 方式一：命令行参数
java -jar yudao-server.jar \
  --spring.datasource.dynamic.datasource.master.url="jdbc:mysql://localhost:3306/ruoyi-vue-pro"

# 方式二：环境变量
export MYSQL_HOST=localhost
export MYSQL_PASSWORD=123456
java -jar yudao-server.jar
```

## 三、热部署

### 3.1 Spring Boot DevTools

项目内置 Spring Boot DevTools，支持热部署：

```xml
<!-- pom.xml 中已包含（开发环境） -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>
```

**使用方式**：

1. 启动项目后，修改 Java 代码
2. 在 IDE 中触发重新编译（IDEA: Build → Build Project 或 Ctrl+F9）
3. DevTools 会自动重启应用

**配置参数**：

```yaml
spring:
  devtools:
    restart:
      enabled: true  # 启用热部署
      additional-paths: src/main/java  # 监控的路径
      exclude: static/**,public/**  # 排除的路径
```

### 3.2 IDEA 热部署配置

1. **开启自动编译**：
   - Settings → Build, Execution, Deployment → Compiler
   - 勾选 "Build project automatically"

2. **开启运行时编译**：
   - Settings → Advanced Settings
   - 勾选 "Allow auto-make to start even if developed application is currently running"

3. **触发重新编译**：
   - 快捷键：Ctrl + F9 (Windows) / Cmd + F9 (Mac)
   - 菜单：Build → Build Project

### 3.3 JRebel（商业工具）

如果使用 JRebel 插件，可以实现更快速的类热替换：

1. 安装 JRebel 插件
2. 激活 JRebel 许可证
3. 使用 JRebel 启动项目

## 四、Docker 部署

### 4.1 构建 Docker 镜像

```bash
# 方式一：使用 docker build
cd yudao-server
mvn clean package -DskipTests
docker build -t yudao-server:latest .

# 方式二：使用 docker-compose
cd script/docker
docker-compose build
```

### 4.2 Docker Compose 部署

项目提供了完整的 Docker Compose 配置：

```bash
# 启动所有服务（MySQL + Redis + 后端 + 前端）
cd script/docker
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f server

# 停止所有服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v
```

### 4.3 Docker 环境变量

可以通过环境变量自定义配置：

```bash
# 数据库配置
MYSQL_DATABASE=ruoyi-vue-pro
MYSQL_ROOT_PASSWORD=123456

# 后端服务配置
JAVA_OPTS=-Xms512m -Xmx512m
MASTER_DATASOURCE_URL=jdbc:mysql://mysql:3306/ruoyi-vue-pro
MASTER_DATASOURCE_USERNAME=root
MASTER_DATASOURCE_PASSWORD=123456
REDIS_HOST=redis
```

### 4.4 Dockerfile 说明

```dockerfile
# 基础镜像
FROM eclipse-temurin:21-jre

# 工作目录
WORKDIR /yudao-server

# 复制 JAR 文件
COPY ./target/yudao-server.jar app.jar

# 环境变量
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xms512m -Xmx512m"

# 暴露端口
EXPOSE 48080

# 启动命令
CMD java ${JAVA_OPTS} -jar app.jar
```

## 五、生产环境部署

### 5.1 生产环境配置

```bash
# 使用生产环境配置启动
java -jar yudao-server.jar --spring.profiles.active=prod
```

**生产环境注意事项**：

1. **JVM 参数优化**：
   ```bash
   java -server \
     -Xms2048m -Xmx2048m \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -XX:+HeapDumpOnOutOfMemoryError \
     -XX:HeapDumpPath=/logs/heapError \
     -jar yudao-server.jar
   ```

2. **日志配置**：
   ```yaml
   logging:
     level:
       root: INFO
       cn.iocoder.yudao: DEBUG
     file:
       name: /logs/yudao-server.log
       max-size: 10MB
       max-history: 30
   ```

3. **数据库连接池优化**：
   ```yaml
   spring:
     datasource:
       druid:
         initial-size: 10
         min-idle: 20
         max-active: 100
         max-wait: 60000
   ```

### 5.2 使用部署脚本

项目提供了生产环境部署脚本 `script/shell/deploy.sh`：

```bash
# 修改脚本中的配置
vim script/shell/deploy.sh

# 关键配置项：
# - BASE_PATH: 项目部署路径
# - SERVER_NAME: 服务名称
# - PROFILES_ACTIVE: 环境标识
# - JAVA_OPS: JVM 参数

# 执行部署
chmod +x script/shell/deploy.sh
./script/shell/deploy.sh
```

**部署脚本功能**：

- ✅ 自动备份旧版本 JAR
- ✅ 优雅关闭服务
- ✅ 部署新版本 JAR
- ✅ 启动服务
- ✅ 健康检查
- ✅ 支持自定义 JVM 参数

### 5.3 Nginx 反向代理

```nginx
upstream yudao-server {
    server 127.0.0.1:48080;
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://yudao-server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## 六、常见问题

### 6.1 端口占用

```bash
# 查看端口占用
lsof -i :48080

# 或
netstat -tunlp | grep 48080

# 强制关闭进程
kill -9 <PID>
```

### 6.2 内存不足

```bash
# 调整 JVM 堆内存
java -Xms256m -Xmx512m -jar yudao-server.jar

# 查看内存使用
jstat -gc <pid>
```

### 6.3 数据库连接失败

检查以下配置：
1. 数据库服务是否启动
2. 数据库连接信息是否正确
3. 防火墙是否开放端口
4. 数据库用户权限是否正确

### 6.4 Redis 连接失败

检查以下配置：
1. Redis 服务是否启动
2. Redis 连接信息是否正确
3. 防火墙是否开放端口
4. Redis 是否需要密码认证

## 七、相关文档

- [官方文档](https://doc.iocoder.cn)
- [快速启动](https://doc.iocoder.cn/quick-start)
- [部署文档](https://doc.iocoder.cn/deploy)
- [环境变量配置](./yudao-server/src/main/resources/ENV-CONFIG.md)
