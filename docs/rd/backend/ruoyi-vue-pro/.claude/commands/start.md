# 启动项目命令

## 使用方式

```
/start [profile]
```

参数：
- `profile`: 环境配置，默认 `local`，可选 `dev`, `prod`

## 启动方式

### 1. Maven 启动

```bash
mvn spring-boot:run -pl yudao-server
```

### 2. JAR 启动

```bash
# 先打包
mvn clean package -DskipTests

# 启动
java -jar yudao-server/target/yudao-server.jar
```

### 3. 指定环境

```bash
# 开发环境
java -jar yudao-server/target/yudao-server.jar --spring.profiles.active=dev

# 生产环境
java -jar yudao-server/target/yudao-server.jar --spring.profiles.active=prod
```

## 启动前检查

1. 检查 MySQL 是否启动
2. 检查 Redis 是否启动
3. 检查数据库配置是否正确
4. 检查端口是否被占用

## 访问地址

启动成功后可访问：

- 接口文档: http://localhost:48080/doc.html
- Swagger UI: http://localhost:48080/swagger-ui
- Actuator: http://localhost:48080/actuator/health
