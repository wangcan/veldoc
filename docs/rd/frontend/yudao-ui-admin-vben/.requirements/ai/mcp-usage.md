# MCP 配置使用指南

## 快速开始

### 1. 环境要求

确保系统已安装：
- Node.js >= 18.0.0
- npm 或 pnpm
- Git

### 2. 配置 GitHub Token（可选）

如果需要使用 GitHub MCP，需要配置 Personal Access Token：

```bash
# 设置环境变量
export GITHUB_TOKEN="your_github_personal_access_token"
```

获取 Token 步骤：
1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 勾选权限：`repo`, `read:org`, `read:user`
4. 生成并保存 Token

### 3. 启动 Claude Code

MCP 配置已添加到 `.claude/settings.json`，启动 Claude Code 时会自动加载。

```bash
# 在项目根目录启动 Claude Code
cd /data/project/frontend/yudao-ui-admin-vben
claude
```

## 可用的 MCP 服务器

### 1. Filesystem（文件系统）✅ 推荐启用

**用途**: 代码文件操作、目录浏览、批量生成

**常用场景**:
```
- "列出 apps/web-ele/src/views 下所有 Vue 组件"
- "批量创建一个新的业务模块目录结构"
- "查找项目中所有的 API 接口定义"
- "读取 package.json 查看依赖版本"
```

### 2. GitHub（仓库管理）✅ 推荐启用

**用途**: Issue 管理、PR 创建、代码协作

**常用场景**:
```
- "查看项目最近的 Issue"
- "创建一个 Pull Request"
- "搜索代码中的 TODO 注释"
- "查看某个文件的提交历史"
```

### 3. Fetch（HTTP 请求）✅ 推荐启用

**用途**: API 测试、文档获取、接口调试

**常用场景**:
```
- "测试用户登录接口 POST /api/auth/login"
- "获取 Element Plus 的最新文档"
- "检查第三方 API 的响应格式"
```

### 4. Memory（知识图谱）✅ 推荐启用

**用途**: 项目知识存储、架构决策记录

**常用场景**:
```
- "记住项目的编码规范：使用 TypeScript 严格模式"
- "存储用户模块的业务逻辑"
- "查询之前讨论的架构设计方案"
```

### 5. Sequential Thinking（结构化思考）⚡ 按需启用

**用途**: 复杂问题分析、架构设计

**常用场景**:
```
- "分析重构权限模块的最佳方案"
- "评估引入新技术栈的风险和收益"
- "排查性能问题的根本原因"
```

## 实用示例

### 示例 1: 创建新模块

```
用户: "在 apps/web-ele/src/views 下创建一个新的 HRM 人事管理模块"

Claude 将：
1. 使用 filesystem MCP 创建目录结构
2. 参考 project rules 生成符合规范的代码
3. 使用 memory MCP 存储模块信息
```

### 示例 2: 代码审查

```
用户: "帮我审查最近的代码提交"

Claude 将：
1. 使用 GitHub MCP 获取最近的 commits
2. 使用 filesystem MCP 读取变更文件
3. 使用 sequential-thinking MCP 分析代码质量
4. 提供审查建议
```

### 示例 3: API 测试

```
用户: "测试一下用户管理相关的所有 API 接口"

Claude 将：
1. 使用 filesystem MCP 查找 API 定义文件
2. 使用 fetch MCP 逐个测试接口
3. 使用 memory MCP 记录测试结果
```

## 禁用特定 MCP

如果某个 MCP 不需要使用，可以在 `.claude/settings.json` 中设置 `disabled: true`：

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "disabled": true  // 禁用此 MCP
    }
  }
}
```

## 故障排查

### 问题 1: MCP 连接失败

**原因**: Node.js 版本过低或 npm 权限问题

**解决**:
```bash
# 检查 Node.js 版本
node --version  # 应该 >= 18.0.0

# 更新 Node.js
nvm install 18
nvm use 18
```

### 问题 2: GitHub Token 无效

**原因**: Token 过期或权限不足

**解决**:
1. 重新生成 GitHub Token
2. 确保勾选了 `repo` 权限
3. 更新环境变量：`export GITHUB_TOKEN="new_token"`

### 问题 3: Filesystem MCP 无法访问文件

**原因**: 配置的路径不正确

**解决**:
检查 `.claude/settings.json` 中的路径配置是否正确：
```json
{
  "mcpServers": {
    "filesystem": {
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/正确的/项目/路径"  // 确保路径正确
      ]
    }
  }
}
```

## 进阶配置

### 自定义 MCP 日志级别

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"],
      "env": {
        "LOG_LEVEL": "debug"  // 启用调试日志
      }
    }
  }
}
```

### 组合使用多个 MCP

最佳实践是组合使用多个 MCP：

```
用户: "分析 vbenjs/vue-vben-admin 仓库的最新架构变化"

Claude 工作流程：
1. GitHub MCP: 获取仓库最新提交
2. Filesystem MCP: 保存代码到临时目录
3. Sequential Thinking MCP: 分析架构变化
4. Memory MCP: 存储分析结果
```

## 团队协作

### 共享 MCP 配置

1. 将 `.claude/settings.json` 提交到 Git
2. 团队成员拉取最新配置
3. 每个人使用 `settings.local.json` 覆盖个人配置

### 个人配置示例

创建 `.claude/settings.local.json`：

```json
{
  "mcpServers": {
    "filesystem": {
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/username/projects/yudao-ui-admin-vben"  // 个人路径
      ]
    }
  }
}
```

## 安全建议

1. ⚠️ **不要提交 Token**: 敏感信息使用环境变量
2. ⚠️ **限制文件访问**: filesystem MCP 只配置必要的目录
3. ⚠️ **定期轮换 Token**: GitHub Token 定期更新
4. ⚠️ **审计权限**: 定期检查 MCP 的访问权限

## 参考文档

- [MCP 官方文档](https://modelcontextprotocol.io/)
- [Claude Code 配置指南](https://docs.anthropic.com/claude/docs)
- [项目 CLAUDE.md](../../CLAUDE.md)

---

**最后更新**: 2026-08-27
**维护者**: Claude AI Assistant
