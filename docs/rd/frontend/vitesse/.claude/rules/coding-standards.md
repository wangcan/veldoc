---
name: coding-standards
description: Vitesse 项目代码规范和最佳实践
metadata:
  type: project
---

# Vitesse 项目代码规范

## ESLint 规则

项目使用 [@antfu/eslint-config](https://github.com/antfu/eslint-config)，遵循以下规则：

- **单引号**: 使用单引号而非双引号
- **无分号**: 不使用分号
- **自动格式化**: 代码自动格式化
- **一致性**: 保持代码风格一致

**Why:** 统一代码风格，提高可读性和维护性。

**How to apply:** 使用 `pnpm lint` 自动修复代码格式问题。

## 命名约定

### 文件命名
- **组件**: PascalCase（例如：`UserProfile.vue`）
- **Composables**: camelCase，以 `use` 开头（例如：`useDark.ts`）
- **Stores**: camelCase，以 `store` 结尾（例如：`user.ts`，导出 `useUserStore`）
- **工具函数**: camelCase（例如：`formatDate.ts`）
- **常量**: UPPER_SNAKE_CASE（例如：`API_BASE_URL`）

### 变量命名
- **响应式变量**: camelCase（例如：`userName`）
- **常量**: UPPER_SNAKE_CASE（例如：`MAX_RETRY_COUNT`）
- **布尔值**: 以 `is`、`has`、`should` 开头（例如：`isDark`、`hasPermission`）
- **私有变量**: 以下划线开头（例如：`_privateMethod`）

### 组件命名
- **页面组件**: PascalCase，以 `Page` 结尾（例如：`HomePage`）
- **布局组件**: kebab-case（例如：`default.vue`）
- **通用组件**: PascalCase（例如：`TheHeader`）

**Why:** 清晰的命名约定有助于代码理解和维护。

**How to apply:** 遵循命名约定，使用 ESLint 自动检查。

## TypeScript 使用

### 严格模式
项目启用 TypeScript 严格模式：
- `strict: true`
- `strictNullChecks: true`
- `noUnusedLocals: true`

### 类型定义

#### Props 类型
```typescript
interface Props {
  title: string
  count?: number
  items: string[]
}

const props = withDefaults(defineProps<Props>(), {
  count: 0,
})
```

#### Emits 类型
```typescript
interface Emits {
  (e: 'update', value: number): void
  (e: 'delete', id: string): void
}

const emit = defineEmits<Emits>()
```

#### 泛型使用
```typescript
// 函数泛型
function fetchData<T>(url: string): Promise<T> {
  return fetch(url).then(r => r.json())
}

// 组件泛型
interface Props<T> {
  items: T[]
  selected: T
}
```

**Why:** 类型安全可以避免运行时错误，提高代码质量。

**How to apply:** 为所有变量、函数和组件提供类型定义。

## Vue 组件规范

### 组件结构

组件应按以下顺序组织：

```vue
<script setup lang="ts">
// 1. 类型定义
interface Props { /* ... */ }
interface Emits { /* ... */ }

// 2. Props 和 Emits
const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// 3. 响应式状态
const count = ref(0)
const items = ref<string[]>([])

// 4. 计算属性
const doubled = computed(() => count.value * 2)

// 5. 方法
function increment() { /* ... */ }

// 6. 生命周期钩子
onMounted(() => { /* ... */ })

// 7. 监听器
watch(count, (newVal) => { /* ... */ })
</script>

<template>
  <!-- 模板内容 -->
</template>

<style scoped>
/* 样式（如有需要） */
</style>
```

### Props 最佳实践

```vue
<script setup lang="ts">
interface Props {
  // ✅ 明确类型
  title: string
  // ✅ 可选属性提供默认值
  count?: number
  // ✅ 复杂对象使用 interface
  user?: User
}

// ✅ 使用 withDefaults 设置默认值
const props = withDefaults(defineProps<Props>(), {
  count: 0,
  user: () => ({ name: '', email: '' }),
})
</script>
```

### Emits 最佳实践

```vue
<script setup lang="ts">
// ✅ 明确的事件签名
interface Emits {
  (e: 'update:modelValue', value: string): void
  (e: 'change', newValue: string, oldValue: string): void
}

const emit = defineEmits<Emits>()

// ✅ 使用类型安全的事件
function handleInput(value: string) {
  emit('update:modelValue', value)
}
</script>
```

**Why:** 统一的组件结构提高可读性和维护性。

**How to apply:** 遵循组件结构规范，使用 TypeScript 类型定义。

## 自动导入规则

### 无需导入的内容

以下 API 和工具无需手动导入：

#### Vue 3 API
- `ref`, `computed`, `watch`, `watchEffect`
- `onMounted`, `onUnmounted`, `onBeforeMount`
- `reactive`, `toRef`, `toRefs`
- 其他 Composition API

#### VueUse API
- `useDark`, `useToggle`
- `useStorage`, `useLocalStorage`
- `useMouse`, `useEventListener`
- 其他 VueUse 组合式函数

#### Vue Router API
- `useRouter`, `useRoute`
- `onBeforeRouteLeave`, `onBeforeRouteUpdate`

#### Vue I18n API
- `useI18n`

#### 项目特定
- `src/composables/` 下的所有函数
- `src/stores/` 下的所有 store
- `src/components/` 下的所有组件

### 需要导入的内容

以下内容需要手动导入：

```typescript
// 第三方库
import { some } from 'lodash-es'
import axios from 'axios'

// 工具函数（不在 composables 目录）
import { formatDate } from '~/utils/format'

// 类型定义
import type { User } from '~/types'
```

**Why:** 自动导入减少样板代码，提高开发效率。

**How to apply:** 熟悉自动导入规则，避免不必要的 import 语句。

## UnoCSS 使用规范

### 原子类优先

优先使用 UnoCSS 原子类而非自定义 CSS：

```vue
<template>
  <!-- ✅ 推荐：使用 UnoCSS -->
  <div class="p-4 bg-white dark:bg-gray-800 rounded-lg shadow-md">
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
      Title
    </h1>
  </div>

  <!-- ❌ 不推荐：使用 scoped CSS -->
  <div class="custom-container">
    <h1 class="custom-title">Title</h1>
  </div>
</template>

<style scoped>
.custom-container {
  padding: 1rem;
  background: white;
  /* ... */
}
</style>
```

### 响应式设计

使用响应式前缀：

```vue
<template>
  <div class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4">
    <!-- 在不同屏幕宽度下自适应 -->
  </div>
  
  <div class="text-sm md:text-base lg:text-lg">
    <!-- 响应式文本大小 -->
  </div>
</template>
```

### 暗色模式

使用 `dark:` 前缀：

```vue
<template>
  <div class="bg-white dark:bg-gray-800 text-gray-900 dark:text-white">
    <!-- 自动适配暗色模式 -->
  </div>
</template>
```

### 预定义 Shortcuts

使用项目预定义的 shortcuts：

```vue
<template>
  <!-- 按钮 -->
  <button class="btn">
    Button
  </button>
  
  <!-- 图标按钮 -->
  <button class="icon-btn">
    <div i-carbon-settings />
  </button>
</template>
```

**Why:** UnoCSS 原子化 CSS 提供高性能和一致性。

**How to apply:** 优先使用原子类，合理使用响应式和暗色模式前缀。

## 注释规范

### 文件注释

```typescript
/**
 * 用户管理页面
 * @description 显示用户列表和详细信息
 * @author Your Name
 * @date 2024-01-01
 */
```

### 函数注释

```typescript
/**
 * 格式化日期
 * @param date - 日期对象或字符串
 * @param format - 格式字符串，默认 'YYYY-MM-DD'
 * @returns 格式化后的日期字符串
 */
function formatDate(date: Date | string, format = 'YYYY-MM-DD'): string {
  // ...
}
```

### 复杂逻辑注释

```typescript
// 检查用户权限，如果无权限则跳转到登录页
if (!hasPermission(user, 'admin')) {
  router.push('/login')
  return
}

// TODO: 优化性能，考虑使用虚拟滚动
// FIXME: 在移动端有布局问题
// NOTE: 这里的逻辑比较复杂，需要重构
```

**Why:** 清晰的注释有助于代码理解和维护。

**How to apply:** 为复杂逻辑、公共 API 和重要文件添加注释。

## 性能优化规范

### 避免不必要的响应式

```typescript
// ✅ 静态值不需要响应式
const API_BASE_URL = 'https://api.example.com'

// ✅ 常量使用 const
const MAX_ITEMS = 100

// ✅ 需要响应式才使用 ref/reactive
const count = ref(0)
```

### 合理使用计算属性

```typescript
// ✅ 使用计算属性缓存
const filteredItems = computed(() => 
  items.value.filter(item => item.active)
)

// ❌ 在方法中重复计算
function getActiveItems() {
  return items.value.filter(item => item.active)
}
```

### 组件懒加载

```vue
<script setup lang="ts">
// ✅ 懒加载大型组件
const HeavyComponent = defineAsyncComponent(
  () => import('./HeavyComponent.vue')
)
</script>
```

### 列表优化

```vue
<template>
  <!-- ✅ 使用 key -->
  <div v-for="item in items" :key="item.id">
    {{ item.name }}
  </div>
  
  <!-- ✅ 虚拟滚动（大数据列表） -->
  <VirtualList :items="largeItems">
    <template #default="{ item }">
      {{ item.name }}
    </template>
  </VirtualList>
</template>
```

**Why:** 性能优化提升用户体验和应用效率。

**How to apply:** 遵循性能优化规范，避免常见的性能陷阱。

## 错误处理规范

### API 请求错误

```typescript
async function fetchData() {
  try {
    const response = await fetch('/api/data')
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    const data = await response.json()
    return data
  } catch (error) {
    console.error('Failed to fetch data:', error)
    // 显示错误提示
    showError('Failed to load data')
    return null
  }
}
```

### 组件错误边界

```vue
<template>
  <ErrorBoundary>
    <MyComponent />
    <template #fallback>
      <div class="error-message">
        Something went wrong
      </div>
    </template>
  </ErrorBoundary>
</template>
```

### 全局错误处理

```typescript
// src/modules/error-handler.ts
export const install: UserModule = ({ app }) => {
  app.config.errorHandler = (err, instance, info) => {
    console.error('Global error:', err)
    console.error('Component:', instance)
    console.error('Error info:', info)
    // 上报错误到监控系统
  }
}
```

**Why:** 良好的错误处理提升应用稳定性。

**How to apply:** 为异步操作、API 请求和关键路径添加错误处理。

## 测试规范

### 单元测试

```typescript
// test/components/TheCounter.test.ts
import { mount } from '@vue/test-utils'
import TheCounter from '~/components/TheCounter.vue'

describe('TheCounter', () => {
  it('renders correctly', () => {
    const wrapper = mount(TheCounter)
    expect(wrapper.html()).toContain('Count')
  })
  
  it('increments when button clicked', async () => {
    const wrapper = mount(TheCounter)
    await wrapper.find('button').trigger('click')
    expect(wrapper.vm.count).toBe(1)
  })
})
```

### E2E 测试

```typescript
// cypress/e2e/home.cy.ts
describe('Home Page', () => {
  it('displays welcome message', () => {
    cy.visit('/')
    cy.contains('Vitesse')
  })
  
  it('navigates to about page', () => {
    cy.visit('/')
    cy.contains('About').click()
    cy.url().should('include', '/about')
  })
})
```

**Why:** 测试确保代码质量和功能正确性。

**How to apply:** 为关键组件和功能编写测试，保持测试覆盖率。

## Git 提交规范

### 提交消息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type 类型
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建工具或辅助工具的变动

#### 示例

```
feat(user): add user profile page

- Add UserProfile component
- Add profile route
- Add profile store

Closes #123
```

**Why:** 规范的提交消息有助于版本管理和变更追踪。

**How to apply:** 遵循 Git 提交规范，使用语义化的提交消息。

## 文档规范

### README 文件

每个主要模块应包含 README 文件：

```markdown
# 模块名称

## 功能描述

简要描述模块的功能和用途。

## 使用方法

提供使用示例和代码片段。

## API 文档

列出公共 API 和类型定义。

## 注意事项

说明使用限制和注意事项。
```

### 代码文档

```typescript
/**
 * 用户管理 Store
 * 
 * @module stores/user
 * @description 管理用户状态、登录登出和用户信息
 * 
 * @example
 * ```typescript
 * const userStore = useUserStore()
 * await userStore.login({ username, password })
 * console.log(userStore.displayName)
 * ```
 */
```

**Why:** 良好的文档帮助团队成员理解和使用代码。

**How to apply:** 为主要模块和公共 API 编写清晰的文档。
