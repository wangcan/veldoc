# MCP 服务器配置文档

## 概述

MCP (Model Context Protocol) 是一种标准化协议，允许 AI 助手与外部工具和服务进行交互。本项目使用 Laravel 13 + SQLite + Vite + Tailwind CSS 4 技术栈，配置了适合 Laravel 开发的 MCP 服务器。

## 当前已配置的 MCP 服务器

### 1. Laravel Boost MCP (已配置)

**配置路径**: `.mcp.json`

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

**特点**:
- Laravel 官方维护，专为 Laravel 项目设计
- 版本: 0.9.4 (最新)
- 无需额外依赖，通过 Artisan 命令启动
- 深度集成 Laravel 生态系统

**核心工具**:

| 工具名称 | 功能描述 | 使用场景 |
|---------|---------|---------|
| `application-info` | 获取应用信息（PHP版本、Laravel版本、依赖包） | 项目初始化、环境检查 |
| `database-query` | 执行只读SQL查询 | 数据分析、调试 |
| `database-schema` | 查看数据库表结构和元数据 | 编写迁移、设计模型 |
| `database-connections` | 列出数据库连接配置 | 多数据库项目 |
| `get-absolute-url` | 获取项目的绝对URL地址 | 生成正确的URL |
| `browser-logs` | 读取浏览器日志和错误 | 前端调试 |
| `last-error` | 获取最后的应用错误 | 快速定位问题 |
| `read-log-entries` | 读取应用日志条目 | 日志分析 |
| `search-docs` | 搜索Laravel生态文档 | 查询API用法 |
| `record-rule` | 记录项目规则到 `.ai/rules` | 知识沉淀 |

**AI 编程时的作用**:
1. **环境感知**: 自动获取 PHP 8.4、Laravel 13.26.1 等版本信息，确保代码兼容性
2. **数据库操作**: 无需手动编写 SQL 即可查看表结构和数据
3. **文档查询**: 快速搜索 Laravel 官方文档，获取版本匹配的 API 用法
4. **错误诊断**: 快速定位应用错误和日志，提高调试效率
5. **知识管理**: 将项目决策和规则持久化到 `.ai/rules`，供团队共享

---

## 推荐配置的其他 MCP 服务器

根据项目技术栈和开发需求，推荐配置以下 MCP 服务器：

### 2. Filesystem MCP

**安装配置**:
```json
{
    "mcpServers": {
        "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data/project/backend/ai-laravel"]
        }
    }
}
```

**特点**:
- 官方维护，稳定可靠
- 提供完整的文件系统操作能力
- 支持文件读写、目录遍历、文件搜索

**核心功能**:
- `read_file` - 读取文件内容
- `write_file` - 写入文件
- `list_directory` - 列出目录内容
- `search_files` - 搜索文件
- `get_file_info` - 获取文件元数据
- `create_directory` - 创建目录
- `move_file` - 移动/重命名文件

**适用场景**:
- 大量文件操作时（如批量重构）
- 需要搜索特定代码模式
- 处理复杂目录结构

**为何推荐**:
虽然 Claude Code 已有内置的文件操作工具，但 Filesystem MCP 提供了更底层的控制和更丰富的搜索能力，适合处理大规模代码库。

---

### 3. Git MCP

**安装配置**:
```json
{
    "mcpServers": {
        "git": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "/data/project/backend/ai-laravel"]
        }
    }
}
```

**特点**:
- 官方维护，与 Git 深度集成
- 提供 Git 操作的高级抽象
- 支持分支管理、提交历史、差异比较

**核心功能**:
- `git_status` - 查看工作区状态
- `git_log` - 查看提交历史
- `git_diff` - 查看差异
- `git_branch` - 分支操作
- `git_commit` - 创建提交
- `git_show` - 查看特定提交

**适用场景**:
- 代码审查时查看变更历史
- 理解代码演进过程
- 多分支管理

**为何推荐**:
项目使用 Git 进行版本控制，Git MCP 能让 AI 更好地理解代码历史和上下文，做出更合理的决策。

---

### 4. Fetch MCP

**安装配置**:
```json
{
    "mcpServers": {
        "fetch": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-fetch"]
        }
    }
}
```

**特点**:
- HTTP 客户端工具
- 支持 GET、POST 等各种 HTTP 方法
- 处理 JSON、HTML 等多种响应格式

**核心功能**:
- HTTP 请求发送
- 响应解析
- Cookie 管理
- 请求头定制

**适用场景**:
- 测试 API 端点
- 调用第三方 API
- 验证 Webhook
- 获取外部资源

**为何推荐**:
Laravel 项目经常需要与外部 API 交互，Fetch MCP 提供了便捷的 HTTP 测试能力，无需离开对话即可测试 API。

---

### 5. Memory MCP

**安装配置**:
```json
{
    "mcpServers": {
        "memory": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-memory"]
        }
    }
}
```

**特点**:
- 持久化知识图谱
- 存储实体和关系
- 跨会话记忆

**核心功能**:
- 创建实体 (entities)
- 建立关系 (relations)
- 查询知识图谱
- 持久化存储

**适用场景**:
- 记录项目架构决策
- 存储业务逻辑知识
- 维护团队编码规范
- 跨会话共享上下文

**为何推荐**:
与 Laravel Boost 的 `record-rule` 互补，Memory MCP 提供了更灵活的知识存储方式，可以记录复杂的业务逻辑和架构关系。

---

### 6. SQLite MCP (可选)

**安装配置**:
```json
{
    "mcpServers": {
        "sqlite": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-sqlite", "/data/project/backend/ai-laravel/database/database.sqlite"]
        }
    }
}
```

**特点**:
- 专门针对 SQLite 数据库
- 提供表结构查询和数据分析
- 支持复杂的 SQL 查询

**核心功能**:
- 执行 SQL 查询
- 查看表结构
- 数据分析

**适用场景**:
- 复杂的数据库查询
- 数据分析和报告
- 性能优化调试

**为何推荐**:
项目使用 SQLite 作为数据库，虽然 Laravel Boost 已提供 `database-query` 和 `database-schema` 工具，但 SQLite MCP 提供了更专业的 SQLite 特性支持，如 PRAGMA 命令等。

---

## 完整配置示例

将以下配置添加到 `.mcp.json`:

```json
{
    "mcpServers": {
        "laravel-boost": {
            "command": "php",
            "args": ["artisan", "boost:mcp"]
        },
        "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data/project/backend/ai-laravel"]
        },
        "git": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "/data/project/backend/ai-laravel"]
        },
        "fetch": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-fetch"]
        },
        "memory": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-memory"]
        },
        "sqlite": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-sqlite", "/data/project/backend/ai-laravel/database/database.sqlite"]
        }
    }
}
```

---

## MCP 服务器对比表

| MCP 服务器 | 维护方 | 主要功能 | 与项目技术栈的关联 | 推荐优先级 |
|-----------|--------|---------|------------------|-----------|
| Laravel Boost | Laravel 官方 | Laravel 深度集成 | 核心开发工具 | ⭐⭐⭐⭐⭐ (已配置) |
| Filesystem | MCP 官方 | 文件系统操作 | 通用开发需求 | ⭐⭐⭐⭐ |
| Git | MCP 官方 | 版本控制 | Git 工作流 | ⭐⭐⭐⭐ |
| Fetch | MCP 官方 | HTTP 请求 | API 开发测试 | ⭐⭐⭐⭐ |
| Memory | MCP 官方 | 知识持久化 | 项目知识管理 | ⭐⭐⭐ |
| SQLite | MCP 官方 | SQLite 专用 | 数据库操作增强 | ⭐⭐⭐ |

---

## 使用建议

### 1. 优先级配置

建议按以下优先级逐步添加 MCP 服务器：

1. **第一优先级**: Laravel Boost (已配置)
   - 这是 Laravel 项目的核心 MCP，提供最关键的集成功能

2. **第二优先级**: Git + Fetch
   - Git MCP 增强版本控制能力
   - Fetch MCP 支持 API 开发和测试

3. **第三优先级**: Filesystem + Memory
   - 文件操作增强
   - 知识持久化

4. **可选**: SQLite MCP
   - 当 Laravel Boost 的数据库工具不够用时再添加

### 2. 权限配置

确保在 `.claude/settings.json` 中添加相应权限：

```json
{
  "permissions": {
    "allow": [
      "mcp__laravel-boost__*",
      "mcp__filesystem__*",
      "mcp__git__*",
      "mcp__fetch__*",
      "mcp__memory__*",
      "mcp__sqlite__*"
    ]
  },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "laravel-boost",
    "filesystem",
    "git",
    "fetch",
    "memory",
    "sqlite"
  ]
}
```

### 3. 性能考虑

- 每个 MCP 服务器都是独立进程，配置过多会影响启动速度
- 建议只启用实际使用的 MCP 服务器
- Laravel Boost 已提供大部分 Laravel 开发所需功能，其他 MCP 作为补充

---

## 总结

MCP 服务器为 AI 编程提供了强大的工具扩展能力。对于 Laravel 项目，**Laravel Boost MCP** 是核心必备工具，它深度集成 Laravel 生态系统，提供应用信息、数据库操作、文档查询等关键功能。其他 MCP 服务器如 Filesystem、Git、Fetch、Memory 等作为补充，可根据实际需求逐步添加。

合理配置 MCP 服务器能显著提升开发效率，让 AI 助手更好地理解项目上下文，做出更准确的代码决策。
