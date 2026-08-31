# Rules 目录分析报告

## 目录概述

`.claude/rules/` 目录包含项目的编码规范文件。这些规则定义了项目的代码风格、最佳实践和开发标准，为 Claude AI 助手和开发团队提供统一的编码指导。

## 目录结构

```
.claude/rules/
├── api-conventions.md       # API 调用规范
├── commit-conventions.md    # Git 提交规范
├── typescript-rules.md      # TypeScript 编码规范
└── vue-style-guide.md       # Vue 组件编写规范
```

## Rule 文件通用结构

每个 Rule 文件都遵循统一的结构：

### 1. 标题和简介

```markdown
# 规范名称

本文档定义了项目中 XXX 的编码规范和最佳实践。
```

### 2. 基本原则

定义规范的基本原则和核心理念。

### 3. 详细规则

分章节详细介绍各项规则。

### 4. 代码示例

提供大量正确和错误的示例对比。

### 5. 最佳实践

总结最佳实践和注意事项。

## Rule 详细分析

### 1. Vue Style Guide (vue-style-guide.md)

#### 基本信息

- **主题**: Vue 组件编写规范
- **范围**: Vue 3 Composition API、组件结构、命名规范
- **目标**: 确保组件代码的一致性、可读性和可维护性

#### 主要内容

##### 1. 组件命名

**文件命名**:
- 使用 kebab-case
- 多个单词，避免与 HTML 元素冲突
- 语义化命名

**示例**:
```typescript
// ✅ 推荐
user-list.vue
product-form.vue
order-detail.vue

// ❌ 不推荐
UserList.vue
productForm.vue
detail.vue
```

**组件注册**:
```vue
<script setup lang="ts">
import UserList from './user-list.vue';
</script>

<template>
  <UserList />
</template>
```

##### 2. Props 定义

**类型定义**:
- 必须定义类型
- 使用 TypeScript interface
- 避免使用 any

**示例**:
```typescript
// ✅ 推荐
interface Props {
  title: string;
  data?: UserInfo[];
  loading?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  data: () => [],
  loading: false,
});

// ❌ 不推荐
const props = defineProps({
  title: String,
  data: Array,
});
```

**默认值**:
- 使用 withDefaults
- 对象/数组使用工厂函数

##### 3. Events 定义

**类型定义**:
```typescript
// ✅ 推荐
interface Emits {
  (e: 'update', value: string): void;
  (e: 'submit', data: FormData): void;
}

const emit = defineEmits<Emits>();

// ❌ 不推荐
const emit = defineEmits(['update', 'submit']);
```

**事件命名**:
- 使用 kebab-case
- 动词开头

##### 4. 插槽使用

**命名规范**:
- 使用 kebab-case
- 语义化命名

**示例**:
```vue
<!-- ✅ 推荐 -->
<template #header-content>
  <h1>标题</h1>
</template>

<template #item-actions="{ item }">
  <button @click="handleEdit(item)">编辑</button>
</template>
```

##### 5. 组件结构

**文件顺序**:
1. script setup - 逻辑代码
2. template - 模板代码
3. style - 样式代码

**代码组织**:
```vue
<script setup lang="ts">
// 1. 导入
import { ref, computed } from 'vue';

// 2. 类型定义
interface Props { /* ... */ }

// 3. Props 和 Emits
const props = defineProps<Props>();
const emit = defineEmits<Emits>();

// 4. 响应式数据
const loading = ref(false);

// 5. 计算属性
const displayData = computed(() => /* ... */);

// 6. 方法
function handleClick() { /* ... */ }

// 7. 生命周期
onMounted(() => { /* ... */ });
</script>

<template>
  <!-- 模板内容 -->
</template>

<style scoped>
/* 样式 */
</style>
```

##### 6. Composition API

**ref vs reactive**:
- 简单值用 ref
- 对象用 reactive
- 保持一致性

**computed**:
```typescript
// 只读
const doubleCount = computed(() => count.value * 2);

// 可写
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: (value) => {
    [firstName.value, lastName.value] = value.split(' ');
  },
});
```

**watch**:
```typescript
// 明确依赖
watch(count, (newValue, oldValue) => {
  console.log(`count changed from ${oldValue} to ${newValue}`);
});

// 避免不必要的深度监听
watch(obj, () => {}, { deep: true });
```

##### 7. 模板规范

**指令使用**:
- 频繁切换用 v-show
- 条件渲染用 v-if
- v-for 必须提供 key

**属性顺序**:
1. is / v-for
2. v-if / v-else-if / v-else / v-show
3. id / ref / key
4. v-model
5. v-on (@)
6. v-bind (:)
7. v-text / v-html
8. 其他属性

##### 8. 样式规范

**Scoped 样式**:
```vue
<style scoped>
.user-list {
  /* 样式 */
}
</style>
```

**Tailwind CSS**:
- 优先使用 Tailwind
- 仅在必要时添加自定义样式

##### 9. 最佳实践

1. **单一职责**: 一个组件一个职责
2. **性能优化**: 懒加载、虚拟滚动、防抖节流
3. **可访问性**: 语义化 HTML、ARIA 属性
4. **测试**: 单元测试、集成测试

#### 特点

- **全面性**: 覆盖 Vue 组件开发的各个方面
- **实用性**: 提供大量代码示例
- **规范性**: 明确的规范和标准
- **最佳实践**: 总结 Vue 3 最佳实践

---

### 2. TypeScript Rules (typescript-rules.md)

#### 基本信息

- **主题**: TypeScript 编码规范
- **范围**: 类型定义、泛型、类型守卫、函数类型
- **目标**: 确保类型安全性和代码质量

#### 主要内容

##### 1. 基本原则

**启用严格模式**:
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

**避免使用 any**:
```typescript
// ✅ 推荐
function parseJSON(json: string): unknown {
  return JSON.parse(json);
}

// ❌ 不推荐
function parseJSON(json: string): any {
  return JSON.parse(json);
}
```

##### 2. 类型定义

**interface vs type**:
```typescript
// interface - 对象结构
interface User {
  id: number;
  name: string;
}

// type - 联合类型、交叉类型
type Status = 'active' | 'inactive';
type Result = Success | Error;
```

**命名规范**:
- PascalCase: 接口名、类型名、类名
- camelCase: 变量名、函数名
- UPPER_SNAKE_CASE: 常量名

**类型导出**:
```typescript
// ✅ 推荐
interface User { /* ... */ }
export type { User };

// ❌ 不推荐
export interface User { /* ... */ }
```

##### 3. 泛型使用

**命名规范**:
```typescript
// 简单泛型
function identity<T>(arg: T): T {
  return arg;
}

// 语义化泛型
function fetchApi<Response>(url: string): Promise<Response> {
  return fetch(url).then(res => res.json());
}
```

**泛型约束**:
```typescript
interface Lengthwise {
  length: number;
}

function getLength<T extends Lengthwise>(arg: T): number {
  return arg.length;
}
```

##### 4. 类型守卫

**类型谓词**:
```typescript
function isUser(data: unknown): data is User {
  return typeof data === 'object'
    && data !== null
    && 'id' in data
    && 'name' in data;
}
```

**可辨识联合**:
```typescript
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

##### 5. 函数类型

**函数重载**:
```typescript
function formatDate(date: Date): string;
function formatDate(date: string): string;
function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString();
}
```

**函数类型定义**:
```typescript
type EventHandler = (event: Event) => void;

interface ApiClient {
  get<T>(url: string, params?: Record<string, any>): Promise<T>;
  post<T>(url: string, data?: any): Promise<T>;
}
```

##### 6. 类型导入

```typescript
// ✅ 推荐
import type { User, CreateUserParams } from './types';
import { UserService } from './service';

// ✅ 推荐 - 混合导入
import { UserService, type User } from './user';
```

##### 7. 可选链和空值合并

```typescript
// 可选链
const name = user?.profile?.name;

// 空值合并
const name = user.name ?? 'Unknown';
```

##### 8. 枚举

```typescript
// 字符串枚举
enum Status {
  Active = 'ACTIVE',
  Inactive = 'INACTIVE',
}

// const 枚举（内联）
const enum ButtonType {
  Primary,
  Secondary,
  Danger,
}
```

##### 9. 工具类型

**常用工具类型**:
```typescript
// Partial - 所有属性可选
type PartialUser = Partial<User>;

// Pick - 选取部分属性
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit - 排除部分属性
type UserWithoutId = Omit<User, 'id'>;

// Record - 创建对象类型
type UserMap = Record<string, User>;
```

**自定义工具类型**:
```typescript
// 深层 Partial
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};
```

##### 10. 声明文件

**模块声明**:
```typescript
declare module 'some-module' {
  export interface Options {
    timeout?: number;
  }
  export function init(options?: Options): void;
}
```

**全局声明**:
```typescript
declare global {
  interface Window {
    customConfig: {
      apiUrl: string;
    };
  }
}
```

#### 特点

- **类型安全**: 确保类型安全
- **最佳实践**: TypeScript 最佳实践
- **实用示例**: 大量代码示例
- **工具类型**: 充分利用 TypeScript 工具类型

---

### 3. API Conventions (api-conventions.md)

#### 基本信息

- **主题**: API 调用规范
- **范围**: RESTful 设计、接口定义、错误处理
- **目标**: 确保 API 接口的一致性和可靠性

#### 主要内容

##### 1. 接口设计

**RESTful 规范**:
```
GET    /api/users           // 获取用户列表
GET    /api/users/:id       // 获取用户详情
POST   /api/users           // 创建用户
PUT    /api/users/:id       // 更新用户
DELETE /api/users/:id       // 删除用户
```

**URL 命名**:
- 使用小写字母
- 使用连字符
- 使用复数形式

**HTTP 状态码**:
- 200: 成功
- 201: 创建成功
- 400: 请求错误
- 401: 未授权
- 403: 无权限
- 404: 资源不存在
- 500: 服务器错误

##### 2. API 文件结构

```
api/
├── core/               # 核心 API
├── system/             # 系统管理
├── business/           # 业务模块
└── request.ts          # axios 实例
```

##### 3. 类型定义

**Namespace 模式**:
```typescript
export namespace UserApi {
  export interface UserInfo {
    id: number;
    username: string;
  }

  export interface PageParams {
    pageNo: number;
    pageSize: number;
  }

  export interface PageResult {
    list: UserInfo[];
    total: number;
  }
}
```

##### 4. API 函数定义

**命名规范**:
```typescript
// ✅ 推荐
export function getUserPage(params: UserApi.PageParams) { /* ... */ }
export function getUserById(id: number) { /* ... */ }
export function createUser(data: UserApi.SaveParams) { /* ... */ }

// ❌ 不推荐
export function userList(params: UserApi.PageParams) { /* ... */ }
export function userDetail(id: number) { /* ... */ }
```

**CRUD 模式**:
```typescript
// 分页查询
export function getXxxPage(params: XxxApi.PageParams) {
  return requestClient.get<XxxApi.PageResult>('/module/xxx/page', { params });
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
```

##### 5. 请求客户端

**统一实例**:
```typescript
import { requestClient } from '#/api/request';

export function getUser(id: number) {
  return requestClient.get<User>(`/user/${id}`);
}
```

**GET 请求**:
```typescript
// 带查询参数
requestClient.get('/users', { params: { status: 1 } });

// 带 URL 参数
requestClient.get(`/users/${id}`);
```

**POST 请求**:
```typescript
// 提交 JSON 数据
requestClient.post('/users', { name: 'John' });

// 表单数据
const formData = new FormData();
formData.append('file', file);
requestClient.post('/upload', formData);
```

##### 6. 错误处理

**统一处理**:
- 401: 自动跳转登录
- 403: 提示无权限
- 404: 提示资源不存在
- 500: 提示服务器错误

**业务错误**:
```typescript
export async function login(credentials: LoginParams) {
  try {
    return await requestClient.post<LoginResult>('/auth/login', credentials);
  } catch (error) {
    if (error.code === 'USER_NOT_FOUND') {
      throw new Error('用户不存在');
    }
    throw error;
  }
}
```

##### 7. 数据转换

**请求前转换**:
```typescript
export function createUser(data: UserForm) {
  const params = {
    ...data,
    status: data.status ? 1 : 0,
    createTime: data.createTime.toISOString(),
  };
  return requestClient.post<UserApi.Entity>('/users', params);
}
```

**响应后转换**:
```typescript
export async function getUser(id: number) {
  const data = await requestClient.get<UserApi.Entity>(`/users/${id}`);
  return {
    ...data,
    status: data.status === 1,
    createTime: new Date(data.createTime),
  };
}
```

##### 8. 导入导出

```typescript
// 导出
export function exportUsers(params: UserApi.PageParams) {
  return requestClient.download('/users/export', params);
}

// 导入
export function importUsers(file: File) {
  const formData = new FormData();
  formData.append('file', file);
  return requestClient.post<ImportResult>('/users/import', formData);
}
```

#### 特点

- **规范性强**: RESTful API 设计规范
- **类型安全**: 完整的 TypeScript 类型
- **统一处理**: 统一的错误处理机制
- **实用示例**: 大量实际应用示例

---

### 4. Commit Conventions (commit-conventions.md)

#### 基本信息

- **主题**: Git 提交规范
- **范围**: 提交信息格式、分支命名、Pull Request 规范
- **目标**: 确保 Git 提交历史的清晰性和可追溯性

#### 主要内容

##### 1. Commit Message 格式

**基本格式**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**:
- feat: 新功能
- fix: Bug 修复
- docs: 文档更新
- style: 代码格式
- refactor: 重构
- perf: 性能优化
- test: 测试
- build: 构建系统
- ci: CI 配置
- chore: 杂项
- revert: 回退

**Subject 规则**:
1. 使用祈使句
2. 不超过 50 字符
3. 不以句号结尾
4. 使用中文

**示例**:
```bash
# ✅ 推荐
feat(user): 添加用户登录功能
fix(order): 修复订单计算错误

# ❌ 不推荐
feat(user): Added user login feature.
fix(order): 修复了订单计算错误。
```

##### 2. 提交示例

**新功能**:
```bash
feat(user): 添加用户注册功能

实现用户注册功能，包括：
- 注册表单验证
- 邮箱验证
- 发送验证码

关闭 #234
```

**Bug 修复**:
```bash
fix(order): 修复订单总价计算错误

修复订单总价计算时未考虑优惠券的问题。
现已在计算时正确扣除优惠券金额。

修复 #567
```

##### 3. 分支命名规范

**分支类型**:
- master: 主分支，生产环境
- develop: 开发分支
- feature/xxx: 新功能分支
- bugfix/xxx: Bug 修复分支
- hotfix/xxx: 紧急修复分支
- release/x.x.x: 发布分支

**命名示例**:
```bash
# ✅ 推荐
feature/user-login
bugfix/order-calculation
release/1.2.0

# ❌ 不推荐
feature/userLogin
bugfix/fix-bug
```

##### 4. Pull Request 规范

**PR 标题**: 遵循 commit message 格式

**PR 描述模板**:
```markdown
## 变更类型
- [ ] 新功能 (feature)
- [ ] Bug 修复 (fix)
- [ ] 文档更新 (docs)

## 变更说明
简要描述变更内容

## 影响范围
- 用户模块
- 订单模块

## 测试情况
- [ ] 单元测试通过
- [ ] 集成测试通过

## 相关 Issue
关闭 #123
```

##### 5. 最佳实践

**提交频率**:
- 小步提交
- 及时提交
- 逻辑完整

**提交信息**:
- 清晰明确
- 关联 Issue
- 避免敏感信息

**提交前检查**:
```bash
# 使用 Git hooks
pnpm lint
pnpm check:type
pnpm test:unit
```

##### 6. 工具支持

**Commitlint**:
```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', ['feat', 'fix', 'docs', ...]],
    'subject-case': [2, 'always', 'lower-case'],
  },
};
```

**Commitizen**:
```bash
pnpm commit
# 或
git cz
```

#### 特点

- **规范性强**: 清晰的提交规范
- **工具支持**: 支持自动化工具
- **团队协作**: 统一团队提交标准
- **可追溯性**: 清晰的提交历史

---

## Rules 共同特点

### 1. 规范性强

所有规则都提供了明确的规范：
- 命名规范
- 代码风格
- 最佳实践
- 禁止事项

### 2. 示例丰富

每个规则都提供大量示例：
- ✅ 推荐的做法
- ❌ 不推荐的做法
- 详细说明和对比

### 3. 覆盖全面

规则覆盖了开发的各个方面：
- Vue 组件开发
- TypeScript 编码
- API 接口设计
- Git 提交规范

### 4. 实用性强

规则来源于实践经验：
- 解决实际问题
- 避免常见错误
- 提高开发效率

## Rules 与其他配置的关系

### 1. 与 CLAUDE.md 的关系

CLAUDE.md 提供总体规范，rules 提供详细规范：
- CLAUDE.md 是概览
- rules 是详细指南

### 2. 与 hooks 的关系

hooks 根据 rules 执行检查：
- pre-commit 检查代码风格
- pre-commit 检查提交信息格式
- 确保代码符合规范

### 3. 与 agents 的关系

agents 生成的代码遵循 rules：
- 生成的代码符合规范
- 类型定义符合 TypeScript 规范
- 组件符合 Vue 规范

## 使用建议

### 1. 新成员入职

建议按以下顺序学习：
1. 阅读 CLAUDE.md（了解项目概况）
2. 学习相关 rules（掌握编码规范）
3. 参考 agents 示例（学习实际应用）

### 2. 日常开发

开发过程中：
- 遵循 rules 中的规范
- 参考示例代码
- 使用 hooks 自动检查

### 3. 代码审查

审查代码时：
- 检查是否符合 rules
- 指出不符合规范的地方
- 提供 rules 中的正确示例

## 总结

`.claude/rules/` 目录包含了四个编码规范文件，它们为项目提供了详细的开发标准：

1. **vue-style-guide.md**: Vue 组件编写规范
2. **typescript-rules.md**: TypeScript 编码规范
3. **api-conventions.md**: API 调用规范
4. **commit-conventions.md**: Git 提交规范

这些 Rules 具有以下优势：

- **规范性强**: 明确的编码标准
- **示例丰富**: 大量正确/错误对比
- **覆盖全面**: 覆盖所有开发场景
- **实用性强**: 来源于实践经验
- **易于学习**: 清晰的结构和说明

建议开发者在日常开发中严格遵循这些规范，以保证代码质量和团队协作效率。同时，也可以根据项目需求扩展和更新这些规则。
