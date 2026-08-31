# 芋道 ruoyi-vue-pro 项目开发指南

## 项目概述

本项目基于 [ruoyi-vue-pro](https://github.com/YunaiV/ruoyi-vue-pro) 开发，使用 `master-jdk25` 分支。

### 技术栈

| 类别 | 技术/版本 |
|------|----------|
| **Java** | JDK 25 |
| **Spring Boot** | 4.1.0 |
| **数据库** | MySQL + MyBatis Plus 3.5.16 |
| **缓存** | Redis + Redisson 4.6.1 |
| **消息队列** | Event/Redis/RabbitMQ/Kafka/RocketMQ |
| **工作流** | Flowable 8.0.0 |
| **安全认证** | Spring Security + Token + Redis |
| **接口文档** | Knife4j 4.5.0 + SpringDoc 3.0.3 |
| **工具类** | Hutool 5.8.46/6.0.0-M22, Guava, FastJson2 |
| **构建工具** | Maven |
| **代码增强** | Lombok 1.18.46, MapStruct 1.6.3 |

### 项目结构

```
ruoyi-vue-pro/
├── yudao-dependencies/       # BOM依赖管理
├── yudao-framework/          # 框架核心
│   ├── yudao-common/                     # 通用工具类
│   ├── yudao-spring-boot-starter-web/    # Web模块
│   ├── yudao-spring-boot-starter-security/ # 安全模块
│   ├── yudao-spring-boot-starter-mybatis/ # MyBatis模块
│   ├── yudao-spring-boot-starter-redis/  # Redis模块
│   └── ...                               # 其他starter
├── yudao-server/             # 主启动模块
├── yudao-module-system/      # 系统模块(用户、角色、权限、菜单)
├── yudao-module-infra/       # 基础设施模块(文件、配置、代码生成)
├── yudao-module-member/      # 会员模块
├── yudao-module-bpm/         # 工作流模块
├── yudao-module-pay/         # 支付模块
├── yudao-module-mall/        # 商城模块
├── yudao-module-crm/         # CRM模块
├── yudao-module-erp/         # ERP模块
├── yudao-module-ai/          # AI大模型模块
├── yudao-module-iot/         # IoT物联网模块
└── ...                       # 其他业务模块
```

## 开发规范

### 代码规范

1. **命名规范**：遵循《阿里巴巴 Java 开发手册》
2. **注释规范**：类、方法必须有中文注释说明
3. **日志规范**：使用 Slf4j，关键操作必须记录日志
4. **异常处理**：使用统一异常处理，抛出 ServiceException

### 分层架构

```
Controller层 → Service层 → Dal层
     ↓            ↓          ↓
   请求处理     业务逻辑    数据访问
```

### 模块依赖原则

- 业务模块依赖 framework 模块
- framework 模块之间可相互依赖
- 业务模块之间**不可**相互依赖

## 常用命令

### 构建命令

```bash
# 编译项目
mvn clean compile

# 打包项目
mvn clean package -DskipTests

# 运行测试
mvn test

# 安装到本地仓库
mvn clean install -DskipTests
```

### 启动命令

```bash
# 使用Maven启动
mvn spring-boot:run -pl yudao-server

# 使用JAR启动
java -jar yudao-server/target/yudao-server.jar
```

### 数据库初始化

```bash
# 执行SQL脚本
mysql -u root -p < sql/mysql/ruoyi-vue-pro.sql
```

## API文档

启动项目后访问：
- Swagger UI: http://localhost:48080/swagger-ui
- Knife4j: http://localhost:48080/doc.html

## 代码生成器

项目内置代码生成器，可通过管理后台快速生成：
- Java实体类、Mapper、Service、Controller
- Vue前端页面
- SQL建表语句

访问路径：系统工具 → 代码生成

## 注意事项

1. **数据库版本**：推荐 MySQL 8.0+
2. **Redis版本**：推荐 Redis 6.0+
3. **多租户支持**：项目内置多租户，开发时注意租户上下文
4. **数据权限**：使用 `@DataPermission` 注解控制数据权限
5. **事务管理**：Service方法添加 `@Transactional` 注解

## 相关文档

- 官方文档: https://doc.iocoder.cn
- 视频教程: https://doc.iocoder.cn/video
- 启动文档: https://doc.iocoder.cn/quick-start
