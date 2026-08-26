# 移除前端依赖与配置更新

**日期**: 2026-08-26  
**任务**: 将项目调整为纯 API 后端服务，支持 MySQL 多数据库连接

---

## 📋 需求背景

项目有两个重要变更：
1. **数据库**: 使用 MySQL，不同模块可能使用不同的数据库
2. **架构**: 纯后端 API 服务，不渲染任何服务端模板

---

## 🔄 更改详情

### 1. 数据库配置更新

#### 文件: `.env.example`

**更改内容**:
```diff
- DB_CONNECTION=sqlite
- # DB_HOST=127.0.0.1
- # DB_PORT=3306
- # DB_DATABASE=laravel
- # DB_USERNAME=root
- # DB_PASSWORD=
+ DB_CONNECTION=mysql
+ DB_HOST=127.0.0.1
+ DB_PORT=3306
+ DB_DATABASE=laravel
+ DB_USERNAME=root
+ DB_PASSWORD=
+ 
+ # Additional database connections (for different modules)
+ # DB_LOGS_CONNECTION=mysql_logs
+ # DB_LOGS_HOST=127.0.0.1
+ # DB_LOGS_DATABASE=logs
+ # DB_LOGS_USERNAME=root
+ # DB_LOGS_PASSWORD=
```

**说明**: 默认使用 MySQL，并提供了多数据库连接的配置示例。

---

#### 文件: `.claude/rules/database.md`

**完全重写**，主要内容包括：

- **多数据库连接配置**: 如何在 `config/database.php` 中配置多个数据库连接
- **使用多连接**: 在查询和模型中指定连接的方法
- **MySQL 特性**:
  - 事务支持（`DB::transaction()`）
  - 外键约束
  - JSON 列支持（MySQL 5.7+）
  - 索引优化
- **测试**: 使用内存 SQLite 进行测试
- **常用命令**: 迁移、回滚、状态检查等

**关键代码示例**:
```php
// 指定连接
DB::connection('mysql_logs')->table('audit_logs')->get();

// 模型指定连接
class AuditLog extends Model
{
    protected $connection = 'mysql_logs';
}
```

---

### 2. 纯 API 后端架构配置

#### 文件: `.claude/rules/frontend.md`

**完全重写**，移除了所有 Vite/Tailwind 相关内容，替换为：

- **API-only 设计原则**: 无 Blade 视图，所有响应为 JSON
- **API Resources**: 使用 Eloquent API Resources 转换数据
- **响应格式标准化**: 成功和错误响应的统一格式
- **API 版本控制**: 如何支持多版本 API
- **认证**: Laravel Sanctum/Passport 使用指南
- **CORS 配置**: 为前端应用配置跨域
- **无前端资源**: 明确说明不需要 Vite 构建流程
- **测试 API**: 使用 `getJson()`、`postJson()` 等方法

**关键代码示例**:
```php
// 控制器返回 JSON
public function index(): JsonResponse
{
    $users = User::with('profile')->paginate();

    return response()->json([
        'data' => UserResource::collection($users),
        'meta' => [
            'current_page' => $users->currentPage(),
            'total' => $users->total(),
        ],
    ]);
}
```

---

#### 文件: `.claude/rules/api-development.md` (新建)

**新增文件**，详细的 API 开发指南，包括：

1. **API Resource Pattern**
   - 创建 Resource: `php artisan make:resource UserResource`
   - Resource 实现示例
   - 数据转换最佳实践

2. **Form Request Validation**
   - 创建 Form Request: `php artisan make:request StoreUserRequest`
   - 验证规则定义
   - 授权检查

3. **Controller Structure**
   - RESTful 控制器方法：`index`, `store`, `show`, `update`, `destroy`
   - 完整的控制器示例代码
   - 响应状态码使用

4. **Route Registration**
   - 在 `routes/api.php` 中注册路由
   - API 版本控制
   - 路由组使用

5. **Error Handling**
   - 异常处理器自定义
   - 常见错误响应（404, 422 等）

6. **Pagination**
   - 标准分页响应格式
   - 包含 meta 和 links 信息

7. **API Authentication**
   - Laravel Sanctum 安装和配置
   - Token 生成和撤销

8. **Rate Limiting**
   - 路由中间件配置

9. **Testing API Endpoints**
   - Feature 测试示例
   - JSON 断言方法

---

### 3. 移除前端依赖

#### 删除的文件和目录

```bash
# 删除的文件
- package.json
- vite.config.js

# 删除的目录
- node_modules/
- resources/css/
- resources/js/
- resources/views/
```

**注意**: `resources/` 目录保留，但内容为空，可用于存放其他资源文件。

---

#### 文件: `composer.json`

**更改内容**:
```diff
  "setup": [
      "composer install",
      "@php -r \"file_exists('.env') || copy('.env.example', '.env');\"",
      "@php artisan key:generate",
-     "@php artisan migrate --force",
-     "npm install --ignore-scripts",
-     "npm run build"
+     "@php artisan migrate --force"
  ],
```

```diff
  "post-create-project-cmd": [
      "@php artisan key:generate --ansi",
-     "@php -r \"file_exists('database/database.sqlite') || touch('database/database.sqlite');\"",
      "@php artisan migrate --graceful --ansi"
  ],
```

**说明**: 
- 移除 npm 安装和构建步骤
- 移除 SQLite 数据库文件创建命令

---

#### 文件: `CLAUDE.md`

**更改内容**:
```diff
  ## Database
  
- - SQLite database at `database/database.sqlite`
+ - MySQL database with multi-connection support
+ - Different modules may use different database connections
  - Tests use in-memory SQLite by default
  - Migrations: `php artisan migrate`, `php artisan migrate:fresh`
  
- ## Frontend
- 
- - Vite 8 with Tailwind CSS 4
- - Entry points: `resources/css/app.css`, `resources/js/app.js`
+ ## Architecture
+ 
+ - Pure backend API service (no server-side templates)
+ - All responses are JSON
+ - Frontend is a separate application consuming this API
+ - Use API Resources for response transformation
```

**说明**: 
- 更新数据库说明为 MySQL
- 移除前端部分，替换为架构说明
- 强调纯 API 后端服务

---

### 4. 更新规则索引

#### 文件: `.claude/rules/index.md`

**更改内容**:
```diff
  ## Rule Files
  
  - [`laravel-version.md`](laravel-version.md) - Laravel 13 specific patterns and APIs
  - [`database.md`](database.md) - MySQL database configuration and multi-database support
+ - [`api-development.md`](api-development.md) - API development patterns and best practices
  - [`testing.md`](testing.md) - PHPUnit testing conventions
  - [`frontend.md`](frontend.md) - Pure API backend architecture
  - [`code-style.md`](code-style.md) - PHP code style and Pint configuration
```

**说明**: 添加了新的 `api-development.md` 规则文件到索引中。

---

## 📚 最终规则文件结构

```
.claude/rules/
├── index.md              # 规则索引
├── laravel-version.md    # Laravel 13 特性
├── database.md           # MySQL + 多数据库 ⭐ 更新
├── api-development.md    # API 开发最佳实践 ⭐ 新增
├── testing.md            # PHPUnit 测试
├── frontend.md           # 纯 API 架构 ⭐ 更新
└── code-style.md         # 代码风格
```

---

## 🎯 影响分析

### 正面影响
1. ✅ **项目结构更清晰**: 移除不需要的前端依赖，减少项目复杂度
2. ✅ **配置更准确**: 反映了实际的技术栈（MySQL、纯 API）
3. ✅ **开发指南更完善**: 新增 API 开发最佳实践文档
4. ✅ **多数据库支持**: 为未来模块化开发提供了基础

### 潜在风险
1. ⚠️ **需要更新 .env 文件**: 开发者需要手动更新 `.env` 文件中的数据库配置
2. ⚠️ **需要重新配置认证**: 如需 API 认证，需安装和配置 Sanctum/Passport

---

## 🚀 后续步骤建议

### 1. 安装 API 认证包

```bash
# 使用 Laravel Sanctum (推荐)
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate

# 或使用 Laravel Passport (OAuth2)
composer require laravel/passport
php artisan passport:install
```

### 2. 配置数据库连接

在 `.env` 文件中配置 MySQL 连接：

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### 3. 配置 CORS

编辑 `config/cors.php`，允许前端应用访问：

```php
'allowed_origins' => ['https://your-frontend-app.com'],
```

### 4. 考虑 API 文档工具

推荐安装以下工具之一：

```bash
# Scribe (推荐，自动生成 API 文档)
composer require knuckleswtf/scribe

# 或 Swagger/OpenAPI
composer require darkaonline/l5-swagger
```

---

## ✅ 验证清单

- [x] 移除前端依赖文件（package.json, vite.config.js）
- [x] 删除前端资源目录（resources/css, resources/js, resources/views）
- [x] 更新 composer.json（移除 npm 命令）
- [x] 更新 .env.example（MySQL 配置）
- [x] 更新 CLAUDE.md（架构说明）
- [x] 创建数据库规则文件（database.md）
- [x] 创建 API 开发规则文件（api-development.md）
- [x] 更新前端规则文件（frontend.md）
- [x] 更新规则索引（index.md）
- [x] 运行 Pint 格式化代码

---

## 📝 总结

本次调整成功将项目转换为纯 API 后端服务，移除了不必要的前端依赖，并完善了数据库和 API 开发的相关文档和规则。项目现在具备以下特点：

- **数据库**: MySQL，支持多数据库连接
- **架构**: 纯 API 后端，JSON 响应
- **文档**: 完善的 API 开发指南和最佳实践
- **规范**: 清晰的代码风格和测试规范

所有更改已应用并通过 Pint 格式化验证。项目已准备好进行 API 开发。
