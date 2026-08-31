# MCP (Model Context Protocol) 配置推荐

## 什么是 MCP?

MCP (Model Context Protocol) 是 Anthropic 推出的开放协议，允许 Claude 安全地连接外部数据源和工具。通过 MCP 服务器，Claude 可以：
- 访问本地文件系统和数据库
- 调用外部 API 和服务
- 执行代码和脚本
- 与开发工具链集成

## 项目技术栈分析

本项目是一个基于 Vue 3 + TypeScript 的企业级管理系统，具有以下特点：

- **前端框架**: Vue 3.5.38 + TypeScript 6.0.3
- **构建工具**: Vite 8.0.10 + pnpm 11.7.0 + Turborepo
- **UI 框架**: Element Plus / Ant Design Vue / Naive UI / TDesign
- **状态管理**: Pinia 3.0.4
- **项目架构**: Monorepo（多应用 + 共享包）
- **业务模块**: 包含 ERP、CRM、HRM、FMS 等多个业务系统

基于项目特点，我们推荐以下 MCP 服务器配置。

---

## 推荐的 MCP 配置

### 1. Filesystem MCP Server（文件系统）

#### 简介
提供对本地文件系统的安全访问，允许 Claude 读取、写入、搜索文件和目录。

#### 安装
```bash
npm install -g @modelcontextprotocol/server-filesystem
```

#### 配置示例
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/data/project/frontend/yudao-ui-admin-vben"
      ],
      "disabled": false
    }
  }
}
```

#### 特点和作用
- ✅ **文件操作**: 读取、写入、删除、重命名文件
- ✅ **目录浏览**: 列出目录结构，搜索文件
- ✅ **代码分析**: 扫描代码库，理解项目结构
- ✅ **批量操作**: 批量创建或修改文件
- 🔒 **安全限制**: 只能访问配置的指定目录

#### 适用场景
- 快速浏览项目文件结构
- 批量生成组件、API 文件
- 分析代码依赖关系
- 重构代码时的文件操作

#### 项目应用示例
```
用户: "帮我查看 apps/web-ele/src/views/system/user 目录下的文件"
Claude: [使用 filesystem MCP 列出目录内容]

用户: "在 apps/web-ele/src/views/fms 目录下创建一个新的列表页面"
Claude: [使用 filesystem MCP 创建所需的 Vue 组件文件]
```

---

### 2. GitHub MCP Server（GitHub 集成）

#### 简介
与 GitHub API 集成，提供仓库、Issue、Pull Request、分支等操作能力。

#### 安装
```bash
npm install -g @modelcontextprotocol/server-github
```

#### 配置示例
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_github_token_here"
      },
      "disabled": false
    }
  }
}
```

#### 特点和作用
- ✅ **仓库管理**: 创建、克隆、fork 仓库
- ✅ **Issue 管理**: 创建、查询、更新 Issue
- ✅ **PR 管理**: 创建 Pull Request，添加评论，合并代码
- ✅ **分支操作**: 创建分支，查看分支差异
- ✅ **搜索功能**: 搜索代码、Issue、PR

#### 适用场景
- 自动化代码审查流程
- 管理 Issue 和 PR
- 从远程仓库拉取最新代码
- 分析项目贡献者活动

#### 项目应用示例
```
用户: "查看 vbenjs/yudao-ui-admin-vben 仓库最近的开源 Issue"
Claude: [使用 GitHub MCP 搜索并列出最近的 Issue]

用户: "帮我创建一个 Pull Request，标题是 'feat: 新增用户管理功能'"
Claude: [使用 GitHub MCP 创建 PR 并提交]
```

---

### 3. Fetch MCP Server（HTTP 请求）

#### 简介
提供 HTTP 请求能力，允许 Claude 访问外部 API、获取网页内容等。

#### 安装
```bash
npm install -g @modelcontextprotocol/server-fetch
```

#### 配置示例
```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "disabled": false
    }
  }
}
```

#### 特点和作用
- ✅ **HTTP 请求**: 支持 GET、POST、PUT、DELETE 等方法
- ✅ **API 测试**: 测试后端 API 接口
- ✅ **网页抓取**: 获取网页内容进行分析
- ✅ **文档获取**: 获取在线文档、API 说明

#### 适用场景
- 测试项目后端 API 接口
- 获取第三方 API 文档
- 验证 API 响应格式
- 调试前后端接口对接问题

#### 项目应用示例
```
用户: "测试一下用户登录接口 POST /api/auth/login"
Claude: [使用 fetch MCP 发送请求并返回结果]

用户: "获取 Element Plus 的最新文档"
Claude: [使用 fetch MCP 访问 Element Plus 官网]
```

---

### 4. Puppeteer MCP Server（浏览器自动化）

#### 简介
基于 Puppeteer 的浏览器自动化工具，可以进行网页截图、UI 测试、爬虫等操作。

#### 安装
```bash
npm install -g @modelcontextprotocol/server-puppeteer
```

#### 配置示例
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "disabled": false
    }
  }
}
```

#### 特点和作用
- ✅ **浏览器控制**: 打开网页、点击、输入、滚动
- ✅ **截图功能**: 对页面或元素进行截图
- ✅ **UI 测试**: 自动化 UI 测试和回归测试
- ✅ **性能分析**: 分析页面加载性能
- ✅ **数据抓取**: 从动态网页抓取数据

#### 适用场景
- 自动化 UI 测试
- 页面截图和文档生成
- 性能分析和优化
- E2E 测试自动化

#### 项目应用示例
```
用户: "启动项目并打开登录页面进行截图"
Claude: [使用 puppeteer MCP 打开浏览器并截图]

用户: "测试一下用户管理列表页的筛选功能"
Claude: [使用 puppeteer MCP 自动操作浏览器进行测试]
```

---

### 5. Memory MCP Server（持久化记忆）

#### 简介
提供知识图谱和持久化存储能力，允许 Claude 存储和检索项目相关信息。

#### 安装
```bash
npm install -g @modelcontextprotocol/server-memory
```

#### 配置示例
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "disabled": false
    }
  }
}
```

#### 特点和作用
- ✅ **知识存储**: 存储项目配置、业务规则、技术决策
- ✅ **上下文保持**: 跨会话保持对话上下文
- ✅ **实体关系**: 构建项目实体关系图
- ✅ **知识检索**: 快速检索历史知识

#### 适用场景
- 记录项目架构设计决策
- 存储业务逻辑和规则
- 保持长期对话上下文
- 构建项目知识库

#### 项目应用示例
```
用户: "记住我们项目的 API 规范：使用 RESTful 风格，统一使用 requestClient"
Claude: [使用 memory MCP 存储这条知识]

用户: "之前我们定义的用户模块架构是什么？"
Claude: [使用 memory MCP 检索并回答]
```

---

### 6. Sequential Thinking MCP Server（结构化思考）

#### 简介
提供结构化思考工具，帮助 Claude 进行复杂的逻辑推理和问题分析。

#### 安装
```bash
npm install -g @modelcontextprotocol/server-sequential-thinking
```

#### 配置示例
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false
    }
  }
}
```

#### 特点和作用
- ✅ **结构化推理**: 按步骤进行逻辑推理
- ✅ **问题分解**: 将复杂问题分解为子问题
- ✅ **思维链**: 保持完整的思考过程
- ✅ **决策辅助**: 辅助技术决策和架构设计

#### 适用场景
- 复杂架构设计
- 多步骤问题分析
- 技术方案选型
- Bug 排查和根因分析

#### 项目应用示例
```
用户: "帮我分析一下如何重构用户权限模块"
Claude: [使用 sequential-thinking MCP 进行结构化分析]

用户: "这个性能问题可能是什么原因导致的？"
Claude: [使用 sequential-thinking MCP 进行系统化推理]
```

---

## 完整配置示例

将以下配置添加到 `.claude/settings.json` 文件中：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/data/project/frontend/yudao-ui-admin-vben"
      ],
      "disabled": false
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_github_token_here"
      },
      "disabled": false
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "disabled": false
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "disabled": false
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "disabled": false
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false
    }
  }
}
```

---

## MCP 配置最佳实践

### 1. 安全性考虑

- 🔒 **最小权限原则**: 只授予必要的权限
- 🔒 **环境变量**: 敏感信息使用环境变量配置
- 🔒 **访问控制**: 限制 filesystem MCP 的访问目录
- 🔒 **Token 管理**: 定期轮换 GitHub Token 等凭证

### 2. 性能优化

- ⚡ **按需启用**: 不常用的 MCP 可以设置 `disabled: true`
- ⚡ **缓存策略**: 合理使用 memory MCP 进行知识缓存
- ⚡ **并行调用**: 多个 MCP 可以并行执行任务

### 3. 团队协作

- 👥 **共享配置**: 将 `settings.json` 提交到 Git 仓库
- 👥 **个人配置**: 使用 `settings.local.json` 存储个人配置
- 👥 **文档同步**: 保持 MCP 使用文档的更新

---

## 常见问题

### Q1: 如何获取 GitHub Personal Access Token?

1. 访问 GitHub Settings -> Developer settings -> Personal access tokens
2. 点击 "Generate new token (classic)"
3. 选择必要的权限：`repo`, `read:org`, `read:user`
4. 生成 Token 并保存到配置文件

### Q2: MCP 服务器启动失败怎么办?

1. 检查 Node.js 版本（建议 18+）
2. 确认 npm/npx 全局安装权限
3. 查看错误日志定位问题
4. 尝试手动安装 MCP 包：`npm install -g @modelcontextprotocol/server-xxx`

### Q3: 如何验证 MCP 是否正常工作?

在 Claude 中执行：
```
列出所有可用的 MCP 服务器
```
或直接测试：
```
使用 filesystem MCP 列出当前目录文件
```

### Q4: 多个 MCP 之间可以协同工作吗?

可以！例如：
1. 使用 GitHub MCP 获取远程仓库代码
2. 使用 Filesystem MCP 将代码保存到本地
3. 使用 Sequential Thinking MCP 分析代码结构
4. 使用 Memory MCP 存储分析结果

---

## 总结

通过合理配置 MCP 服务器，可以大幅提升 Claude 在本项目中的开发效率：

| MCP Server | 核心能力 | 适用场景 |
|-----------|---------|---------|
| Filesystem | 文件操作 | 代码生成、重构、批量操作 |
| GitHub | 仓库管理 | Issue/PR 管理、代码协作 |
| Fetch | HTTP 请求 | API 测试、文档获取 |
| Puppeteer | 浏览器自动化 | UI 测试、截图、爬虫 |
| Memory | 知识存储 | 项目知识库、上下文保持 |
| Sequential Thinking | 结构化推理 | 架构设计、问题分析 |

建议根据实际需求启用相应的 MCP，并遵循安全最佳实践进行配置。

---

## 参考资源

- [MCP 官方文档](https://modelcontextprotocol.io/)
- [Anthropic MCP GitHub](https://github.com/modelcontextprotocol)
- [Claude Code 文档](https://docs.anthropic.com/claude/docs)
- [Vue Vben Admin 文档](https://doc.vben.pro/)
