# Vitesse 项目 MCP 配置指南

## 什么是 MCP？

MCP (Model Context Protocol) 是 Anthropic 推出的开放协议，允许 AI 助手安全地连接外部工具、数据源和服务。通过 MCP，Claude Code 可以：

- 访问本地文件系统
- 执行 HTTP 请求
- 操作 Git 仓库
- 连接数据库
- 浏览器自动化测试

## 推荐的 MCP 配置

基于 Vitesse 项目的技术栈（Vue 3、Vite、Pinia、TypeScript、UnoCSS 等），以下是推荐的 MCP 配置：

---

### 1. Filesystem MCP

**包名**: `@anthropic-ai/mcp-server-filesystem`

**特点**:
- 提供安全的文件系统访问能力
- 支持读写、创建、删除文件和目录
- 支持文件搜索和内容检索
- 可配置访问路径白名单

**在项目中的作用**:

1. **组件开发辅助**
   - 快速创建 Vue 组件文件（`.vue`）
   - 自动生成组件模板代码
   - 批量创建模块化组件结构

2. **路由配置**
   - 自动创建页面文件（`src/pages/`）
   - 管理路由配置文件

3. **状态管理**
   - 创建 Pinia Store 文件
   - 生成 store 模板代码

4. **样式文件管理**
   - 创建 UnoCSS 配置
   - 管理全局样式文件

**配置示例**:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-filesystem",
        "/data/project/frontend/vitesse"
      ]
    }
  }
}
```

---

### 2. Fetch MCP

**包名**: `@anthropic-ai/mcp-server-fetch`

**特点**:
- 提供 HTTP 请求能力
- 支持 GET、POST、PUT、DELETE 等方法
- 支持自定义请求头和请求体
- 支持处理 JSON、XML 等响应格式

**在项目中的作用**:

1. **API 数据获取**
   - 模拟 API 请求，测试数据交互
   - 获取外部数据源（如图片、文章内容）

2. **阅读模块开发**
   - 获取古籍、小说内容数据
   - 测试章节内容的 API 接口

3. **百科模块开发**
   - 获取词条数据
   - 测试搜索接口

4. **图片浏览模块**
   - 测试图片上传接口
   - 验证图片 URL 有效性

**配置示例**:
```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-fetch"]
    }
  }
}
```

---

### 3. Git MCP

**包名**: `@anthropic-ai/mcp-server-git`

**特点**:
- 提供完整的 Git 操作能力
- 支持查看状态、提交、推送、拉取
- 支持分支管理、合并、变基
- 支持查看提交历史和差异

**在项目中的作用**:

1. **版本控制**
   - 自动化代码提交
   - 管理功能分支
   - 查看代码变更历史

2. **协作开发**
   - 创建和管理分支
   - 合并功能代码
   - 处理冲突

3. **代码审查**
   - 查看代码差异
   - 追踪问题修复
   - 生成变更报告

**配置示例**:
```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-git",
        "--repository",
        "/data/project/frontend/vitesse"
      ]
    }
  }
}
```

---

### 4. GitHub MCP

**包名**: `@anthropic-ai/mcp-server-github`

**特点**:
- 提供 GitHub API 集成
- 支持创建、查看、更新 Issues
- 支持创建、管理 Pull Requests
- 支持仓库搜索和文件浏览
- 支持 GitHub Actions 查看

**在项目中的作用**:

1. **项目管理**
   - 创建功能需求 Issue
   - 跟踪 Bug 报告
   - 管理项目里程碑

2. **代码协作**
   - 创建 Pull Request
   - 添加代码审查评论
   - 管理 PR 状态

3. **持续集成**
   - 查看 CI/CD 构建状态
   - 管理部署流程

4. **文档协作**
   - 更新 README
   - 管理项目文档

**配置示例**:
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "your-github-token"
      }
    }
  }
}
```

---

### 5. Playwright MCP (推荐用于测试)

**包名**: `@playwright/mcp-server`

**特点**:
- 提供浏览器自动化能力
- 支持 Chromium、Firefox、WebKit
- 支持页面截图、录制
- 支持表单填写、点击操作
- 支持响应式设计测试

**在项目中的作用**:

1. **E2E 测试辅助**
   - 自动化测试用户流程
   - 验证页面功能
   - 截图测试

2. **响应式设计验证**
   - 测试不同屏幕尺寸下的布局
   - 验证移动端和 PC 端适配
   - 截取不同断点的页面截图

3. **组件测试**
   - 测试组件交互
   - 验证表单提交
   - 测试动态内容

4. **阅读模块测试**
   - 测试翻页功能
   - 验证书签管理
   - 测试章节导航

5. **图片浏览模块测试**
   - 测试图片上传
   - 验证灯箱预览
   - 测试图片网格布局

**配置示例**:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp-server"]
    }
  }
}
```

---

### 6. Puppeteer MCP (替代方案)

**包名**: `@puppeteer/mcp-server`

**特点**:
- 基于 Chromium 的浏览器自动化
- 性能优于 Playwright（仅 Chromium）
- 更轻量级

**在项目中的作用**:

与 Playwright 类似，用于：
- E2E 测试
- 响应式设计验证
- 页面截图
- 性能测试

**配置示例**:
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@puppeteer/mcp-server"]
    }
  }
}
```

---

## 完整配置示例

在 `.claude/settings.json` 中配置所有推荐的 MCP：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-filesystem",
        "/data/project/frontend/vitesse"
      ]
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-fetch"]
    },
    "git": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-git",
        "--repository",
        "/data/project/frontend/vitesse"
      ]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "your-github-token"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp-server"]
    }
  }
}
```

---

## MCP 使用场景详解

### 场景 1: 创建图片浏览模块

使用 Filesystem MCP 创建组件结构：

```
src/components/ImageGallery.vue
src/components/ImagePreview.vue
src/components/ImageUploader.vue
src/pages/gallery/index.vue
src/pages/gallery/[id].vue
```

### 场景 2: 开发阅读模块

结合多个 MCP：

1. **Fetch MCP**: 获取小说/古籍内容数据
2. **Filesystem MCP**: 创建阅读器组件和页面
3. **Playwright MCP**: 测试阅读器响应式布局

### 场景 3: 响应式设计验证

使用 Playwright MCP：

```javascript
// 测试不同断点
const viewports = [
  { width: 375, height: 667 },   // 移动端
  { width: 768, height: 1024 },  // 平板
  { width: 1280, height: 720 },  // 桌面
]

for (const viewport of viewports) {
  await page.setViewportSize(viewport)
  await page.screenshot({ path: `screenshot-${viewport.width}.png` })
}
```

### 场景 4: Git 工作流

使用 Git MCP 和 GitHub MCP：

1. 创建功能分支
2. 提交代码变更
3. 创建 Pull Request
4. 添加审查评论
5. 合并代码

---

## MCP 优先级建议

根据项目需求，MCP 的优先级排序：

| 优先级 | MCP | 原因 |
|--------|-----|------|
| ⭐⭐⭐⭐⭐ | Filesystem | 核心开发工具，创建组件、页面等 |
| ⭐⭐⭐⭐⭐ | Git | 版本控制必需 |
| ⭐⭐⭐⭐ | GitHub | 项目协作和代码审查 |
| ⭐⭐⭐⭐ | Fetch | API 开发和数据获取 |
| ⭐⭐⭐ | Playwright | E2E 测试和响应式验证 |

---

## 安全注意事项

1. **Filesystem MCP**
   - 仅授权必要的目录访问
   - 避免授权系统敏感目录

2. **GitHub MCP**
   - 使用最小权限的 GitHub Token
   - 定期更新和撤销旧 Token

3. **Fetch MCP**
   - 注意不要请求内部 API
   - 避免泄露敏感信息

4. **Playwright MCP**
   - 仅用于开发和测试环境
   - 不要用于生产环境操作

---

## 安装和配置步骤

### 1. 安装 Claude Code CLI

```bash
# 已安装则跳过
npm install -g @anthropic-ai/claude-code
```

### 2. 配置 MCP

编辑 `.claude/settings.json` 文件，添加 MCP 配置。

### 3. 验证 MCP 状态

在 Claude Code 中运行：
```bash
/mcp
```

查看已配置的 MCP 服务器状态。

---

## 总结

通过配置这些 MCP，Claude Code 将能够：

1. **高效开发** - 快速创建 Vue 组件、页面和 Store
2. **版本控制** - 自动化 Git 工作流
3. **团队协作** - 管理 GitHub Issues 和 PRs
4. **数据交互** - 获取和测试 API 数据
5. **质量保证** - 自动化 E2E 测试和响应式验证

这些 MCP 将显著提升 Vitesse 项目的开发效率和代码质量，特别是在图片浏览、阅读模块、百科页面等功能开发中发挥重要作用。
