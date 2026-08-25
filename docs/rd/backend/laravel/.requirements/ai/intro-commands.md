# commands 目录分析

## 目录概述

`.claude/commands/` 目录包含自定义斜杠命令（slash commands）的定义文件。这些命令是快速访问常用功能的快捷方式，通过 `/命令名` 的方式调用，提高开发效率。

## 目录位置

```
/data/project/backend/ai-laravel/.claude/commands/
```

## 目录结构

```
.claude/commands/
├── make-model.md      # 创建模型命令
├── make-api.md        # 创建 API 资源命令
├── run-tests.md       # 运行测试命令
├── db-inspect.md      # 数据库检查命令
└── laravel-docs.md    # Laravel 文档搜索命令
```

## 命令文件格式

每个命令文件都采用 Markdown 格式，包含：

```markdown
# Command Name

Brief description

## Usage

```
/command-name [arguments] [options]
```

## Options

- `--option` - Description

## Examples

```bash
# Example usage
/command-name argument
```

## Implementation

When invoked, I will:
1. Step 1
2. Step 2
...
```

---

## 命令详细分析

### 1. Make Model（创建模型）

**文件**: `make-model.md`

#### 基本信息

- **命令**: `/make-model`
- **用途**: 创建新的 Eloquent 模型及相关文件
- **底层命令**: `php artisan make:model`

#### 使用语法

```bash
/make-model ModelName [options]
```

#### 可用选项

| 选项 | 简写 | 功能 |
|-----|------|------|
| `--migration` | `-m` | 创建迁移文件 |
| `--factory` | `-f` | 创建工厂文件 |
| `--seeder` | `-s` | 创建种子文件 |
| `--controller` | `-c` | 创建控制器 |
| `--api` | - | 创建 API 控制器 |
| `--all` | `-a` | 创建所有文件（迁移、工厂、种子、控制器）|

#### 使用示例

```bash
# 仅创建模型
/make-model Post

# 创建模型和迁移
/make-model Post -m

# 创建模型和所有相关文件
/make-model Post --all

# 创建模型和 API 控制器
/make-model Post --api
```

#### 实现流程

当调用此命令时，AI 会：

1. **运行 Artisan 命令**
   ```bash
   php artisan make:model Post [options]
   ```

2. **显示创建的文件**
   - 列出所有生成的文件路径
   - 说明每个文件的作用

3. **建议下一步操作**
   - 定义模型关系
   - 添加查询作用域
   - 配置属性转换

#### 命令映射表

| 选项 | Artisan 等价命令 |
|-----|-----------------|
| `-m` | `--migration` |
| `-f` | `--factory` |
| `-s` | `--seed` |
| `-c` | `--controller` |
| `-a` | `--all` |
| `--api` | `--controller --api` |

#### 使用场景

```bash
# 场景1：快速原型开发
/make-model Product -m

# 场景2：完整功能开发
/make-model Product --all

# 场景3：API 开发
/make-model Product --api
```

#### 实际效果示例

```bash
用户：/make-model Product --all

AI 执行：
php artisan make:model Product --all

输出：
✅ 创建以下文件：
- app/Models/Product.php
- database/migrations/xxxx_create_products_table.php
- database/factories/ProductFactory.php
- database/seeders/ProductSeeder.php
- app/Http/Controllers/ProductController.php

💡 建议下一步：
- 在模型中定义关系（如 belongsTo, hasMany）
- 在迁移中添加必要的列和索引
- 在工厂中定义测试数据规则
```

---

### 2. Make API（创建 API 资源）

**文件**: `make-api.md`

#### 基本信息

- **命令**: `/make-api`
- **用途**: 创建完整的 RESTful API 资源
- **特点**: 一站式创建所有 API 相关文件

#### 使用语法

```bash
/make-api ResourceName
```

#### 创建的文件

调用 `/make-api Product` 会创建：

| 文件类型 | 文件路径 | 说明 |
|---------|---------|------|
| 模型 | `app/Models/Product.php` | Eloquent 模型 |
| 迁移 | `database/migrations/xxxx_create_products_table.php` | 数据库迁移 |
| 工厂 | `database/factories/ProductFactory.php` | 测试数据工厂 |
| 控制器 | `app/Http/Controllers/Api/V1/ProductController.php` | API 控制器 |
| 资源 | `app/Http/Resources/ProductResource.php` | API 资源转换 |
| 存储请求 | `app/Http/Requests/Api/V1/StoreProductRequest.php` | 存储验证 |
| 更新请求 | `app/Http/Requests/Api/V1/UpdateProductRequest.php` | 更新验证 |
| 路由 | `routes/api.php` | API 路由（追加）|
| 测试 | `tests/Feature/Api/V1/ProductTest.php` | 功能测试 |

#### 使用示例

```bash
# 创建产品 API
/make-api Product

# 创建订单 API
/make-api Order

# 创建用户 API
/make-api User
```

#### 实现流程

当调用此命令时，AI 会：

1. **询问字段信息**
   - 字段名称
   - 字段类型（string, integer, text 等）
   - 是否必填

2. **创建迁移**
   - 根据字段定义创建迁移文件
   - 添加适当的索引

3. **创建模型**
   - 定义 `$fillable` 属性
   - 配置类型转换
   - 定义关系

4. **创建工厂**
   - 定义字段规则
   - 使用 Faker 生成数据

5. **创建控制器**
   - 实现 CRUD 方法
   - 使用路由模型绑定
   - 返回 API 资源

6. **创建资源**
   - 定义 JSON 输出格式
   - 条件加载关系

7. **创建验证请求**
   - Store 验证规则
   - Update 验证规则

8. **添加路由**
   - 在 `routes/api.php` 添加路由

9. **创建测试**
   - 列表测试
   - 创建测试
   - 更新测试
   - 删除测试

10. **运行 Pint**
    - 格式化所有 PHP 文件

#### 使用场景

```bash
# 场景：快速创建完整的 API 资源
用户：/make-api Product

AI 会询问：
📝 请提供 Product 的字段信息：
- name (string, required)
- price (decimal, required)
- description (text, optional)
- category_id (foreignId, required)

AI 执行：
1. 创建迁移（包含 name, price, description, category_id 列）
2. 创建模型（配置 $fillable 和 casts）
3. 创建工厂（定义 name, price, description 规则）
4. 创建 ProductController（index, show, store, update, destroy）
5. 创建 ProductResource（转换 JSON 输出）
6. 创建 StoreProductRequest 和 UpdateProductRequest（验证规则）
7. 在 routes/api.php 添加路由
8. 创建 ProductTest（测试所有端点）
9. 运行 Pint 格式化
```

#### 自定义选项

创建后可自定义：

- **模型**: 添加关系、作用域
- **验证**: 修改验证规则
- **作用域**: 添加过滤逻辑
- **资源**: 自定义输出格式

---

### 3. Run Tests（运行测试）

**文件**: `run-tests.md`

#### 基本信息

- **命令**: `/run-tests`
- **用途**: 运行 PHPUnit 测试套件
- **底层命令**: `php artisan test`

#### 使用语法

```bash
/run-tests [filter] [options]
```

#### 可用选项

| 选项 | 简写 | 功能 |
|-----|------|------|
| `--compact` | `-c` | 紧凑输出 |
| `--parallel` | `-p` | 并行执行 |
| `--filter=name` | - | 按名称过滤 |
| `--stop-on-failure` | - | 首次失败时停止 |

#### 使用示例

```bash
# 运行所有测试
/run-tests

# 紧凑输出
/run-tests --compact

# 运行特定测试文件
/run-tests tests/Feature/UserTest.php

# 按名称过滤
/run-tests --filter=test_user_can_login

# 并行执行
/run-tests --parallel

# 组合选项
/run-tests --compact --filter=AuthenticationTest
```

#### 实现流程

当调用此命令时，AI 会：

1. **运行测试**
   ```bash
   php artisan test [options]
   ```

2. **显示测试结果**
   - 测试数量
   - 通过/失败状态
   - 错误详情
   - 执行时间
   - 内存使用

3. **分析失败（如有）**
   - 解释失败原因
   - 提供修复建议
   - 提供相关代码位置

4. **建议下一步**
   - 运行完整测试套件（如果只运行了部分）
   - 修复失败的测试

#### 测试输出示例

```
🧪 运行测试...

  PASS  Tests\Feature\UserTest
  ✓ user can register
  ✓ user can login
  ✓ user can logout

  PASS  Tests\Feature\ProductTest
  ✓ product list
  ✓ product create
  ✓ product update
  ✓ product delete

  Tests:  8 passed
  Time:   1.23s
  Memory: 12.45 MB
```

#### 常见场景

**提交前验证**:
```bash
# 运行完整测试套件确保没有破坏现有功能
/run-tests --compact
```

**开发过程中**:
```bash
# 运行与当前更改相关的测试
/run-tests --filter=AuthenticationTest
```

**修复 Bug 后**:
```bash
# 验证特定测试用例
/run-tests --filter=test_user_can_login
```

**CI/CD 环境**:
```bash
# 并行执行以加快速度
/run-tests --parallel --stop-on-failure
```

---

### 4. Database Inspect（数据库检查）

**文件**: `db-inspect.md`

#### 基本信息

- **命令**: `/db-inspect`
- **用途**: 检查数据库模式和运行查询
- **底层工具**: Laravel Boost MCP `database-schema`

#### 使用语法

```bash
/db-inspect [table]
/db-inspect --query "SQL"
```

#### 使用示例

```bash
# 显示所有表
/db-inspect

# 显示特定表详情
/db-inspect users

# 显示表结构和索引
/db-inspect products

# 运行自定义查询
/db-inspect --query "SELECT * FROM users LIMIT 10"
```

#### 实现流程

当调用此命令时，AI 会：

1. **使用 database-schema 工具**
   - 检查表结构
   - 获取列信息
   - 查看索引和外键

2. **显示表信息**
   - 表名列表（摘要模式）
   - 列名和类型
   - 可空和默认值
   - 主键和索引
   - 外键约束

3. **可选查询**
   - 使用 `--query` 运行自定义 SQL
   - 显示查询结果

#### 输出示例

```bash
用户：/db-inspect users

AI 输出：
📊 表结构: users

| 列名 | 类型 | 可空 | 默认值 | 索引 |
|-----|------|------|--------|------|
| id | bigint | NO | - | PRIMARY |
| name | varchar(255) | NO | - | - |
| email | varchar(255) | NO | - | UNIQUE |
| email_verified_at | timestamp | YES | NULL | - |
| password | varchar(255) | NO | - | - |
| remember_token | varchar(100) | YES | NULL | - |
| created_at | timestamp | YES | NULL | - |
| updated_at | timestamp | YES | NULL | - |

索引:
- PRIMARY: id
- UNIQUE: email

外键: 无
```

#### 使用场景

**理解现有模式**:
```bash
# 创建迁移前查看现有表结构
/db-inspect users
```

**验证迁移结果**:
```bash
# 运行迁移后验证表结构
/db-inspect products
```

**调试数据库问题**:
```bash
# 检查索引和外键
/db-inspect orders
```

**探索数据关系**:
```bash
# 查看所有表
/db-inspect

# 检查特定表
/db-inspect order_items
```

---

### 5. Laravel Docs（Laravel 文档搜索）

**文件**: `laravel-docs.md`

#### 基本信息

- **命令**: `/laravel-docs`
- **用途**: 搜索 Laravel 官方文档
- **底层工具**: Laravel Boost MCP `search-docs`
- **特点**: 版本特定的文档（Laravel 13.26.1）

#### 使用语法

```bash
/laravel-docs query [query...]
```

#### 使用示例

```bash
# 搜索单个关键词
/laravel-docs validation

# 搜索多个关键词
/laravel-docs "rate limiting" middleware

# 搜索特定包
/laravel-docs --package=laravel/framework routing

# 搜索 API 用法
/laravel-docs "query builder"

# 搜索关系
/laravel-docs relationships eager loading
```

#### 实现流程

当调用此命令时，AI 会：

1. **调用 search-docs 工具**
   - 搜索 Laravel 13.26.1 文档
   - 返回相关片段

2. **返回文档内容**
   - API 用法示例
   - 代码片段
   - 最佳实践

3. **提供链接**
   - 完整文档章节链接
   - 相关主题链接

#### 输出示例

```bash
用户：/laravel-docs validation

AI 输出：
📖 Laravel 13 文档 - 验证

## 快速验证

使用 validate 方法：

```php
$request->validate([
    'title' => 'required|unique:posts|max:255',
    'body' => 'required',
]);
```

## 表单请求验证

创建表单请求：

```bash
php artisan make:request StorePostRequest
```

## 验证规则

常用规则：
- required - 必填
- email - 邮箱格式
- unique - 唯一
- max:255 - 最大长度

📚 完整文档: https://laravel.com/docs/13/validation
```

#### 使用场景

**查询 API 用法**:
```bash
# 查询验证方法
/laravel-docs validation
```

**确保版本兼容**:
```bash
# 查询 Laravel 13 特定 API
/laravel-docs "route model binding"
```

**学习最佳实践**:
```bash
# 查询缓存最佳实践
/laravel-docs caching
```

**发现新功能**:
```bash
# 查询新特性
/laravel-docs "php 8 attributes"
```

#### 为什么使用此命令

- ✅ **版本特定**: 匹配项目 Laravel 版本
- ✅ **API 兼容**: 确保使用的 API 可用
- ✅ **最佳实践**: 提供官方推荐做法
- ✅ **发现功能**: 了解框架能力

---

## 命令对比表

| 命令 | 用途 | 底层工具/命令 | 创建文件数 |
|-----|------|--------------|----------|
| `/make-model` | 创建模型 | `php artisan make:model` | 1-5 个 |
| `/make-api` | 创建完整 API | 多个 Artisan 命令 | 9 个 |
| `/run-tests` | 运行测试 | `php artisan test` | 0 个 |
| `/db-inspect` | 检查数据库 | `database-schema` MCP | 0 个 |
| `/laravel-docs` | 搜索文档 | `search-docs` MCP | 0 个 |

---

## 命令使用流程图

```
开发流程:

1. 设计阶段
   /db-inspect → 查看现有数据库结构
   /laravel-docs → 查询 API 用法

2. 创建阶段
   /make-model → 创建模型
   /make-api → 创建完整 API

3. 测试阶段
   /run-tests → 运行测试

4. 调试阶段
   /db-inspect → 验证数据库状态
   /run-tests --filter=... → 运行特定测试
```

---

## 最佳实践

### 1. 组合使用命令

**创建新功能**:
```bash
# 步骤1: 查看现有数据库
/db-inspect

# 步骤2: 创建完整 API
/make-api Product

# 步骤3: 运行测试
/run-tests --compact
```

**调试问题**:
```bash
# 步骤1: 搜索相关文档
/laravel-docs "query builder"

# 步骤2: 检查数据库状态
/db-inspect products

# 步骤3: 运行相关测试
/run-tests --filter=ProductTest
```

### 2. 使用选项提高效率

```bash
# 快速创建
/make-model Post -m

# 紧凑输出
/run-tests --compact

# 并行执行
/run-tests --parallel

# 精准过滤
/run-tests --filter=test_user_can_login
```

### 3. 自定义命令

可以创建新的命令文件：

```markdown
# Custom Command

Description

## Usage

```
/custom-command [args]
```

## Implementation

When invoked, I will:
1. Step 1
2. Step 2
```

---

## 总结

`.claude/commands/` 目录包含五个自定义斜杠命令：

1. **`/make-model`** - 创建 Eloquent 模型及相关文件
2. **`/make-api`** - 创建完整的 RESTful API 资源
3. **`/run-tests`** - 运行 PHPUnit 测试套件
4. **`/db-inspect`** - 检查数据库模式和运行查询
5. **`/laravel-docs`** - 搜索 Laravel 官方文档

这些命令：
- 提供常用功能的快捷方式
- 封装最佳实践
- 提高开发效率
- 减少重复性工作

通过合理使用这些命令，开发者可以：
- 快速创建模型和 API
- 轻松管理测试
- 便捷查询文档和数据库
- 加速开发流程
