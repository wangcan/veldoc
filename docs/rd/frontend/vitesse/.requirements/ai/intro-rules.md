# Rules 目录分析

## 目录概述

`.claude/rules/` 目录存放项目开发规则文件。这些规则会被 Claude 自动加载到上下文中，指导代码生成和重构行为。

## 文件列表

| 文件 | 描述 |
|------|------|
| `vue-style.md` | Vue 开发规范 |
| `typescript-style.md` | TypeScript 开发规范 |
| `responsive-design.md` | 响应式设计规范 |

---

## 1. vue-style.md

### 核心内容

#### 组件结构

定义了 Vue 单文件组件的标准顺序：
1. `<script setup>` - 逻辑层
2. `<template>` - 模板层
3. `<style>` - 样式层

#### Props 定义

推荐使用 TypeScript 接口：
```typescript
interface Props {
  id: string
  title: string
  items: Item[]
  config?: Config
}
const props = defineProps<Props>()
```

#### Emits 定义

使用类型化 Emits：
```typescript
const emit = defineEmits<{
  change: [value: string]
  submit: []
}>()
```

#### 组件命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 全局单例 | `The*.vue` | TheHeader.vue |
| 基础组件 | `Base*.vue` | BaseButton.vue |
| 功能组件 | 功能前缀 | ImageGallery.vue |

#### 响应式数据

- 简单类型使用 `ref`
- 对象类型使用 `reactive` 或 `ref`

#### 组合式函数

- 放置在 `src/composables/` 目录
- 使用 `use` 前缀命名
- 返回响应式引用或方法

#### 模板最佳实践

- `v-for` 始终提供 `key`
- 频繁切换用 `v-show`
- 条件渲染用 `v-if`

#### 样式规范

- 优先使用 UnoCSS 原子类
- 仅在必要时使用 scoped CSS

### 作用

确保生成的 Vue 组件代码符合项目规范，包括结构、类型定义、命名和最佳实践。

---

## 2. typescript-style.md

### 核心内容

#### 类型定义

- 对象类型使用 `interface`
- 联合类型、映射类型使用 `type`

#### 函数类型

显式类型注解：
```typescript
function fetchUser(id: string): Promise<User> {
  return fetch(`/api/users/${id}`).then(res => res.json())
}
```

#### 泛型使用

泛型函数和泛型接口的定义规范。

#### 类型断言

谨慎使用 `as`，优先使用类型守卫。

#### 类型导入

使用 `type` 关键字区分类型导入：
```typescript
import type { User, Status } from './types'
```

#### 常用工具类型

- `Partial<T>` - 所有属性可选
- `Required<T>` - 所有属性必选
- `Pick<T, K>` - 选取部分属性
- `Omit<T, K>` - 排除部分属性
- `Record<K, T>` - 构造对象类型

#### Vue 相关类型

- 组件实例类型
- Props 类型
- Store 类型

### 作用

确保 TypeScript 代码的类型安全和一致性，提供常用工具类型的使用指南。

---

## 3. responsive-design.md

### 核心内容

#### 设计原则

- **移动优先**：默认样式针对移动端
- 使用断点逐步增强桌面端体验

#### 断点系统

| 断点 | 最小宽度 | 典型设备 |
|------|---------|---------|
| `sm` | 640px | 大手机/小平板 |
| `md` | 768px | 平板竖屏 |
| `lg` | 1024px | 平板横屏/笔记本 |
| `xl` | 1280px | 桌面显示器 |
| `2xl` | 1536px | 大屏显示器 |

#### 布局模式

- 弹性布局：`flex flex-col md:flex-row`
- 网格布局：`grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`
- 容器宽度：`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`

#### 字体大小

响应式排版示例：
```vue
<h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold">
  响应式标题
</h1>
```

#### 间距系统

响应式间距：`py-8 md:py-12 lg:py-16`

#### 图片处理

- 固定比例：`aspect-video`
- 响应式尺寸：`w-full max-w-md lg:max-w-lg`

#### 导航设计

- 移动端：汉堡菜单
- 桌面端：水平导航

#### 表单设计

- 触摸友好尺寸：最小 44×44px
- 按钮最小高度：44px

#### 表格响应式

- 移动端：卡片列表
- 桌面端：表格视图

#### 测试清单

响应式设计测试要点：
- 320px - 1920px 各种屏幕尺寸
- 导航、图片、表单、按钮、文字等元素

### 作用

确保生成的代码支持响应式设计，满足项目"PC 端和移动端"双端支持的目标。

---

## 目录作用总结

### 1. 自动加载上下文

规则文件会被自动加载到 Claude 的上下文中：
- 无需手动引用
- 在所有代码生成任务中生效
- 确保规范一致性

### 2. 规范文档化

将开发规范以 Markdown 形式记录：
- 清晰的代码示例
- 详细的说明文档
- 易于维护和更新

### 3. 多维度覆盖

三个规则文件覆盖了：
- **框架层面**：Vue 组件开发规范
- **语言层面**：TypeScript 类型规范
- **设计层面**：响应式设计规范

## 规则优先级

规则文件的内容会在 Claude 生成代码时自动生效，优先级高于 Claude 的默认行为，但低于用户的显式指令。

## 扩展建议

可根据项目需要添加更多规则：

| 潜在规则 | 用途 |
|---------|------|
| `api-style.md` | API 调用和错误处理规范 |
| `testing-style.md` | 测试编写规范 |
| `accessibility.md` | 无障碍设计规范 |
| `performance.md` | 性能优化规范 |
| `security.md` | 安全编码规范 |
