# rules 目录分析

## 目录概述

`.claude/rules/` 目录包含项目特定的规则文件，这些规则为 AI 助手提供细粒度的编码指导和最佳实践。规则文件针对特定技术栈版本和项目特点，确保生成的代码符合项目标准。

## 目录位置

```
/data/project/backend/ai-laravel/.claude/rules/
```

## 目录结构

```
.claude/rules/
├── index.md             # 规则索引
├── laravel-version.md   # Laravel 版本特定规则
├── database.md          # 数据库规则（SQLite）
├── testing.md           # 测试规则（PHPUnit）
├── frontend.md          # 前端规则（Vite + Tailwind CSS 4）
└── code-style.md        # 代码风格规则（Pint）
```

## 规则文件格式

规则文件采用 Markdown 格式，包含：

```markdown
# Rule Title

Description of the rule

## Section 1

- Rule 1
- Rule 2

## Code Examples

```php
// Example code
```
```

---

## 规则详细分析

### 1. index.md（规则索引）

#### 文件内容

```markdown
# Project Rules Index

This directory contains project-specific rules that guide AI assistants when working on this codebase.

## Rule Files

- [`laravel-version.md`](laravel-version.md) - Laravel 13 specific patterns and APIs
- [`database.md`](database.md) - SQLite-specific considerations
- [`testing.md`](testing.md) - PHPUnit testing conventions
- [`frontend.md`](frontend.md) - Frontend stack (Vite + Tailwind CSS 4)
- [`code-style.md`](code-style.md) - PHP code style and Pint configuration

## How Rules Work

Rules are loaded automatically when working in this project. They provide context-specific guidance that supplements the general Laravel best practices.

## Adding New Rules

When you discover patterns or decisions specific to this project:

1. Create a new markdown file in this directory
2. Add a link to it in this index
3. Keep rules concise and actionable
```

#### 作用

- **规则导航**: 提供所有规则文件的索引
- **快速参考**: 列出规则文件及其用途
- **使用说明**: 说明规则如何工作
- **扩展指南**: 指导如何添加新规则

#### 规则加载机制

```
项目启动
    ↓
读取 index.md
    ↓
加载所有规则文件
    ↓
AI 助手获得项目特定指导
    ↓
生成符合规则的代码
```

---

### 2. laravel-version.md（Laravel 版本规则）

#### 基本信息

- **Laravel 版本**: 13.26.1
- **PHP 版本**: 8.4
- **用途**: 版本特定的 API 和模式

#### 关键内容

##### 匿名迁移

Laravel 13 支持匿名迁移，无需类名：

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->timestamps();
        });
    }
};
```

**优势**:
- 简洁：无需类名
- 现代：符合 PHP 7+ 匿名类特性
- 标准：Laravel 11+ 推荐方式

##### 属性转换

使用 `casts()` 方法代替 `$casts` 属性：

```php
// ✅ Laravel 11+ 推荐
protected function casts(): array
{
    return [
        'email_verified_at' => 'datetime',
        'options' => 'array',
    ];
}

// ❌ 旧方式（不推荐）
protected $casts = [
    'email_verified_at' => 'datetime',
    'options' => 'array',
];
```

**原因**:
- 支持依赖注入
- 支持复杂的转换逻辑
- 符合现代 PHP 实践

##### 路由文件

- `routes/web.php` - Web 路由
- `routes/api.php` - API 路由（自动前缀 `/api`）

##### 配置查看

使用 Artisan 命令查看配置：

```bash
php artisan config:show app.name
php artisan config:show database.default
```

#### API 变化（从 Laravel 10/11）

| 特性 | Laravel 10/11 | Laravel 13 |
|-----|--------------|-----------|
| `Route::controller()` | 支持 | 已弃用 |
| `__construct()` 属性提升 | 可选 | 标准 |
| 测试注解 | `@test` | `#[Test]` 属性 |

#### 版本验证

使用 `search-docs` 工具验证 API：

```bash
# 在 AI 对话中
查询 Laravel 13 的 Eloquent 关系语法
```

#### 为什么需要版本规则

- ✅ **避免过时 API**: 不使用已弃用的方法
- ✅ **利用新特性**: 使用最新功能
- ✅ **版本兼容**: 确保代码在当前版本运行
- ✅ **最佳实践**: 遵循官方推荐

---

### 3. database.md（数据库规则）

#### 基本信息

- **数据库引擎**: SQLite
- **数据库位置**: `database/database.sqlite`
- **测试数据库**: 内存数据库 (`:memory:`)

#### SQLite 特性考虑

##### 数据库位置

SQLite 数据库文件位置：

```bash
database/database.sqlite
```

初始化命令：

```bash
touch database/database.sqlite
```

##### SQLite 限制

**1. 外键约束**

SQLite 默认不强制外键，但 Laravel 会启用：

```php
// Laravel 自动启用外键约束
Schema::enableForeignKeyConstraints();
```

**2. ALTER TABLE 限制**

SQLite 的 ALTER TABLE 支持有限：

```php
// ❌ 不支持（需要 doctrine/dbal）
$table->dropColumn('old_column');

// ✅ 推荐方式
// 1. 创建新表
// 2. 迁移数据
// 3. 删除旧表
// 4. 重命名新表
```

**3. 无 JSON 列类型**

使用 `text` 列存储 JSON：

```php
// ✅ 正确
$table->text('options');

// 模型中
protected function casts(): array
{
    return [
        'options' => 'array',
    ];
}

// ❌ SQLite 不支持
$table->json('options');
```

**4. 并发写入**

- 读操作：并发友好
- 写操作：会锁定
- 适用场景：开发环境、低流量生产

##### 测试配置

测试使用内存 SQLite：

```php
// phpunit.xml
<env name="DB_CONNECTION" value="sqlite"/>
<env name="DB_DATABASE" value=":memory:"/>
```

**优势**:
- 快速：内存操作
- 隔离：测试间不共享数据
- 自动清理：测试结束自动清理

##### 迁移注意事项

**兼容性处理**:

```php
// ❌ 避免在 SQLite 上使用
Schema::table('users', function (Blueprint $table) {
    $table->dropColumn('email');
});

// ✅ 使用兼容的方式
// 1. 创建新迁移
// 2. 使用 renameColumn（需 doctrine/dbal）
$table->renameColumn('old', 'new');
```

##### 数据库命令

```bash
# 创建数据库文件
php artisan db --create

# 运行迁移
php artisan migrate

# 重置数据库
php artisan migrate:fresh

# 查看迁移状态
php artisan migrate:status
```

##### Schema 检查

使用 MCP 工具检查：

```bash
# 摘要模式
database-schema --summary

# 详细模式
database-schema --filter=users --include_column_details
```

#### SQLite 最佳实践

| 场景 | 建议 |
|-----|------|
| 开发环境 | ✅ 完美适合 |
| CI/CD | ✅ 快速可靠 |
| 小型生产 | ✅ 可接受 |
| 高并发生产 | ⚠️ 考虑 MySQL/PostgreSQL |

---

### 4. testing.md（测试规则）

#### 基本信息

- **测试框架**: PHPUnit 12.5
- **不使用**: Pest
- **位置**: `tests/Feature` 和 `tests/Unit`

#### 测试创建

```bash
# 功能测试
php artisan make:test ExampleTest

# 单元测试
php artisan make:test ExampleTest --unit
```

#### 测试结构

所有测试应：
- 继承 `Tests\TestCase`
- 使用 `#[Test]` 属性
- 遵循 Arrange-Act-Assert 模式
- 使用描述性的方法名

#### 测试模板

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use PHPUnit\Framework\Attributes\Test;

class AuthenticationTest extends TestCase
{
    #[Test]
    public function user_can_login_with_valid_credentials(): void
    {
        // Arrange
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        // Act
        $response = $this->postJson('/api/login', [
            'email' => 'test@example.com',
            'password' => 'password',
        ]);

        // Assert
        $response->assertOk()
            ->assertJsonStructure(['token']);
    }
}
```

#### 运行测试

```bash
# 所有测试
php artisan test

# 特定文件
php artisan test tests/Feature/ExampleTest.php

# 按名称过滤
php artisan test --filter=test_name

# 紧凑输出
php artisan test --compact

# 并行执行（更快）
php artisan test --parallel
```

#### 测试数据

使用模型工厂：

```php
// 创建单个记录
$user = User::factory()->create();

// 创建多个记录
$users = User::factory()->count(10)->create();

// 使用状态
$admin = User::factory()->admin()->create();
```

使用 Faker：

```php
// 方式1：$this->faker
$name = $this->faker->name();

// 方式2：fake() 助手
$email = fake()->email();
```

#### 常用断言

**HTTP 断言**:
```php
$response->assertOk();                    // 200
$response->assertCreated();               // 201
$response->assertNotFound();              // 404
$response->assertForbidden();             // 403
$response->assertUnauthorized();          // 401
```

**JSON 断言**:
```php
$response->assertJson(['key' => 'value']);
$response->assertJsonStructure(['data' => ['id', 'name']]);
$response->assertJsonPath('data.id', 1);
```

**数据库断言**:
```php
$this->assertDatabaseHas('users', ['email' => 'test@example.com']);
$this->assertDatabaseMissing('users', ['email' => 'deleted@example.com']);
$this->assertDatabaseCount('users', 5);
```

#### Fake 服务

隔离测试外部依赖：

```php
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Event;

Mail::fake();
Queue::fake();
Event::fake();

// 验证邮件已发送
Mail::assertSent(OrderShipped::class);

// 验证队列任务已分发
Queue::assertPushed(ProcessPodcast::class);

// 验证事件已触发
Event::assertDispatched(UserCreated::class);
```

#### 测试最佳实践

| 实践 | 说明 |
|-----|------|
| 快速 | 测试应该快速执行 |
| 隔离 | 测试间不应相互依赖 |
| 明确 | 测试名称应清楚描述意图 |
| 简洁 | 每个测试只验证一件事 |
| 完整 | 覆盖成功、失败和边缘情况 |

---

### 5. frontend.md（前端规则）

#### 基本信息

- **构建工具**: Vite 8.0.0
- **CSS 框架**: Tailwind CSS 4.0.0
- **插件**: @tailwindcss/vite
- **Laravel 集成**: laravel-vite-plugin 3.1

#### 构建命令

```bash
# 开发（热重载）
npm run dev

# 生产构建
npm run build
```

#### 入口点

- **CSS**: `resources/css/app.css`
- **JS**: `resources/js/app.js`

#### Blade 中使用资源

```blade
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>App</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <!-- Content -->
</body>
</html>
```

#### Tailwind CSS 4 配置

Tailwind 4 使用 CSS-first 配置：

```css
/* resources/css/app.css */
@import "tailwindcss";

@theme {
  --color-brand: #your-color;
  --font-family-sans: 'Inter', sans-serif;
}
```

**关键变化**（从 Tailwind 3）:
- ❌ 不再需要 `tailwind.config.js`
- ✅ 使用 CSS `@theme` 指令配置
- ✅ 性能提升
- ✅ 简化设置

#### 开发工作流

**方式1：Laravel 开发服务器（推荐）**

```bash
composer run dev
```
- 包含 PHP 服务器
- 包含 Vite 热重载
- 一键启动

**方式2：分离终端**

```bash
# 终端1：PHP 服务器
php artisan serve

# 终端2：Vite 开发服务器
npm run dev
```

#### 生产部署

```bash
npm run build
```

输出位置：`public/build/`

#### 故障排查

**Vite Manifest 错误**:

```
Illuminate\Foundation\ViteException: Unable to locate file in Vite manifest
```

解决方案：
```bash
npm run build
# 或者运行开发服务器
npm run dev
```

**前端更改不生效**:
1. 确保 Vite 开发服务器运行中
2. 清除浏览器缓存
3. 硬刷新（Ctrl+Shift+R 或 Cmd+Shift+R）

---

### 6. code-style.md（代码风格规则）

#### 基本信息

- **格式化工具**: Laravel Pint
- **PHP 版本**: 8.4
- **风格标准**: Laravel 官方风格

#### Pint 使用

```bash
# 格式化修改的文件
vendor/bin/pint --dirty --format agent

# 格式化特定文件
vendor/bin/pint app/Models/User.php

# 测试模式（CI）
vendor/bin/pint --test
```

#### PHP 8 特性

**构造函数属性提升**:

```php
// ✅ 推荐
public function __construct(
    public string $name,
    protected User $user,
) {}

// ❌ 不推荐
public function __construct()
{
    // 空构造函数
}
```

**命名参数**:

```php
User::create([
    'name' => 'John',
    'email' => 'john@example.com',
]);
```

**Match 表达式**:

```php
$status = match($code) {
    200, 300 => 'success',
    400, 500 => 'error',
    default => 'unknown',
};
```

**Null-safe 操作符**:

```php
$user?->profile?->avatar;
```

**Null 合并赋值**:

```php
$name ??= 'default';
```

#### 类型声明

始终声明类型：

```php
public function getUser(int $id): ?User
{
    return User::find($id);
}

public function process(array $data): void
{
    // ...
}
```

#### PHPDoc 数组形状

```php
/**
 * @param array{id: int, name: string} $data
 * @return array{success: bool, message: string}
 */
public function process(array $data): array
{
    return [
        'success' => true,
        'message' => 'Processed',
    ];
}
```

#### 控制结构

始终使用花括号：

```php
// ✅ 正确
if ($condition) {
    return true;
}

// ❌ 错误
if ($condition) return true;
```

#### 枚举命名

使用 TitleCase：

```php
enum Status: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case PendingApproval = 'pending_approval';
}
```

#### 提交前检查

修改 PHP 文件后始终运行 Pint：

```bash
vendor/bin/pint --dirty --format agent
```

**自动执行**:
通过 PostToolUse 钩子自动执行（已在 `settings.json` 配置）。

---

## 规则对比表

| 规则文件 | 主要内容 | 适用范围 |
|---------|---------|---------|
| `laravel-version.md` | Laravel 13 API、匿名迁移、casts() | 所有 PHP 文件 |
| `database.md` | SQLite 特性、迁移注意事项 | 数据库相关 |
| `testing.md` | PHPUnit 用法、断言、Fake | 测试文件 |
| `frontend.md` | Vite、Tailwind CSS 4、构建 | 前端文件 |
| `code-style.md` | PHP 8 特性、Pint、命名规范 | 所有 PHP 文件 |

---

## 规则应用流程

```
1. AI 助手启动
   ↓
2. 读取 index.md
   ↓
3. 加载所有规则文件
   ↓
4. 分析任务上下文
   ↓
5. 应用相关规则
   ↓
6. 生成符合规范的代码
   ↓
7. 自动格式化（Pint）
```

---

## 添加新规则

### 步骤1：创建规则文件

```markdown
# New Rule Title

Description of the rule

## Guidelines

- Rule 1
- Rule 2

## Examples

```php
// Example code
```
```

### 步骤2：更新索引

在 `index.md` 中添加：

```markdown
- [`new-rule.md`](new-rule.md) - Description
```

### 步骤3：测试规则

创建测试用例验证规则是否正确应用。

---

## 最佳实践

### 1. 保持简洁

```markdown
# ✅ 好
Use `casts()` method instead of `$casts` property.

# ❌ 差
You should consider using the `casts()` method instead of 
the traditional `$casts` property because it offers more 
flexibility and better support for dependency injection...
```

### 2. 提供示例

```markdown
# ✅ 好
```php
protected function casts(): array
{
    return ['options' => 'array'];
}
```

# ❌ 差
Use casts() method.
```

### 3. 针对性

规则应针对项目特定需求，而非通用最佳实践：

```markdown
# ✅ 项目特定
This project uses SQLite. Avoid `DROP COLUMN` in migrations.

# ❌ 通用
Always use meaningful variable names.
```

---

## 总结

`.claude/rules/` 目录包含六个规则文件：

1. **`index.md`** - 规则索引和使用指南
2. **`laravel-version.md`** - Laravel 13 版本特定规则
3. **`database.md`** - SQLite 数据库规则
4. **`testing.md`** - PHPUnit 测试规则
5. **`frontend.md`** - Vite + Tailwind CSS 4 前端规则
6. **`code-style.md`** - PHP 8 代码风格规则

这些规则：
- 针对项目技术栈定制
- 确保版本兼容性
- 遵循最佳实践
- 提供具体示例

通过这些规则，AI 助手能够：
- 生成符合 Laravel 13 规范的代码
- 正确使用 SQLite 特性
- 编写高质量的 PHPUnit 测试
- 使用现代 PHP 8 语法
- 构建 Tailwind CSS 4 前端

规则文件是项目知识库的核心组成部分，它们将项目特定的决策和最佳实践文档化，确保代码质量和一致性。
