# Agents 目录分析

## 目录概述

`.claude/agents/` 目录存放自定义子代理定义文件。每个代理是一个独立的 Markdown 文件，包含代理的配置和指令。

## 文件列表

| 文件 | 描述 |
|------|------|
| `component-generator.md` | Vue 组件生成器 |
| `page-generator.md` | Vue 页面生成器 |
| `store-generator.md` | Pinia Store 生成器 |

---

## 1. component-generator.md

### 基本信息

```yaml
name: component-generator
description: 生成 Vue 组件代码的专用代理，遵循项目规范创建高质量的 Vue 3 组件
model: claude-sonnet-5
tools:
  - Read
  - Write
  - Edit
```

### 核心职责

1. 根据用户描述生成符合项目规范的 Vue 3 组件
2. 确保组件支持响应式设计（PC 和移动端）
3. 使用 UnoCSS 原子化类名进行样式设计
4. 添加适当的 TypeScript 类型定义
5. 考虑国际化支持

### 提供的内容

- **组件模板**：标准的 Vue 3 组件结构（script setup + template + style）
- **命名规范**：The*（全局）、Base*（基础）、功能前缀（模块）
- **响应式设计原则**：UnoCSS 响应式前缀使用指南
- **示例用法**：创建图片画廊组件的示例

### 作用

作为专用代码生成器，自动生成符合项目规范的 Vue 组件，减少手动编写样板代码的工作量。

---

## 2. page-generator.md

### 基本信息

```yaml
name: page-generator
description: 生成 Vue 页面代码的专用代理，自动处理路由和布局配置
model: claude-sonnet-5
tools:
  - Read
  - Write
  - Edit
```

### 核心职责

1. 根据用户描述生成符合项目规范的 Vue 页面
2. 自动处理路由配置（文件系统路由）
3. 选择合适的布局组件
4. 确保页面支持响应式设计
5. 考虑 SEO 和性能优化

### 提供的内容

- **页面模板**：基础 Vue 页面和 Markdown 页面模板
- **路由规则**：文件路径到路由路径的映射表
- **布局选择**：default、home、404 布局的使用说明
- **响应式设计**：移动端和桌面端适配要求

### 作用

简化页面创建流程，自动处理路由配置，确保页面符合 SEO 和响应式设计要求。

---

## 3. store-generator.md

### 基本信息

```yaml
name: store-generator
description: 生成 Pinia Store 代码的专用代理，遵循 Composition API 风格
model: claude-sonnet-5
tools:
  - Read
  - Write
  - Edit
```

### 核心职责

1. 根据用户描述生成符合规范的 Pinia Store
2. 使用 Composition API 风格（推荐）
3. 添加适当的 TypeScript 类型
4. 考虑 SSR 兼容性（vite-ssg）

### 提供的内容

- **Store 模板**：完整的 Composition API 风格 Store 示例
- **命名规范**：文件名使用 kebab-case，函数名使用 camelCase
- **SSR 兼容性**：处理 SSR 环境的注意事项
- **示例用法**：创建图片画廊 Store 的示例

### 作用

快速生成状态管理代码，确保 Store 符合 Pinia 最佳实践和 SSR 兼容要求。

---

## 目录作用总结

### 1. 代码生成自动化

三个代理覆盖了 Vue 项目的核心开发场景：
- 组件生成
- 页面生成
- 状态管理生成

### 2. 规范一致性

所有代理都遵循项目定义的规范：
- Vue 3 + TypeScript
- UnoCSS 原子化样式
- 响应式设计
- 文件系统路由

### 3. 开发效率提升

通过预定义模板和最佳实践：
- 减少样板代码编写
- 避免常见错误
- 加速开发流程

## 使用方式

代理通常通过 Skill 工具或直接调用来使用：

```bash
# 通过 Skill 触发（推荐）
/create-component ImageGallery 图片画廊组件

# 或直接指定代理
# Claude 会自动选择合适的代理执行任务
```

## 扩展建议

可根据项目需要添加更多代理：

| 潜在代理 | 用途 |
|---------|------|
| `composable-generator.md` | 生成组合式函数 |
| `api-service-generator.md` | 生成 API 服务层 |
| `test-generator.md` | 生成单元测试和 E2E 测试 |
| `i18n-generator.md` | 生成国际化语言包 |
