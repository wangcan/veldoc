---
name: create-component
description: 创建新的 Vue 组件，支持自动生成模板和类型定义
trigger: /create-component
---

# 创建 Vue 组件技能

使用此技能快速创建符合项目规范的 Vue 组件。

## 使用方法

```
/create-component <组件名称> [描述]
```

## 示例

```
/create-component ImageGallery 图片画廊组件，支持网格展示和灯箱预览
```

## 执行步骤

1. 确认组件名称和功能描述
2. 选择组件类型：
   - 全局组件 (The*)
   - 基础组件 (Base*)
   - 功能模块组件
3. 在 `src/components/` 目录创建组件文件
4. 生成符合规范的组件代码
5. 添加必要的类型定义
6. 确保响应式设计支持

## 组件模板

根据组件类型选择合适的模板：

### 基础 UI 组件

```vue
<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()
</script>

<template>
  <button
    class="base-button"
    :class="[variant, size]"
    :disabled="disabled"
    @click="emit('click', $event)"
  >
    <slot />
  </button>
</template>
```

### 功能模块组件

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// Props 和 Emits 定义
interface Props {
  // 属性定义
}

const props = defineProps<Props>()

// 响应式状态
const state = ref()

// 计算属性
const computed = computed(() => {})

// 生命周期
onMounted(() => {
  // 初始化逻辑
})
</script>

<template>
  <div class="module-component">
    <!-- 响应式布局 -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <!-- 内容 -->
    </div>
  </div>
</template>
```

## 注意事项

- 组件文件自动全局注册，无需手动 import
- 使用 UnoCSS 原子类优先，必要时添加 scoped 样式
- 确保移动端和桌面端都有良好的体验
