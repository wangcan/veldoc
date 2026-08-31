# TypeScript 编码规范

本文档定义了项目中 TypeScript 的编码规范和最佳实践。

## 基本原则

### 启用严格模式

项目已启用 TypeScript 严格模式，确保类型安全：

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true
  }
}
```

### 避免使用 any

- **禁止使用 any**: 避免使用 `any` 类型
- **使用 unknown**: 对于未知类型使用 `unknown`，并进行类型守卫
- **使用具体类型**: 尽可能使用具体的类型定义

```typescript
// ✅ 推荐
function parseJSON(json: string): unknown {
  return JSON.parse(json);
}

function isUser(data: unknown): data is User {
  return typeof data === 'object' && data !== null && 'id' in data;
}

// ❌ 不推荐
function parseJSON(json: string): any {
  return JSON.parse(json);
}
```

## 类型定义

### interface vs type

- **interface**: 用于定义对象结构、可扩展的类型
- **type**: 用于联合类型、交叉类型、映射类型

```typescript
// ✅ 推荐 - 对象结构用 interface
interface User {
  id: number;
  name: string;
  email: string;
}

// ✅ 推荐 - 联合类型用 type
type Status = 'active' | 'inactive';
type Result = Success | Error;

// ✅ 推荐 - 复杂类型用 type
type DeepPartial<T> = {
  [P in keyof T]?: DeepPartial<T[P]>;
};
```

### 命名规范

- **PascalCase**: 接口名、类型名、类名、枚举名
- **camelCase**: 变量名、函数名、方法名、属性名
- **UPPER_SNAKE_CASE**: 常量名、枚举值

```typescript
// ✅ 推荐
interface UserInfo {
  id: number;
  userName: string;
}

type ApiResult<T> = {
  code: number;
  data: T;
};

const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';

enum Status {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

// ❌ 不推荐
interface userInfo {
  Id: number;
  UserName: string;
}

const max_retry_count = 3;
```

### 类型导出

- **统一导出**: 在文件末尾统一导出类型
- **命名导出**: 优先使用命名导出

```typescript
// ✅ 推荐
interface User {
  id: number;
  name: string;
}

interface CreateUserParams {
  name: string;
  email: string;
}

export type { User, CreateUserParams };

// ❌ 不推荐
export interface User {
  id: number;
  name: string;
}

export interface CreateUserParams {
  name: string;
  email: string;
}
```

## 泛型使用

### 泛型命名

- **单个大写字母**: 常见泛型参数使用 T、U、V
- **语义化命名**: 复杂泛型使用语义化名称

```typescript
// ✅ 推荐 - 简单泛型
function identity<T>(arg: T): T {
  return arg;
}

// ✅ 推荐 - 语义化泛型
function fetchApi<Response>(url: string): Promise<Response> {
  return fetch(url).then(res => res.json());
}

// ✅ 推荐 - 多个泛型参数
function map<Input, Output>(
  array: Input[],
  fn: (item: Input) => Output
): Output[] {
  return array.map(fn);
}
```

### 泛型约束

- **合理约束**: 为泛型添加合理的约束
- **避免过度约束**: 不要过度限制泛型的灵活性

```typescript
// ✅ 推荐
interface Lengthwise {
  length: number;
}

function getLength<T extends Lengthwise>(arg: T): number {
  return arg.length;
}

// ✅ 推荐 - keyof 约束
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// ❌ 不推荐 - 过度约束
function process<T extends { id: number; name: string }>(data: T): T {
  return data;
}
```

## 类型守卫

### 类型谓词

使用类型谓词（type predicate）进行类型收窄：

```typescript
// ✅ 推荐
function isUser(data: unknown): data is User {
  return typeof data === 'object'
    && data !== null
    && 'id' in data
    && 'name' in data;
}

function isApiError(error: unknown): error is ApiError {
  return typeof error === 'object'
    && error !== null
    && 'code' in error
    && 'message' in error;
}
```

### 可辨识联合

使用可辨识联合（discriminated union）处理变体：

```typescript
// ✅ 推荐
interface Success {
  type: 'success';
  data: User;
}

interface Error {
  type: 'error';
  error: string;
}

type Result = Success | Error;

function handleResult(result: Result) {
  switch (result.type) {
    case 'success':
      console.log(result.data);
      break;
    case 'error':
      console.error(result.error);
      break;
  }
}
```

## 函数类型

### 函数重载

为函数提供精确的类型重载：

```typescript
// ✅ 推荐
function formatDate(date: Date): string;
function formatDate(date: string): string;
function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString();
}
```

### 函数类型定义

明确函数的参数和返回类型：

```typescript
// ✅ 推荐
type EventHandler = (event: Event) => void;

interface ApiClient {
  get<T>(url: string, params?: Record<string, any>): Promise<T>;
  post<T>(url: string, data?: any): Promise<T>;
}

// ❌ 不推荐
type EventHandler = Function;

interface ApiClient {
  get: Function;
  post: Function;
}
```

## 类型导入

### 导入类型

使用 `import type` 导入仅用于类型注解的声明：

```typescript
// ✅ 推荐
import type { User, CreateUserParams } from './types';
import { UserService } from './service';

// ✅ 推荐 - 混合导入
import { UserService, type User } from './user';

// ❌ 不推荐
import { User } from './types'; // User 仅用作类型
```

## 可选链和空值合并

### 可选链

使用可选链操作符 `?.` 安全访问属性：

```typescript
// ✅ 推荐
const name = user?.profile?.name;
const firstItem = array?.[0];
const result = obj.method?.();

// ❌ 不推荐
const name = user && user.profile && user.profile.name;
```

### 空值合并

使用空值合并操作符 `??` 提供默认值：

```typescript
// ✅ 推荐
const name = user.name ?? 'Unknown';
const count = items.length ?? 0;

// ❌ 不推荐
const name = user.name || 'Unknown'; // 会排除 falsy 值
const count = items.length || 0;
```

## 枚举

### 使用枚举

为有限的选项集合使用枚举：

```typescript
// ✅ 推荐 - 字符串枚举
enum Status {
  Active = 'ACTIVE',
  Inactive = 'INACTIVE',
}

// ✅ 推荐 - 数字枚举
enum Direction {
  Up = 1,
  Down,
  Left,
  Right,
}

// ✅ 推荐 - const 枚举（内联）
const enum ButtonType {
  Primary,
  Secondary,
  Danger,
}
```

### 枚举 vs 联合类型

根据场景选择：

```typescript
// ✅ 推荐 - 固定选项用枚举
enum Status {
  Active = 'ACTIVE',
  Inactive = 'INACTIVE',
}

// ✅ 推荐 - 简单选项用联合类型
type ButtonSize = 'small' | 'medium' | 'large';
```

## 工具类型

### 常用工具类型

充分利用 TypeScript 提供的工具类型：

```typescript
// Partial - 所有属性可选
type PartialUser = Partial<User>;

// Required - 所有属性必需
type RequiredUser = Required<User>;

// Readonly - 所有属性只读
type ReadonlyUser = Readonly<User>;

// Pick - 选取部分属性
type UserPreview = Pick<User, 'id' | 'name' | 'avatar'>;

// Omit - 排除部分属性
type UserWithoutId = Omit<User, 'id'>;

// Record - 创建对象类型
type UserMap = Record<string, User>;

// ReturnType - 获取函数返回类型
type Result = ReturnType<typeof fetchData>;

// Parameters - 获取函数参数类型
type Params = Parameters<typeof fetchData>;
```

### 自定义工具类型

创建项目特定的工具类型：

```typescript
// 深层 Partial
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// 非空属性
type NonNullable<T> = T extends null | undefined ? never : T;

// 必需属性
type RequiredKeys<T> = {
  [K in keyof T]-?: T[K];
}[keyof T];
```

## 声明文件

### 模块声明

为第三方模块添加类型声明：

```typescript
// types/some-module.d.ts
declare module 'some-module' {
  export interface Options {
    timeout?: number;
    retries?: number;
  }

  export function init(options?: Options): void;
  export function destroy(): void;
}
```

### 全局声明

为全局变量添加类型声明：

```typescript
// types/global.d.ts
declare global {
  interface Window {
    customConfig: {
      apiUrl: string;
      version: string;
    };
  }
}

export {};
```

## 最佳实践

1. **启用严格模式**: 确保类型安全
2. **避免 any**: 使用具体类型或 unknown
3. **明确类型**: 为所有变量、函数、参数添加类型
4. **使用工具类型**: 充分利用 TypeScript 工具类型
5. **类型复用**: 提取公共类型到独立文件
6. **及时更新**: 保持类型定义与实现同步

---

遵循这些规范，可以确保 TypeScript 代码的类型安全性、可读性和可维护性。
