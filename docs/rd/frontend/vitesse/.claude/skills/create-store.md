---
name: create-store
description: 创建 Pinia Store，使用 Composition API 风格
trigger: /create-store
---

# 创建 Pinia Store 技能

使用此技能快速创建符合项目规范的 Pinia Store。

## 使用方法

```
/create-store <store名称> [描述]
```

## 示例

```
/create-store gallery 图片画廊状态管理
/create-store user 用户信息和认证状态
/create-store reading 阅读进度和书签管理
```

## 执行步骤

1. 确认 Store 名称和功能描述
2. 定义状态结构
3. 确定需要的 actions 和 getters
4. 在 `src/stores/` 目录创建 Store 文件
5. 添加 TypeScript 类型定义
6. 考虑 SSR 兼容性

## Store 模板

### 基础 Store

```typescript
// src/stores/example.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useExampleStore = defineStore('example', () => {
  // State
  const items = ref<Item[]>([])
  const loading = ref(false)

  // Getters
  const hasItems = computed(() => items.value.length > 0)

  // Actions
  function addItem(item: Item) {
    items.value.push(item)
  }

  return {
    items,
    loading,
    hasItems,
    addItem,
  }
})
```

### 带持久化的 Store

```typescript
// src/stores/preferences.ts
import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export const usePreferencesStore = defineStore('preferences', () => {
  const theme = ref<'light' | 'dark'>('light')
  const fontSize = ref(16)

  // 持久化到 localStorage
  watch([theme, fontSize], () => {
    if (import.meta.client) {
      localStorage.setItem('preferences', JSON.stringify({
        theme: theme.value,
        fontSize: fontSize.value,
      }))
    }
  }, { immediate: true })

  return {
    theme,
    fontSize,
  }
})
```

### 异步数据 Store

```typescript
// src/stores/data.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useDataStore = defineStore('data', () => {
  const data = ref<DataItem[]>([])
  const loading = ref(false)
  const error = ref<Error | null>(null)

  // Getters
  const dataById = computed(() => {
    return Object.fromEntries(data.value.map(item => [item.id, item]))
  })

  // Actions
  async function fetchData() {
    loading.value = true
    error.value = null
    try {
      const response = await fetch('/api/data')
      data.value = await response.json()
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  return {
    data,
    loading,
    error,
    dataById,
    fetchData,
  }
})
```

## 命名规范

- 文件名: `kebab-case-store.ts`
- Store ID: `kebab-case`
- 函数名: `useKebabCaseStore`
- 类型导出: `export type ExampleStore = ReturnType<typeof useExampleStore>`

## SSR 注意事项

对于 vite-ssg 项目：
- 避免在 Store 初始化时访问 `window` 或 `document`
- 使用 `import.meta.client` 检查客户端环境
- 在 `modules/pinia.ts` 中处理状态序列化
