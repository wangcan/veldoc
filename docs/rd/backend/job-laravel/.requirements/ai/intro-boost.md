# Laravel Boost 模块分析

## 模块概述

**Laravel Boost** 是由 Laravel 官方团队开发的 MCP（Model Context Protocol）服务器，专为 Laravel 应用设计。它为 AI 编程助手（如 Claude Code）提供深度集成能力，使 AI 能够更好地理解、操作和生成 Laravel 代码。

### 版本信息
- 当前版本：`2.5.5`
- Composer 包名：`laravel/boost`

---

## Boost 提供的工具

Boost 通过 MCP 协议向 AI 助手提供以下工具：

| 工具名称 | 功能描述 | 使用场景 |
|---------|---------|---------|
| `application-info` | 获取应用信息（PHP 版本、Laravel 版本、已安装包） | 会话开始时了解项目环境 |
| `database-schema` | 读取数据库结构（表、列、索引、外键） | 编写迁移、模型前查看表结构 |
| `database-query` | 执行只读 SQL 查询 | 调试数据、验证查询结果 |
| `database-connections` | 列出数据库连接配置 | 了解数据库配置 |
| `browser-logs` | 读取浏览器日志 | 调试前端错误 |
| `read-log-entries` | 读取应用日志 | 调试后端错误 |
| `last-error` | 获取最近的错误/异常 | 快速定位问题 |
| `get-absolute-url` | 获取绝对 URL | 生成正确的项目 URL |
| `search-docs` | 搜索 Laravel 文档 | 查询版本特定的 API 文档 |
| `record-rule` | 记录项目规则 | 保存约定到 `.ai/rules` |

---

## Boost 在 AI 编程中的生效机制

### 1. 启动时加载

当 Claude Code 启动时，会自动检测项目中的 Boost 配置：

```
项目启动
    ↓
检测 composer.json 中的 laravel/boost
    ↓
加载 MCP 服务器配置
    ↓
注册 Boost 工具到 AI 助手
    ↓
AI 助手可以使用 Boost 工具
```

### 2. 配置位置

Boost 的 MCP 配置通常位于：
- Claude Desktop: `claude_desktop_config.json`
- Claude Code CLI: 项目 `.claude/` 目录

### 3. 工具调用流程

```
AI 助手识别任务
    ↓
选择合适的 Boost 工具
    ↓
通过 MCP 协议调用工具
    ↓
Boost 在 Laravel 应用上下文中执行
    ↓
返回结果给 AI 助手
    ↓
AI 助手基于结果生成代码
```

---

## Boost 的作用

### 1. 代码生成增强

**数据库感知**
```
传统方式: AI 手动读取 migration 文件推测表结构
Boost 方式: 直接查询 database-schema 获取精确结构
```

**版本感知**
```
传统方式: AI 可能使用过时的 API
Boost 方式: search-docs 返回当前安装版本的正确文档
```

### 2. 调试效率提升

| 场景 | 传统方式 | Boost 方式 |
|------|---------|-----------|
| 查看错误 | 手动打开 storage/logs/laravel.log | `last-error` 一键获取 |
| 前端调试 | 浏览器控制台 | `browser-logs` 直接读取 |
| 数据验证 | 编写 tinker 脚本 | `database-query` 直接查询 |

### 3. 约定管理

Boost 的 `record-rule` 工具支持：

```
分析项目约定
    ↓
识别编码模式
    ↓
记录到 .ai/rules/
    ↓
团队共享约定
    ↓
新 AI 会话自动加载
```

### 4. 文档搜索

`search-docs` 工具的优势：

- **版本精确**：返回当前安装版本的文档
- **语义搜索**：理解查询意图
- **多包支持**：Laravel、Inertia、Pest、Livewire、Filament 等

---

## Boost 与 CLAUDE.md 的关系

### CLAUDE.md 中的 Boost 规则

```markdown
## Boost Rules
- 优先使用 Boost 工具而非 shell 命令
- 使用 search-docs 查询版本特定文档
- 使用 database-schema 查看表结构
- 使用 record-rule 记录项目规则
```

### 生效流程

```
CLAUDE.md 加载
    ↓
AI 助手读取 Boost 规则
    ↓
遇到数据库查询任务
    ↓
优先选择 database-schema 工具
    ↓
而非手动读取 migration 文件
```

---

## Boost 与 Skills 的关系

### infer-conventions 技能

```
infer-conventions 分析项目
    ↓
发现编码约定
    ↓
调用 record-rule MCP 工具
    ↓
保存到 .ai/rules/
```

### laravel-best-practices 技能

```
编写 Laravel 代码
    ↓
需要查询 API
    ↓
调用 search-docs 工具
    ↓
获取版本正确的文档
```

---

## Boost 工具使用示例

### 1. 获取应用信息

```php
// AI 调用
mcp__laravel-boost__application-info()

// 返回
{
  "php_version": "8.4",
  "laravel_version": "13.26.1",
  "database_engine": "sqlite",
  "packages": [...]
}
```

### 2. 查看数据库结构

```php
// AI 调用
mcp__laravel-boost__database-schema(summary: true)

// 返回表名和列类型概览
```

### 3. 执行只读查询

```php
// AI 调用
mcp__laravel-boost__database-query(query: "SELECT COUNT(*) FROM users")

// 返回查询结果
```

### 4. 搜索文档

```php
// AI 调用
mcp__laravel-boost__search-docs(
  queries: ["rate limiting", "routing"],
  packages: ["laravel/framework"]
)

// 返回版本匹配的文档片段
```

---

## Boost 的优势

### 1. 减少幻觉
- 直接访问真实数据库结构
- 获取精确的版本信息
- 查询实际的错误日志

### 2. 提高准确性
- 版本特定的 API 文档
- 真实的项目配置
- 实际的代码约定

### 3. 加速开发
- 无需手动读取文件
- 一键获取关键信息
- 自动化约定记录

### 4. 团队协作
- 规则存储在 `.ai/rules/`
- 提交到版本控制
- 团队成员共享约定

---

## 配置示例

### composer.json

```json
{
  "require-dev": {
    "laravel/boost": "^2.5"
  }
}
```

### MCP 配置

```json
{
  "mcpServers": {
    "laravel-boost": {
      "command": "php",
      "args": ["artisan", "boost:mcp"]
    }
  }
}
```

---

## 最佳实践

### 1. 会话开始时
```php
// 首先调用 application-info 了解环境
mcp__laravel-boost__application-info()
```

### 2. 编写模型前
```php
// 查看表结构
mcp__laravel-boost__database-schema(filter: "users")
```

### 3. 查询 API 前
```php
// 搜索版本特定的文档
mcp__laravel-boost__search-docs(queries: ["validation", "form request"])
```

### 4. 调试错误时
```php
// 获取最近的错误
mcp__laravel-boost__last-error()
```

### 5. 发现约定后
```php
// 记录团队约定
mcp__laravel-boost__record-rule(
  glob: "app/Models/**",
  title: "Use UUID primary keys",
  note: "All models use HasUuids trait"
)
```

---

## 总结

Laravel Boost 是连接 AI 助手与 Laravel 应用的桥梁，它通过 MCP 协议提供：

1. **深度集成**：直接访问应用内部状态
2. **版本感知**：确保代码与安装版本兼容
3. **约定管理**：记录和共享编码风格
4. **调试支持**：快速定位和解决问题

在 AI 编程场景中，Boost 显著提高了代码生成的准确性、一致性和效率。
