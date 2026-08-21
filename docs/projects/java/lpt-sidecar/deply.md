# lpt-sidecar 项目部署手册

## 1. 环境要求

### 1.1 基础环境

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| JDK | 1.8+ | Java运行环境 |
| Gradle | 7.x | 构建工具(可使用gradlew) |
| MySQL | 5.7+ | 数据库 |
| Redis | 6.0+ | 缓存服务 |
| Node.js | 14+ | 字帖生成依赖 |

### 1.2 环境变量配置

在项目根目录创建 `.env` 文件：

```bash
# 应用端口
APP_PORT=7777

# 数据库连接
DB_URL=jdbc:mysql://localhost:3306/your_database?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai
DB_USERNAME=root
DB_PASSWORD=your_password

# 日志级别
LOG_LEVEL=DEBUG

# 节点配置(单机部署设为1，多节点部署每个节点编号不同)
NODE_NUM=1
NODE_COUNT=1

# Redis连接
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PWD=your_redis_password
REDIS_DATABASE=2
```

---

## 2. 本地开发启动

### 2.1 克隆项目

```bash
cd /data/java/backend/
git clone <repository-url> lpt-sidecar
cd lpt-sidecar
```

### 2.2 配置环境变量

复制环境变量模板：

```bash
cp .env.example .env
# 编辑 .env 文件，填入实际配置
vim .env
```

### 2.3 使用 Gradle 启动

#### 方式一：使用 gradlew (推荐)

```bash
# Unix/Linux/Mac
./gradlew bootRun

# Windows
gradlew.bat bootRun
```

#### 方式二：指定 Profile

```bash
# 开发环境
./gradlew bootRun --args='--spring.profiles.active=dev'

# 测试环境
./gradlew bootRun --args='--spring.profiles.active=test'

# 生产环境
./gradlew bootRun --args='--spring.profiles.active=pro'
```

### 2.4 使用 IDE 启动

#### IntelliJ IDEA

1. 打开项目，等待 Gradle 同步完成
2. 找到 `src/main/java/com/liupin/utils/UtilsApplication.java`
3. 右键 -> Run 'UtilsApplication'
4. 在 Run Configuration 中可配置环境变量：
   - `spring.profiles.active=dev`

#### VS Code

1. 安装 Extension Pack for Java
2. 打开项目
3. 在 `UtilsApplication.java` 中点击 Run | Debug
4. 在 `launch.json` 中配置环境变量

### 2.5 指定环境 Profile

在启动参数中指定：

```bash
# 命令行参数
--spring.profiles.active=dev

# JVM参数
-Dspring.profiles.active=dev

# 环境变量
export SPRING_PROFILES_ACTIVE=dev
```

---

## 3. 热部署配置

### 3.1 DevTools 配置

项目已集成 `spring-boot-devtools`，支持热部署。

#### 启用热部署

1. 确认 `build.gradle` 中已添加依赖：

```gradle
developmentOnly 'org.springframework.boot:spring-boot-devtools'
```

2. IDE 配置：

##### IntelliJ IDEA

- Settings -> Build, Execution, Deployment -> Compiler -> 勾选 "Build project automatically"
- Settings -> Advanced Settings -> 勾选 "Allow auto-make to start even if developed application is currently running"

##### Eclipse

- Project -> Build Automatically (勾选)

#### 触发重新加载

- **IDE**: 保存文件后自动重新加载（可能需要手动触发 Build）
- **命令行**: 修改代码后，Gradle 会自动重新加载

### 3.2 热部署范围

DevTools 支持以下内容的热更新：
- Java 类（方法体内修改）
- 配置文件（application.yml/properties）
- 静态资源

**注意**: 以下修改需要重启：
- 新增/删除类
- 修改方法签名
- 修改注解

### 3.3 禁用热部署

生产环境应禁用热部署：

```bash
# 启动时添加参数
java -jar -Dspring.devtools.restart.enabled=false app.jar

# 或在 application.yml 中配置
spring:
  devtools:
    restart:
      enabled: false
```

---

## 4. 项目打包

### 4.1 打包为 JAR

#### 方式一：使用 gradlew

```bash
# 打包（跳过测试）
./gradlew bootJar -x test

# 打包并执行测试
./gradlew bootJar
```

#### 方式二：指定 Profile 打包

```bash
# 测试环境
./gradlew bootJar -Dspring.profiles.active=test

# 生产环境
./gradlew bootJar -Dspring.profiles.active=pro
```

### 4.2 打包输出位置

打包后的 JAR 文件位于：

```
build/libs/utils-0.0.1-SNAPSHOT.jar
```

### 4.3 打包命令详解

| 命令 | 说明 |
|------|------|
| `./gradlew bootJar` | 打包为可执行JAR |
| `./gradlew build` | 完整构建(包含测试) |
| `./gradlew build -x test` | 跳过测试构建 |
| `./gradlew clean build` | 清理后重新构建 |
| `./gradlew jar` | 打包为普通JAR(不包含依赖) |
| `./gradlew bootJar` | 打包为可执行JAR(包含所有依赖) |

### 4.4 查看打包结果

```bash
# 查看生成的JAR
ls -lh build/libs/

# 查看JAR内容
jar -tf build/libs/utils-0.0.1-SNAPSHOT.jar
```

---

## 5. 服务器部署

### 5.1 手动部署

#### 步骤1：上传文件

```bash
# 创建目录
mkdir -p /usr/local/liupin/newtool

# 上传JAR包
scp build/libs/utils-0.0.1-SNAPSHOT.jar user@server:/usr/local/liupin/newtool/

# 上传启动脚本
scp run-server.sh user@server:/usr/local/liupin/newtool/
```

#### 步骤2：创建 .env 文件

```bash
vim /usr/local/liupin/newtool/.env
```

内容参考第1.2节。

#### 步骤3：赋予脚本执行权限

```bash
chmod +x /usr/local/liupin/newtool/run-server.sh
```

#### 步骤4：启动服务

```bash
cd /usr/local/liupin/newtool

# 启动
./run-server.sh start

# 停止
./run-server.sh stop

# 远程重启(部署后使用)
./run-server.sh remote_start utils-0.0.1-SNAPSHOT.jar
```

### 5.2 使用 Gradle SSH 插件部署

项目已配置 SSH 部署任务。

#### 配置服务器信息

编辑 `build.gradle` 中的 `deploy` 任务：

```gradle
task deploy(dependsOn: bootJar) {
    doLast {
        ssh.remotes {
            webServer {
                host = 'your.server.ip'
                user = 'your_username'
                password = 'your_password'
                // 或使用密钥认证
                // identity = file('path/to/key')
            }
        }
        ssh.run {
            session(ssh.remotes.webServer) {
                def appdir = '/usr/local/liupin/newtool'
                put from: 'build/libs/utils-0.0.1-SNAPSHOT.jar', into: appdir
                put from: 'run-server.sh', into: appdir
                execute "sh $appdir/run-server.sh remote_start utils-0.0.1-SNAPSHOT.jar"
            }
        }
    }
}
```

#### 执行部署

```bash
./gradlew deploy
```

### 5.3 Systemd 服务管理（推荐）

创建系统服务文件：

```bash
sudo vim /etc/systemd/system/lpt-sidecar.service
```

内容：

```ini
[Unit]
Description=LPT Sidecar Service
After=network.target mysql.service redis.service

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/liupin/newtool
Environment="JAVA_OPTS=-Xms1g -Xmx1g"
EnvironmentFile=/usr/local/liupin/newtool/.env
ExecStart=/usr/bin/java $JAVA_OPTS -jar /usr/local/liupin/newtool/utils-0.0.1-SNAPSHOT.jar --spring.profiles.active=test
ExecStop=/bin/kill -15 $MAINPID
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

#### 服务管理命令

```bash
# 重新加载systemd配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start lpt-sidecar

# 停止服务
sudo systemctl stop lpt-sidecar

# 重启服务
sudo systemctl restart lpt-sidecar

# 查看状态
sudo systemctl status lpt-sidecar

# 查看日志
sudo journalctl -u lpt-sidecar -f

# 开机自启
sudo systemctl enable lpt-sidecar

# 取消开机自启
sudo systemctl disable lpt-sidecar
```

---

## 6. 多节点部署

### 6.1 节点配置说明

多节点部署时，每个节点需要不同的 `NODE_NUM`。

#### 节点1配置

```bash
# .env
NODE_NUM=1
NODE_COUNT=2
```

打包并部署到服务器1。

#### 节点2配置

```bash
# .env
NODE_NUM=2
NODE_COUNT=2
```

打包并部署到服务器2。

### 6.2 负载均衡配置

Nginx 配置示例：

```nginx
upstream lpt_backend {
    server 192.168.1.101:7777 weight=1;
    server 192.168.1.102:7777 weight=1;
}

server {
    listen 80;
    server_name your.domain.com;

    location / {
        proxy_pass http://lpt_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 6.3 任务分配策略

在 `ImageService.insertCommodity` 方法中：

```java
// 单节点
commodity.setNode(1);

// 多节点轮询
commodity.setNode(RandomUtil.alternateReturn());
```

---

## 7. Docker 部署（可选）

### 7.1 创建 Dockerfile

```dockerfile
FROM openjdk:8-jre-slim

WORKDIR /app

# 复制JAR包
COPY build/libs/utils-0.0.1-SNAPSHOT.jar app.jar

# 复制.env文件(可选，建议使用环境变量)
# COPY .env .env

# 暴露端口
EXPOSE 7777

# 启动命令
ENTRYPOINT ["java", "-Xms1g", "-Xmx1g", "-jar", "app.jar"]
```

### 7.2 构建镜像

```bash
# 打包项目
./gradlew bootJar -x test

# 构建Docker镜像
docker build -t lpt-sidecar:latest .
```

### 7.3 运行容器

```bash
docker run -d \
  --name lpt-sidecar \
  -p 7777:7777 \
  -e SPRING_PROFILES_ACTIVE=test \
  -e DB_URL=jdbc:mysql://host:3306/db \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=pwd \
  -e REDIS_HOST=redis \
  -e NODE_NUM=1 \
  -e NODE_COUNT=1 \
  lpt-sidecar:latest
```

### 7.4 Docker Compose

```yaml
version: '3.8'

services:
  app:
    image: lpt-sidecar:latest
    container_name: lpt-sidecar
    ports:
      - "7777:7777"
    environment:
      - SPRING_PROFILES_ACTIVE=test
      - DB_URL=jdbc:mysql://mysql:3306/lpt_db
      - DB_USERNAME=root
      - DB_PASSWORD=pwd
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - NODE_NUM=1
      - NODE_COUNT=1
    depends_on:
      - mysql
      - redis
    restart: unless-stopped

  mysql:
    image: mysql:5.7
    environment:
      - MYSQL_ROOT_PASSWORD=pwd
      - MYSQL_DATABASE=lpt_db
    volumes:
      - mysql_data:/var/lib/mysql

  redis:
    image: redis:6
    volumes:
      - redis_data:/data

volumes:
  mysql_data:
  redis_data:
```

启动：

```bash
docker-compose up -d
```

---

## 8. 日志与监控

### 8.1 日志配置

日志配置文件：`src/main/resources/log4j2.xml`

#### 日志文件位置

- 控制台输出
- 可在 log4j2.xml 中配置文件输出路径

#### 查看实时日志

```bash
# 使用 run-server.sh 启动时
tail -f /usr/local/liupin/newtool/project.log

# 使用 systemd 时
journalctl -u lpt-sidecar -f
```

### 8.2 JVM 监控

启用 JMX 远程监控：

```bash
java -Dcom.sun.management.jmxremote \
     -Dcom.sun.management.jmxremote.port=9010 \
     -Dcom.sun.management.jmxremote.authenticate=false \
     -Dcom.sun.management.jmxremote.ssl=false \
     -jar utils-0.0.1-SNAPSHOT.jar
```

使用 JConsole 或 VisualVM 连接监控。

---

## 9. 常见问题

### 9.1 端口被占用

```bash
# 查看端口占用
netstat -tlnp | grep 7777

# 或
lsof -i:7777

# 结束进程
kill -9 <PID>
```

### 9.2 数据库连接失败

检查：
1. `.env` 文件中的数据库配置是否正确
2. MySQL 服务是否启动
3. 数据库用户权限
4. 网络连通性

### 9.3 Redis 连接失败

检查：
1. Redis 服务状态：`systemctl status redis`
2. `.env` 中的 Redis 配置
3. Redis 密码认证

### 9.4 内存不足

调整 JVM 参数：

```bash
# 增大内存
java -Xms2g -Xmx2g -jar app.jar

# 或在 run-server.sh 中修改
```

### 9.5 热部署不生效

检查：
1. IDE 是否启用了自动编译
2. devtools 依赖是否正确配置
3. 是否处于开发环境

---

## 10. 健康检查

### 10.1 应用健康检查

访问健康检查端点（需启用 Spring Boot Actuator）：

```bash
curl http://localhost:7777/actuator/health
```

### 10.2 数据库连接检查

```bash
# MySQL
mysql -h host -u user -p

# Redis
redis-cli -h host -p port -a password ping
```

---

## 11. 备份与恢复

### 11.1 数据库备份

```bash
# 备份
mysqldump -u root -p database_name > backup_$(date +%Y%m%d).sql

# 恢复
mysql -u root -p database_name < backup_20240101.sql
```

### 11.2 配置备份

定期备份 `.env` 文件和 `application.yml`。

---

## 12. 安全建议

### 12.1 生产环境配置

1. 禁用 devtools：
   ```yaml
   spring:
     devtools:
       restart:
         enabled: false
   ```

2. 修改默认端口

3. 使用强密码

4. 启用 HTTPS

5. 配置防火墙规则

### 12.2 敏感信息保护

- 不要将 `.env` 文件提交到版本控制
- 使用环境变量或配置中心管理敏感配置
- 定期更新密钥和密码

---

## 13. 附录

### 13.1 常用命令速查

| 命令 | 说明 |
|------|------|
| `./gradlew bootRun` | 本地启动 |
| `./gradlew bootJar` | 打包JAR |
| `./gradlew build` | 完整构建 |
| `./gradlew clean` | 清理构建 |
| `./gradlew deploy` | SSH部署 |
| `./run-server.sh start` | 启动服务 |
| `./run-server.sh stop` | 停止服务 |
| `./run-server.sh remote_start` | 远程重启 |

### 13.2 目录结构

| 目录 | 说明 |
|------|------|
| `/usr/local/liupin/newtool` | 应用部署目录 |
| `/usr/local/liupin/name-copybook` | 字帖数据目录 |
| `/usr/local/liupin/newtool/webserver/nginx` | Nginx目录 |

### 13.3 联系方式

如有问题，请联系项目维护人员。

---

**文档更新日期**: 2026-08-17
