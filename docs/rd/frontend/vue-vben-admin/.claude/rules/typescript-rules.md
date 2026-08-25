# TypeScript 编码规范

## 基础类型

### 使用类型推断

```typescript
// ✅ 推荐：让 TypeScript 推断类型
let name = 'John'; // string
let count = 0; // number
let isActive = true; // boolean

// ❌ 不推荐：显式声明简单类型
let name: string = 'John';
let count: number = 0;
```

### 复杂类型显式声明

```typescript
// ✅ 推荐：复杂类型显式声明
const users: User[] = [];
const config: AppConfig = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
};

// ❌ 不推荐：复杂类型依赖推断
const users = []; // any[]
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
};
```

## 接口 vs 类型

### 使用 interface 定义对象

```typescript
// ✅ 推荐：使用 interface
interface User {
  id: string;
  name: string;
  email: string;
}

// ❌ 不推荐：使用 type
type User = {
  id: string;
  name: string;
  email: string;
};
```

### 使用 type 定义联合类型

```typescript
// ✅ 推荐：使用 type
type Status = 'active' | 'inactive' | 'pending';
type Result = SuccessResult | ErrorResult;

// ❌ 不推荐：使用 interface（无法实现）
```

### 使用 type 定义工具类型

```typescript
// ✅ 推荐
type PartialUser = Partial<User>;
type ReadonlyUser = Readonly<User>;
type UserKeys = keyof User;
type UserName = User['name'];
```

## 函数类型

### 参数类型

```typescript
// ✅ 推荐：明确参数类型
function greet(name: string, age: number): string {
  return `Hello, ${name}! You are ${age} years old.`;
}

// ✅ 推荐：可选参数
function greet(name: string, age?: number): string {
  return `Hello, ${name}!`;
}

// ✅ 推荐：默认参数
function greet(name: string, age: number = 0): string {
  return `Hello, ${name}!`;
}
```

### 函数重载

```typescript
// ✅ 推荐：函数重载
function formatDate(date: Date): string;
function formatDate(date: string): string;
function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toISOString();
}
```

### 箭头函数

```typescript
// ✅ 推荐：简单函数使用箭头函数
const add = (a: number, b: number): number => a + b;

// ✅ 推荐：复杂函数使用常规函数
function processUsers(users: User[]): ProcessedUser[] {
  // 复杂逻辑
  return users.map(user => ({
    ...user,
    processed: true,
  }));
}
```

## 泛型

### 泛型函数

```typescript
// ✅ 推荐
function identity<T>(arg: T): T {
  return arg;
}

// ✅ 推荐：泛型约束
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

### 泛型接口

```typescript
// ✅ 推荐
interface ApiResponse<T> {
  code: number;
  data: T;
  message: string;
}

interface PaginationResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
}
```

### 泛型类型

```typescript
// ✅ 推荐
type Result<T, E = Error> = {
  success: boolean;
  value?: T;
  error?: E;
};
```

## any vs unknown

### 避免 any

```typescript
// ❌ 不推荐：使用 any
function processData(data: any) {
  return data.value; // 可能运行时错误
}

// ✅ 推荐：使用 unknown
function processData(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return data.value;
  }
  throw new Error('Invalid data');
}
```

### 类型守卫

```typescript
// ✅ 推荐：自定义类型守卫
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj &&
    'email' in obj
  );
}

function processUser(data: unknown) {
  if (isUser(data)) {
    console.log(data.name); // TypeScript 知道这是 User
  }
}
```

## 联合类型与交叉类型

### 联合类型

```typescript
// ✅ 推荐
type Status = 'pending' | 'approved' | 'rejected';
type Result = Success | Failure;

function handleResult(result: Result) {
  if ('data' in result) {
    // Success
  } else {
    // Failure
  }
}
```

### 交叉类型

```typescript
// ✅ 推荐
interface BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

interface User extends BaseEntity {
  name: string;
  email: string;
}

// 或使用交叉类型
type User = BaseEntity & {
  name: string;
  email: string;
};
```

## 枚举

### 使用字面量联合类型替代枚举

```typescript
// ✅ 推荐：字面量联合类型
type Direction = 'up' | 'down' | 'left' | 'right';

// ❌ 不推荐：枚举
enum Direction {
  Up = 'up',
  Down = 'down',
  Left = 'left',
  Right = 'right',
}
```

### 数字枚举

```typescript
// ✅ 推荐：数字枚举（仅当需要数值时）
enum HttpStatus {
  OK = 200,
  BadRequest = 400,
  NotFound = 404,
  InternalServerError = 500,
}
```

## 类型断言

### 避免滥用类型断言

```typescript
// ❌ 不推荐：过度使用类型断言
const value = data as string;

// ✅ 推荐：类型检查
if (typeof data === 'string') {
  const value = data;
}
```

### 使用 const 断言

```typescript
// ✅ 推荐
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;

// 类型为 { readonly apiUrl: "https://api.example.com"; readonly timeout: 5000 }
```

### 非空断言

```typescript
// ❌ 不推荐：过度使用非空断言
const element = document.getElementById('app')!;

// ✅ 推荐：空值检查
const element = document.getElementById('app');
if (element) {
  // 使用 element
}
```

## 类

### 类定义

```typescript
// ✅ 推荐
class UserService {
  private users: User[] = [];
  
  constructor(private apiClient: ApiClient) {}
  
  async getUser(id: string): Promise<User> {
    const user = await this.apiClient.get<User>(`/users/${id}`);
    return user;
  }
  
  addUser(user: User): void {
    this.users.push(user);
  }
}
```

### 访问修饰符

```typescript
// ✅ 推荐：明确访问修饰符
class User {
  public name: string;
  protected age: number;
  private password: string;
  
  constructor(name: string, age: number, password: string) {
    this.name = name;
    this.age = age;
    this.password = password;
  }
}
```

## 工具类型

### 常用工具类型

```typescript
// Partial - 所有属性可选
type PartialUser = Partial<User>;

// Required - 所有属性必需
type RequiredUser = Required<User>;

// Readonly - 所有属性只读
type ReadonlyUser = Readonly<User>;

// Pick - 选取部分属性
type UserName = Pick<User, 'name'>;

// Omit - 排除部分属性
type UserWithoutPassword = Omit<User, 'password'>;

// Record - 构造对象类型
type UserMap = Record<string, User>;

// ReturnType - 获取函数返回类型
type UserResult = ReturnType<typeof getUser>;
```

## 模块导入

### 导入类型

```typescript
// ✅ 推荐：使用 type 关键字
import type { User, UserListParams } from './types';

// ✅ 推荐：混合导入
import { getUser } from './api';
import type { User } from './types';
```

### 重导出

```typescript
// ✅ 推荐
export type { User, UserListParams } from './types';
export { getUser } from './api';
export * from './utils';
```

## 最佳实践

1. **启用严格模式**: `"strict": true`
2. **避免 any**: 使用 unknown 或具体类型
3. **使用类型推断**: 简单类型无需显式声明
4. **明确函数返回类型**: 提高代码可读性
5. **使用接口**: 定义对象类型
6. **使用类型别名**: 定义联合类型、工具类型
7. **类型守卫**: 运行时类型检查
8. **文档注释**: 为复杂类型添加注释
