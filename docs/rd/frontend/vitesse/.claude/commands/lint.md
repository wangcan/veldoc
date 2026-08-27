---
name: lint
description: 代码检查和格式化
---

# 代码检查

使用 ESLint 进行代码检查和自动修复。

```bash
# 运行检查
pnpm lint

# 自动修复
pnpm lint --fix
```

## 配置文件

项目使用 `@antfu/eslint-config`，配置位于：
- `eslint.config.js` - ESLint 配置

## 检查规则

- Vue 3 推荐规则
- TypeScript 严格规则
- UnoCSS 类名排序
- 自动导入检查

## Git Hooks

项目配置了 `simple-git-hooks`：
- `pre-commit`: 自动运行 `lint-staged`
- 只检查暂存的文件

## 类型检查

```bash
pnpm typecheck
```

检查 TypeScript 类型错误。
