# Commands 目录分析

## 目录概述

`.claude/commands/` 目录存放自定义斜杠命令定义文件。每个命令是一个 Markdown 文件，定义了可通过 `/命令名` 触发的快捷操作。

## 文件列表

| 文件 | 命令 | 描述 |
|------|------|------|
| `build.md` | `/build` | 构建生产版本 |
| `dev.md` | `/dev` | 启动开发服务器 |
| `lint.md` | `/lint` | 代码检查和格式化 |
| `test.md` | `/test` | 运行测试 |

---

## 1. build.md

### 基本信息

```yaml
name: build
description: 构建生产版本
```

### 内容摘要

- **命令**: `pnpm build`
- **构建输出**: `dist/` 目录结构说明
- **预览命令**: `pnpm preview`
- **注意事项**: SSG 配置和构建警告检查

### 作用

快速触发项目构建，提供构建输出位置和预览方法的说明。适用于需要生成静态站点的场景。

---

## 2. dev.md

### 基本信息

```yaml
name: dev
description: 启动开发服务器
```

### 内容摘要

- **命令**: `pnpm dev`（默认端口 3333）
- **命令选项**:
  - `--port <port>` - 指定端口
  - `--host` - 监听所有网络接口
  - `--open` - 自动打开浏览器
- **使用示例**: 不同场景下的命令示例

### 作用

提供开发服务器启动的快捷方式，包含常用选项说明。适用于日常开发调试。

---

## 3. lint.md

### 基本信息

```yaml
name: lint
description: 代码检查和格式化
```

### 内容摘要

- **命令**: `pnpm lint` 和 `pnpm lint --fix`
- **配置文件**: `eslint.config.js`，使用 `@antfu/eslint-config`
- **检查规则**: Vue 3、TypeScript、UnoCSS、自动导入
- **Git Hooks**: `pre-commit` 自动运行 `lint-staged`
- **类型检查**: `pnpm typecheck`

### 作用

快速执行代码质量检查，了解项目的代码规范配置。适用于代码提交前的质量保障。

---

## 4. test.md

### 基本信息

```yaml
name: test
description: 运行测试
```

### 内容摘要

- **单元测试**: `pnpm test`（Vitest）
- **E2E 测试**: `pnpm test:e2e`（Cypress）
- **测试文件位置**:
  - 单元测试: `test/**/*.test.ts`
  - E2E 测试: `cypress/**/*.cy.ts`
- **测试示例**: Vitest 单元测试代码模板

### 作用

快速运行测试套件，提供测试框架使用说明。适用于确保代码质量和功能正确性。

---

## 目录作用总结

### 1. 常用命令快捷访问

将高频使用的命令封装为斜杠命令：

```
/build  → pnpm build
/dev    → pnpm dev
/lint   → pnpm lint
/test   → pnpm test
```

### 2. 命令文档化

每个命令文件不仅是触发器，也是文档：
- 提供命令选项说明
- 包含使用示例
- 说明配置细节

### 3. 团队协作一致性

确保所有开发者：
- 使用相同的命令参数
- 了解命令的输出和作用
- 遵循项目的测试和构建流程

## 使用方式

在 Claude Code 中直接输入斜杠命令：

```
/dev
/build
/lint --fix
/test
```

## 命令与 Skill 的区别

| 特性 | Commands | Skills |
|------|----------|--------|
| 触发方式 | `/命令名` | `/skill名` 或自动触发 |
| 用途 | 快速执行固定命令 | 多步骤交互式任务 |
| 复杂度 | 简单命令包装 | 包含复杂逻辑和模板 |
| 示例 | `/dev` 启动服务器 | `/create-component` 生成组件 |

## 扩展建议

可根据项目需要添加更多命令：

| 潜在命令 | 用途 |
|---------|------|
| `preview.md` | 预览构建结果 |
| `clean.md` | 清理构建产物和缓存 |
| `update.md` | 更新项目依赖 |
| `analyze.md` | 分析构建产物大小 |
