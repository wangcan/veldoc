---
name: dev
description: 启动开发服务器
---

# 启动开发服务器

启动 Vite 开发服务器，默认端口 3333。

```bash
pnpm dev
```

## 选项

- `--port <port>` - 指定端口
- `--host` - 监听所有网络接口
- `--open` - 自动打开浏览器

## 示例

```bash
# 默认启动
pnpm dev

# 指定端口
pnpm dev --port 3000

# 局域网访问
pnpm dev --host
```
