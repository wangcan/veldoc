# /api - 快速创建 API 接口

## 描述

快速创建标准化的 API 接口定义，包含类型定义、请求方法、Mock 数据等。

## 用法

```
/api <资源名称> [选项]
```

## 参数

### 资源名称
- 格式：kebab-case（如 `user-management`）
- 必须：是

### 选项

- `--methods=<方法列表>`: HTTP 方法
  - 格式：逗号分隔
  - 默认：`get,post,put,delete`
  - 可选值：`get,post,put,patch,delete`

- `--path=<路径>`: API 路径前缀
  - 默认：`/api/资源名称`

- `--auth`: 需要认证
  - 默认：`true`

- `--no-auth`: 不需要认证

- `--cache`: 启用缓存
  - 默认：`false`

- `--mock`: 生成 Mock 数据
  - 默认：`false`

- `--restful`: RESTful 风格
  - 默认：`true`

## 示例

### 创建完整 CRUD API

```bash
/api user --methods=get,post,put,delete
```

生成文件：
- `src/api/user.ts`
- `src/api/types/user.ts`

### 创建只读 API

```bash
/api config --methods=get
```

生成文件：
- `src/api/config.ts`
- `src/api/types/config.ts`

### 创建带 Mock 的 API

```bash
/api product --mock
```

生成文件：
- `src/api/product.ts`
- `src/api/types/product.ts`
- `src/api/mock/product.ts`

### 创建带缓存的 API

```bash
/api category --cache
```

## 生成的文件

### API 文件 (api/resource-name.ts)

```typescript
import { request } from '@/utils/request';
import type {
  ResourceName,
  ResourceNameListParams,
  ResourceNameCreateParams,
  ResourceNameUpdateParams,
} from './types/resource-name';

// 获取列表
export function getResourceNameList(params: ResourceNameListParams) {
  return request.get<PageResult<ResourceName>>('/api/resource-name', { params });
}

// 获取详情
export function getResourceName(id: string) {
  return request.get<ResourceName>(`/api/resource-name/${id}`);
}

// 创建
export function createResourceName(data: ResourceNameCreateParams) {
  return request.post<ResourceName>('/api/resource-name', data);
}

// 更新
export function updateResourceName(id: string, data: ResourceNameUpdateParams) {
  return request.put<ResourceName>(`/api/resource-name/${id}`, data);
}

// 删除
export function deleteResourceName(id: string) {
  return request.delete(`/api/resource-name/${id}`);
}
```

### 类型文件 (api/types/resource-name.ts)

```typescript
// 资源实体
export interface ResourceName {
  id: string;
  name: string;
  createdAt: string;
  updatedAt: string;
}

// 列表查询参数
export interface ResourceNameListParams {
  page?: number;
  pageSize?: number;
  keyword?: string;
}

// 创建参数
export interface ResourceNameCreateParams {
  name: string;
}

// 更新参数
export interface ResourceNameUpdateParams {
  name?: string;
}
```

### Mock 文件 (api/mock/resource-name.ts)

```typescript
import type { MockMethod } from 'vite-plugin-mock';

export default [
  {
    url: '/api/resource-name',
    method: 'get',
    response: ({ query }) => {
      return {
        code: 0,
        data: {
          items: [
            { id: '1', name: 'Mock Data 1' },
            { id: '2', name: 'Mock Data 2' },
          ],
          total: 100,
        },
      };
    },
  },
  {
    url: '/api/resource-name/:id',
    method: 'get',
    response: ({ query }) => {
      return {
        code: 0,
        data: { id: query.id, name: 'Mock Data' },
      };
    },
  },
] as MockMethod[];
```

## RESTful 风格

### 标准路由

```
GET    /api/users          # 获取用户列表
GET    /api/users/:id      # 获取单个用户
POST   /api/users          # 创建用户
PUT    /api/users/:id      # 更新用户（全量）
PATCH  /api/users/:id      # 更新用户（部分）
DELETE /api/users/:id      # 删除用户
```

### 特殊路由

```
POST   /api/users/batch-delete    # 批量删除
POST   /api/users/export          # 导出数据
GET    /api/users/import/template # 导入模板
POST   /api/users/import          # 导入数据
```

## API 方法

### GET 请求

```typescript
// 查询参数
export function getList(params: ListParams) {
  return request.get<Response>('/api/resource', { params });
}

// 路径参数
export function getDetail(id: string) {
  return request.get<Response>(`/api/resource/${id}`);
}
```

### POST 请求

```typescript
// 创建资源
export function create(data: CreateParams) {
  return request.post<Response>('/api/resource', data);
}

// 批量操作
export function batchOperation(ids: string[]) {
  return request.post('/api/resource/batch', { ids });
}
```

### PUT 请求

```typescript
// 全量更新
export function update(id: string, data: UpdateParams) {
  return request.put<Response>(`/api/resource/${id}`, data);
}
```

### PATCH 请求

```typescript
// 部分更新
export function partialUpdate(id: string, data: Partial<UpdateParams>) {
  return request.patch<Response>(`/api/resource/${id}`, data);
}
```

### DELETE 请求

```typescript
// 删除资源
export function remove(id: string) {
  return request.delete(`/api/resource/${id}`);
}
```

## 响应格式

### 成功响应

```typescript
interface SuccessResponse<T> {
  code: 0;
  data: T;
  message: string;
}
```

### 分页响应

```typescript
interface PageResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
}
```

### 错误响应

```typescript
interface ErrorResponse {
  code: number;
  message: string;
  errors?: Record<string, string[]>;
}
```

## 高级功能

### 请求拦截

```typescript
// 添加请求拦截器
request.interceptors.request.use((config) => {
  config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

### 响应拦截

```typescript
// 添加响应拦截器
request.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response.status === 401) {
      // 处理认证失败
    }
    return Promise.reject(error);
  }
);
```

### 缓存策略

```typescript
// 使用缓存
export function getList(params: ListParams) {
  return request.get<Response>('/api/resource', {
    params,
    cache: {
      enabled: true,
      ttl: 5 * 60 * 1000, // 5 分钟
    },
  });
}
```

### 请求取消

```typescript
// 取消请求
const controller = new AbortController();

export function getList(params: ListParams) {
  return request.get<Response>('/api/resource', {
    params,
    signal: controller.signal,
  });
}

// 取消
controller.abort();
```

## 工作流程

1. **解析参数**: 获取资源名称和选项
2. **生成类型**: 创建类型定义文件
3. **创建方法**: 创建 API 方法
4. **生成 Mock**: 如需要，创建 Mock 数据

## 注意事项

1. 资源名称必须是 kebab-case
2. 类型定义应完整准确
3. 遵循 RESTful 设计规范
4. 添加错误处理和日志

## 相关命令

- `/component`: 创建组件
- `/page`: 创建页面
- `/test`: 创建测试
- `/mock`: 创建 Mock 数据
