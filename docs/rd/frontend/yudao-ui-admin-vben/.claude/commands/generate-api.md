# /generate-api

从 Swagger 文档生成 API 代码的命令。

## 用法

```bash
/generate-api <swagger-url|swagger-file> [options]
```

## 参数

- `swagger-url|swagger-file`: Swagger 文档 URL 或本地文件路径（必填）

## 选项

- `--output`: 输出目录，默认 `src/api`
- `--module`: 模块名称，自动从 Swagger 解析
- `--typescript`: 是否生成 TypeScript 类型，默认 true
- `--axios`: 是否生成 axios 请求代码，默认 true
- `--format`: 是否格式化代码，默认 true

## 示例

### 从 URL 生成

```bash
/generate-api https://api.example.com/swagger.json
```

### 从本地文件生成

```bash
/generate-api ./swagger.json
```

### 指定输出目录

```bash
/generate-api https://api.example.com/swagger.json --output=src/api/v2
```

### 仅生成类型定义

```bash
/generate-api ./swagger.json --axios=false
```

## 生成内容

### 1. 类型定义

根据 Swagger schema 生成 TypeScript 类型：

```typescript
// api/user/model.ts
export namespace UserApi {
  export interface UserInfo {
    /** 用户ID */
    id: number;
    /** 用户名 */
    username: string;
    /** 邮箱 */
    email: string;
    /** 状态：0-禁用 1-启用 */
    status: number;
    /** 创建时间 */
    createTime: string;
  }

  export interface PageParams {
    /** 页码 */
    pageNo: number;
    /** 每页数量 */
    pageSize: number;
    /** 用户名 */
    username?: string;
  }

  export interface PageResult {
    list: UserInfo[];
    total: number;
  }
}
```

### 2. API 函数

根据 Swagger paths 生成 API 函数：

```typescript
// api/user/index.ts
import { requestClient } from '#/api/request';
import type * as Model from './model';

/**
 * 获取用户分页列表
 */
export function getUserPage(params: Model.UserApi.PageParams) {
  return requestClient.get<Model.UserApi.PageResult>('/system/user/page', { params });
}

/**
 * 获取用户详情
 */
export function getUserById(id: number) {
  return requestClient.get<Model.UserApi.UserInfo>(`/system/user/${id}`);
}

/**
 * 创建用户
 */
export function createUser(data: Model.UserApi.UserInfo) {
  return requestClient.post<Model.UserApi.UserInfo>('/system/user', data);
}
```

### 3. 枚举定义

根据 Swagger enum 生成枚举或常量：

```typescript
// api/user/model.ts
export enum UserStatus {
  /** 禁用 */
  Disabled = 0,
  /** 启用 */
  Enabled = 1,
}

export const USER_STATUS_OPTIONS = [
  { label: '禁用', value: UserStatus.Disabled },
  { label: '启用', value: UserStatus.Enabled },
];
```

## Swagger 规范要求

### Tags 分组

使用 tags 对 API 进行分组：

```json
{
  "tags": [
    { "name": "user", "description": "用户管理" },
    { "name": "order", "description": "订单管理" }
  ]
}
```

### 描述信息

为每个接口和字段添加描述：

```json
{
  "paths": {
    "/user/{id}": {
      "get": {
        "summary": "获取用户详情",
        "description": "根据用户ID获取用户详细信息",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "用户ID",
            "required": true,
            "schema": { "type": "integer" }
          }
        ]
      }
    }
  }
}
```

### Schema 定义

使用 schema 定义数据结构：

```json
{
  "components": {
    "schemas": {
      "UserInfo": {
        "type": "object",
        "properties": {
          "id": { "type": "integer", "description": "用户ID" },
          "username": { "type": "string", "description": "用户名" }
        }
      }
    }
  }
}
```

## 生成规则

### 命名转换

- **URL**: `/system/user/get-page` → `getUserPage`
- **Type**: `UserInfo` → `UserInfo`（保持原样）
- **Property**: `user_name` → `userName`（camelCase）

### 类型映射

| Swagger Type | TypeScript Type |
|--------------|----------------|
| string | string |
| integer | number |
| number | number |
| boolean | boolean |
| array | T[] |
| object | Record<string, any> |
| date-time | string |
| file | File |

### 路径处理

- **GET**: 使用 params 传递参数
- **POST/PUT**: 使用 data 传递参数
- **DELETE**: 单个用路径参数，批量用 data
- **文件上传**: 使用 FormData

## 自定义配置

创建配置文件自定义生成规则：

```javascript
// .api-generator.js
module.exports = {
  // 输出目录
  output: 'src/api',

  // 类型映射
  typeMap: {
    'date-time': 'Date',
    'file': 'File',
  },

  // 命名转换
  naming: {
    // 接口名转换
    operationId: (id) => camelCase(id),
    // 类型名转换
    schema: (name) => pascalCase(name),
  },

  // 模板自定义
  templates: {
    api: './templates/api.ts.ejs',
    model: './templates/model.ts.ejs',
  },
};
```

## 后续操作

生成代码后，需要：

1. **检查类型**: 验证生成的类型是否正确
2. **调整接口**: 根据实际需求调整接口参数
3. **添加注释**: 为复杂的接口添加使用说明
4. **测试接口**: 测试生成的接口是否正常工作

## 注意事项

- Swagger 文档必须符合 OpenAPI 规范
- 生成的代码需要根据实际情况调整
- 某些复杂类型可能需要手动定义
- 建议定期从最新的 Swagger 重新生成

---

此命令可快速从 Swagger 文档生成符合项目规范的 API 代码，减少手动编写的工作量。
