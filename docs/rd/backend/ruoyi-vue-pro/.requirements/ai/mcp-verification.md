# MCP 配置成功验证

## ✅ 配置状态

**验证时间：** 2026-08-27 21:40

### 已成功配置的 MCP 服务器

1. **Filesystem MCP** - `mcp-server-filesystem`
   - 状态：✔ Connected
   - 功能：项目文件系统访问
   - 路径：`/data/project/java/ruoyi-vue-pro`

2. **MySQL MCP** - `mcp-server-mysql`
   - 状态：✔ Connected
   - 功能：数据库查询和操作
   - 数据库：`ruoyi-vue-pro`
   - 主机：127.0.0.1:3306

## 配置方法

### 方法一：使用 Claude Code CLI 命令（推荐）

```bash
# 添加 Filesystem MCP
claude mcp add filesystem -- mcp-server-filesystem /data/project/java/ruoyi-vue-pro

# 添加 MySQL MCP
claude mcp add mysql \
  -e MYSQL_HOST=127.0.0.1 \
  -e MYSQL_PORT=3306 \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=lptdata123 \
  -e MYSQL_DATABASE=ruoyi-vue-pro \
  -- mcp-server-mysql

# 查看已配置的 MCP
claude mcp list

# 移除 MCP
claude mcp remove <name>
```

### 方法二：手动编辑配置文件

编辑 `.claude/settings.local.json`：

```json
{
  "mcpServers": {
    "mysql": {
      "command": "mcp-server-mysql",
      "env": {
        "MYSQL_HOST": "127.0.0.1",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASSWORD": "lptdata123",
        "MYSQL_DATABASE": "ruoyi-vue-pro"
      }
    },
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["/data/project/java/ruoyi-vue-pro"]
    }
  }
}
```

## 使用示例

### 在 Claude Code 中使用 MySQL MCP

直接向 Claude 发送请求：

```
查询 system_user 表的前 5 条记录
```

Claude 会自动使用 MySQL MCP 执行查询。

### 使用 Filesystem MCP

```
列出项目根目录的所有文件
```

## 验证命令

```bash
# 查看 MCP 状态
claude mcp list

# 测试 MySQL MCP
# 在 Claude Code 中请求：查询 system_user 表数量

# 测试 Filesystem MCP
# 在 Claude Code 中请求：读取 CLAUDE.md 文件
```

## 常见问题

### Q: 为什么 `/mcp` 显示 "No MCP servers configured"？

**A:** 可能的原因：
1. 配置文件格式错误
2. MCP 服务器未安装
3. 需要使用 `claude mcp add` 命令添加

**解决方案：**
使用 `claude mcp add` 命令添加 MCP 服务器，而不是手动编辑配置文件。

### Q: MySQL MCP 连接失败？

**A:** 检查：
1. MySQL 服务是否运行：`systemctl status mysql`
2. 数据库连接参数是否正确
3. 用户权限是否足够

### Q: 如何重新加载 MCP 配置？

**A:**
- 方法一：重启 Claude Code
- 方法二：使用 `claude mcp remove` 和 `claude mcp add` 重新配置

## 相关文档

- 详细配置说明：`.requirements/ai/mcp.md`
- 项目配置：`.claude/settings.local.json`
- MCP 官方文档：https://modelcontextprotocol.io/
