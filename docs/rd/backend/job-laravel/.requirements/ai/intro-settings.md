# settings.json 文件分析

## 文件概述

`.claude/settings.json` 是项目级别的 Claude Code 配置文件，定义了 AI 助手在项目中的行为、权限和工具集成。此文件会被提交到 Git，供团队成员共享。

## 文件位置

```
/data/project/backend/ai-laravel/.claude/settings.json
```

## 完整文件内容

```json
{
  "$schema": "https://claude.ai/schema/settings.json",
  "project": {
    "name": "ai-laravel",
    "description": "Laravel 13 backend project with SQLite, PHPUnit, and Tailwind CSS 4"
  },
  "model": "sonnet",
  "permissions": {
    "allow": [
      "Bash(composer *)",
      "Bash(npm run *)",
      "Bash(php artisan *)",
      "Bash(php vendor/bin/pint *)",
      "Bash(php artisan test *)",
      "Bash(php artisan migrate *)",
      "Bash(php artisan config:*)",
      "Bash(php artisan route:*)",
      "Bash(php artisan cache:*)",
      "Bash(php artisan db:*)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git branch *)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Read(**)",
      "Edit(**)",
      "Write(**)",
      "mcp__laravel-boost__*"
    ]
  },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "laravel-boost"
  ],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "php vendor/bin/pint --dirty --format agent"
          }
        ]
      }
    ]
  }
}
```

## 配置项详解

### 1. $schema

```json
"$schema": "https://claude.ai/schema/settings.json"
```

**作用**: 指向 JSON Schema 定义文件，用于 IDE 验证和自动补全。

**意义**: 
- 确保 JSON 格式正确
- 支持编辑器提供智能提示
- 文档化可用配置选项

### 2. project

```json
"project": {
  "name": "ai-laravel",
  "description": "Laravel 13 backend project with SQLite, PHPUnit, and Tailwind CSS 4"
}
```

**作用**: 项目元数据，描述项目基本信息。

**字段说明**:
- `name`: 项目名称，用于识别和显示
- `description`: 项目描述，说明技术栈和主要特性

**应用场景**:
- AI 助手理解项目上下文
- 日志和报告中标识项目
- 团队成员快速了解项目概况

### 3. model

```json
"model": "sonnet"
```

**作用**: 指定 AI 助手使用的默认模型。

**可选值**:
- `sonnet` - 平衡性能和速度（默认）
- `opus` - 最强推理能力
- `haiku` - 最快响应速度

**影响**:
- 决定 AI 的推理能力
- 影响响应速度和成本
- 可在运行时通过 `/model` 命令切换

### 4. permissions

```json
"permissions": {
  "allow": [...]
}
```

**作用**: 定义 AI 助手被允许执行的操作。

#### 权限分类

**A. Composer 相关**
```json
"Bash(composer *)"
```
- 允许运行所有 `composer` 命令
- 包括 `composer install`、`composer update`、`composer require` 等
- 用于依赖管理

**B. NPM 相关**
```json
"Bash(npm run *)"
```
- 允许运行 `npm run` 脚本
- 包括 `npm run dev`、`npm run build` 等
- 用于前端构建

**C. Artisan 命令**
```json
"Bash(php artisan *)",
"Bash(php artisan test *)",
"Bash(php artisan migrate *)",
"Bash(php artisan config:*)",
"Bash(php artisan route:*)",
"Bash(php artisan cache:*)",
"Bash(php artisan db:*)"
```
- 允许运行 Laravel Artisan 命令
- 细粒度控制不同类型的命令
- 覆盖测试、迁移、配置、路由、缓存、数据库操作

**D. Pint 代码格式化**
```json
"Bash(php vendor/bin/pint *)"
```
- 允许运行 Pint 代码格式化工具
- 确保代码风格一致

**E. Git 操作**
```json
"Bash(git status)",
"Bash(git log *)",
"Bash(git diff *)",
"Bash(git branch *)"
```
- 允许只读 Git 操作
- 不包括 `git commit`、`git push` 等写操作
- 保护代码仓库安全

**F. 文件系统操作**
```json
"Bash(ls *)",
"Bash(cat *)",
"Bash(find *)",
"Bash(grep *)"
```
- 允许只读文件系统操作
- 用于探索和搜索代码

**G. 文件工具权限**
```json
"Read(**)",
"Edit(**)",
"Write(**)"
```
- `Read(**)`: 允许读取所有文件
- `Edit(**)`: 允许编辑现有文件
- `Write(**)`: 允许创建新文件

**H. MCP 工具权限**
```json
"mcp__laravel-boost__*"
```
- 允许使用所有 Laravel Boost MCP 工具
- 包括 `database-query`、`database-schema`、`search-docs` 等

### 5. MCP 服务器配置

```json
"enableAllProjectMcpServers": true,
"enabledMcpjsonServers": [
  "laravel-boost"
]
```

**作用**: 配置 MCP (Model Context Protocol) 服务器集成。

**字段说明**:
- `enableAllProjectMcpServers`: 启用所有项目级 MCP 服务器
- `enabledMcpjsonServers`: 指定从 `.mcp.json` 加载的服务器列表

**当前配置**:
- 启用了 `laravel-boost` MCP 服务器
- 通过 `php artisan boost:mcp` 启动

### 6. hooks

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "php vendor/bin/pint --dirty --format agent"
        }
      ]
    }
  ]
}
```

**作用**: 定义工具执行后的自动化钩子。

#### 钩子类型

**PostToolUse**: 工具执行后触发

**配置解析**:
- `matcher`: 匹配工具名称的正则表达式，`Edit|Write` 表示编辑或写入文件后触发
- `hooks`: 要执行的钩子列表
- `type: "command"`: 执行 shell 命令
- `command`: 具体的命令内容

**实际效果**:
- 每次编辑或创建 PHP 文件后
- 自动运行 Pint 格式化
- 确保代码风格始终一致
- 无需手动格式化

## 与 settings.local.json 的关系

### settings.json vs settings.local.json

| 特性 | settings.json | settings.local.json |
|-----|--------------|---------------------|
| 版本控制 | 提交到 Git | Git 忽略 |
| 用途 | 团队共享配置 | 个人本地覆盖 |
| 优先级 | 基础配置 | 覆盖基础配置 |
| 示例 | 全局权限、模型选择 | 个人偏好、测试配置 |

### 合并策略

两个文件会深度合并：
- 相同字段：`settings.local.json` 覆盖
- 不同字段：合并保留
- 数组字段：合并去重

### 当前 settings.local.json 内容

```json
{
  "permissions": {
    "allow": [
      "Bash(php artisan *)",
      "mcp__laravel-boost__application-info"
    ]
  },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "laravel-boost"
  ]
}
```

**作用**: 
- 额外允许 `php artisan *` 命令
- 额外允许 `mcp__laravel-boost__application-info` 工具
- 继承基础配置的其他设置

## 安全考虑

### 1. 最小权限原则

当前配置遵循最小权限原则：
- Git 操作仅限只读
- 避免危险的 shell 命令
- 明确指定允许的工具

### 2. 敏感操作保护

以下操作需要额外批准：
- `git commit` - 提交代码
- `git push` - 推送到远程
- `rm` - 删除文件
- 数据库删除/清空操作

### 3. 权限粒度

权限配置从粗到细：
- `Bash(*)` - 允许所有 Bash 命令（不推荐）
- `Bash(php *)` - 允许所有 php 命令
- `Bash(php artisan migrate *)` - 仅允许迁移命令

## 最佳实践

### 1. 权限管理

```json
// 推荐：明确指定需要的权限
"Bash(php artisan migrate *)"

// 不推荐：过度宽松的权限
"Bash(*)"
```

### 2. 钩子使用

```json
// 自动化重复性任务
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {"type": "command", "command": "vendor/bin/pint --dirty"}
      ]
    }
  ]
}
```

### 3. MCP 集成

```json
// 明确启用需要的 MCP 服务器
"enabledMcpjsonServers": [
  "laravel-boost",
  "filesystem"
]
```

## 配置示例

### 开发环境配置

```json
{
  "model": "sonnet",
  "permissions": {
    "allow": [
      "Bash(php artisan *)",
      "Bash(composer *)",
      "Bash(npm run *)",
      "Read(**)",
      "Edit(**)",
      "Write(**)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {"type": "command", "command": "vendor/bin/pint --dirty"}
        ]
      }
    ]
  }
}
```

### 生产环境配置

```json
{
  "model": "opus",
  "permissions": {
    "allow": [
      "Read(**)",
      "Bash(git status)",
      "Bash(git log *)"
    ]
  }
}
```

## 故障排查

### 权限被拒绝

**症状**: AI 尝试执行命令但被拒绝

**解决方案**:
1. 检查 `settings.json` 中的权限配置
2. 确保命令匹配允许的模式
3. 考虑添加到 `settings.local.json`

### 钩子不执行

**症状**: 编辑文件后 Pint 未运行

**排查步骤**:
1. 检查钩子配置是否正确
2. 确认 Pint 已安装：`composer require laravel/pint --dev`
3. 手动测试命令：`php vendor/bin/pint --dirty --format agent`

### MCP 服务器连接失败

**症状**: Laravel Boost 工具不可用

**解决方案**:
1. 检查 `.mcp.json` 配置
2. 确认 `laravel/boost` 已安装
3. 运行 `php artisan boost:mcp` 测试

## 总结

`settings.json` 是 Claude Code 项目的核心配置文件，它：

1. **定义项目身份** - 名称、描述、技术栈
2. **控制 AI 行为** - 模型选择、权限范围
3. **集成外部工具** - MCP 服务器、自动化钩子
4. **保障安全性** - 细粒度权限控制

通过合理配置，可以实现：
- 自动化代码格式化
- 安全的文件操作
- 高效的 MCP 工具集成
- 团队配置共享

这份配置文件与 CLAUDE.md 协同工作，CLAUDE.md 提供"做什么"的指导，settings.json 提供"能做什么"的限制和"如何自动化"的机制。
