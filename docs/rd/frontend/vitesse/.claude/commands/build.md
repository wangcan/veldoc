---
name: build
description: 构建生产版本
---

# 构建生产版本

使用 vite-ssg 构建静态站点。

```bash
pnpm build
```

## 构建输出

构建完成后，静态文件位于 `dist/` 目录：

```
dist/
├── index.html
├── assets/
│   ├── index.[hash].js
│   └── index.[hash].css
├── pwa-*.png
└── sitemap.xml
```

## 预览构建结果

```bash
pnpm preview
```

## 注意事项

- 构建前确保所有页面可静态生成
- 动态内容需要在 `vite.config.ts` 中配置 `ssgOptions`
- 检查构建日志中的警告信息
