# CLAUDE.md 文件分析

## 文件概述

`CLAUDE.md` 是项目级别的 AI 助手指令文件，位于项目根目录。它为 Claude Code 等 AI 编程助手提供项目特定的上下文和指导原则，确保 AI 生成的代码符合项目规范。

## 文件位置

```
/data/project/backend/ai-laravel/CLAUDE.md
```

## 文件结构

文件分为以下几个主要部分：

### 1. Laravel Boost Guidelines（Laravel Boost 指南）

#### Foundation Rules（基础规则）
- **PHP 版本**: 8.4
- **Laravel 版本**: 13.26.1
- **技能激活**: 项目包含领域特定技能，必须激活相关技能
- **代码约定**: 遵循现有代码约定，使用描述性命名
- **验证脚本**: 测试覆盖的功能不需要额外验证脚本
- **应用结构**: 遵循现有目录结构
- **前端构建**: 提醒运行 `npm run build` 或 `npm run dev`
- **文档文件**: 仅在用户明确请求时创建
- **回复风格**: 简洁明了

#### Boost Rules（Boost 工具规则）
- **工具优先**: 优先使用 Laravel Boost MCP 工具而非手动方式
- **文档搜索**: 使用 `search-docs` 工具查询版本特定的 API
- **项目规则**: 遵循 `.ai/rules` 目录中的项目规则
- **Artisan 命令**: 直接使用 Artisan 命令行工具
- **Tinker**: 用于调试和测试，使用单引号防止 shell 展开

#### PHP Rules（PHP 规则）
- 使用花括号包裹控制结构
- 使用 PHP 8 构造函数属性提升
- 明确声明返回类型和参数类型提示
- 枚举键使用 TitleCase
- 优先使用 PHPDoc 块而非内联注释

#### Laravel/Core Rules（Laravel 核心规则）
- 使用 `php artisan make:` 命令创建新文件
- 创建模型时同时创建工厂和种子
- API 默认使用 Eloquent API Resources 和版本控制
- 生成链接优先使用命名路由和 `route()` 函数
- 测试使用工厂，使用 `$this->faker` 或 `fake()`

#### Pint/Core Rules（Pint 代码格式化规则）
- 修改 PHP 文件后必须运行 Pint 格式化
- 使用 `vendor/bin/pint --dirty --format agent`

#### PHPUnit/Core Rules（PHPUnit 测试规则）
- 使用 PHPUnit 进行测试
- 测试应覆盖所有成功路径、失败路径和边缘情况
- 不经批准不得删除测试文件
- 运行最小数量的测试

### 2. Project Commands（项目命令）

提供了开发和设置相关的常用命令：

```bash
# 开发
composer run dev          # 启动 Laravel 开发服务器（带实时重载）
npm run dev               # 启动 Vite 前端开发服务器
npm run build             # 构建生产环境前端资源

# 设置
composer run setup        # 完整项目设置
```

### 3. Database（数据库）

- 数据库类型: SQLite
- 数据库位置: `database/database.sqlite`
- 测试使用内存数据库
- 迁移命令: `php artisan migrate`, `php artisan migrate:fresh`

### 4. Frontend（前端）

- 构建工具: Vite 8
- CSS 框架: Tailwind CSS 4
- 入口点:
  - CSS: `resources/css/app.css`
  - JS: `resources/js/app.js`

## 文件作用

### 1. 为 AI 助手提供项目上下文

CLAUDE.md 作为 AI 编程助手的"使用说明书"，告诉 AI：
- 项目使用的技术栈版本
- 如何正确使用 Laravel 生态系统的各个组件
- 项目特定的代码风格和约定
- 哪些工具可用以及如何使用

### 2. 确保代码一致性

通过明确的规则和指南，确保：
- 所有代码遵循相同的命名约定
- 使用正确的 Laravel API（版本特定）
- 遵循项目架构决策
- 保持代码风格统一

### 3. 提高开发效率

- 减少重复性决策（如命名规范、目录结构等）
- 提供快速参考（常用命令、工具使用）
- 避免常见错误（版本不兼容、错误的 API 用法）

### 4. 知识传递

对于新加入团队的开发者或 AI 助手：
- 快速了解项目架构和技术栈
- 学习项目的最佳实践
- 避免破坏现有代码风格

## 与其他配置文件的关系

### .claude/ 目录

CLAUDE.md 是顶级指令文件，而 `.claude/` 目录包含更具体的配置：

| 文件/目录 | 与 CLAUDE.md 的关系 |
|----------|-------------------|
| `settings.json` | AI 助手的权限和配置设置 |
| `agents/` | 专门的子代理定义 |
| `skills/` | 领域特定的技能指南 |
| `rules/` | 项目特定的规则文件 |
| `commands/` | 自定义斜杠命令 |
| `hooks/` | 自动化钩子脚本 |

### 层级关系

```
CLAUDE.md (顶层指令)
    ↓
.claude/rules/ (具体规则)
    ↓
.claude/skills/ (领域技能)
    ↓
.claude/agents/ (专门代理)
```

## 最佳实践

### 1. 保持更新

当项目技术栈或约定发生变化时，及时更新 CLAUDE.md：
- 升级 Laravel 版本后更新版本号
- 添加新工具时补充使用说明
- 调整代码风格时更新规则

### 2. 简洁明了

- 避免过度解释显而易见的内容
- 重点说明项目特定的决策
- 提供实用的示例

### 3. 版本特定

- 始终注明具体版本号（如 Laravel 13.26.1）
- 提供版本间的 API 变化说明
- 提醒使用 `search-docs` 查询文档

### 4. 工具集成

- 充分利用 Laravel Boost MCP 工具
- 整合其他项目工具（如 Pint、PHPUnit）
- 提供常用命令的快速参考

## 总结

CLAUDE.md 是连接 AI 助手与项目代码库的桥梁。它不仅提供技术栈信息和代码约定，还定义了 AI 如何与项目交互的标准流程。通过这份文档，AI 助手能够：

1. **理解项目上下文** - 技术栈、版本、架构
2. **遵循编码标准** - 命名、风格、模式
3. **正确使用工具** - Artisan、Pint、PHPUnit 等
4. **保持一致性** - 与现有代码库保持同步

这份文件是 Laravel 项目中 AI 辅助开发的核心配置，确保 AI 生成的代码符合 Laravel 最佳实践和项目特定要求。
