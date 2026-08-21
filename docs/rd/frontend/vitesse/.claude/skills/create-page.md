---
name: create-page
description: 创建新的页面组件，配置路由和布局
---

# 创建页面组件

这个 skill 用于创建新的页面组件，配置路由和布局。

## 使用场景

当需要创建新的页面时使用此 skill。

## 执行步骤

1. **确定路由路径**
   - 确定页面的 URL 路径
   - 确定是否需要动态路由参数
   - 确定文件位置（`src/pages/`）

2. **选择布局**
   - 从现有布局中选择（default、home、404）
   - 或创建新的布局组件

3. **创建页面文件**
   - 使用 `<script setup lang="ts">` 语法
   - 设置页面元信息
   - 实现页面逻辑
   - 使用 UnoCSS 样式

4. **配置国际化**
   - 在语言文件中添加翻译键
   - 使用 `useI18n()` 获取翻译函数

## 页面模板

### 基础页面模板

```vue
<script setup lang="ts">
/**
 * [页面名称]
 * @description [页面描述]
 */

defineOptions({
  name: '[PageName]Page',
})

const { t } = useI18n()

useHead({
  title: () => t('[translation-key]'),
})
</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
    <!-- 页面内容 -->
  </div>
</template>

<route lang="yaml">
meta:
  layout: default
</route>
```

### 动态路由页面模板

```vue
<script setup lang="ts">
/**
 * [页面名称]
 * @description [页面描述]
 */

defineOptions({
  name: '[PageName]Page',
})

const route = useRoute()
const router = useRouter()
const param = computed(() => route.params.param as string)

const { t } = useI18n()

useHead({
  title: () => t('[translation-key]'),
})

// 加载数据
const data = ref(null)
const loading = ref(true)

onMounted(async () => {
  // 加载数据逻辑
  loading.value = false
})
</script>

<template>
  <div v-if="loading" class="text-center py-8">
    Loading...
  </div>
  <div v-else class="max-w-4xl mx-auto p-6">
    <!-- 页面内容 -->
  </div>
</template>

<route lang="yaml">
meta:
  layout: default
</route>
```

## 路由配置规则

### 文件路径映射

- `src/pages/index.vue` → `/`
- `src/pages/about.vue` → `/about`
- `src/pages/users/index.vue` → `/users`
- `src/pages/users/[id].vue` → `/users/:id`
- `src/pages/users/[id]/settings.vue` → `/users/:id/settings`

### 路由元信息

在页面中使用 `<route>` 块配置元信息：

```vue
<route lang="yaml">
meta:
  layout: admin
  requiresAuth: true
  title: 'Admin Dashboard'
</route>
```

## 布局选择

### default 布局
- 标准页面布局
- 包含页眉和页脚
- 适用于大多数页面

### home 布局
- 首页布局
- 居中显示
- 适用于落地页、首页

### 404 布局
- 404 错误页面布局
- 简洁显示错误信息

### 自定义布局
如需新布局，在 `src/layouts/` 创建：

```vue
<!-- src/layouts/admin.vue -->
<script setup lang="ts">
// 布局逻辑
</script>

<template>
  <div class="min-h-screen flex">
    <aside class="w-64">
      <!-- 侧边栏 -->
    </aside>
    <main class="flex-1">
      <slot />
    </main>
  </div>
</template>
```

## 国际化配置

在对应的语言文件中添加翻译键：

```yaml
# locales/en.yml
page:
  title: 'Page Title'
  description: 'Page Description'
```

```yaml
# locales/zh-CN.yml
page:
  title: '页面标题'
  description: '页面描述'
```

## 注意事项

1. 页面组件放在 `src/pages/` 目录
2. 使用 `defineOptions` 设置组件名称（以 `Page` 结尾）
3. 总是设置页面标题（`useHead`）
4. 为异步数据提供加载状态
5. 处理路由参数错误和数据加载失败
6. 使用国际化管理页面文本
7. 遵循代码规范和命名约定
