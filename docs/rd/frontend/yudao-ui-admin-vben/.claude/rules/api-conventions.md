# API 调用规范

本文档定义了项目中 API 接口的设计和调用规范。

## 接口设计

### RESTful 规范

遵循 RESTful API 设计原则：

- **GET**: 查询资源
- **POST**: 创建资源
- **PUT**: 更新资源（全量）
- **PATCH**: 更新资源（部分）
- **DELETE**: 删除资源

```typescript
// ✅ 推荐
GET    /api/users           // 获取用户列表
GET    /api/users/:id       // 获取用户详情
POST   /api/users           // 创建用户
PUT    /api/users/:id       // 更新用户
DELETE /api/users/:id       // 删除用户

// ❌ 不推荐
GET    /api/getUsers
POST   /api/createUser
POST   /api/updateUser
POST   /api/deleteUser
```

### URL 命名

- **使用小写字母**: URL 路径使用小写字母
- **使用连字符**: 多个单词使用连字符 `-` 分隔
- **使用复数**: 资源名使用复数形式

```typescript
// ✅ 推荐
/api/users
/api/user-profiles
/api/order-items

// ❌ 不推荐
/api/Users
/api/userProfiles
/api/order_item
```

### HTTP 状态码

正确使用 HTTP 状态码：

- **200**: 成功
- **201**: 创建成功
- **204**: 删除成功（无返回内容）
- **400**: 请求参数错误
- **401**: 未授权
- **403**: 无权限
- **404**: 资源不存在
- **500**: 服务器错误

## API 文件结构

### 目录组织

每个模块的 API 文件组织：

```
api/
├── core/               # 核心 API（认证、配置等）
│   ├── auth.ts
│   └── config.ts
├── system/             # 系统管理
│   ├── user/
│   ├── role/
│   └── menu/
├── business/           # 业务模块
│   ├── order/
│   └── product/
└── request.ts          # axios 实例配置
```

### 文件命名

- **使用 kebab-case**: 文件名使用小写字母和连字符
- **模块化组织**: 每个模块一个目录

```
api/
├── user/
│   ├── index.ts        # 用户 API
│   └── model.ts        # 类型定义
├── order/
│   ├── index.ts
│   └── model.ts
```

## 类型定义

### Namespace 模式

使用 namespace 组织相关类型：

```typescript
// ✅ 推荐
export namespace UserApi {
  export interface UserInfo {
    id: number;
    username: string;
    email: string;
    status: number;
    createTime: string;
  }

  export interface PageParams {
    pageNo: number;
    pageSize: number;
    username?: string;
    status?: number;
  }

  export interface SaveParams {
    id?: number;
    username: string;
    email: string;
    status: number;
  }

  export interface PageResult {
    list: UserInfo[];
    total: number;
  }
}
```

### 通用类型

定义通用的 API 类型：

```typescript
// 通用分页参数
export interface PageParams {
  pageNo: number;
  pageSize: number;
}

// 通用分页结果
export interface PageResult<T> {
  list: T[];
  total: number;
}

// 通用响应
export interface ApiResponse<T = any> {
  code: number;
  data: T;
  message: string;
}
```

## API 函数定义

### 命名规范

- **动词开头**: 使用动词开头表达操作意图
- **语义化命名**: 函数名应清楚表达用途

```typescript
// ✅ 推荐
export function getUserPage(params: UserApi.PageParams) { /* ... */ }
export function getUserById(id: number) { /* ... */ }
export function createUser(data: UserApi.SaveParams) { /* ... */ }
export function updateUser(data: UserApi.SaveParams) { /* ... */ }
export function deleteUser(id: number) { /* ... */ }

// ❌ 不推荐
export function userList(params: UserApi.PageParams) { /* ... */ }
export function userDetail(id: number) { /* ... */ }
export function addUser(data: UserApi.SaveParams) { /* ... */ }
```

### 函数签名

明确函数的参数和返回类型：

```typescript
// ✅ 推荐
export function getUserPage(
  params: UserApi.PageParams
): Promise<UserApi.PageResult> {
  return requestClient.get<UserApi.PageResult>('/system/user/page', { params });
}

// ✅ 推荐 - 多个参数使用对象
export function getOrders(
  params: OrderApi.QueryParams,
  options?: RequestOptions
): Promise<OrderApi.PageResult> {
  return requestClient.get<OrderApi.PageResult>('/order/page', {
    params,
    ...options,
  });
}
```

### CRUD 模式

标准的 CRUD 接口定义：

```typescript
// 分页查询
export function getXxxPage(params: XxxApi.PageParams) {
  return requestClient.get<XxxApi.PageResult>('/module/xxx/page', { params });
}

// 列表查询（不分页）
export function getXxxList(params?: XxxApi.QueryParams) {
  return requestClient.get<XxxApi.Entity[]>('/module/xxx/list', { params });
}

// 详情查询
export function getXxxById(id: number) {
  return requestClient.get<XxxApi.Entity>(`/module/xxx/${id}`);
}

// 创建
export function createXxx(data: XxxApi.SaveParams) {
  return requestClient.post<XxxApi.Entity>('/module/xxx', data);
}

// 更新
export function updateXxx(data: XxxApi.SaveParams) {
  return requestClient.put<XxxApi.Entity>('/module/xxx', data);
}

// 删除
export function deleteXxx(id: number) {
  return requestClient.delete(`/module/xxx/${id}`);
}

// 批量删除
export function deleteXxxList(ids: number[]) {
  return requestClient.delete('/module/xxx/list', { data: { ids } });
}
```

## 请求客户端

### 统一实例

使用项目统一的请求客户端：

```typescript
import { requestClient } from '#/api/request';

// ✅ 推荐
export function getUser(id: number) {
  return requestClient.get<User>(`/user/${id}`);
}

// ❌ 不推荐 - 直接使用 axios
import axios from 'axios';

export function getUser(id: number) {
  return axios.get(`/user/${id}`);
}
```

### 请求配置

#### GET 请求

```typescript
// 带查询参数
requestClient.get('/users', { params: { status: 1 } });

// 带 URL 参数
requestClient.get(`/users/${id}`);

// 带响应类型
requestClient.get<User[]>('/users');
```

#### POST 请求

```typescript
// 提交 JSON 数据
requestClient.post('/users', { name: 'John', email: 'john@example.com' });

// 带响应类型
requestClient.post<User>('/users', userData);

// 表单数据
const formData = new FormData();
formData.append('file', file);
requestClient.post('/upload', formData, {
  headers: { 'Content-Type': 'multipart/form-data' },
});
```

#### PUT 请求

```typescript
// 更新资源
requestClient.put(`/users/${id}`, userData);
```

#### DELETE 请求

```typescript
// 删除单个资源
requestClient.delete(`/users/${id}`);

// 批量删除
requestClient.delete('/users', { data: { ids: [1, 2, 3] } });
```

### 特殊配置

#### 超时配置

```typescript
export function getLargeData() {
  return requestClient.get('/large-data', {
    timeout: 10000, // 10秒超时
  });
}
```

#### 重试机制

```typescript
export function getUnstableData() {
  return requestClient.get('/unstable-api', {
    retry: 3, // 重试3次
    retryDelay: 1000, // 重试延迟1秒
  });
}
```

#### 取消请求

```typescript
const controller = new AbortController();

export function searchData(keyword: string) {
  return requestClient.get('/search', {
    params: { keyword },
    signal: controller.signal,
  });
}

// 取消请求
controller.abort();
```

## 错误处理

### 统一处理

项目已统一处理常见错误，API 函数无需额外处理：

- **401**: 自动跳转登录
- **403**: 提示无权限
- **404**: 提示资源不存在
- **500**: 提示服务器错误

### 业务错误

业务相关错误在 API 函数中处理：

```typescript
export async function login(credentials: LoginParams) {
  try {
    const result = await requestClient.post<LoginResult>('/auth/login', credentials);
    return result;
  } catch (error) {
    // 特殊错误处理
    if (error.code === 'USER_NOT_FOUND') {
      throw new Error('用户不存在');
    }
    throw error;
  }
}
```

### 错误类型

定义错误类型：

```typescript
export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

export function isApiError(error: unknown): error is ApiError {
  return typeof error === 'object'
    && error !== null
    && 'code' in error
    && 'message' in error;
}
```

## 数据转换

### 请求前转换

发送请求前转换数据：

```typescript
export function createUser(data: UserForm) {
  // 转换表单数据为 API 参数
  const params: UserApi.SaveParams = {
    username: data.username,
    email: data.email,
    status: data.status ? 1 : 0, // 转换布尔值
    createTime: data.createTime.toISOString(), // 转换日期
  };
  return requestClient.post<UserApi.Entity>('/users', params);
}
```

### 响应后转换

接收响应后转换数据：

```typescript
export async function getUser(id: number) {
  const data = await requestClient.get<UserApi.Entity>(`/users/${id}`);
  // 转换 API 响应为前端数据
  return {
    ...data,
    status: data.status === 1, // 转换为布尔值
    createTime: new Date(data.createTime), // 转换为 Date
  };
}
```

## 导入导出

### 导出功能

```typescript
export function exportUsers(params: UserApi.PageParams) {
  return requestClient.download('/users/export', params);
}

export function exportUsersToExcel(params: UserApi.PageParams) {
  return requestClient.download('/users/export/excel', params, {
    responseType: 'blob',
  });
}
```

### 导入功能

```typescript
export function importUsers(file: File) {
  const formData = new FormData();
  formData.append('file', file);

  return requestClient.post<ImportResult>('/users/import', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
}
```

## 租户支持

### 租户 ID

项目自动添加租户 ID 到请求头：

```typescript
// 自动添加 header: tenant-id
requestClient.get('/users');
```

### 访问租户

访问其他租户数据时添加 visit-tenant-id：

```typescript
export function getTenantUsers(tenantId: number) {
  return requestClient.get<User[]>('/users', {
    headers: { 'visit-tenant-id': tenantId },
  });
}
```

## 最佳实践

1. **统一请求客户端**: 使用项目统一的 requestClient
2. **类型安全**: 为所有 API 定义类型
3. **错误处理**: 合理处理错误
4. **语义化命名**: 使用清晰的函数名
5. **RESTful 设计**: 遵循 RESTful API 设计规范
6. **文档注释**: 为复杂接口添加注释

---

遵循这些规范，可以确保 API 接口的一致性、可维护性和可靠性。
