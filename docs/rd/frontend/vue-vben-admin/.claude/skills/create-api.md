---
name: create-api
description: 快速创建 API 接口定义和请求方法
triggers:
  - "创建 API"
  - "新建接口"
  - "add api"
---

# 快速创建 API 接口

这个技能帮助你快速创建标准化的 API 接口定义，包含类型定义和请求方法。

## 使用方法

```
/create-api <资源名称> [选项]
```

### 参数

- `资源名称`: API 资源名称（如 user、order）
- `选项`:
  - `--methods=get,post,put,delete`: 指定 HTTP 方法
  - `--auth`: 需要认证
  - `--cache`: 启用缓存
  - `--mock`: 生成 Mock 数据

### 示例

```bash
# 创建用户 API
/create-api user --methods=get,post,put,delete

# 创建订单 API（带认证）
/create-api order --auth

# 创建产品 API（带缓存和 Mock）
/create-api product --cache --mock
```

## 生成的文件

### API 定义文件 (index.ts)

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

### 类型文件 (types.ts)

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

### Mock 文件 (mock.ts)

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

## API 设计规范

### RESTful 规范

- `GET`: 查询资源
- `POST`: 创建资源
- `PUT`: 更新资源（全量）
- `PATCH`: 更新资源（部分）
- `DELETE`: 删除资源

### 命名规范

- **资源名**: 复数形式（如 users、orders）
- **路由参数**: 使用 `:id` 格式
- **查询参数**: camelCase（如 pageSize）

### 响应格式

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

## 最佳实践

1. **类型安全**: 为所有接口定义类型
2. **错误处理**: 统一处理错误
3. **请求取消**: 支持取消请求
4. **缓存策略**: 合理使用缓存
5. **日志记录**: 记录关键请求
6. **Mock 数据**: 方便前端开发
