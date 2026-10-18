# agents 目录分析

## 目录概述

`.claude/agents/` 目录包含自定义子代理（subagents）的定义文件。这些代理是专门化的 AI 助手，针对特定类型的任务进行优化，提供更专业和高效的服务。

## 目录位置

```
/data/project/backend/ai-laravel/.claude/agents/
```

## 目录结构

```
.claude/agents/
├── migration-specialist.md    # 数据库迁移专家
├── test-writer.md             # 测试编写专家
├── api-builder.md             # API 构建专家
└── model-architect.md         # 模型架构师
```

## 代理文件格式

每个代理文件都采用以下标准格式：

```markdown
---
name: agent-name
description: Agent description
model: sonnet | opus | haiku
tools:
  - Tool1
  - Tool2
  - ...
---

# Agent Title

Agent instructions and guidelines...
```

### 前置元数据

| 字段 | 说明 | 示例 |
|-----|------|------|
| `name` | 代理唯一标识符 | `migration-specialist` |
| `description` | 代理功能描述 | 创建和管理数据库迁移 |
| `model` | 使用的 AI 模型 | `sonnet`（默认）、`opus`、`haiku` |
| `tools` | 可用工具列表 | `Bash`, `Read`, `Edit`, `Write` 等 |

---

## 代理详细分析

### 1. Migration Specialist（迁移专家）

**文件**: `migration-specialist.md`

#### 基本信息

- **名称**: `migration-specialist`
- **模型**: Sonnet
- **专长**: 数据库迁移和模式设计

#### 可用工具

```yaml
tools:
  - Bash
  - Read
  - Edit
  - Write
  - mcp__laravel-boost__database-schema
  - mcp__laravel-boost__database-query
```

#### 职责范围

1. **创建新迁移**
   - 遵循 Laravel 约定
   - 使用 `php artisan make:migration`

2. **设计数据库模式**
   - 合理的列类型选择
   - 索引优化
   - 外键约束

3. **管理复杂变更**
   - 重命名列/表
   - 修改列类型
   - 删除列/表

4. **确保可逆性**
   - 实现 `up()` 和 `down()` 方法
   - 测试迁移回滚

#### 工作流程

```
1. 理解需求 → 分析数据模型
2. 检查现有模式 → database-schema 工具
3. 设计模式 → 规划列、索引、外键
4. 创建迁移 → php artisan make:migration
5. 实现 → 编写 up() 和 down()
6. 验证 → 测试迁移执行和回滚
```

#### 关键指导原则

- 使用 `php artisan make:migration` 创建迁移文件
- 为 WHERE 子句和 JOIN 的列添加索引
- 合理使用外键约束
- 一个迁移专注于一件事
- 始终提供可逆的 `down()` 方法
- 考虑 SQLite 兼容性

#### Laravel 13 特性

- 支持匿名迁移（无需类名）
- 使用 `$table->id()` 简写
- 使用 `$table->foreignIdFor(Model::class)` 创建外键

#### 使用场景示例

```bash
# 场景：创建用户表
用户：我需要创建一个 users 表

Migration Specialist 会：
1. 分析需求（用户名、邮箱、密码等字段）
2. 检查是否已存在 users 表
3. 创建包含适当索引和外键的迁移
4. 确保 down() 方法正确实现
5. 验证迁移可以正常运行
```

---

### 2. Test Writer（测试编写专家）

**文件**: `test-writer.md`

#### 基本信息

- **名称**: `test-writer`
- **模型**: Sonnet
- **专长**: PHPUnit 测试编写

#### 可用工具

```yaml
tools:
  - Bash
  - Read
  - Edit
  - Write
```

#### 职责范围

1. **编写 PHPUnit 测试类**
   - 功能测试（Feature Tests）
   - 单元测试（Unit Tests）
   - API 测试

2. **设计测试数据**
   - 使用模型工厂
   - 创建测试 fixtures

3. **确保覆盖率**
   - 成功路径（Happy Paths）
   - 边缘情况（Edge Cases）
   - 失败场景（Failure Scenarios）

#### 工作流程

```
1. 分析代码 → 理解被测代码
2. 识别测试用例 → 列出所有场景
3. 创建测试文件 → php artisan make:test
4. 编写测试 → 实现测试方法
5. 使用工厂 → 创建测试数据
6. 运行测试 → 确保通过
```

#### 测试结构模板

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use PHPUnit\Framework\Attributes\Test;

class ExampleTest extends TestCase
{
    #[Test]
    public function test_name_describes_what_is_tested(): void
    {
        // Arrange - 准备
        $user = User::factory()->create();

        // Act - 执行
        $response = $this->actingAs($user)
            ->getJson('/api/endpoint');

        // Assert - 断言
        $response->assertOk()
            ->assertJsonStructure(['data']);
    }
}
```

#### 常用断言

**HTTP 断言**:
- `assertOk()` - 200 状态
- `assertCreated()` - 201 状态
- `assertNotFound()` - 404 状态
- `assertForbidden()` - 403 状态

**JSON 断言**:
- `assertJson()` - JSON 内容
- `assertJsonStructure()` - JSON 结构
- `assertJsonPath()` - JSON 路径

**数据库断言**:
- `assertDatabaseHas()` - 数据存在
- `assertDatabaseMissing()` - 数据不存在
- `assertDatabaseCount()` - 数据计数

#### 关键指导原则

- 使用 `php artisan make:test NameTest` 创建功能测试
- 使用 `--unit` 标志创建单元测试
- 遵循 Arrange-Act-Assert 模式
- 使用描述性的测试方法名
- 使用 `$this->faker` 或 `fake()` 生成测试数据
- 测试成功和失败场景
- 使用 `actingAs()` 处理认证路由

#### 使用场景示例

```bash
# 场景：测试用户登录 API
用户：为登录 API 编写测试

Test Writer 会：
1. 分析登录 API 的业务逻辑
2. 创建测试文件 LoginTest.php
3. 编写测试用例：
   - 有效凭据登录成功
   - 无效凭据登录失败
   - 缺少字段验证错误
4. 使用工厂创建测试用户
5. 运行测试确保通过
```

---

### 3. API Builder（API 构建专家）

**文件**: `api-builder.md`

#### 基本信息

- **名称**: `api-builder`
- **模型**: Sonnet
- **专长**: RESTful API 构建

#### 可用工具

```yaml
tools:
  - Bash
  - Read
  - Edit
  - Write
  - mcp__laravel-boost__search-docs
```

#### 职责范围

1. **设计 RESTful API**
   - 遵循 REST 约定
   - 合理的端点设计

2. **创建 API 控制器**
   - CRUD 操作
   - 资源转换

3. **实现请求验证**
   - Form Request
   - 内联验证

4. **配置路由和中间件**
   - API 路由定义
   - 认证和授权

#### RESTful 约定

| HTTP 方法 | URI | Action | 用途 |
|----------|-----|--------|------|
| GET | `/api/resource` | index | 列表 |
| POST | `/api/resource` | store | 创建 |
| GET | `/api/resource/{id}` | show | 详情 |
| PUT/PATCH | `/api/resource/{id}` | update | 更新 |
| DELETE | `/api/resource/{id}` | destroy | 删除 |

#### 工作流程

```
1. 设计 API → 规划端点
2. 创建控制器 → php artisan make:controller --api
3. 定义路由 → routes/api.php
4. 创建资源 → API Resources
5. 添加验证 → Form Requests
6. 编写测试 → 确保功能正确
```

#### 控制器示例

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $users = User::query()
            ->when($request->search, fn($q, $search) => 
                $q->where('name', 'like', "%{$search}%")
            )
            ->paginate($request->per_page ?? 15);

        return UserResource::collection($users)
            ->response();
    }

    public function show(User $user): JsonResponse
    {
        return UserResource::make($user)
            ->response();
    }
}
```

#### 关键指导原则

- 使用 API Resources 进行一致的响应格式化
- 版本化 API：`Api/V1/`、`Api/V2/`
- 使用路由模型绑定
- 使用 Policies 实现授权
- 返回适当的 HTTP 状态码
- 列表端点包含分页
- 使用限流中间件

#### 使用场景示例

```bash
# 场景：创建产品 API
用户：为产品创建完整的 RESTful API

API Builder 会：
1. 规划 API 端点（列表、详情、创建、更新、删除）
2. 创建 ProductController（API 控制器）
3. 定义 API 路由
4. 创建 ProductResource（资源转换）
5. 创建 StoreProductRequest 和 UpdateProductRequest（验证）
6. 添加认证和授权
7. 编写 API 测试
```

---

### 4. Model Architect（模型架构师）

**文件**: `model-architect.md`

#### 基本信息

- **名称**: `model-architect`
- **模型**: Sonnet
- **专长**: Eloquent ORM 和模型设计

#### 可用工具

```yaml
tools:
  - Bash
  - Read
  - Edit
  - Write
  - mcp__laravel-boost__database-schema
  - mcp__laravel-boost__database-query
  - mcp__laravel-boost__search-docs
```

#### 职责范围

1. **设计 Eloquent 模型**
   - 定义关系
   - 配置 casts
   - 实现作用域

2. **优化查询性能**
   - 防止 N+1 问题
   - 使用预加载
   - 索引建议

3. **实现高级功能**
   - 访问器和修改器
   - 模型事件
   - 软删除

4. **创建工厂和种子**
   - 测试数据生成
   - 状态定义

#### 关系类型

| 关系类型 | 方法 | 用例 |
|---------|------|------|
| 一对一 | `hasOne()` / `belongsTo()` | 用户-资料 |
| 一对多 | `hasMany()` / `belongsTo()` | 用户-文章 |
| 多对多 | `belongsToMany()` | 用户-角色 |
| 远层一对多 | `hasManyThrough()` | 国家-文章（通过用户）|
| 多态 | `morphOne()` / `morphMany()` | 评论-文章/视频 |

#### 工作流程

```
1. 分析需求 → 理解数据模型和关系
2. 创建模型 → php artisan make:model -mf
3. 定义关系 → belongsTo, hasMany 等
4. 添加作用域 → 创建查询作用域
5. 配置 casts → 定义属性类型转换
6. 创建工厂 → 设计测试工厂
7. 验证模式 → 确保模型匹配数据库
```

#### 模型示例

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'title',
        'content',
        'user_id',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'published_at' => 'datetime',
            'is_published' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    public function scopePublished($query)
    {
        return $query->whereNotNull('published_at')
            ->where('published_at', '<=', now());
    }
}
```

#### 关键指导原则

- 始终预加载关系防止 N+1：`with('relation')`
- 使用 `scopes` 封装可复用的查询逻辑
- 定义 `$fillable` 或使用 `guarded = []`
- 使用属性类型转换处理日期、JSON 和枚举
- 适当使用软删除
- 使用 `php artisan make:model --help` 查看可用选项

#### 使用场景示例

```bash
# 场景：创建博客文章模型
用户：我需要一个 Post 模型，属于用户，有多个评论

Model Architect 会：
1. 分析需求（用户关系、评论关系）
2. 创建 Post 模型和迁移
3. 定义 belongsTo(User::class) 关系
4. 定义 hasMany(Comment::class) 关系
5. 添加 published 作用域
6. 配置日期类型转换
7. 创建 PostFactory 测试工厂
```

---

## 代理使用方式

### 1. 通过 Skill 工具调用

```bash
# 调用迁移专家
/skill migration-specialist

# 调用测试编写专家
/skill test-writer

# 调用 API 构建专家
/skill api-builder

# 调用模型架构师
/skill model-architect
```

### 2. 通过 Agent 工具调用

```json
{
  "subagent_type": "migration-specialist",
  "prompt": "创建一个 users 表的迁移"
}
```

### 3. 自动激活

根据任务上下文，Claude Code 会自动激活合适的代理：

- 检测到数据库迁移任务 → Migration Specialist
- 检测到测试编写任务 → Test Writer
- 检测到 API 开发任务 → API Builder
- 检测到模型设计任务 → Model Architect

---

## 代理对比表

| 代理 | 专长 | 主要工具 | 典型场景 |
|-----|------|---------|---------|
| Migration Specialist | 数据库迁移 | database-schema, database-query | 创建表、修改模式 |
| Test Writer | PHPUnit 测试 | Bash, Read, Edit, Write | 编写功能/单元测试 |
| API Builder | RESTful API | search-docs | 创建 API 端点 |
| Model Architect | Eloquent ORM | database-schema, database-query, search-docs | 设计模型和关系 |

---

## 最佳实践

### 1. 选择合适的代理

根据任务类型选择专门的代理：

```bash
# 数据库相关 → migration-specialist
用户：创建一个新表

# 测试相关 → test-writer
用户：为这个功能编写测试

# API 相关 → api-builder
用户：创建一个 RESTful API

# 模型相关 → model-architect
用户：设计用户模型及其关系
```

### 2. 组合使用代理

复杂任务可以组合多个代理：

```
任务：创建完整的用户管理功能

步骤：
1. Model Architect → 设计 User 模型
2. Migration Specialist → 创建 users 表迁移
3. API Builder → 创建用户 API 端点
4. Test Writer → 编写 API 测试
```

### 3. 自定义代理

可以创建新的代理文件：

```markdown
---
name: custom-agent
description: Custom agent description
model: sonnet
tools:
  - Bash
  - Read
  - Edit
  - Write
---

# Custom Agent

Instructions for the custom agent...
```

---

## 总结

`.claude/agents/` 目录包含四个专门化的子代理：

1. **Migration Specialist** - 数据库迁移和模式设计专家
2. **Test Writer** - PHPUnit 测试编写专家
3. **API Builder** - RESTful API 构建专家
4. **Model Architect** - Eloquent 模型设计专家

这些代理：
- 针对特定领域优化
- 提供专门的工具集
- 遵循最佳实践
- 提高开发效率和代码质量

通过使用这些专门化代理，AI 助手能够提供更专业、更符合 Laravel 约定的代码，减少错误和返工。
