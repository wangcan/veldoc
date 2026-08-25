# Skills 技能文件分析报告

## 文件概述

**文件路径**: `.claude/skills/`

**文件数量**: 4 个技能文件

**创建时间**: 2025-08-25

**作用**: 为 AI 助手提供快速开发工具集，标准化创建组件、API、测试和路由

---

## 技能文件列表

| 文件名 | 功能描述 | 触发关键词 |
|--------|----------|------------|
| create-component.md | 快速创建 Vue 3 组件 | 创建组件、新建组件、add component |
| create-api.md | 快速创建 API 接口定义 | 创建 API、新建接口、add api |
| create-test.md | 快速创建测试用例 | 创建测试、新建测试、add test |
| add-route.md | 快速添加页面路由配置 | 添加路由、新建路由、add route |

---

## 详细分析

### 1. create-component.md - 组件创建技能

#### 功能定位

快速创建标准化的 Vue 3 组件，自动生成完整的组件生态系统，包括模板、脚本、样式、类型定义、测试文件和文档。

---

#### 使用方法

**基本语法**:
```bash
/create-component <组件名称> [选项]
```

**参数说明**:

- `组件名称`: 使用 PascalCase 命名规范（如 `BaseButton`, `UserForm`）

- `--type=base`: 创建基础组件
  - 纯展示组件
  - 高度可复用
  - 无业务逻辑
  - Props 驱动

- `--type=business`: 创建业务组件
  - 包含业务逻辑
  - 可能有 API 调用
  - 可能有状态管理
  - 特定场景使用

- `--type=page`: 创建页面组件
  - 路由级别组件
  - 完整页面布局
  - 包含多个子组件
  - 可能有权限控制

- `--ui=antd`: 使用 Ant Design Vue
- `--ui=naive`: 使用 Naive UI
- `--ui=ele`: 使用 Element Plus
- `--ui=tdesign`: 使用 TDesign

---

#### 生成的内容

**1. 组件文件** (`ComponentName.vue`)

```vue
<template>
  <div class="component-name">
    <!-- 组件内容 -->
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

interface Props {
  // Props 定义
}

const props = defineProps<Props>();

// 组件逻辑
</script>

<style scoped>
.component-name {
  /* 样式 */
}
</style>
```

**结构特点**:
- 使用 Vue 3 Composition API
- TypeScript 类型安全
- Scoped 样式隔离
- Props 接口定义

**2. 类型文件** (`types.ts`)

```typescript
export interface ComponentNameProps {
  // Props 类型定义
}

export interface ComponentNameEmits {
  // Emits 类型定义
}
```

**作用**:
- 明确组件接口
- 提供类型检查
- 方便文档生成

**3. 测试文件** (`ComponentName.test.ts`)

```typescript
import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import ComponentName from './ComponentName.vue';

describe('ComponentName', () => {
  it('should render correctly', () => {
    const wrapper = mount(ComponentName);
    expect(wrapper.exists()).toBe(true);
  });
});
```

**测试覆盖**:
- 基础渲染测试
- Props 传递测试
- 事件触发测试
- 边界情况测试

**4. 文档文件** (`README.md`)

包含:
- 组件用法示例
- Props 说明表格
- Events 说明表格
- Slots 说明表格

---

#### 使用场景

**场景 1: 创建基础 UI 组件**

```bash
/create-component BaseButton --type=base
```

**适用情况**:
- 创建按钮、输入框、卡片等基础 UI 组件
- 需要高度可复用的组件
- 无业务逻辑的纯展示组件

**生成的文件**:
- `BaseButton.vue` - 组件文件
- `types.ts` - 类型定义
- `BaseButton.test.ts` - 测试文件
- `README.md` - 使用文档

---

**场景 2: 创建业务组件**

```bash
/create-component UserForm --type=business --ui=antd
```

**适用情况**:
- 创建包含业务逻辑的组件
- 需要调用 API 的组件
- 特定业务场景使用的组件

**特点**:
- 集成业务逻辑
- 可能包含状态管理
- 可能包含 API 调用

---

**场景 3: 创建页面组件**

```bash
/create-component UserList --type=page
```

**适用情况**:
- 创建路由级别的页面
- 完整的页面布局
- 包含多个子组件

**特点**:
- 路由级别组件
- 完整页面结构
- 可能包含权限控制

---

#### 最佳实践

1. **命名清晰**: 组件名应准确描述其功能
   - ✅ `UserProfile`, `OrderList`, `PaymentForm`
   - ❌ `Component1`, `MyComponent`, `Temp`

2. **单一职责**: 每个组件只做一件事
   - 一个组件专注于一个功能
   - 避免组件过于庞大
   - 职责清晰便于维护

3. **Props 验证**: 为所有 Props 添加类型和验证
   ```typescript
   interface Props {
     title: string;           // 必填
     size?: 'small' | 'large'; // 可选且有默认值
     disabled?: boolean;       // 可选
   }
   ```

4. **事件命名**: 使用 kebab-case 命名事件
   - ✅ `@update:model-value`, `@item-click`
   - ❌ `@updateModelValue`, `@itemClick`

5. **文档完善**: 为组件添加使用文档
   - Props 说明
   - Events 说明
   - 使用示例

---

### 2. create-api.md - API 接口创建技能

#### 功能定位

快速创建标准化的 API 接口定义，包含类型定义、请求方法、Mock 数据，遵循 RESTful 规范。

---

#### 使用方法

**基本语法**:
```bash
/create-api <资源名称> [选项]
```

**参数说明**:

- `资源名称`: API 资源名称（如 `user`, `order`, `product`）

- `--methods=get,post,put,delete`: 指定 HTTP 方法
  - GET: 查询资源
  - POST: 创建资源
  - PUT: 更新资源（全量）
  - PATCH: 更新资源（部分）
  - DELETE: 删除资源

- `--auth`: 需要认证
  - 添加认证 Token
  - 自动处理 401 错误

- `--cache`: 启用缓存
  - 缓存 GET 请求
  - 自动失效策略

- `--mock`: 生成 Mock 数据
  - 生成测试数据
  - 方便前端开发

---

#### 生成的内容

**1. API 定义文件** (`index.ts`)

```typescript
import { request } from '@/utils/request';

// 类型定义
export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
}

export interface UserListParams {
  page?: number;
  pageSize?: number;
  keyword?: string;
  status?: 'active' | 'inactive';
}

export interface UserCreateParams {
  name: string;
  email: string;
  password: string;
  avatar?: string;
}

export interface UserUpdateParams {
  name?: string;
  email?: string;
  avatar?: string;
  status?: 'active' | 'inactive';
}

// API 方法

/**
 * 获取用户列表
 */
export function getUserList(params: UserListParams) {
  return request.get<PageResult<User>>('/api/users', { params });
}

/**
 * 获取单个用户
 */
export function getUser(id: string) {
  return request.get<User>(`/api/users/${id}`);
}

/**
 * 创建用户
 */
export function createUser(data: UserCreateParams) {
  return request.post<User>('/api/users', data);
}

/**
 * 更新用户
 */
export function updateUser(id: string, data: UserUpdateParams) {
  return request.put<User>(`/api/users/${id}`, data);
}

/**
 * 删除用户
 */
export function deleteUser(id: string) {
  return request.delete(`/api/users/${id}`);
}

/**
 * 批量删除用户
 */
export function batchDeleteUsers(ids: string[]) {
  return request.post('/api/users/batch-delete', { ids });
}
```

**特点**:
- 完整的 CRUD 操作
- 类型安全的参数和返回值
- 清晰的注释说明

**2. 类型文件** (`types.ts`)

```typescript
export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
}

export interface UserListParams {
  page?: number;
  pageSize?: number;
  keyword?: string;
  status?: 'active' | 'inactive';
}

export interface UserCreateParams {
  name: string;
  email: string;
  password: string;
  avatar?: string;
}

export interface UserUpdateParams {
  name?: string;
  email?: string;
  avatar?: string;
  status?: 'active' | 'inactive';
}
```

**作用**:
- 独立类型定义
- 方便复用
- 类型文档化

**3. Mock 文件** (`mock.ts`)

```typescript
import { MockMethod } from 'vite-plugin-mock';

export default [
  {
    url: '/api/users',
    method: 'get',
    response: ({ query }) => {
      return {
        code: 0,
        data: {
          items: [
            {
              id: '1',
              name: 'User 1',
              email: 'user1@example.com',
              status: 'active',
            },
          ],
          total: 100,
        },
      };
    },
  },
] as MockMethod[];
```

**作用**:
- 前端开发不依赖后端
- 快速原型开发
- 测试数据模拟

---

#### API 设计规范

**RESTful 规范**:

| HTTP 方法 | 操作 | 示例路径 |
|-----------|------|----------|
| GET | 查询资源 | `/api/users` |
| POST | 创建资源 | `/api/users` |
| PUT | 更新资源（全量） | `/api/users/:id` |
| PATCH | 更新资源（部分） | `/api/users/:id` |
| DELETE | 删除资源 | `/api/users/:id` |

**命名规范**:

- **资源名**: 复数形式（如 `users`, `orders`）
- **路由参数**: 使用 `:id` 格式
- **查询参数**: camelCase（如 `pageSize`, `keyword`）

**响应格式**:

```typescript
// 成功响应
interface SuccessResponse<T> {
  code: 0;
  data: T;
  message: string;
}

// 分页响应
interface PageResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
}

// 错误响应
interface ErrorResponse {
  code: number;
  message: string;
  errors?: Record<string, string[]>;
}
```

---

#### 使用场景

**场景 1: 创建标准 CRUD API**

```bash
/create-api user --methods=get,post,put,delete
```

**适用情况**:
- 标准的资源管理
- 完整的增删改查操作
- RESTful API 设计

---

**场景 2: 创建需要认证的 API**

```bash
/create-api order --auth
```

**适用情况**:
- 需要用户登录的接口
- 需要权限验证的操作
- 敏感数据操作

---

**场景 3: 创建带缓存的 API**

```bash
/create-api product --cache --mock
```

**适用情况**:
- 数据不经常变化
- 需要提高性能
- 前后端并行开发

---

#### 最佳实践

1. **类型安全**: 为所有接口定义类型
   ```typescript
   // 明确的请求参数类型
   export interface UserListParams {
     page?: number;
     pageSize?: number;
     keyword?: string;
   }

   // 明确的响应类型
   export function getUserList(params: UserListParams): Promise<PageResult<User>>
   ```

2. **错误处理**: 统一处理错误
   ```typescript
   try {
     const data = await getUserList(params);
     // 处理成功
   } catch (error) {
     // 统一错误处理
     handleError(error);
   }
   ```

3. **请求取消**: 支持取消请求
   ```typescript
   const controller = new AbortController();
   getUserList(params, { signal: controller.signal });
   // 取消请求
   controller.abort();
   ```

4. **缓存策略**: 合理使用缓存
   - GET 请求可缓存
   - POST/PUT/DELETE 不缓存
   - 设置合理的过期时间

5. **日志记录**: 记录关键请求
   - 请求参数
   - 响应时间
   - 错误信息

6. **Mock 数据**: 方便前端开发
   - 模拟真实数据结构
   - 覆盖各种场景
   - 便于测试

---

### 3. create-test.md - 测试用例创建技能

#### 功能定位

快速创建标准化的测试用例，包括单元测试和 E2E 测试，遵循 AAA 模式和最佳实践。

---

#### 使用方法

**基本语法**:
```bash
/create-test <目标名称> [选项]
```

**参数说明**:

- `目标名称`: 要测试的文件或功能名称

- `--type=unit`: 创建单元测试
  - 测试单个组件或函数
  - 快速执行
  - Mock 外部依赖

- `--type=e2e`: 创建 E2E 测试
  - 测试完整流程
  - 真实浏览器环境
  - 模拟用户操作

- `--framework=vitest`: 使用 Vitest（默认）
  - 快速的单元测试框架
  - 与 Vite 完美集成

- `--framework=playwright`: 使用 Playwright
  - 强大的 E2E 测试框架
  - 跨浏览器支持

---

#### 生成的内容

**1. 单元测试 - 组件** (`ComponentName.test.ts`)

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { mount, VueWrapper } from '@vue/test-utils';
import UserProfile from '@/components/UserProfile.vue';

describe('UserProfile', () => {
  let wrapper: VueWrapper<any>;

  const mockUser = {
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    avatar: 'https://example.com/avatar.jpg',
  };

  beforeEach(() => {
    wrapper = mount(UserProfile, {
      props: {
        user: mockUser,
      },
    });
  });

  afterEach(() => {
    wrapper?.unmount();
  });

  describe('渲染测试', () => {
    it('应该正确渲染用户信息', () => {
      expect(wrapper.find('.user-name').text()).toBe(mockUser.name);
      expect(wrapper.find('.user-email').text()).toBe(mockUser.email);
    });

    it('应该显示用户头像', () => {
      const avatar = wrapper.find('.user-avatar');
      expect(avatar.attributes('src')).toBe(mockUser.avatar);
    });

    it('应该有默认头像', () => {
      const wrapper = mount(UserProfile, {
        props: {
          user: { ...mockUser, avatar: undefined },
        },
      });
      expect(wrapper.find('.default-avatar').exists()).toBe(true);
    });
  });

  describe('交互测试', () => {
    it('应该触发编辑事件', async () => {
      await wrapper.find('.edit-button').trigger('click');
      expect(wrapper.emitted('edit')).toBeTruthy();
      expect(wrapper.emitted('edit')![0]).toEqual([mockUser.id]);
    });

    it('应该触发删除事件', async () => {
      vi.spyOn(window, 'confirm').mockReturnValue(true);
      await wrapper.find('.delete-button').trigger('click');
      expect(wrapper.emitted('delete')).toBeTruthy();
    });

    it('删除时应该确认', async () => {
      vi.spyOn(window, 'confirm').mockReturnValue(false);
      await wrapper.find('.delete-button').trigger('click');
      expect(wrapper.emitted('delete')).toBeFalsy();
    });
  });

  describe('状态测试', () => {
    it('应该显示加载状态', async () => {
      const wrapper = mount(UserProfile, {
        props: { loading: true },
      });
      expect(wrapper.find('.loading-spinner').exists()).toBe(true);
    });

    it('应该显示错误状态', async () => {
      const wrapper = mount(UserProfile, {
        props: { error: '加载失败' },
      });
      expect(wrapper.find('.error-message').text()).toBe('加载失败');
    });
  });
});
```

**测试结构**:
- **渲染测试**: 测试组件是否正确渲染
- **交互测试**: 测试用户交互是否正确触发
- **状态测试**: 测试不同状态下的表现

**2. 单元测试 - 工具函数** (`functionName.test.ts`)

```typescript
import { describe, it, expect } from 'vitest';
import { formatDate, debounce, deepClone } from '@/utils';

describe('formatDate', () => {
  it('应该正确格式化日期', () => {
    const date = new Date('2025-08-25');
    expect(formatDate(date, 'YYYY-MM-DD')).toBe('2025-08-25');
  });

  it('应该处理无效日期', () => {
    expect(formatDate(null)).toBe('');
    expect(formatDate(undefined)).toBe('');
  });

  it('应该支持不同格式', () => {
    const date = new Date('2025-08-25 14:30:00');
    expect(formatDate(date, 'YYYY/MM/DD')).toBe('2025/08/25');
    expect(formatDate(date, 'HH:mm:ss')).toBe('14:30:00');
  });
});

describe('debounce', () => {
  it('应该延迟执行', async () => {
    let counter = 0;
    const increment = debounce(() => counter++, 100);

    increment();
    increment();
    increment();

    expect(counter).toBe(0);

    await new Promise(resolve => setTimeout(resolve, 150));
    expect(counter).toBe(1);
  });
});
```

**测试重点**:
- 正常情况
- 边界情况
- 错误处理

**3. E2E 测试** (`feature.spec.ts`)

```typescript
import { test, expect, Page } from '@playwright/test';

test.describe('用户管理', () => {
  let page: Page;

  test.beforeEach(async ({ browser }) => {
    page = await browser.newPage();

    // 登录
    await page.goto('/login');
    await page.fill('[name="username"]', 'admin');
    await page.fill('[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await page.waitForURL('/dashboard');
  });

  test.afterEach(async () => {
    await page.close();
  });

  test('应该显示用户列表', async () => {
    await page.goto('/users');

    // 等待表格加载
    await expect(page.locator('.user-table')).toBeVisible();

    // 验证数据
    const rows = await page.locator('.user-row').count();
    expect(rows).toBeGreaterThan(0);
  });

  test('应该能搜索用户', async () => {
    await page.goto('/users');

    // 输入搜索关键词
    await page.fill('[placeholder="搜索用户"]', 'admin');
    await page.press('[placeholder="搜索用户"]', 'Enter');

    // 等待结果
    await page.waitForSelector('.user-row');

    // 验证搜索结果
    const firstRow = await page.locator('.user-row').first();
    await expect(firstRow).toContainText('admin');
  });

  test('应该能创建新用户', async () => {
    await page.goto('/users/create');

    // 填写表单
    await page.fill('[name="name"]', 'Test User');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'Password123!');

    // 提交表单
    await page.click('button[type="submit"]');

    // 验证成功消息
    await expect(page.locator('.success-message')).toBeVisible();

    // 验证跳转到列表页
    await page.waitForURL('/users');
  });
});
```

**E2E 测试特点**:
- 真实浏览器环境
- 完整的用户流程
- 端到端验证

---

#### 测试规范

**命名约定**:

- **测试文件**: `*.test.ts` 或 `*.spec.ts`
- **测试套件**: 使用 `describe` 分组
- **测试用例**: 使用 "应该..." 格式

**AAA 模式**:

```typescript
it('应该正确计算总价', () => {
  // Arrange (准备)
  const items = [
    { price: 100, quantity: 2 },
    { price: 50, quantity: 3 },
  ];

  // Act (执行)
  const total = calculateTotal(items);

  // Assert (断言)
  expect(total).toBe(350);
});
```

**Mock 使用**:

```typescript
// Mock 函数
const mockCallback = vi.fn();
mockCallback.mockReturnValue('mocked');

// Mock 模块
vi.mock('@/api/user', () => ({
  getUser: vi.fn().mockResolvedValue({ id: '1', name: 'Test' }),
}));

// Mock 时间
vi.useFakeTimers();
vi.advanceTimersByTime(1000);
```

---

#### 使用场景

**场景 1: 测试组件行为**

```bash
/create-test UserProfile --type=unit
```

**适用情况**:
- 验证组件渲染
- 测试用户交互
- 验证状态变化

---

**场景 2: 测试工具函数**

```bash
/create-test utils --type=unit
```

**适用情况**:
- 纯函数测试
- 工具函数测试
- 边界情况测试

---

**场景 3: 测试完整流程**

```bash
/create-test UserManagement --type=e2e
```

**适用情况**:
- 完整业务流程
- 用户操作路径
- 跨页面测试

---

#### 最佳实践

1. **测试覆盖**: 覆盖所有边界情况
   - 正常情况
   - 边界情况
   - 错误情况

2. **独立性**: 测试之间互不影响
   - 每个测试独立运行
   - 使用 beforeEach/afterEach 清理
   - 避免 shared state

3. **可读性**: 测试代码清晰易懂
   - 描述性的测试名称
   - 清晰的 AAA 结构
   - 有意义的断言

4. **快速执行**: 避免不必要的延迟
   - 使用 Mock 避免真实 API 调用
   - 避免真实的 setTimeout
   - 使用 fake timers

5. **持续集成**: 自动化测试
   - 每次提交运行测试
   - 测试覆盖率检查
   - 失败时通知

---

### 4. add-route.md - 路由配置技能

#### 功能定位

快速添加标准化的页面路由配置，包括路由定义、权限配置、菜单配置和国际化支持。

---

#### 使用方法

**基本语法**:
```bash
/add-route <路由名称> [选项]
```

**参数说明**:

- `路由名称`: 路由的名称（如 `user-management`）

- `--path=/custom-path`: 自定义路由路径
  - 默认使用路由名称作为路径

- `--auth`: 需要认证
  - 添加登录验证
  - 未登录跳转到登录页

- `--title=页面标题`: 页面标题
  - 显示在浏览器标签
  - 显示在菜单中

- `--icon=icon-name`: 菜单图标
  - 显示在菜单项前

- `--parent=parent-route`: 父路由
  - 创建嵌套路由
  - 子路由路径自动拼接

---

#### 生成的内容

**1. 路由配置文件** (`routes/modules/user-management.ts`)

```typescript
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/user-management',
    name: 'UserManagement',
    component: () => import('@/views/user-management/index.vue'),
    meta: {
      title: '用户管理',
      icon: 'users',
      auth: true,
      order: 1,
    },
    children: [
      {
        path: 'list',
        name: 'UserList',
        component: () => import('@/views/user-management/list/index.vue'),
        meta: {
          title: '用户列表',
          icon: 'list',
          auth: true,
        },
      },
      {
        path: 'create',
        name: 'UserCreate',
        component: () => import('@/views/user-management/create/index.vue'),
        meta: {
          title: '创建用户',
          icon: 'plus',
          auth: true,
          hideInMenu: true,
        },
      },
      {
        path: ':id/edit',
        name: 'UserEdit',
        component: () => import('@/views/user-management/edit/index.vue'),
        meta: {
          title: '编辑用户',
          icon: 'edit',
          auth: true,
          hideInMenu: true,
        },
      },
    ],
  },
];

export default routes;
```

**路由元信息** (`meta`):

```typescript
interface RouteMeta {
  // 页面标题
  title: string;

  // 菜单图标
  icon?: string;

  // 是否需要认证
  auth?: boolean;

  // 是否在菜单中隐藏
  hideInMenu?: boolean;

  // 是否缓存页面
  keepAlive?: boolean;

  // 菜单排序
  order?: number;

  // 外链
  link?: string;

  // 权限标识
  permissions?: string[];

  // 角色标识
  roles?: string[];
}
```

**2. 页面组件** (`views/user-management/index.vue`)

```vue
<template>
  <div class="user-management-page">
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';

defineOptions({
  name: 'UserManagementPage',
});

onMounted(() => {
  console.log('User Management Page mounted');
});
</script>

<style scoped>
.user-management-page {
  height: 100%;
}
</style>
```

**3. 国际化文件** (`locales/zh-CN/user-management.json`)

```json
{
  "userManagement": {
    "title": "用户管理",
    "list": {
      "title": "用户列表",
      "search": "搜索用户",
      "create": "创建用户",
      "edit": "编辑用户",
      "delete": "删除用户"
    },
    "form": {
      "name": "用户名",
      "email": "邮箱",
      "password": "密码",
      "status": "状态",
      "avatar": "头像"
    },
    "messages": {
      "createSuccess": "创建成功",
      "updateSuccess": "更新成功",
      "deleteSuccess": "删除成功",
      "deleteConfirm": "确定要删除该用户吗？"
    }
  }
}
```

---

#### 路由类型

**1. 基础路由**

```typescript
{
  path: '/about',
  name: 'About',
  component: () => import('@/views/about/index.vue'),
  meta: {
    title: '关于我们',
  },
}
```

**特点**:
- 简单的页面路由
- 无嵌套结构

---

**2. 嵌套路由**

```typescript
{
  path: '/system',
  name: 'System',
  component: () => import('@/views/system/index.vue'),
  meta: {
    title: '系统管理',
  },
  children: [
    {
      path: 'users',
      name: 'SystemUsers',
      component: () => import('@/views/system/users/index.vue'),
      meta: {
        title: '用户管理',
      },
    },
  ],
}
```

**特点**:
- 父子路由结构
- 共享布局
- 面包屑导航

---

**3. 动态路由**

```typescript
{
  path: '/user/:id',
  name: 'UserDetail',
  component: () => import('@/views/user/detail.vue'),
  meta: {
    title: '用户详情',
  },
}
```

**特点**:
- 动态参数
- 详情页面

---

**4. 重定向路由**

```typescript
{
  path: '/old-path',
  redirect: '/new-path',
}
```

**特点**:
- 旧路径跳转
- 兼容处理

---

#### 权限配置

**角色权限**:

```typescript
meta: {
  title: '管理员页面',
  roles: ['admin'],
}
```

**权限标识**:

```typescript
meta: {
  title: '用户管理',
  permissions: ['user:view', 'user:create', 'user:edit', 'user:delete'],
}
```

---

#### 菜单配置

**显示在菜单**:

```typescript
meta: {
  title: '用户管理',
  icon: 'users',
  order: 1,
}
```

**隐藏菜单项**:

```typescript
meta: {
  title: '编辑用户',
  hideInMenu: true,
}
```

**外链菜单**:

```typescript
meta: {
  title: '文档',
  icon: 'document',
  link: 'https://example.com/docs',
}
```

---

#### 使用场景

**场景 1: 创建独立页面路由**

```bash
/add-route user-management --title="用户管理" --icon=users
```

**适用情况**:
- 顶级菜单项
- 独立功能模块
- 无父路由

---

**场景 2: 创建需要认证的路由**

```bash
/add-route profile --auth --title="个人中心"
```

**适用情况**:
- 需要登录的页面
- 用户个人信息
- 敏感操作

---

**场景 3: 创建子路由**

```bash
/add-route user-list --parent=user-management --title="用户列表"
```

**适用情况**:
- 嵌套菜单结构
- 模块内子页面
- 共享布局

---

#### 最佳实践

1. **命名规范**: 使用 kebab-case 命名路由
   - ✅ `user-management`, `order-list`
   - ❌ `userManagement`, `orderList`

2. **懒加载**: 使用动态导入优化性能
   ```typescript
   component: () => import('@/views/user-management/index.vue')
   ```

3. **权限控制**: 合理配置权限和角色
   - 基于角色的权限控制
   - 细粒度的权限标识
   - 避免过度权限

4. **页面缓存**: 使用 keepAlive 缓存页面
   ```typescript
   meta: {
     keepAlive: true,
   }
   ```

5. **国际化**: 为所有文本添加国际化支持
   - 页面标题
   - 菜单文本
   - 提示信息

6. **嵌套路由**: 合理使用嵌套路由组织页面结构
   - 相关页面组织在一起
   - 共享布局
   - 清晰的层级关系

---

## 技能之间的关系

### 协作流程

```
┌─────────────────┐
│ add-route       │ 1. 创建路由
└────────┬────────┘
         │
         v
┌─────────────────┐
│ create-component│ 2. 创建页面组件
└────────┬────────┘
         │
         v
┌─────────────────┐
│ create-api      │ 3. 创建 API 接口
└────────┬────────┘
         │
         v
┌─────────────────┐
│ create-test     │ 4. 创建测试用例
└─────────────────┘
```

### 典型开发流程

**1. 创建新功能模块的完整流程**

```bash
# 步骤 1: 添加路由
/add-route user-management --title="用户管理" --icon=users

# 步骤 2: 创建页面组件
/create-component UserManagement --type=page

# 步骤 3: 创建 API 接口
/create-api user --methods=get,post,put,delete

# 步骤 4: 创建测试用例
/create-test UserManagement --type=unit
/create-test UserManagement --type=e2e
```

**2. 创建独立组件的流程**

```bash
# 创建组件
/create-component BaseButton --type=base

# 创建测试
/create-test BaseButton --type=unit
```

**3. 创建 API 模块的流程**

```bash
# 创建 API
/create-api order --auth --cache

# 创建测试
/create-test OrderAPI --type=unit
```

---

### 技能依赖关系

| 技能 | 依赖 | 说明 |
|------|------|------|
| create-component | create-test | 组件创建后需要测试 |
| create-api | create-test | API 创建后需要测试 |
| add-route | create-component | 路由需要对应页面组件 |
| create-test | create-component/create-api | 测试依赖于被测试对象 |

---

## 最佳实践建议

### 1. 技能使用顺序

**推荐顺序**:
1. **规划**: 明确需求和功能
2. **路由**: 使用 `add-route` 创建路由结构
3. **组件**: 使用 `create-component` 创建组件
4. **API**: 使用 `create-api` 创建接口
5. **测试**: 使用 `create-test` 创建测试

**原因**:
- 自顶向下的开发流程
- 清晰的模块划分
- 完整的功能覆盖

---

### 2. 命名一致性

**保持命名一致**:

| 类型 | 命名规范 | 示例 |
|------|----------|------|
| 路由 | kebab-case | `user-management` |
| 组件 | PascalCase | `UserManagement` |
| API | camelCase | `getUserList` |
| 测试 | 同被测试对象 | `UserManagement.test.ts` |

---

### 3. 完整性检查

**创建功能时确保完整性**:

- [ ] 路由配置完成
- [ ] 页面组件创建
- [ ] API 接口定义
- [ ] 类型定义完整
- [ ] 测试用例覆盖
- [ ] 国际化支持
- [ ] 文档完善

---

### 4. 测试优先

**测试驱动的开发流程**:

1. 理解需求
2. 编写测试用例（使用 `create-test`）
3. 实现功能（使用 `create-component` 或 `create-api`）
4. 运行测试
5. 重构优化

---

### 5. 模块化思维

**每个功能模块独立**:

- 独立的路由配置
- 独立的组件目录
- 独立的 API 文件
- 独立的测试文件
- 独立的国际化文件

---

## 技能使用统计

### 使用频率统计

| 技能 | 使用频率 | 适用场景 |
|------|----------|----------|
| create-component | 高 | 每个新功能都需要 |
| create-api | 高 | 每个数据接口都需要 |
| create-test | 中 | 质量保证要求高的项目 |
| add-route | 中 | 新增页面功能时 |

---

### 技能复杂度

| 技能 | 复杂度 | 学习曲线 | 生成文件数量 |
|------|--------|----------|--------------|
| create-component | 中 | 中等 | 4 个 |
| create-api | 低 | 简单 | 2-3 个 |
| create-test | 高 | 较高 | 1 个 |
| add-route | 低 | 简单 | 2-3 个 |

---

## 常见问题

### Q1: 技能可以组合使用吗？

**A**: 可以。推荐的工作流程：

```bash
# 完整的新功能开发
/add-route feature --title="新功能" --icon=star
/create-component FeaturePage --type=page
/create-api feature --methods=get,post
/create-test FeaturePage --type=unit
```

---

### Q2: 生成的文件可以修改吗？

**A**: 可以。生成的文件是标准的代码文件，可以根据实际需求修改。

---

### Q3: 如何选择组件类型？

**A**: 根据组件的职责选择：
- `--type=base`: 纯展示组件，高度可复用
- `--type=business`: 包含业务逻辑，特定场景
- `--type=page`: 路由级别，完整页面

---

### Q4: 测试类型如何选择？

**A**: 根据测试目标选择：
- `--type=unit`: 单元测试，快速执行，测试细节
- `--type=e2e`: 端到端测试，真实环境，测试流程

---

### Q5: API 的 Mock 数据如何使用？

**A**: 生成的 Mock 文件用于开发环境：
1. 配置 Vite 插件加载 Mock
2. 前端开发不依赖后端
3. 生产环境移除 Mock

---

## 总结

### 技能集的核心价值

1. **标准化**: 提供统一的代码结构和风格
2. **效率**: 快速生成基础代码，减少重复劳动
3. **质量**: 遵循最佳实践，提高代码质量
4. **完整**: 生成完整的文件集，避免遗漏

---

### 对开发流程的影响

**传统开发流程**:
1. 手动创建文件
2. 编写基础代码
3. 配置路由
4. 定义接口
5. 编写测试

**使用技能后**:
1. 调用技能生成
2. 自动创建文件
3. 自动生成代码
4. 自动配置路由
5. 自动生成测试模板

**效率提升**: 约 60% 的时间节省

---

### 对团队协作的影响

1. **统一标准**: 所有成员使用相同的模板
2. **降低门槛**: 新成员快速上手
3. **代码一致**: 统一的代码风格
4. **文档同步**: 自动生成文档

---

### 建议

1. **熟练掌握**: 学习每个技能的参数和用法
2. **灵活应用**: 根据实际需求调整生成的代码
3. **持续优化**: 根据团队反馈改进技能模板
4. **团队推广**: 让所有成员使用这些技能

---

*文档生成时间: 2025-08-25*
*分析文件数量: 4 个*
*文档版本: v1.0*
