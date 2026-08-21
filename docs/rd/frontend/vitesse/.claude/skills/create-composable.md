---
name: create-composable
description: 创建新的组合式函数，封装可复用逻辑
---

# 创建组合式函数

这个 skill 用于创建新的组合式函数，封装可复用逻辑。

## 使用场景

当需要创建可复用的逻辑时使用此 skill。

## 执行步骤

1. **确定功能范围**
   - 确定需要封装的逻辑
   - 确定输入和输出
   - 确定是否需要响应式

2. **设计接口**
   - 定义参数类型
   - 定义返回值类型
   - 考虑可配置性

3. **创建组合式函数**
   - 使用 Composition API
   - 提供完整类型定义
   - 实现核心逻辑

4. **添加文档**
   - 添加函数注释
   - 提供使用示例
   - 说明参数和返回值

## 组合式函数模板

### 基础模板

```typescript
// src/composables/use[Name].ts

/**
 * [组合式函数名称]
 * @description [函数描述]
 *
 * @param [参数名] - [参数描述]
 * @returns [返回值描述]
 *
 * @example
 * ```typescript
 * const { data, loading, error } = use[Name]()
 * ```
 */

export function use[Name]() {
  // 响应式状态
  // const state = ref()

  // 计算属性
  // const computed = computed(() => {})

  // 方法
  // function method() {}

  // 生命周期钩子
  // onMounted(() => {})

  // 清理逻辑
  // onUnmounted(() => {})

  return {
    // 返回响应式状态和方法
  }
}
```

### 完整示例：useFetch

```typescript
// src/composables/useFetch.ts

/**
 * 数据获取组合式函数
 * @description 封装 fetch 请求，提供 loading、error 状态管理
 *
 * @param url - 请求 URL
 * @param options - 配置选项
 * @returns 响应式数据、加载状态、错误信息、执行函数
 *
 * @example
 * ```typescript
 * const { data, loading, error, execute } = useFetch('/api/users')
 * ```
 */

export interface UseFetchOptions<T> {
  immediate?: boolean // 是否立即执行
  initialData?: T // 初始数据
  headers?: Record<string, string> // 请求头
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  body?: any // 请求体
  onSuccess?: (data: T) => void // 成功回调
  onError?: (error: Error) => void // 错误回调
}

export function useFetch<T>(
  url: string,
  options: UseFetchOptions<T> = {}
) {
  const {
    immediate = true,
    initialData,
    headers,
    method = 'GET',
    body,
    onSuccess,
    onError,
  } = options

  const data = ref<T | undefined>(initialData)
  const error = ref<Error | null>(null)
  const loading = ref(false)

  async function execute() {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
        body: body ? JSON.stringify(body) : undefined,
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      data.value = await response.json()
      onSuccess?.(data.value)
    } catch (e) {
      error.value = e as Error
      onError?.(error.value)
    } finally {
      loading.value = false
    }
  }

  // 立即执行
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

### 完整示例：useLocalStorage

```typescript
// src/composables/useLocalStorage.ts

/**
 * localStorage 响应式封装
 * @description 提供响应式的 localStorage 操作
 *
 * @param key - 存储 key
 * @param defaultValue - 默认值
 * @returns 响应式值和设置方法
 *
 * @example
 * ```typescript
 * const { value, set, remove } = useLocalStorage('theme', 'light')
 * ```
 */

export function useLocalStorage<T>(
  key: string,
  defaultValue: T
) {
  const value = ref<T>(defaultValue)

  // 从 localStorage 读取
  function load() {
    const stored = localStorage.getItem(key)
    if (stored !== null) {
      try {
        value.value = JSON.parse(stored)
      } catch {
        value.value = stored as any
      }
    }
  }

  // 保存到 localStorage
  function save(newValue: T) {
    localStorage.setItem(key, JSON.stringify(newValue))
    value.value = newValue
  }

  // 移除
  function remove() {
    localStorage.removeItem(key)
    value.value = defaultValue
  }

  // 初始化加载
  load()

  // 监听变化自动保存
  watch(value, (newValue) => {
    localStorage.setItem(key, JSON.stringify(newValue))
  }, { deep: true })

  return {
    value,
    set: save,
    remove,
    load,
  }
}
```

### 完整示例：useMouse

```typescript
// src/composables/useMouse.ts

/**
 * 鼠标位置追踪
 * @description 追踪鼠标在页面上的位置
 *
 * @returns 鼠标坐标和追踪控制
 *
 * @example
 * ```typescript
 * const { x, y, start, stop } = useMouse()
 * ```
 */

export function useMouse() {
  const x = ref(0)
  const y = ref(0)
  const isTracking = ref(false)

  function update(event: MouseEvent) {
    x.value = event.pageX
    y.value = event.pageY
  }

  function start() {
    if (isTracking.value) return
    window.addEventListener('mousemove', update)
    isTracking.value = true
  }

  function stop() {
    if (!isTracking.value) return
    window.removeEventListener('mousemove', update)
    isTracking.value = false
  }

  // 自动开始追踪
  onMounted(start)
  onUnmounted(stop)

  return {
    x,
    y,
    isTracking,
    start,
    stop,
  }
}
```

### 完整示例：useDebounce

```typescript
// src/composables/useDebounce.ts

/**
 * 防抖函数
 * @description 提供防抖功能
 *
 * @param fn - 需要防抖的函数
 * @param delay - 延迟时间（毫秒）
 * @returns 防抖后的函数和取消方法
 *
 * @example
 * ```typescript
 * const { debouncedFn, cancel } = useDebounce(search, 300)
 * ```
 */

export function useDebounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number = 300
) {
  let timeoutId: ReturnType<typeof setTimeout> | null = null

  const debouncedFn = (...args: Parameters<T>) => {
    if (timeoutId) {
      clearTimeout(timeoutId)
    }
    timeoutId = setTimeout(() => {
      fn(...args)
      timeoutId = null
    }, delay)
  }

  const cancel = () => {
    if (timeoutId) {
      clearTimeout(timeoutId)
      timeoutId = null
    }
  }

  onUnmounted(cancel)

  return {
    debouncedFn,
    cancel,
  }
}
```

### 完整示例：useScroll

```typescript
// src/composables/useScroll.ts

/**
 * 滚动监听
 * @description 监听页面滚动位置和方向
 *
 * @returns 滚动信息
 *
 * @example
 * ```typescript
 * const { scrollY, direction, isAtTop, isAtBottom } = useScroll()
 * ```
 */

export function useScroll() {
  const scrollY = ref(0)
  const direction = ref<'up' | 'down'>('down')
  const isAtTop = computed(() => scrollY.value === 0)
  const isAtBottom = computed(() => {
    return scrollY.value + window.innerHeight >= document.body.scrollHeight
  })

  let lastScrollY = 0

  function handleScroll() {
    scrollY.value = window.scrollY

    // 判断滚动方向
    if (scrollY.value > lastScrollY) {
      direction.value = 'down'
    } else if (scrollY.value < lastScrollY) {
      direction.value = 'up'
    }

    lastScrollY = scrollY.value
  }

  function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  function scrollToBottom() {
    window.scrollTo({
      top: document.body.scrollHeight,
      behavior: 'smooth',
    })
  }

  onMounted(() => {
    window.addEventListener('scroll', handleScroll, { passive: true })
  })

  onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll)
  })

  return {
    scrollY,
    direction,
    isAtTop,
    isAtBottom,
    scrollToTop,
    scrollToBottom,
  }
}
```

## 设计原则

### 1. 单一职责

每个组合式函数应只负责一个功能：

```typescript
// ❌ 不推荐：职责过多
function useUser() {
  // 包含登录、注册、权限、资料等多个功能
}

// ✅ 推荐：职责单一
function useAuth() {
  // 只负责认证相关
}

function useUserProfile() {
  // 只负责用户资料
}
```

### 2. 响应式优先

返回的值应保持响应性：

```typescript
// ✅ 返回 ref
function useCount() {
  const count = ref(0)
  return { count } // count 是响应式的
}

// ❌ 返回普通值
function useCount() {
  const count = 0
  return { count } // count 不是响应式的
}
```

### 3. 清理副作用

在 `onUnmounted` 中清理副作用：

```typescript
function useEventListener(target: EventTarget, event: string, callback: () => void) {
  onMounted(() => {
    target.addEventListener(event, callback)
  })

  // ✅ 清理监听器
  onUnmounted(() => {
    target.removeEventListener(event, callback)
  })
}
```

### 4. 可配置性

提供合理的默认值和配置选项：

```typescript
function useFetch(url: string, options: UseFetchOptions = {}) {
  const {
    immediate = true, // 默认立即执行
    initialData = null, // 默认初始值
    // ...
  } = options

  // ...
}
```

## 命名约定

- **文件名**: camelCase，以 `use` 开头（例如：`useFetch.ts`）
- **函数名**: 以 `use` 开头（例如：`useFetch`）
- **返回值**: 使用对象解构（例如：`{ data, loading, error }`）

## 自动导入

`src/composables/` 下的组合式函数会自动导入，无需手动 import：

```vue
<script setup lang="ts">
// ✅ 无需 import
const { data, loading } = useFetch('/api/users')

// ❌ 不需要这样
// import { useFetch } from '~/composables/useFetch'
</script>
```

## 测试组合式函数

```typescript
// test/composables/useFetch.test.ts
import { useFetch } from '~/composables/useFetch'

describe('useFetch', () => {
  it('fetches data successfully', async () => {
    const { data, loading, error, execute } = useFetch('/api/test', {
      immediate: false,
    })

    expect(loading.value).toBe(false)

    await execute()

    expect(loading.value).toBe(false)
    expect(data.value).toBeDefined()
    expect(error.value).toBeNull()
  })

  it('handles errors', async () => {
    const { error, execute } = useFetch('/api/not-found', {
      immediate: false,
    })

    await execute()

    expect(error.value).toBeDefined()
  })
})
```

## 最佳实践

1. **单一职责**: 每个函数只负责一个功能
2. **响应式**: 返回 ref 或 reactive 值
3. **清理副作用**: 在 onUnmounted 中清理
4. **类型安全**: 提供完整的类型定义
5. **文档完善**: 添加注释和使用示例
6. **可测试**: 编写单元测试
7. **可配置**: 提供合理的配置选项

## 注意事项

1. 组合式函数放在 `src/composables/` 目录
2. 函数名以 `use` 开头
3. 返回值使用对象解构
4. 自动导入，无需手动 import
5. 提供完整类型定义
6. 处理清理逻辑
7. 遵循代码规范和命名约定
