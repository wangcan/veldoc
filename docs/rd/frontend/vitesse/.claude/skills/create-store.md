---
name: create-store
description: 创建新的 Pinia store，管理应用状态
---

# 创建 Pinia Store

这个 skill 用于创建新的 Pinia store，管理应用状态。

## 使用场景

当需要创建新的状态管理时使用此 skill。

## 执行步骤

1. **确定状态范围**
   - 确定需要管理的数据
   - 确定状态的操作
   - 确定是否需要持久化

2. **设计 Store 结构**
   - 定义 State 类型
   - 定义 Getters
   - 定义 Actions

3. **创建 Store 文件**
   - 使用 Composition API 风格
   - 提供完整类型定义
   - 实现状态逻辑

4. **测试 Store**
   - 测试 Actions
   - 测试 Getters
   - 测试状态持久化（如有）

## Store 模板

### 基础 Store 模板

```typescript
// src/stores/[name].ts

/**
 * [Store 名称]
 * @description [Store 描述]
 */

// 类型定义
export interface [InterfaceName] {
  // 状态类型定义
}

export const use[StoreName]Store = defineStore('[store-name]', () => {
  // State
  // const state = ref()

  // Getters
  // const getter = computed(() => {})

  // Actions
  // function action() {}

  return {
    // State
    // Getters
    // Actions
  }
})
```

### 完整 Store 模板

```typescript
// src/stores/[name].ts

/**
 * 用户管理 Store
 * @description 管理用户登录状态、用户信息和权限
 * 
 * @example
 * ```typescript
 * const userStore = useUserStore()
 * await userStore.login({ username, password })
 * console.log(userStore.displayName)
 * ```
 */

// 类型定义
export interface User {
  id: string
  name: string
  email: string
  avatar?: string
}

export interface LoginCredentials {
  username: string
  password: string
}

// Store 定义
export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const isLoggedIn = computed(() => !!user.value && !!token.value)
  const displayName = computed(() => user.value?.name || 'Guest')
  const avatarUrl = computed(() => user.value?.avatar || '/default-avatar.png')

  // Actions
  async function login(credentials: LoginCredentials) {
    loading.value = true
    error.value = null
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials),
      })
      
      if (!response.ok) {
        throw new Error('Login failed')
      }
      
      const data = await response.json()
      user.value = data.user
      token.value = data.token
      
      // 持久化
      localStorage.setItem('token', data.token)
    } catch (e) {
      error.value = (e as Error).message
      throw e
    } finally {
      loading.value = false
    }
  }

  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
  }

  async function fetchUser() {
    if (!token.value) return
    
    loading.value = true
    try {
      const response = await fetch('/api/user', {
        headers: { Authorization: `Bearer ${token.value}` },
      })
      user.value = await response.json()
    } catch (e) {
      error.value = (e as Error).message
    } finally {
      loading.value = false
    }
  }

  // 初始化时从 localStorage 恢复 token
  function init() {
    const savedToken = localStorage.getItem('token')
    if (savedToken) {
      token.value = savedToken
      fetchUser()
    }
  }

  // 自动调用初始化
  init()

  return {
    // State
    user,
    token,
    loading,
    error,
    // Getters
    isLoggedIn,
    displayName,
    avatarUrl,
    // Actions
    login,
    logout,
    fetchUser,
  }
})
```

## 状态持久化

### 使用 localStorage

```typescript
export const usePreferencesStore = defineStore('preferences', () => {
  const theme = ref<'light' | 'dark'>('light')
  const language = ref('en')
  
  // 持久化
  watchEffect(() => {
    localStorage.setItem('preferences', JSON.stringify({
      theme: theme.value,
      language: language.value,
    }))
  })
  
  // 恢复
  function loadFromStorage() {
    const stored = localStorage.getItem('preferences')
    if (stored) {
      const data = JSON.parse(stored)
      theme.value = data.theme
      language.value = data.language
    }
  }
  
  loadFromStorage()
  
  return { theme, language, loadFromStorage }
})
```

### 使用 Pinia 持久化插件

```typescript
// src/modules/pinia.ts
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

export const install: UserModule = ({ app }) => {
  const pinia = createPinia()
  pinia.use(piniaPluginPersistedstate)
  app.use(pinia)
}

// src/stores/user.ts
export const useUserStore = defineStore('user', () => {
  // ...
}, {
  persist: true, // 启用持久化
})
```

## 在组件中使用

```vue
<script setup lang="ts">
const userStore = useUserStore()

// 访问 state
const userName = userStore.name

// 访问 getter
const displayName = userStore.displayName

// 解构（保持响应性）
const { name, email, isLoggedIn } = storeToRefs(userStore)

// 调用 action
function handleLogin() {
  userStore.login({ username, password })
}
</script>
```

## 异步数据处理

```typescript
export const usePostsStore = defineStore('posts', () => {
  const posts = ref<Post[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  // 获取数据
  async function fetchPosts() {
    loading.value = true
    error.value = null
    try {
      const response = await fetch('/api/posts')
      posts.value = await response.json()
    } catch (e) {
      error.value = (e as Error).message
    } finally {
      loading.value = false
    }
  }
  
  // 创建数据
  async function createPost(post: CreatePostDto) {
    const response = await fetch('/api/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(post),
    })
    const newPost = await response.json()
    posts.value.push(newPost)
    return newPost
  }
  
  // 更新数据
  async function updatePost(id: string, post: UpdatePostDto) {
    const response = await fetch(`/api/posts/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(post),
    })
    const updatedPost = await response.json()
    const index = posts.value.findIndex(p => p.id === id)
    if (index !== -1) {
      posts.value[index] = updatedPost
    }
    return updatedPost
  }
  
  // 删除数据
  async function deletePost(id: string) {
    await fetch(`/api/posts/${id}`, { method: 'DELETE' })
    posts.value = posts.value.filter(p => p.id !== id)
  }
  
  return {
    posts,
    loading,
    error,
    fetchPosts,
    createPost,
    updatePost,
    deletePost,
  }
})
```

## Store 组合

```typescript
// src/stores/cart.ts
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])
  
  // 使用其他 store
  const userStore = useUserStore()
  
  const total = computed(() => 
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  )
  
  function addItem(item: CartItem) {
    const existing = items.value.find(i => i.id === item.id)
    if (existing) {
      existing.quantity += item.quantity
    } else {
      items.value.push(item)
    }
    
    console.log(`Added item for user: ${userStore.displayName}`)
  }
  
  return { items, total, addItem }
})
```

## 测试 Store

```typescript
// test/stores/user.test.ts
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from '~/stores/user'

describe('User Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
  
  it('initializes with default values', () => {
    const store = useUserStore()
    expect(store.user).toBeNull()
    expect(store.isLoggedIn).toBe(false)
  })
  
  it('logs in successfully', async () => {
    const store = useUserStore()
    await store.login({ username: 'test', password: 'password' })
    expect(store.isLoggedIn).toBe(true)
    expect(store.displayName).toBe('Test User')
  })
  
  it('logs out correctly', () => {
    const store = useUserStore()
    store.login({ username: 'test', password: 'password' })
    store.logout()
    expect(store.user).toBeNull()
    expect(store.token).toBeNull()
  })
})
```

## 最佳实践

1. **使用 Composition API**: 使用 `defineStore` 的 Composition API 语法
2. **命名约定**: Store 文件和函数使用 `useXxxStore` 命名
3. **单一职责**: 每个 Store 管理一个领域的数据
4. **类型安全**: 为所有 state、getters 和 actions 提供类型定义
5. **持久化**: 需要持久化的数据应手动实现或使用插件
6. **异步处理**: Actions 中处理异步操作和错误
7. **性能优化**: 合理使用 computed 避免重复计算

## 注意事项

1. Store 放在 `src/stores/` 目录
2. 使用 Composition API 风格定义
3. 提供完整的类型定义
4. 避免循环依赖
5. 解构时使用 `storeToRefs` 保持响应性
6. 复杂逻辑拆分为多个 store
7. 遵循代码规范和命名约定
