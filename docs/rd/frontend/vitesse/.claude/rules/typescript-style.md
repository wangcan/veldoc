# TypeScript 开发规范

## 类型定义

### 使用 interface 定义对象类型

```typescript
// 推荐
interface User {
  id: string
  name: string
  email: string
  role: 'admin' | 'user'
}

// 类型别名用于联合类型、映射类型等
type Status = 'pending' | 'active' | 'inactive'
type UserKeys = keyof User
```

### 使用 type 定义工具类型

```typescript
// 联合类型
type Theme = 'light' | 'dark'

// 映射类型
type ReadonlyUser = Readonly<User>

// 条件类型
type ApiResponse<T> = {
  data: T
  error: null
} | {
  data: null
  error: Error
}
```

## 函数类型

### 函数参数和返回值

```typescript
// 显式类型注解
function fetchUser(id: string): Promise<User> {
  return fetch(`/api/users/${id}`).then(res => res.json())
}

// 箭头函数
const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
}
```

### 函数重载

```typescript
function format(input: string): string
function format(input: number): string
function format(input: string | number): string {
  return String(input)
}
```

## 泛型使用

### 泛型函数

```typescript
// 泛型函数
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}

// 使用
const user: User = { id: '1', name: 'John', email: 'john@example.com', role: 'user' }
const name = getProperty(user, 'name') // 类型推断为 string
```

### 泛型接口

```typescript
interface ApiResponse<T> {
  data: T
  status: number
  message: string
}

interface PaginatedResponse<T> {
  items: T[]
  total: number
  page: number
  pageSize: number
}
```

## 类型断言

### 谨慎使用 as

```typescript
// 避免不必要的断言
const input = document.querySelector('input') as HTMLInputElement

// 使用类型守卫替代
function isInputElement(el: Element): el is HTMLInputElement {
  return el.tagName === 'INPUT'
}

const input = document.querySelector('input')
if (input && isInputElement(input)) {
  input.value // 安全访问
}
```

### 非空断言

```typescript
// 谨慎使用 !
const element = document.getElementById('app')!

// 更安全的方式
const element = document.getElementById('app')
if (element) {
  // 安全使用
}
```

## 类型导入

### 使用 type 关键字

```typescript
// 仅导入类型
import type { User, Status } from './types'

// 混合导入
import { formatDate } from './utils'
import type { DateFormat } from './types'
```

## 类型声明文件

### 全局类型声明

```typescript
// src/shims.d.ts
declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

// 环境变量类型
interface ImportMetaEnv {
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

## 严格模式配置

### tsconfig.json

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## 常用工具类型

```typescript
// Partial - 所有属性可选
type PartialUser = Partial<User>

// Required - 所有属性必选
type RequiredUser = Required<User>

// Pick - 选取部分属性
type UserPreview = Pick<User, 'id' | 'name'>

// Omit - 排除部分属性
type UserWithoutEmail = Omit<User, 'email'>

// Record - 构造对象类型
type UserMap = Record<string, User>

// ReturnType - 获取函数返回类型
type FetchUserReturn = ReturnType<typeof fetchUser>

// Parameters - 获取函数参数类型
type FetchUserParams = Parameters<typeof fetchUser>
```

## Vue 相关类型

### 组件实例类型

```typescript
import type { ComponentPublicInstance } from 'vue'

// 组件 ref 类型
const componentRef = ref<ComponentPublicInstance | null>(null)
```

### Props 类型

```typescript
import type { PropType } from 'vue'

// 复杂 props 类型
const props = defineProps({
  items: {
    type: Array as PropType<Item[]>,
    required: true,
  },
  config: {
    type: Object as PropType<Config>,
    default: () => ({ theme: 'light' }),
  },
})
```

### Store 类型

```typescript
import type { Pinia } from 'pinia'

// Store 类型导出
export type UserStore = ReturnType<typeof useUserStore>
```
