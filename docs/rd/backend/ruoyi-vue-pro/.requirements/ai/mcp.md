# MCP (Model Context Protocol) 配置说明

## 概述

本文档介绍了为 ruoyi-vue-pro 项目配置的 MCP 服务器，包括各 MCP 的特点、作用和使用场景。

## 已配置的 MCP 列表

### 1. MySQL MCP (`@benborla29/mcp-server-mysql`)

**特点：**
- 直接连接 MySQL 数据库进行查询和操作
- 支持执行 SQL 语句、查询表结构、分析数据
- 支持读写操作，可以进行数据修改
- 无需离开 Claude Code 即可操作数据库

**作用：**
- 快速查询和验证数据库数据
- 执行数据迁移和初始化脚本
- 分析表结构和索引
- 调试数据库相关问题

**使用场景示例：**
```
- 查询用户表数据：SELECT * FROM system_user LIMIT 10
- 查看表结构：DESCRIBE system_menu
- 分析索引：SHOW INDEX FROM system_user
- 统计数据：SELECT COUNT(*) FROM system_user
```

**安装命令：**
```bash
npm install -g @benborla29/mcp-server-mysql
```

**配置位置：** `.claude/settings.local.json`

---

### 2. Filesystem MCP (`@modelcontextprotocol/server-filesystem`)

**特点：**
- 安全的文件系统访问
- 支持读写文件、目录操作
- 支持文件搜索和监控
- 可以限定访问目录范围，提高安全性

**作用：**
- 批量处理文件
- 代码生成和重构
- 项目结构分析
- 配置文件管理

**使用场景示例：**
```
- 读取配置文件：查看 application.yaml
- 批量修改：更新所有 Controller 注解
- 代码生成：生成 Entity、Mapper、Service
- 文件搜索：查找所有包含特定注解的文件
```

**安装命令：**
```bash
npm install -g @modelcontextprotocol/server-filesystem
```

**配置位置：** `.claude/settings.local.json`

---

### 3. GitHub MCP (`@modelcontextprotocol/server-github`) ⚠️

**状态：** 已弃用 (Deprecated)

**特点：**
- 连接 GitHub/Gitee 代码仓库
- 支持查看 Issue、PR、代码审查
- 支持创建和管理仓库资源

**注意：** 此包已被 npm 标记为弃用，建议使用 GitHub CLI (`gh`) 或其他替代方案。

**替代方案：**
- 使用 `gh` 命令行工具
- 使用 GitHub REST API
- 使用 Git 命令进行版本控制

**安装命令：**
```bash
# 不推荐安装，仅作为参考
npm install -g @modelcontextprotocol/server-github
```

---

## 配置文件示例

### settings.local.json 完整配置

```json
{
  "description": "本地个人配置，此文件不会提交到Git。请根据本地环境配置数据库连接等信息。",
  "mcpServers": {
    "mysql": {
      "command": "mcp-server-mysql",
      "env": {
        "MYSQL_HOST": "localhost",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASSWORD": "请在本地配置您的数据库密码",
        "MYSQL_DATABASE": "ruoyi-vue-pro"
      }
    },
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["/data/project/java/ruoyi-vue-pro"]
    },
    "github": {
      "command": "mcp-server-github",
      "env": {
        "GITHUB_TOKEN": "请在本地配置您的GitHub Token"
      }
    }
  }
}
```

## MCP 安装说明

### 前置条件

确保系统已安装：
- Node.js 18+
- npm 包管理器

### 安装 MCP 服务器

```bash
# 安装 MySQL MCP 服务器（支持读写操作）
npm install -g @benborla29/mcp-server-mysql

# 安装 Filesystem MCP 服务器
npm install -g @modelcontextprotocol/server-filesystem

# 安装 GitHub MCP 服务器（已弃用，不推荐）
# npm install -g @modelcontextprotocol/server-github
```

### 验证安装

```bash
# 检查可执行文件是否可用
which mcp-server-mysql
which mcp-server-filesystem

# 或者直接运行查看帮助信息
mcp-server-mysql --help
mcp-server-filesystem --help
```

### 配置环境变量

在 `settings.local.json` 中配置必要的环境变量：

```json
{
  "mcpServers": {
    "mysql": {
      "env": {
        "MYSQL_HOST": "localhost",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASSWORD": "your_password_here",
        "MYSQL_DATABASE": "ruoyi-vue-pro"
      }
    }
  }
}
```

**重要提示：**
- `settings.local.json` 文件已在 `.gitignore` 中，不会提交到 Git
- 请务必修改 `MYSQL_PASSWORD` 为您的实际数据库密码
- 如果 MySQL 不在本地，请修改 `MYSQL_HOST`

## 使用 MCP

### 验证 MCP 连接

启动 Claude Code 后，MCP 服务器会自动加载。可通过以下方式验证：

1. **查看 MCP 状态**：在 Claude Code 中执行 `/mcp` 命令
2. **测试 MySQL MCP**：请求查询数据库表
3. **测试 Redis MCP**：请求查看 Redis keys

### 常用命令

```bash
# 查看已加载的 MCP
/mcp

# 重新加载 MCP
/mcp-reload
```

## MCP 安全注意事项

1. **敏感信息保护**：
   - `settings.local.json` 不应提交到 Git
   - 数据库密码、Token 等应使用环境变量

2. **权限控制**：
   - GitHub Token 应使用最小权限原则
   - 数据库用户应有适当的权限限制

3. **网络安全**：
   - 确保 MySQL、Redis 只监听本地或内网
   - 使用 SSL/TLS 连接生产环境

## 项目特定的 MCP 使用建议

### 数据库操作 (MySQL MCP)

使用 MySQL MCP 可以直接在 Claude Code 中查询和操作数据库：

```sql
-- 查看项目所有表
SHOW TABLES;

-- 查看用户表结构
DESCRIBE system_user;

-- 查询菜单树
SELECT id, name, parent_id, sort
FROM system_menu
WHERE deleted = 0
ORDER BY parent_id, sort;

-- 查询用户数量
SELECT COUNT(*) as user_count FROM system_user WHERE deleted = 0;

-- 查看最近的操作日志
SELECT * FROM system_operate_log ORDER BY create_time DESC LIMIT 10;
```

### 文件系统操作 (Filesystem MCP)

使用 Filesystem MCP 可以安全地访问项目文件：

```
- 查看项目结构
- 读取配置文件 (application.yaml)
- 批量处理代码文件
- 生成代码模板
```

### GitHub/Gitee 操作

推荐使用 `gh` 命令行工具（GitHub CLI）：

```bash
# 查看项目 Issues
gh issue list --repo YunaiV/ruoyi-vue-pro

# 创建 Pull Request
gh pr create --title "feat: 新功能" --body "描述"

# 查看提交历史
gh repo view YunaiV/ruoyi-vue-pro

# 克隆项目
gh repo clone YunaiV/ruoyi-vue-pro
```

如果使用 Gitee，可以使用 `git` 命令：

```bash
# 查看远程仓库
git remote -v

# 推送代码
git push origin custom

# 查看提交历史
git log --oneline -10
```

## 常见问题

### Q: MCP 连接失败？

**A:** 检查以下几点：
1. MCP 服务器是否已安装（运行 `which mcp-server-mysql` 检查）
2. 环境变量配置是否正确
3. 网络连接是否正常
4. 重启 Claude Code 以重新加载配置

### Q: MySQL MCP 无法连接数据库？

**A:** 检查：
1. MySQL 服务是否启动（`systemctl status mysql`）
2. 数据库连接参数是否正确
3. 用户是否有访问权限
4. 数据库是否存在（`SHOW DATABASES;`）
5. 防火墙是否允许连接

### Q: Filesystem MCP 访问被拒绝？

**A:** 确保：
1. 配置中的路径正确（args 参数）
2. Claude Code 有访问该目录的权限
3. 目录存在且可读

### Q: 如何测试 MCP 是否正常工作？

**A:**
1. 在 Claude Code 中输入 `/mcp` 查看已加载的 MCP
2. 尝试简单的数据库查询测试 MySQL MCP
3. 尝试读取文件测试 Filesystem MCP

## 参考资料

- [MCP 官方文档](https://modelcontextprotocol.io/)
- [Claude Code MCP 指南](https://docs.anthropic.com/claude-code/mcp)
- [ruoyi-vue-pro 项目文档](https://doc.iocoder.cn)

---

**最后更新：** 2026-08-27
**维护者：** Claude Code
