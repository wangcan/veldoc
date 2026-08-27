# Vue 开发规范

## 组件结构

### 选项顺序

Vue 单文件组件应按以下顺序组织：

1. `<script setup>` - 逻辑层
2. `<template>` - 模板层
3. `<style>` - 样式层（如有）

```vue
<script setup lang="ts">
// 1. 导入
import { ref, computed, onMounted } from 'vue'

// 2. Props 定义
interface Props {
  title: string
  count?: number
}
const props = withDefaults(defineProps<Props>(), {
  count: 0,
})

// 3. Emits 定义
const emit = defineEmits<{
  update: [value: number]
}>()

// 4. 响应式状态
const localState = ref(0)

// 5. 计算属性
const doubled = computed(() => props.count * 2)

// 6. 方法
function handleClick() {
  emit('update', localState.value)
}

// 7. 生命周期钩子
onMounted(() => {
  // 初始化
})
</script>

<template>
  <!-- 模板内容 -->
</template>

<style scoped>
/* 样式 */
</style>
```

## Props 定义

### 使用 TypeScript 接口

```typescript
// 推荐
interface Props {
  id: string
  title: string
  items: Item[]
  config?: Config
}

const props = defineProps<Props>()
```

### 设置默认值

```typescript
interface Props {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
})
```

## Emits 定义

### 使用类型化 Emits

```typescript
// 推荐
const emit = defineEmits<{
  change: [value: string]
  submit: []
  update: [id: string, data: Record<string, any>]
}>()

// 调用
emit('change', 'new value')
```

## 组件命名

### 文件命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 全局单例 | `The*.vue` | TheHeader.vue, TheFooter.vue |
| 基础组件 | `Base*.vue` | BaseButton.vue, BaseInput.vue |
| 功能组件 | 功能前缀 | ImageGallery.vue, BookReader.vue |

### 组件内命名

```vue
<template>
  <!-- 使用 PascalCase -->
  <ImageGallery />
  <BookReader />
  
  <!-- 不使用 kebab-case -->
  <!-- <image-gallery /> -->
</template>
```

## 响应式数据

### 使用 ref 和 reactive

```typescript
// 简单类型用 ref
const count = ref(0)
const name = ref('')

// 对象类型用 reactive 或 ref
const state = reactive({
  items: [],
  loading: false,
})

// 或使用 ref
const items = ref<Item[]>([])
```

### 解包响应式值

```typescript
// 在模板中自动解包
<template>
  <div>{{ count }}</div>
</template>

// 在 script 中使用 .value
const doubled = computed(() => count.value * 2)
```

## 组合式函数

### 使用规则

- 放置在 `src/composables/` 目录
- 使用 `use` 前缀命名
- 返回响应式引用或方法

```typescript
// src/composables/useFetch.ts
export function useFetch<T>(url: string) {
  const data = ref<T | null>(null)
  const error = ref<Error | null>(null)
  const loading = ref(false)

  async function execute() {
    loading.value = true
    try {
      const response = await fetch(url)
      data.value = await response.json()
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  return { data, error, loading, execute }
}
```

## 模板最佳实践

### v-for 和 key

```vue
<template>
  <!-- 始终提供 key -->
  <div v-for="item in items" :key="item.id">
    {{ item.name }}
  </div>
</template>
```

### v-if 和 v-show

```vue
<template>
  <!-- 频繁切换用 v-show -->
  <div v-show="isVisible">频繁切换的内容</div>
  
  <!-- 条件渲染用 v-if -->
  <div v-if="hasPermission">需要权限的内容</div>
</template>
```

### 事件处理

```vue
<template>
  <!-- 使用箭头函数 -->
  <button @click="() => handleClick(id)">
    点击
  </button>
  
  <!-- 传递事件对象 -->
  <form @submit="(e) => handleSubmit(e)">
    <button type="submit">提交</button>
  </form>
</template>
```

## 样式规范

### UnoCSS 优先

```vue
<template>
  <!-- 优先使用 UnoCSS 原子类 -->
  <div class="flex items-center justify-between p-4 bg-white dark:bg-gray-800">
    <span class="text-lg font-bold">标题</span>
  </div>
</template>

<style scoped>
/* 仅用于无法用原子类表达的复杂样式 */
.custom-animation {
  animation: custom-animation 0.3s ease;
}
</style>
```
