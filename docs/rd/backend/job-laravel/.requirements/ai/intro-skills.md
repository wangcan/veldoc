# skills 目录分析

## 目录概述

`.claude/skills/` 目录包含领域特定的技能文件，这些技能是专门化的知识库，为 AI 助手提供深度专业知识和最佳实践指导。与规则文件不同，技能更侧重于特定领域的完整知识体系。

## 目录位置

```
/data/project/backend/ai-laravel/.claude/skills/
```

## 目录结构

```
.claude/skills/
├── infer-conventions/
│   ├── SKILL.md                    # 技能定义
│   └── references/
│       └── checklist.md            # 检测清单
├── laravel-best-practices/
│   ├── SKILL.md                    # 技能定义
│   └── rules/
│       ├── advanced-queries.md     # 高级查询
│       ├── architecture.md         # 架构设计
│       ├── blade-views.md          # Blade 视图
│       ├── caching.md              # 缓存策略
│       ├── collections.md          # 集合操作
│       ├── config.md               # 配置管理
│       ├── db-performance.md       # 数据库性能
│       ├── eloquent.md             # Eloquent ORM
│       ├── error-handling.md       # 错误处理
│       ├── events-notifications.md # 事件通知
│       ├── http-client.md          # HTTP 客户端
│       ├── mail.md                 # 邮件系统
│       ├── migrations.md           # 数据库迁移
│       ├── queue-jobs.md           # 队列任务
│       ├── routing.md              # 路由设计
│       ├── scheduling.md           # 任务调度
│       ├── security.md             # 安全实践
│       ├── style.md                # 代码风格
│       ├── testing.md              # 测试实践
│       └── validation.md           # 数据验证
└── tailwindcss-development/
    └── SKILL.md                    # 技能定义
```

## 技能文件格式

每个技能都有一个主文件 `SKILL.md`，包含前置元数据：

```markdown
---
name: skill-name
description: "Skill description"
license: MIT
metadata:
  author: laravel
---

# Skill Title

Skill content and instructions...
```

---

## 技能详细分析

### 1. Infer Conventions（推断约定）

**目录**: `infer-conventions/`

#### 基本信息

- **名称**: `infer-conventions`
- **用途**: 分析应用程序的实际编码风格并记录为共享规则
- **触发时机**: 
  - 检测、推断、文档化或标准化项目约定
  - 设置或扩展 `.ai/rules`
  - 解决混合或冲突模式
  - 团队成员入职培训

#### 核心功能

**1. 系统性约定检测**

扫描约 49 个 Laravel 约定维度：
- 验证（Validation）
- 模型（Models）
- 架构（Architecture）
- 测试（Testing）
- 前端（Frontend）
- 数据库（Database）
- 控制台（Console）

**2. 房屋模式发现**

识别项目特定的模式：
- 基础类和抽象类
- 通用的 traits
- 租户或授权作用域
- 命名方案
- 自定义助手函数

**3. 冲突报告**

检测并报告：
- 混合风格
- 竞争模式
- 不一致的实现

**4. 规则记录**

使用 `record-rule` MCP 工具将规则保存到 `.ai/rules`。

#### 工作流程

```
步骤0：定位
├── 读取 composer.json
├── 检查 Pint/PHPStan/Rector 配置
├── 读取 .ai/rules/index.md
└── 映射 app/ 目录树

步骤1：预定义扫描
├── 打开 references/checklist.md
├── 使用搜索提示处理每个维度
└── 给出裁决：Pattern | Conflict | Default | No signal | Tooling-owned

步骤2：开放式检查
├── 确认非默认 app/ 目录的用法
├── 寻找项目独特特征
└── 记录真实结构模式

步骤3：确认
├── 批量展示所有候选
├── 用户批准/拒绝
└── 冲突询问/推迟

步骤4：记录
├── 调用 record-rule
├── 选择适当的 glob
└── 写入规则（去除检测证据）

步骤5：总结
├── 列出已记录规则
├── 报告冲突
└── 提醒提交 .ai/rules
```

#### 基本原则

**1. 一致性优先**

代码库的大多数风格就是约定，不评判，不提出"更好"模式。

**2. 记录决策，非默认**

一致的模式只有在反映选择时才值得记录：
- 应用选择了一个有效选项
- 模式会令有能力的代理惊讶

**3. 架构选择是黄金**

记录存在和故意缺失：
- Action 类及其调用方式
- 服务对象
- DTO（spatie/laravel-data vs readonly classes）
- Form Request vs inline 验证
- 事件监听器 vs 直接调用

**4. 无重复**

先读取 `.ai/rules/index.md`，已覆盖的维度标记为完成并跳过。

#### 检测清单维度

检查清单包含 49 个维度，分为 10 组：

**A. 验证 & HTTP 输入**
- 验证入口点
- 自定义规则位置
- 类型化输入获取
- 自定义消息/属性

**B. 控制器 & 路由**
- 控制器形状
- 业务逻辑位置
- 路由处理器风格
- 中间件分配
- 路由模型绑定
- 限流

**C. 授权**
- 授权主页
- 授权调用站点

**D. Eloquent & 模型**
- 批量赋值
- 访问器/修改器
- 主键类型
- 自定义转换
- 数据/查询层
- 查询作用域
- 模型事件
- 预加载姿态

**E. 架构 & 组织**
- Action/Service 结构
- DTOs
- 依赖获取
- 解耦方式
- 助手 vs Facade 惯用语
- 命名空间布局
- 枚举

**F. 前端 & 视图**
- 前端栈
- Blade 组合
- 本地化

**G. 数据库 & 迁移**
- 外键
- down() 方法
- 枚举存储
- 事务
- 幂等写入

**H. 测试**
- 框架
- DB 重置
- Fixtures
- 协作者隔离
- 端点断言

**I. 响应 & API 资源**
- 响应形状
- 资源关系包含
- 分页契约
- Web 重定向/URLs

**J. 字符串、集合 & 日期**
- 迭代惯用语
- 字符串 API
- 日期

#### 使用场景

```bash
# 场景：新项目入职
用户：推断这个项目的编码约定

Infer Conventions 会：
1. 扫描整个代码库
2. 检测验证、模型、架构等约定
3. 报告发现的模式
4. 记录到 .ai/rules
5. 生成总结报告
```

#### 为什么使用此技能

- ✅ **团队知识共享**: 新成员快速了解项目风格
- ✅ **AI 上下文**: AI 助手理解项目约定
- ✅ **一致性保障**: 新代码遵循现有风格
- ✅ **决策记录**: 持久化架构决策

---

### 2. Laravel Best Practices（Laravel 最佳实践）

**目录**: `laravel-best-practices/`

#### 基本信息

- **名称**: `laravel-best-practices`
- **用途**: 编写、审查或重构 Laravel PHP 代码的最佳实践
- **触发时机**: 
  - 创建或修改控制器、模型、迁移等
  - N+1 和查询性能问题
  - 授权和安全模式
  - 架构决策

#### 核心原则

**1. 一致性优先**

检查应用已有的做法，遵循现有模式，不引入第二种方式。

**2. 最小变更**

做最小连贯的更改，保持应用的架构和命名。

**3. 版本验证**

使用 `search-docs` 验证版本敏感的 Laravel API。

#### 规则索引

该技能包含 20 个规则文件：

| 关注点 | 规则文件 |
|-------|---------|
| 查询计数、预加载、索引、大数据集 | `db-performance.md` |
| 子查询、聚合、复杂排序和查询计划 | `advanced-queries.md` |
| 模型、关系、作用域、类型转换 | `eloquent.md` |
| 认证、授权、输入安全、机密、上传 | `security.md` |
| Form Requests 和验证规则 | `validation.md` |
| 控制器、路由绑定、资源、中间件 | `routing.md` |
| 模式变更、列、外键、索引 | `migrations.md` |
| 任务、重试、唯一性、批次、Horizon | `queue-jobs.md` |
| 缓存生命周期、失效、锁、记忆化 | `caching.md` |
| 出站请求、重试、超时、fakes | `http-client.md` |
| 异常、报告、渲染、日志上下文 | `error-handling.md` |
| 事件和通知 | `events-notifications.md` |
| Mailables 和邮件断言 | `mail.md` |
| 计划任务和重叠保护 | `scheduling.md` |
| 集合、惰性迭代、批量操作 | `collections.md` |
| Blade 组件、属性、composers | `blade-views.md` |
| 环境值和应用配置 | `config.md` |
| Pest/PHPUnit 模式、工厂、fakes | `testing.md` |
| 命名、助手、文件边界、PHP 风格 | `style.md` |
| Actions、services、依赖、应用结构 | `architecture.md` |

#### 应用流程

```
1. 检查变更文件和项目配置
   ├── 查看已建立的模式
   └── 仅在正确性或安全缺陷时偏离

2. 映射关注点到规则索引
   ├── 读取每个映射的规则文件
   └── 跳过无关规则文件

3. 做最小连贯更改
   └── 保持架构和命名

4. 验证版本敏感 API
   └── 使用 search-docs

5. 运行最窄相关测试
   └── 格式化和静态分析

6. 重读差异对比每个映射规则
   └── 确保符合规则
```

#### 关键规则示例

**数据库性能**:

```php
// ❌ N+1 查询问题
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name;
}

// ✅ 预加载
$posts = Post::with('author')->get();
foreach ($posts as $post) {
    echo $post->author->name;
}
```

**Eloquent 最佳实践**:

```php
// ❌ 硬编码表名
DB::table('users')->where('active', true)->get();

// ✅ 使用模型
User::where('active', true)->get();
```

**架构设计**:

```php
// ❌ 服务定位
$service = app(OrderService::class);

// ✅ 依赖注入
public function __construct(private OrderService $service) {}
```

#### 决策规则

- 优先使用框架功能和现有抽象
- 避免投机性抽象
- 避免在 Blade 视图中访问数据库
- 防止隐藏的 N+1 查询

#### 使用场景

```bash
# 场景：创建新控制器
用户：创建一个 ProductController

Laravel Best Practices 会：
1. 检查现有控制器模式
2. 应用路由规则
3. 确保授权检查
4. 防止 N+1 查询
5. 遵循项目约定
```

#### 为什么使用此技能

- ✅ **代码质量**: 确保遵循最佳实践
- ✅ **性能优化**: 防止 N+1 和其他性能问题
- ✅ **安全性**: 实施授权和安全模式
- ✅ **一致性**: 遵循项目现有模式

---

### 3. Tailwind CSS Development（Tailwind CSS 开发）

**目录**: `tailwindcss-development/`

#### 基本信息

- **名称**: `tailwindcss-development`
- **用途**: Tailwind CSS 样式开发
- **触发时机**: 
  - 用户消息包含 'tailwind'
  - 构建响应式网格布局
  - 样式化 UI 组件
  - 添加暗色模式变体
  - 修复间距或排版

#### 核心功能

**1. Tailwind CSS v4 支持**

- 使用最新版本
- CSS-first 配置
- 避免已弃用的工具类

**2. 响应式设计**

- Flexbox 布局
- Grid 布局
- 响应式变体

**3. 暗色模式**

- 支持 `dark:` 变体
- 遵循项目现有模式

#### Tailwind CSS v4 特性

**CSS-First 配置**:

```css
/* resources/css/app.css */
@import "tailwindcss";

@theme {
  --color-brand: oklch(0.72 0.11 178);
}
```

**不再需要 `tailwind.config.js`**。

**导入语法变化**:

```css
/* ❌ Tailwind v3 */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* ✅ Tailwind v4 */
@import "tailwindcss";
```

**已替换的工具类**:

| 已弃用 | 替代 |
|--------|------|
| `bg-opacity-*` | `bg-black/*` |
| `flex-shrink-*` | `shrink-*` |
| `overflow-ellipsis` | `text-ellipsis` |

#### 常用模式

**Flexbox 布局**:

```html
<div class="flex items-center justify-between gap-4">
    <div>左侧内容</div>
    <div>右侧内容</div>
</div>
```

**Grid 布局**:

```html
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
    <div>卡片 1</div>
    <div>卡片 2</div>
    <div>卡片 3</div>
</div>
```

**暗色模式**:

```html
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
    内容自适应颜色方案
</div>
```

#### 使用指南

**间距**:

使用 `gap` 工具类而不是 margin：

```html
<!-- ✅ 推荐 -->
<div class="flex gap-8">
    <div>项目 1</div>
    <div>项目 2</div>
</div>

<!-- ❌ 不推荐 -->
<div class="flex">
    <div class="mr-8">项目 1</div>
    <div>项目 2</div>
</div>
```

#### 常见陷阱

- 使用已弃用的 v3 工具类
- 使用 `@tailwind` 指令而非 `@import "tailwindcss"`
- 尝试使用 `tailwind.config.js` 而非 CSS `@theme` 指令
- 为兄弟元素使用 margin 而非 gap
- 项目使用暗色模式时忘记添加暗色变体

#### 使用场景

```bash
# 场景：创建响应式卡片网格
用户：创建一个 3 列的产品卡片网格

Tailwind CSS Development 会：
1. 使用 Grid 布局
2. 添加响应式断点
3. 设置适当的间距
4. 添加暗色模式支持（如项目使用）
```

#### 为什么使用此技能

- ✅ **版本正确**: 使用 Tailwind v4 语法
- ✅ **响应式**: 实现现代响应式设计
- ✅ **一致性**: 遵循项目现有样式
- ✅ **最佳实践**: 避免常见陷阱

---

## 技能对比表

| 技能 | 专长 | 规则文件数 | 主要用途 |
|-----|------|----------|---------|
| `infer-conventions` | 约定推断 | 1 (checklist) | 项目入职、知识提取 |
| `laravel-best-practices` | Laravel 最佳实践 | 20 | 代码质量、性能优化 |
| `tailwindcss-development` | Tailwind CSS | 0 | 前端样式、响应式设计 |

---

## 技能激活机制

### 自动激活

技能根据上下文自动激活：

```bash
# 检测到数据库相关 → 自动激活 laravel-best-practices
用户：创建一个 Product 模型

# 检测到 Tailwind → 自动激活 tailwindcss-development
用户：用 Tailwind 创建一个卡片组件

# 检测到约定提取 → 自动激活 infer-conventions
用户：分析这个项目的编码约定
```

### 手动激活

通过 Skill 工具手动激活：

```bash
/skill infer-conventions
/skill laravel-best-practices
/skill tailwindcss-development
```

---

## 技能与规则的关系

### 层级关系

```
CLAUDE.md (顶层指令)
    ↓
Skills (领域专业知识)
    ↓
Rules (项目特定规则)
    ↓
代码实现
```

### 区别

| 特性 | 技能 | 规则 |
|-----|------|------|
| 范围 | 领域知识 | 项目特定 |
| 粒度 | 全面、系统 | 简洁、针对 |
| 触发 | 自动或手动 | 总是加载 |
| 内容 | 最佳实践、示例 | 项目决策、约定 |

### 协作示例

```bash
创建 User 模型时：

1. CLAUDE.md 提供基础指导
   ↓
2. laravel-best-practices 技能提供 Eloquent 最佳实践
   ↓
3. database.md 规则提供 SQLite 特定指导
   ↓
4. 生成符合所有层级的代码
```

---

## 扩展技能

### 创建新技能

```markdown
---
name: custom-skill
description: "Custom skill description"
license: MIT
metadata:
  author: team-name
---

# Custom Skill

## Purpose

Description of what this skill does.

## Guidelines

- Guideline 1
- Guideline 2

## Examples

```php
// Example code
```
```

### 组织规则文件

技能可以包含多个规则文件：

```
custom-skill/
├── SKILL.md
└── rules/
    ├── rule1.md
    ├── rule2.md
    └── rule3.md
```

---

## 最佳实践

### 1. 正确触发

只在相关上下文中激活技能：

```bash
# ✅ 正确
用户：优化这个查询 → laravel-best-practices

# ❌ 错误
用户：修复 CSS 样式 → laravel-best-practices（不相关）
```

### 2. 遵循技能指导

技能提供的是经过验证的最佳实践，应认真遵循。

### 3. 结合项目规则

技能是通用最佳实践，需要与项目特定规则结合使用。

### 4. 及时更新

项目演进时，更新技能内容以反映最新实践。

---

## 总结

`.claude/skills/` 目录包含三个领域特定技能：

1. **`infer-conventions`** - 项目约定推断和分析
   - 扫描 49 个约定维度
   - 检测冲突和不一致
   - 记录到 `.ai/rules`

2. **`laravel-best-practices`** - Laravel 最佳实践库
   - 20 个规则文件
   - 覆盖 Eloquent、性能、安全、架构等
   - 确保代码质量和性能

3. **`tailwindcss-development`** - Tailwind CSS v4 开发
   - 现代响应式设计
   - CSS-first 配置
   - 避免已弃用 API

这些技能：
- 提供深度专业知识
- 自动应用于相关上下文
- 与项目规则协同工作
- 提高代码质量和一致性

技能是 Claude Code 智能化的重要组成部分，它们将领域专家的知识编码为可执行的指导原则，使 AI 助手能够生成高质量、符合最佳实践的代码。
