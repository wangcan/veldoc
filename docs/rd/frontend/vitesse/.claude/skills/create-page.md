---
name: create-page
description: 创建新的页面，自动处理路由配置和布局选择
trigger: /create-page
---

# 创建页面技能

使用此技能快速创建符合项目规范的 Vue 页面。

## 使用方法

```
/create-page <页面路径> [描述]
```

## 示例

```
/create-page gallery/index 图片画廊列表页
/create-page gallery/[id] 图片详情页，显示单张图片
/create-page books/[id]/[chapter] 书籍章节阅读页
```

## 执行步骤

1. 确认页面路径和功能描述
2. 确定路由类型：
   - 静态路由 (`index.vue`)
   - 动态路由 (`[id].vue`)
   - 嵌套路由 (目录结构)
3. 选择合适的布局
4. 在 `src/pages/` 目录创建页面文件
5. 生成页面代码，包括：
   - SEO 元信息
   - 响应式布局
   - 必要的组件引用

## 页面模板

### 列表页

```vue
<script setup lang="ts">
import { useHead } from '@unhead/vue'

useHead({
  title: '页面标题',
  meta: [
    { name: 'description', content: '页面描述' },
  ],
})

// 列表数据
const items = ref([])
</script>

<template>
  <div class="page-list p-4 md:p-6">
    <h1 class="text-2xl md:text-3xl font-bold mb-6">页面标题</h1>
    
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      <!-- 列表项 -->
    </div>
  </div>
</template>
```

### 详情页（动态路由）

```vue
<script setup lang="ts">
import { useRoute } from 'vue-router/auto'

const route = useRoute('/gallery/[id]')

// 使用路由参数
const id = computed(() => route.params.id)

// 获取详情数据
const detail = ref(null)

onMounted(async () => {
  // 加载数据
})
</script>

<template>
  <div class="page-detail p-4 md:p-6">
    <h1 class="text-2xl md:text-3xl font-bold mb-6">{{ detail?.title }}</h1>
    
    <!-- 详情内容 -->
  </div>
</template>
```

## 布局配置

```vue
<route lang="yaml">
definePage:
  layout: home
</route>
```

## Markdown 页面

对于简单的内容页面，可以使用 Markdown：

```markdown
---
title: 页面标题
description: 页面描述
---

# 标题

页面内容...
```
