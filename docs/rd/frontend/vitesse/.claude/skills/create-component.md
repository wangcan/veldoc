---
name: create-component
description: 创建新的 Vue 组件，遵循项目规范
---

# 创建 Vue 组件

这个 skill 用于创建新的 Vue 组件，遵循 Vitesse 项目规范。

## 使用场景

当需要创建新的 Vue 组件时使用此 skill。

## 执行步骤

1. **理解需求**
   - 确定组件的功能和职责
   - 确定组件的位置（components 目录）
   - 确定组件的类型（页面组件、布局组件、通用组件）

2. **设计接口**
   - 定义 Props 接口
   - 定义 Emits 接口
   - 定义 Slots（如有需要）

3. **创建组件文件**
   - 使用 `<script setup lang="ts">` 语法
   - 提供完整的类型定义
   - 使用 UnoCSS 原子类
   - 遵循代码规范

4. **添加文档**
   - 添加组件注释
   - 提供 Props 和 Emits 说明
   - 提供使用示例

## 组件模板

### 基础组件模板

```vue
<script setup lang="ts">
/**
 * [组件名称]
 * @description [组件描述]
 * 
 * @example
 * ```vue
 * <[ComponentName] />
 * ```
 */

// 类型定义
interface Props {
  // 定义 props
}

interface Emits {
  // 定义 emits
}

// Props 和 Emits
const props = withDefaults(defineProps<Props>(), {
  // 默认值
})

const emit = defineEmits<Emits>()

// 响应式状态
// const localState = ref()

// 计算属性
// const computed = computed(() => {})

// 方法
// function method() {}

// 生命周期钩子
// onMounted(() => {})
</script>

<template>
  <div class="[组件样式]">
    <!-- 组件内容 -->
  </div>
</template>
```

## 命名约定

- **文件名**: PascalCase（例如：`UserProfile.vue`）
- **组件名**: 在 `defineOptions` 中设置（例如：`UserProfile`）
- **全局组件**: 以 `The` 开头（例如：`TheHeader`）

## 注意事项

1. 使用 Composition API 和 `<script setup>` 语法
2. 自动导入的 API 无需手动 import
3. 样式优先使用 UnoCSS 原子类
4. 遵循 TypeScript 类型定义规范
5. 遵循 ESLint 规则（单引号、无分号）
6. 组件职责单一，保持简洁
