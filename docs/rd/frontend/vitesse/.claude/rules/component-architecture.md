---
name: component-architecture
description: Vitesse 项目组件架构设计原则和目录结构
metadata:
  type: project
---

# 组件架构设计

## 目录结构

```
src/
├── components/          # 自动导入的全局组件
│   ├── TheHeader.vue    # 全局页眉
│   ├── TheFooter.vue    # 全局页脚
│   ├── TheCounter.vue   # 计数器组件
│   └── TheInput.vue     # 输入框组件
├── composables/         # 自动导入的组合式函数
│   ├── dark.ts          # 暗色模式切换
│   └── useFetch.ts      # 数据获取
├── layouts/             # 布局组件
│   ├── default.vue      # 默认布局
│   ├── home.vue         # 首页布局
│   └── 404.vue          # 404 页面布局
├── modules/             # 应用模块（自动加载）
│   ├── i18n.ts          # 国际化
│   ├── pinia.ts         # 状态管理
│   ├── pwa.ts           # PWA
│   └── nprogress.ts     # 进度条
├── pages/               # 页面组件（文件系统路由）
│   ├── index.vue        # 首页
│   ├── hi/
│   │   └── [name].vue   # 动态路由
│   └── [...all].vue     # 404 页面
├── stores/              # Pinia 状态管理
│   └── user.ts          # 用户状态
└── styles/              # 全局样式
    └── main.css         # 主样式文件
```

**Why:** 清晰的目录结构有助于代码组织和维护。

**How to apply:** 按照约定的目录结构组织代码。

## 组件分类

### 1. 页面组件 (Pages)

位于 `src/pages/`，通过文件系统自动生成路由。

**职责：**
- 页面级布局和内容
- 页面级状态管理
- 路由参数处理
- 页面元信息设置

**示例：**
```vue
<!-- src/pages/user/[id].vue -->
<script setup lang="ts">
defineOptions({
  name: 'UserDetailPage',
})

const route = useRoute()
const router = useRouter()
const userId = computed(() => route.params.id as string)

const user = ref<User | null>(null)
const loading = ref(true)

onMounted(async () => {
  user.value = await fetchUser(userId.value)
  loading.value = false
})

useHead({
  title: () => user.value?.name || 'User Detail',
})
</script>

<template>
  <div v-if="loading" class="text-center py-8">
    Loading...
  </div>
  <div v-else-if="user" class="max-w-4xl mx-auto p-6">
    <h1 class="text-3xl font-bold mb-4">
      {{ user.name }}
    </h1>
    <p class="text-gray-600">
      {{ user.email }}
    </p>
  </div>
</template>

<route lang="yaml">
meta:
  layout: default
</route>
```

### 2. 布局组件 (Layouts)

位于 `src/layouts/`，定义页面的整体布局结构。

**职责：**
- 页面整体布局
- 全局导航
- 全局页眉和页脚
- 响应式布局切换

**示例：**
```vue
<!-- src/layouts/admin.vue -->
<script setup lang="ts">
const route = useRoute()
const menuItems = [
  { path: '/admin', label: 'Dashboard' },
  { path: '/admin/users', label: 'Users' },
  { path: '/admin/settings', label: 'Settings' },
]
</script>

<template>
  <div class="min-h-screen flex">
    <!-- 侧边栏 -->
    <aside class="w-64 bg-gray-100 dark:bg-gray-800 border-r">
      <nav class="p-4">
        <ul class="space-y-2">
          <li v-for="item in menuItems" :key="item.path">
            <RouterLink
              :to="item.path"
              class="block px-4 py-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
              :class="{ 'bg-teal-100 dark:bg-teal-900': route.path === item.path }"
            >
              {{ item.label }}
            </RouterLink>
          </li>
        </ul>
      </nav>
    </aside>
    
    <!-- 主内容区 -->
    <main class="flex-1 p-6">
      <slot />
    </main>
  </div>
</template>
```

### 3. 全局组件 (Components)

位于 `src/components/`，自动导入，全局可用。

**职责：**
- 可复用的 UI 组件
- 业务无关的通用组件
- 基础组件（按钮、输入框等）

**示例：**
```vue
<!-- src/components/BaseButton.vue -->
<script setup lang="ts">
interface Props {
  type?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
}

interface Emits {
  (e: 'click', event: MouseEvent): void
}

const props = withDefaults(defineProps<Props>(), {
  type: 'primary',
  size: 'md',
  disabled: false,
  loading: false,
})

const emit = defineEmits<Emits>()

const sizeClasses = {
  sm: 'px-2 py-1 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
}

const typeClasses = {
  primary: 'bg-teal-600 text-white hover:bg-teal-700',
  secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300 dark:bg-gray-700 dark:text-white',
  ghost: 'bg-transparent hover:bg-gray-100 dark:hover:bg-gray-800',
}
</script>

<template>
  <button
    class="rounded font-medium transition-colors duration-200"
    :class="[
      sizeClasses[size],
      typeClasses[type],
      { 'opacity-50 cursor-not-allowed': disabled || loading },
    ]"
    :disabled="disabled || loading"
    @click="emit('click', $event)"
  >
    <span v-if="loading" class="inline-block animate-spin mr-2">
      <div i-carbon-renew />
    </span>
    <slot />
  </button>
</template>
```

### 4. 组合式函数 (Composables)

位于 `src/composables/`，自动导入，封装可复用逻辑。

**职责：**
- 封装可复用的逻辑
- 响应式状态管理
- 生命周期管理
- 第三方库集成

**示例：**
```typescript
// src/composables/useFetch.ts
export interface UseFetchOptions<T> {
  immediate?: boolean
  initialData?: T
  onSuccess?: (data: T) => void
  onError?: (error: Error) => void
}

export function useFetch<T>(
  url: string,
  options: UseFetchOptions<T> = {}
) {
  const { immediate = true, initialData } = options
  
  const data = ref<T | undefined>(initialData)
  const error = ref<Error | null>(null)
  const loading = ref(false)
  
  async function execute() {
    loading.value = true
    error.value = null
    
    try {
      const response = await fetch(url)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      data.value = await response.json()
      options.onSuccess?.(data.value)
    } catch (e) {
      error.value = e as Error
      options.onError?.(error.value)
    } finally {
      loading.value = false
    }
  }
  
  if (immediate) {
    execute()
  }
  
  return {
    data,
    error,
    loading,
    execute,
  }
}
```

### 5. Store (State Management)

位于 `src/stores/`，使用 Pinia 管理应用状态。

**职责：**
- 全局状态管理
- 跨组件数据共享
- 数据持久化
- 异步操作

**示例：**
```typescript
// src/stores/user.ts
export interface User {
  id: string
  name: string
  email: string
  avatar?: string
}

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  
  const isLoggedIn = computed(() => !!user.value && !!token.value)
  const displayName = computed(() => user.value?.name || 'Guest')
  
  async function login(credentials: LoginCredentials) {
    const response = await fetch('/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials),
    })
    
    const data = await response.json()
    user.value = data.user
    token.value = data.token
  }
  
  function logout() {
    user.value = null
    token.value = null
  }
  
  return {
    user,
    token,
    isLoggedIn,
    displayName,
    login,
    logout,
  }
})
```

### 6. 模块 (Modules)

位于 `src/modules/`，应用启动时自动加载。

**职责：**
- 应用级配置
- 插件初始化
- 全局中间件
- 路由守卫

**示例：**
```typescript
// src/modules/analytics.ts
export const install: UserModule = ({ router }) => {
  router.afterEach((to, from) => {
    // 页面访问统计
    trackPageView(to.fullPath)
  })
}
```

## 组件设计原则

### 1. 单一职责原则

每个组件应只负责一个功能：

```vue
<!-- ❌ 不推荐：组件职责过多 -->
<UserProfileAndSettings />

<!-- ✅ 推荐：职责分离 -->
<UserProfile />
<UserSettings />
```

### 2. 可复用性

组件应设计为可复用：

```vue
<!-- ❌ 不推荐：硬编码 -->
<div class="bg-teal-600 text-white p-4">
  Submit
</div>

<!-- ✅ 推荐：可配置 -->
<BaseButton type="primary">
  Submit
</BaseButton>
```

### 3. Props 向下，Events 向上

数据流应该是单向的：

```vue
<!-- 父组件 -->
<script setup lang="ts">
const count = ref(0)

function handleUpdate(newCount: number) {
  count.value = newCount
}
</script>

<template>
  <Counter :count="count" @update="handleUpdate" />
</template>

<!-- 子组件 -->
<script setup lang="ts">
interface Props {
  count: number
}

interface Emits {
  (e: 'update', value: number): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

function increment() {
  emit('update', props.count + 1)
}
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

### 4. 组合优于继承

优先使用组合式函数而非混入：

```typescript
// ❌ 不推荐：使用 mixins
const scrollMixin = {
  mounted() {
    window.addEventListener('scroll', this.handleScroll)
  },
  methods: {
    handleScroll() { /* ... */ }
  }
}

// ✅ 推荐：使用组合式函数
function useScroll() {
  const scrollY = ref(0)
  
  onMounted(() => {
    window.addEventListener('scroll', () => {
      scrollY.value = window.scrollY
    })
  })
  
  return { scrollY }
}
```

### 5. 保持组件简单

避免过度抽象：

```vue
<!-- ❌ 过度抽象 -->
<RenderlessCounter v-slot="{ count, increment }">
  <button @click="increment">{{ count }}</button>
</RenderlessCounter>

<!-- ✅ 简单直接 -->
<script setup lang="ts">
const count = ref(0)

function increment() {
  count.value++
}
</script>

<template>
  <button @click="increment">{{ count }}</button>
</template>
```

## 组件通信模式

### 1. Props 和 Emits

父子组件通信的标准方式：

```vue
<!-- 父组件 -->
<template>
  <ChildComponent
    :data="parentData"
    @change="handleChange"
  />
</template>

<!-- 子组件 -->
<script setup lang="ts">
interface Props {
  data: string
}

interface Emits {
  (e: 'change', newValue: string): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()
</script>
```

### 2. Provide/Inject

跨层级组件通信：

```vue
<!-- 祖先组件 -->
<script setup lang="ts">
const theme = ref('light')
provide('theme', theme)
</script>

<!-- 后代组件 -->
<script setup lang="ts">
const theme = inject<Ref<string>>('theme')
</script>
```

### 3. Store

全局状态管理：

```vue
<script setup lang="ts">
const userStore = useUserStore()

// 访问状态
const userName = userStore.displayName

// 调用 action
userStore.login({ username, password })
</script>
```

### 4. 事件总线

简单的组件通信：

```typescript
// src/composables/useEventBus.ts
const eventBus = ref({})

export function useEventBus() {
  function emit(event: string, data?: any) {
    eventBus.value[event] = data
  }
  
  function on(event: string, callback: (data?: any) => void) {
    watch(
      () => eventBus.value[event],
      (newVal) => {
        if (newVal !== undefined) {
          callback(newVal)
          delete eventBus.value[event]
        }
      }
    )
  }
  
  return { emit, on }
}
```

## 组件测试策略

### 1. 单元测试

测试组件逻辑：

```typescript
import { mount } from '@vue/test-utils'
import TheCounter from '~/components/TheCounter.vue'

describe('TheCounter', () => {
  it('renders initial count', () => {
    const wrapper = mount(TheCounter, {
      props: { count: 5 }
    })
    expect(wrapper.text()).toContain('5')
  })
  
  it('emits update event', async () => {
    const wrapper = mount(TheCounter)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('update')).toBeTruthy()
  })
})
```

### 2. 集成测试

测试组件交互：

```typescript
import { mount } from '@vue/test-utils'
import UserForm from '~/components/UserForm.vue'
import { createPinia, setActivePinia } from 'pinia'

describe('UserForm Integration', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
  
  it('updates user store on submit', async () => {
    const wrapper = mount(UserForm)
    const userStore = useUserStore()
    
    await wrapper.find('input[name="name"]').setValue('John')
    await wrapper.find('form').trigger('submit')
    
    expect(userStore.name).toBe('John')
  })
})
```

### 3. E2E 测试

测试用户流程：

```typescript
// cypress/e2e/user-flow.cy.ts
describe('User Flow', () => {
  it('completes user registration', () => {
    cy.visit('/register')
    cy.get('input[name="name"]').type('John Doe')
    cy.get('input[name="email"]').type('john@example.com')
    cy.get('button[type="submit"]').click()
    cy.url().should('include', '/dashboard')
  })
})
```

## 性能优化

### 1. 组件懒加载

```vue
<script setup lang="ts">
// 懒加载大型组件
const HeavyComponent = defineAsyncComponent(
  () => import('./HeavyComponent.vue')
)
</script>

<template>
  <Suspense>
    <HeavyComponent />
    <template #fallback>
      <div>Loading...</div>
    </template>
  </Suspense>
</template>
```

### 2. 虚拟滚动

大数据列表优化：

```vue
<script setup lang="ts">
import { useVirtualList } from '@vueuse/core'

const { list, containerProps, wrapperProps } = useVirtualList(
  largeItems,
  { itemHeight: 50 }
)
</script>

<template>
  <div v-bind="containerProps" style="height: 400px; overflow: auto;">
    <div v-bind="wrapperProps">
      <div v-for="{ data, index } in list" :key="index" style="height: 50px;">
        {{ data.name }}
      </div>
    </div>
  </div>
</template>
```

### 3. 计算属性缓存

```vue
<script setup lang="ts">
// ✅ 使用计算属性
const filteredItems = computed(() => 
  items.value.filter(item => item.active)
)

// ❌ 避免在模板中计算
// <div v-for="item in items.filter(i => i.active)">
</script>
```

### 4. 合理使用 v-if 和 v-show

```vue
<template>
  <!-- v-if: 条件为 false 时不渲染，适合不频繁切换 -->
  <HeavyComponent v-if="showHeavy" />
  
  <!-- v-show: 始终渲染，仅切换 display，适合频繁切换 -->
  <div v-show="isVisible" class="tooltip">
    Tooltip content
  </div>
</template>
```

## 最佳实践总结

1. **组件职责单一**: 每个组件只负责一个功能
2. **可复用性**: 设计可复用的通用组件
3. **类型安全**: 使用 TypeScript 提供完整类型定义
4. **性能优化**: 懒加载、虚拟滚动、计算属性缓存
5. **测试覆盖**: 为关键组件编写单元测试和 E2E 测试
6. **文档完善**: 为公共组件编写使用文档
7. **代码风格**: 遵循项目 ESLint 规则和命名约定
8. **渐进式开发**: 从简单组件开始，逐步增强功能
