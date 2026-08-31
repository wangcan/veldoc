# .claude/commands/ 目录文件分析

## 目录概述

`.claude/commands/` 目录存放自定义斜杠命令（Slash Commands）定义文件。每个命令是一个可快速执行的预定义操作，通过 `/命令名` 的方式调用。

## 文件列表

```
.claude/commands/
├── build.md     # 构建项目命令
├── db-init.md   # 数据库数据库初始化命令
└── start.md     # 启动项目命令
```

---

## 1. build.md - 构建项目命令

### 基本信息

| 属性 | 值 |
|------|-----|
| 命令名 | `/build` |
| 功能 | 构建项目 |
| 选项 | `--skip-tests`, `--clean`, `--offline` |

### 使用方式

```bash
/build [选项]
```

### 命令内容

#### 编译命令

```bash
mvn compile
```

#### 打包命令

```bash
# 打包并跳过测试
mvn clean package -DskipTests

# 打包并运行测试
mvn clean package
```

#### 安装到本地仓库

```bash
mvn clean install -DskipTests
```

#### 指定模块构建

```bash
mvn clean package -pl yudao-module-system -am
```

### 构建产物

- `yudao-server/target/yudao-server.jar` - 可执行 JAR

### 构建优化

| 优化方式 | 命令 |
|---------|------|
| 并行构建 | `mvn clean package -DskipTests -T 4` |
| 离线构建 | `mvn clean package -DskipTests -o` |
| 单模块构建 | `mvn clean package -DskipTests -pl yudao-module-system` |

### 使用场景

- 编译检查代码语法
- 打包生成可执行 JAR
- 安装到本地仓库供其他项目使用
- 快速验证代码修改

---

## 2. db-init.md - 数据库初始化命令

### 基本信息

| 属性 | 值 |
|------|-----|
| 命令名 | `/db-init` |
| 功能 | 初始化数据库 |
| 参数 | `[database]` - 数据库名，默认 `ruoyi-vue-pro` |

### 使用方式

```bash
/db-init [database]
```

### 初始化步骤

#### 1. 创建数据库

```sql
CREATE DATABASE IF NOT EXISTS `ruoyi-vue-pro`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

#### 2. 执行 SQL 脚本

```bash
# Linux/Mac
mysql -u root -p ruoyi-vue-pro < sql/mysql/ruoyi-vue-pro.sql

# Windows
mysql -u root -p ruoyi-vue-pro < sql\mysql\ruoyi-vue-pro.sql
```

#### 3. 验证初始化

```sql
-- 查看表数量
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'ruoyi-vue-pro';

-- 查看用户表
SELECT * FROM system_user WHERE id = 1;
```

### SQL 脚本位置

| 类型 | 路径 |
|------|------|
| 主脚本 | `sql/mysql/ruoyi-vue-pro.sql` |
| 升级脚本 | `sql/mysql/upgrade/` |

### 默认账号

| 用户名 | 密码 | 角色 |
|-------|------|------|
| admin | admin123 | 超级管理员 |
| user | user123 | 普通用户 |

### 注意事项

1. 确保数据库服务已启动
2. 确保有创建数据库的权限
3. 生产环境请修改默认密码

### 使用场景

- 新环境初始化
- 重置开发环境数据库
- 导入测试数据

---

## 3. start.md - 启动项目命令

### 基本信息

| 属性 | 值 |
|------|-----|
| 命令名 | `/start` |
| 功能 | 启动项目 |
| 参数 | `[profile]` - 环境配置，默认 `local`，可选 `dev`, `prod` |

### 使用方式

```bash
/start [profile]
```

### 启动方式

#### 1. Maven 启动

```bash
mvn spring-boot:run -pl yudao-server
```

#### 2. JAR 启动

```bash
# 先打包
mvn clean package -DskipTests

# 启动
java -jar yudao-server/target/yudao-server.jar
```

#### 3. 指定环境

```bash
# 开发环境
java -jar yudao-server/target/yudao-server.jar --spring.profiles.active=dev

# 生产环境
java -jar yudao-server/target/yudao-server.jar --spring.profiles.active=prod
```

### 启动前检查

1. 检查 MySQL 是否启动
2. 检查 Redis 是否启动
3. 检查数据库配置是否正确
4. 检查端口是否被占用

### 访问地址

启动成功后可访问：

| 服务 | 地址 |
|------|------|
| 接口文档 | http://localhost:48080/doc.html |
| Swagger UI | http://localhost:48080/swagger-ui |
| Actuator | http://localhost:48080/actuator/health |

### 使用场景

- 启动开发服务器
- 启动指定环境的应用
- 验证配置是否正确

---

## 命令设计模式

### 1. 单一职责

每个命令只做一件事：
- `build` - 构建项目
- `db-init` - 初始化数据库
- `start` - 启动项目

### 2. 参数支持

支持可选参数和选项：
- `/build --skip-tests` - 跳过测试构建
- `/db-init mydb` - 初始化指定数据库
- `/start dev` - 启动开发环境

### 3. 清晰的文档

每个命令文件包含：
- 使用方式
- 命令详解
- 参数说明
- 注意事项
- 使用场景

---

## 文件格式规范

### 结构

每个命令文件使用 Markdown 格式：

```markdown
# 命令标题

## 使用方式

```bash
/command [参数] [选项]
```

## 命令详解

### 命令1

```bash
command example
```

### 命令2

...

## 注意事项

1. ...
2. ...

## 使用场景

- ...
```

### 最佳实践

1. **简洁明了** - 命令名简短易记
2. **参数合理** - 提供合理的默认值
3. **文档完整** - 包含使用说明和注意事项
4. **示例丰富** - 提供多种使用示例

---

## 使用方式

### 调用命令

在 Claude Code 会话中输入：

```
/build --skip-tests
/db-init
/start dev
```

### 命令组合

可以组合使用多个命令：

```
先执行 /db-init 初始化数据库
然后执行 /build 构建项目
最后执行 /start 启动项目
```

---

## 扩展建议

可以根据项目需要添加更多命令：

| 建议命令 | 功能 |
|---------|------|
| `/test` | 运行测试 |
| `/deploy` | 部署到服务器 |
| `/logs` | 查看日志 |
| `/migrate` | 数据库迁移 |
| `/codegen` | 代码生成 |

---

## 与 Skills 的区别

### Commands

- **即时执行** - 输入后立即执行
- **简单操作** - 执行预定义的命令
- **无状态** - 不保存上下文

### Skills

- **多步骤流程** - 执行复杂的操作流程
- **状态管理** - 可能需要多步交互
- **参数化** - 支持复杂的参数配置

---

## 总结

`.claude/commands/` 目录定义了三个常用命令：

1. **build** - 项目构建，支持编译、打包、安装
2. **db-init** - 数据库初始化，创建数据库并导入数据
3. **start** - 项目启动，支持多种启动方式和环境配置

这些命令提供了快速执行常见操作的能力，提高了开发效率。每个命令都有清晰的文档和示例，方便团队成员使用。
