# Vitesse 项目 MCP 配置指南

## 什么是 MCP？

MCP (Model Context Protocol) 是一种标准化的协议，允许 Claude 与外部工具和服务进行交互。通过配置 MCP，Claude 可以获得更强大的能力，如文件操作、数据库访问、API 调用等。

## 项目技术栈概览

本项目基于 Vitesse 模板，主要技术栈包括：

- **框架**: Vue 3 + TypeScript
- **状态管理**: Pinia
- **路由**: Vue Router v5
- **样式**: UnoCSS 原子化 CSS
- **构建工具**: Vite
- **工具库**: VueUse
- **国际化**: Vue I18n
- **测试**: Vitest + Cypress
- **包管理**: pnpm

## 推荐的 MCP 配置

基于项目技术栈和开发需求，推荐以下 MCP 配置：

---

### 1. 文件系统 MCP (@modelcontextprotocol/server-filesystem)

#### 特点
- 提供安全的文件系统访问能力
- 支持文件读写、创建、删除等操作
- 可配置访问权限和路径限制

#### 作用
- **组件开发**: 快速创建 Vue 组件文件
- **路由管理**: 自动生成路由配置文件
- **配置修改**: 修改项目配置文件（如 vite.config.ts）
- **代码重构**: 批量重命名、移动文件

#### 配置示例
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/data/project/frontend/vitesse"
      ]
    }
  }
}
```

#### 适用场景
- 创建新的 Vue 组件、页面、Store
- 批量文件操作（如重命名组件）
- 项目结构重组

---

### 2. GitHub MCP (@modelcontextprotocol/server-github)

#### 特点
- 与 GitHub API 深度集成
- 支持 Issue、PR、代码审查
- 可查看仓库信息、文件历史

#### 作用
- **版本控制**: 查看提交历史、分支管理
- **代码审查**: 创建 PR、Review 代码
- **Issue 管理**: 创建、查询、关闭 Issue
- **协作开发**: 查看团队成员、权限管理

#### 配置示例
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

#### 适用场景
- 查看项目提交历史
- 创建功能分支的 PR
- 管理项目 Issue 和需求
- Code Review 自动化

---

### 3. Puppeteer MCP (@modelcontextprotocol/server-puppeteer)

#### 特点
- 无头浏览器自动化
- 支持截图、PDF 生成
- 可执行页面交互测试

#### 作用
- **E2E 测试**: 辅助 Cypress 进行端到端测试
- **可视化验证**: 截图验证页面效果
- **性能测试**: 页面加载性能分析
- **响应式测试**: 测试不同设备尺寸下的表现

#### 配置示例
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

#### 适用场景
- 截图验证响应式布局（移动端/PC端）
- 自动化测试页面交互
- 生成页面预览图片
- 捕获页面错误和警告

---

### 4. Fetch MCP (@modelcontextprotocol/server-fetch)

#### 特点
- HTTP 请求能力
- 支持 REST API 调用
- 支持各种认证方式

#### 作用
- **API 测试**: 测试后端 API 接口
- **数据获取**: 获取远程数据（如图片、小说内容）
- **第三方集成**: 调用第三方服务 API
- **调试**: 验证 API 请求和响应

#### 配置示例
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

#### 适用场景
- 测试图片浏览模块的图片加载
- 获取小说/古籍内容数据
- 调用百科 API 获取词条信息
- 验证图表数据接口

---

### 5. SQLite MCP (@modelcontextprotocol/server-sqlite)

#### 特点
- 轻量级数据库访问
- 支持 SQL 查询
- 本地数据存储

#### 作用
- **本地缓存**: 缓存图片、小说内容
- **离线功能**: 实现离线阅读功能
- **数据管理**: 管理用户书签、阅读进度
- **测试数据**: 存储测试数据集

#### 配置示例
```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sqlite",
        "--db-path",
        "/data/project/frontend/vitesse/data/local.db"
      ]
    }
  }
}
```

#### 适用场景
- 存储用户阅读进度和书签
- 缓存小说章节内容
- 管理百科词条数据
- 存储用户偏好设置

---

## 完整配置示例

### 项目级配置 (.claude/settings.json)

```json
{
  "$schema": "https://claude.ai/schema/settings.json",
  "permissions": {
    "allow": [
      "Bash(pnpm install:*)",
      "Bash(pnpm add:*)",
      "Bash(pnpm dev:*)",
      "Bash(pnpm build:*)",
      "Bash(pnpm lint:*)",
      "Bash(pnpm typecheck:*)",
      "Bash(pnpm test:*)",
      "Read(**/*.vue)",
      "Read(**/*.ts)",
      "Edit(**/*.vue)",
      "Edit(**/*.ts)"
    ]
  },
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/data/project/frontend/vitesse"
      ]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
```

### 本地个人配置 (.claude/settings.local.json)

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sqlite",
        "--db-path",
        "/data/project/frontend/vitesse/data/local.db"
      ]
    }
  }
}
```

---

## MCP 与项目模块的协同

### 图片浏览模块
- **Fetch MCP**: 获取远程图片列表
- **SQLite MCP**: 缓存图片元数据
- **Puppeteer MCP**: 验证图片加载和响应式布局

### 阅读模块
- **Fetch MCP**: 获取小说/古籍内容
- **SQLite MCP**: 存储阅读进度、书签
- **Filesystem MCP**: 管理本地电子书文件

### 百科模块
- **Fetch MCP**: 调用百科 API
- **SQLite MCP**: 缓存词条数据
- **Puppeteer MCP**: 测试搜索功能

### 表格模块
- **Fetch MCP**: 获取表格数据
- **SQLite MCP**: 本地数据管理
- **Filesystem MCP**: 导出 CSV/Excel 文件

### 图表模块
- **Fetch MCP**: 获取图表数据
- **SQLite MCP**: 存储历史数据
- **Puppeteer MCP**: 截图生成图表图片

---

## 安全注意事项

1. **权限控制**
   - 仅授予必要的文件访问权限
   - 使用路径限制防止越权访问
   - 敏感操作需用户确认

2. **密钥管理**
   - API 密钥存储在环境变量中
   - 使用 `.env` 文件管理敏感配置
   - 不要在 Git 中提交密钥

3. **数据安全**
   - SQLite 数据库文件应添加到 `.gitignore`
   - 定期备份重要数据
   - 敏感数据加密存储

---

## 安装和配置步骤

### 1. 安装 MCP 包
```bash
# 全局安装（可选）
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-puppeteer
npm install -g @modelcontextprotocol/server-fetch
npm install -g @modelcontextprotocol/server-sqlite
```

### 2. 配置 GitHub Token（如需使用 GitHub MCP）
```bash
# 创建 GitHub Personal Access Token
# 访问: https://github.com/settings/tokens

# 设置环境变量
export GITHUB_TOKEN="your_personal_access_token"
```

### 3. 更新项目配置
编辑 `.claude/settings.json`，添加所需的 MCP 服务器配置。

### 4. 验证配置
重启 Claude Code，使用 `/mcp` 命令查看已加载的 MCP 服务器。

---

## 常见问题

### Q: MCP 加载失败怎么办？
A: 检查以下几点：
1. 确保 npx 命令可用
2. 检查网络连接（首次使用需下载包）
3. 验证配置文件 JSON 格式正确

### Q: 如何查看 MCP 是否正常工作？
A: 使用命令 `/mcp` 查看已加载的 MCP 服务器列表。

### Q: 多个 MCP 之间会冲突吗？
A: 不会。每个 MCP 服务器独立运行，互不干扰。

### Q: 如何临时禁用某个 MCP？
A: 在配置文件中注释掉或删除对应的 MCP 配置项。

---

## 总结

通过合理配置 MCP，可以显著提升开发效率：

| MCP | 核心能力 | 适用模块 |
|-----|---------|---------|
| Filesystem | 文件操作 | 所有模块 |
| GitHub | 版本控制 | 项目管理 |
| Puppeteer | 浏览器自动化 | 测试、验证 |
| Fetch | 网络请求 | 数据获取 |
| SQLite | 本地存储 | 数据缓存 |

建议根据实际需求选择性配置，避免过度配置影响性能。
