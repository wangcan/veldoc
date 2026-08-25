# .claude/rules/ 规则文件分析报告

## 目录概述

**目录路径**: `.claude/rules/`（项目 Claude 配置目录）

**包含文件**: 4 个规则文件
- `vue-rules.md` - Vue 3 编码规范（384 行）
- `typescript-rules.md` - TypeScript 编码规范（416 行）
- `style-rules.md` - 样式编码规范（408 行）
- `git-rules.md` - Git 提交规范（430 行）

**创建时间**: 2025-08-25

**作用**: 为 AI 助手提供详细的编码规范和最佳实践指导，确保生成的代码符合项目标准

---

## 文件一：vue-rules.md

### 1.1 内容概览

**文件大小**: 384 行

**核心内容**: Vue 3 组件开发的完整规范指南

**主要章节**:
1. 组件定义
2. 命名规范
3. Props 定义
4. Emits 定义
5. 响应式数据
6. 计算属性
7. 生命周期
8. 模板规范
9. 样式规范
10. 组件导入
11. 最佳实践

---

### 1.2 主要规则分类

#### 类别 1：组件定义规范

**规则**: 使用 `<script setup>` 语法

**原因**:
- 更简洁的语法
- 更好的类型推断
- 自动暴露变量和函数
- 减少样板代码

**代码对比**:
```vue
<!-- ✅ 推荐 -->
<script setup lang="ts">
import { ref } from 'vue';
const count = ref(0);
</script>

<!-- ❌ 不推荐 -->
<script>
export default {
  data() {
    return { count: 0 };
  },
};
</script>
```

---

#### 类别 2：命名规范

**组件命名**:
- 使用 PascalCase
- 示例: `UserProfile.vue`, `UserList.vue`, `BaseButton.vue`

**Props 命名**:
- 使用 camelCase
- 示例: `userName`, `isActive`

**事件命名**:
- 使用 kebab-case
- 示例: `update:model-value`, `user-selected`

**使用场景**: 适用于所有 Vue 组件的命名，确保团队命名风格统一

---

#### 类别 3：Props 定义规范

**类型定义**:
```typescript
// ✅ 推荐：使用 interface
interface Props {
  title: string;
  count?: number;
  users: User[];
}
const props = defineProps<Props>();

// ❌ 不推荐：运行时声明
const props = defineProps({
  title: String,
  count: Number,
});
```

**默认值设置**:
```typescript
// ✅ 推荐：使用 withDefaults
const props = withDefaults(defineProps<Props>(), {
  count: 0,
  users: () => [],
});
```

**使用场景**: 定义组件输入属性时使用，确保类型安全和良好的 IDE 支持

---

#### 类别 4：Emits 定义规范

**类型定义**:
```typescript
// ✅ 推荐：使用类型定义
interface Emits {
  (e: 'update:modelValue', value: string): void;
  (e: 'change', newValue: string, oldValue: string): void;
}
const emit = defineEmits<Emits>();
```

**使用场景**: 定义组件事件时使用，确保事件类型安全

---

#### 类别 5：响应式数据规范

**ref vs reactive 选择原则**:
- **简单类型**: 使用 `ref`（string, number, boolean）
- **复杂对象**: 使用 `reactive`（对象、数组）

**代码示例**:
```typescript
// ✅ 推荐：简单类型使用 ref
const count = ref(0);
const name = ref('John');

// ✅ 推荐：复杂对象使用 reactive
const state = reactive({
  users: [],
  loading: false,
  error: null,
});
```

**解构响应式对象**:
```typescript
// ✅ 推荐：使用 toRefs
const { users, loading } = toRefs(state);

// ❌ 不推荐：直接解构（会失去响应性）
const { users, loading } = state;
```

**使用场景**: 管理组件内部状态时使用，确保响应性正确

---

#### 类别 6：模板规范

**指令缩写统一**:
```vue
<!-- ✅ 推荐：统一使用缩写 -->
<div v-if="show">Content</div>
<button @click="handleClick">Click</button>
<input v-model="value" />
```

**v-for 与 key**:
```vue
<!-- ✅ 推荐：使用唯一 ID -->
<div v-for="item in items" :key="item.id">
  {{ item.name }}
</div>

<!-- ❌ 不推荐：使用索引作为 key -->
<div v-for="(item, index) in items" :key="index">
  {{ item.name }}
</div>
```

**v-if 与 v-for 分离**:
```vue
<!-- ✅ 推荐：使用计算属性过滤 -->
<div v-for="item in activeItems" :key="item.id">
  {{ item.name }}
</div>

<script setup>
const activeItems = computed(() => items.value.filter(item => item.active));
</script>

<!-- ❌ 不推荐：同时使用 -->
<div v-for="item in items" v-if="item.active" :key="item.id">
  {{ item.name }}
</div>
```

**使用场景**: 编写组件模板时使用，确保性能和可读性

---

#### 类别 7：样式规范

**Scoped 样式**:
```vue
<!-- ✅ 推荐 -->
<style scoped>
.user-profile {
  padding: 16px;
}
</style>

<!-- ❌ 不推荐：全局样式污染 -->
<style>
.user-profile {
  padding: 16px;
}
</style>
```

**深度选择器**:
```vue
<!-- ✅ 推荐 -->
<style scoped>
.parent :deep(.child) {
  color: red;
}
</style>

<!-- ❌ 不推荐：已废弃 -->
<style scoped>
.parent >>> .child {
  color: red;
}
</style>
```

**使用场景**: 编写组件样式时使用，避免样式污染和冲突

---

### 1.3 最佳实践建议

1. **组件职责单一**: 每个组件只做一件事
2. **Props 向下，Events 向上**: 数据单向流动
3. **合理使用 v-show/v-if**: 频繁切换用 v-show
4. **避免在模板中使用复杂表达式**: 使用计算属性
5. **及时清理副作用**: 使用 watchEffect 的清理函数
6. **类型安全**: 使用 TypeScript 类型定义
7. **文档完善**: 为复杂组件添加注释

---

## 文件二：typescript-rules.md

### 2.1 内容概览

**文件大小**: 416 行

**核心内容**: TypeScript 编码的完整规范指南

**主要章节**:
1. 基础类型
2. 接口 vs 类型
3. 函数类型
4. 泛型
5. any vs unknown
6. 联合类型与交叉类型
7. 枚举
8. 类型断言
9. 类
10. 工具类型
11. 模块导入
12. 最佳实践

---

### 2.2 主要规则分类

#### 类别 1：类型推断规范

**简单类型推断**:
```typescript
// ✅ 推荐：让 TypeScript 推断类型
let name = 'John'; // string
let count = 0; // number

// ❌ 不推荐：显式声明简单类型
let name: string = 'John';
let count: number = 0;
```

**复杂类型显式声明**:
```typescript
// ✅ 推荐：复杂类型显式声明
const users: User[] = [];
const config: AppConfig = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
};

// ❌ 不推荐：复杂类型依赖推断
const users = []; // any[]
```

**使用场景**: 定义变量类型时使用，平衡简洁性和类型安全

---

#### 类别 2：interface vs type 选择

**使用 interface 定义对象**:
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

**使用 type 定义联合类型**:
```typescript
// ✅ 推荐：使用 type
type Status = 'active' | 'inactive' | 'pending';
type Result = SuccessResult | ErrorResult;
```

**使用 type 定义工具类型**:
```typescript
// ✅ 推荐
type PartialUser = Partial<User>;
type ReadonlyUser = Readonly<User>;
type UserKeys = keyof User;
type UserName = User['name'];
```

**使用场景**: 
- interface: 定义对象类型、可扩展类型
- type: 定义联合类型、交叉类型、工具类型

---

#### 类别 3：函数类型规范

**参数类型**:
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

**函数重载**:
```typescript
// ✅ 推荐：函数重载
function formatDate(date: Date): string;
function formatDate(date: string): string;
function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toISOString();
}
```

**使用场景**: 定义函数签名时使用，确保类型安全和良好的 IDE 提示

---

#### 类别 4：泛型规范

**泛型函数**:
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

**泛型接口**:
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

**使用场景**: 定义可复用的、类型安全的函数和接口

---

#### 类别 5：any vs unknown 规范

**避免 any**:
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

**类型守卫**:
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

**使用场景**: 处理不确定类型的数据时使用，确保类型安全

---

#### 类别 6：枚举规范

**使用字面量联合类型替代枚举**:
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

**数字枚举**:
```typescript
// ✅ 推荐：数字枚举（仅当需要数值时）
enum HttpStatus {
  OK = 200,
  BadRequest = 400,
  NotFound = 404,
  InternalServerError = 500,
}
```

**使用场景**: 
- 字符串枚举: 使用字面量联合类型
- 数字枚举: 仅在需要数值映射时使用

---

#### 类别 7：类型断言规范

**避免滥用类型断言**:
```typescript
// ❌ 不推荐：过度使用类型断言
const value = data as string;

// ✅ 推荐：类型检查
if (typeof data === 'string') {
  const value = data;
}
```

**使用 const 断言**:
```typescript
// ✅ 推荐
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;

// 类型为 { readonly apiUrl: "https://api.example.com"; readonly timeout: 5000 }
```

**非空断言**:
```typescript
// ❌ 不推荐：过度使用非空断言
const element = document.getElementById('app')!;

// ✅ 推荐：空值检查
const element = document.getElementById('app');
if (element) {
  // 使用 element
}
```

**使用场景**: 需要类型转换时使用，但应谨慎使用

---

#### 类别 8：工具类型

**常用工具类型**:
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

**使用场景**: 基于现有类型创建新类型，提高代码复用性

---

### 2.3 最佳实践建议

1. **启用严格模式**: `"strict": true`
2. **避免 any**: 使用 unknown 或具体类型
3. **使用类型推断**: 简单类型无需显式声明
4. **明确函数返回类型**: 提高代码可读性
5. **使用接口**: 定义对象类型
6. **使用类型别名**: 定义联合类型、工具类型
7. **类型守卫**: 运行时类型检查
8. **文档注释**: 为复杂类型添加注释

---

## 文件三：style-rules.md

### 3.1 内容概览

**文件大小**: 408 行

**核心内容**: CSS 和样式编码的完整规范指南

**主要章节**:
1. CSS 命名规范
2. 选择器
3. CSS 变量
4. 布局
5. 响应式设计
6. Tailwind CSS
7. 样式组织
8. 性能优化
9. 可访问性
10. 最佳实践

---

### 3.2 主要规则分类

#### 类别 1：CSS 命名规范

**BEM 命名法**:
```css
/* ✅ 推荐：BEM 命名 */
.user-profile { /* Block */ }
.user-profile__avatar { /* Element */ }
.user-profile--active { /* Modifier */ }

/* ❌ 不推荐：无语义命名 */
.container { }
.item1 { }
.red { }
```

**语义化命名**:
```css
/* ✅ 推荐：语义化命名 */
.header { }
.sidebar { }
.user-list { }
.submit-button { }

/* ❌ 不推荐：表现层命名 */
.red-text { }
.big-font { }
.margin-top-20 { }
```

**使用场景**: 编写 CSS 类名时使用，确保命名语义化和可维护性

---

#### 类别 2：选择器规范

**避免深层嵌套**:
```css
/* ✅ 推荐：扁平化选择器 */
.user-card { }
.user-card-title { }
.user-card-content { }

/* ❌ 不推荐：深层嵌套 */
.user .card .header .title { }
.container .wrapper .content .item { }
```

**避免通用选择器**:
```css
/* ✅ 推荐：具体选择器 */
.user-list > li { }
.card .title { }

/* ❌ 不推荐：通用选择器 */
* { margin: 0; }
.user-list * { }
```

**使用场景**: 编写 CSS 选择器时使用，确保性能和可维护性

---

#### 类别 3：CSS 变量规范

**定义和使用变量**:
```css
/* ✅ 推荐：定义变量 */
:root {
  --primary-color: #1890ff;
  --success-color: #52c41a;
  --warning-color: #faad14;
  --error-color: #f5222d;
  --text-color: #333;
  --border-radius: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
}

.user-card {
  background-color: var(--primary-color);
  padding: var(--spacing-md);
  border-radius: var(--border-radius);
}

/* ❌ 不推荐：硬编码值 */
.user-card {
  background-color: #1890ff;
  padding: 16px;
  border-radius: 4px;
}
```

**响应式变量**:
```css
/* ✅ 推荐：响应式变量 */
:root {
  --container-width: 1200px;
}

@media (max-width: 768px) {
  :root {
    --container-width: 100%;
  }
}

.container {
  width: var(--container-width);
}
```

**使用场景**: 定义主题色、间距、圆角等可复用的样式值

---

#### 类别 4：布局规范

**Flexbox 布局**:
```css
/* ✅ 推荐：使用 Flexbox */
.container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

/* ❌ 不推荐：传统布局 */
.container {
  overflow: hidden;
}

.item {
  float: left;
  margin-right: 16px;
}
```

**Grid 布局**:
```css
/* ✅ 推荐：使用 Grid */
.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

/* ❌ 不推荐：手动计算 */
.grid-container {
  overflow: hidden;
}

.grid-item {
  width: calc(25% - 12px);
  margin-right: 16px;
  margin-bottom: 16px;
}
```

**使用场景**: 实现页面布局时使用，优先选择 Flexbox 和 Grid

---

#### 类别 5：响应式设计规范

**移动优先**:
```css
/* ✅ 推荐：移动优先 */
.container {
  width: 100%;
  padding: 16px;
}

@media (min-width: 768px) {
  .container {
    width: 750px;
  }
}

@media (min-width: 1200px) {
  .container {
    width: 1170px;
  }
}
```

**使用场景**: 实现响应式布局时使用，确保移动端体验

---

#### 类别 6：Tailwind CSS 规范

**工具类优先**:
```vue
<!-- ✅ 推荐：使用工具类 -->
<div class="flex items-center justify-between p-4 bg-white rounded-lg shadow-md">
  <span class="text-lg font-semibold text-gray-900">Title</span>
  <button class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
    Button
  </button>
</div>

<!-- ❌ 不推荐：自定义样式 -->
<div class="custom-container">
  <span class="custom-title">Title</span>
  <button class="custom-button">Button</button>
</div>

<style scoped>
.custom-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  /* ... */
}
</style>
```

**提取组件类**:
```vue
<!-- ✅ 推荐：复杂样式提取组件类 -->
<button class="btn-primary">
  Submit
</button>

<style scoped>
.btn-primary {
  @apply px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors duration-200;
}
</style>
```

**响应式前缀**:
```vue
<!-- ✅ 推荐：响应式前缀 -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <div class="p-4">Item 1</div>
  <div class="p-4">Item 2</div>
  <div class="p-4">Item 3</div>
</div>
```

**使用场景**: 使用 Tailwind CSS 开发时使用，优先使用工具类

---

#### 类别 7：样式组织规范

**按功能分组**:
```css
/* ✅ 推荐：按功能分组 */
.user-card {
  /* 布局 */
  display: flex;
  flex-direction: column;
  gap: 16px;

  /* 盒模型 */
  width: 100%;
  padding: 16px;
  border-radius: 8px;

  /* 视觉 */
  background-color: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

  /* 排版 */
  font-size: 14px;
  line-height: 1.5;
  color: #333;
}
```

**属性顺序**:
```css
/* ✅ 推荐：属性顺序 */
.element {
  /* 1. 定位 */
  position: relative;
  top: 0;
  left: 0;
  z-index: 1;

  /* 2. 盒模型 */
  display: flex;
  width: 100px;
  height: 100px;
  padding: 16px;
  margin: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;

  /* 3. 视觉 */
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  opacity: 1;

  /* 4. 排版 */
  font-size: 14px;
  line-height: 1.5;
  text-align: center;
  color: #333;

  /* 5. 动画 */
  transition: all 0.3s ease;
  animation: fadeIn 0.5s;

  /* 6. 其他 */
  cursor: pointer;
  user-select: none;
}
```

**使用场景**: 组织 CSS 代码时使用，提高可读性和可维护性

---

#### 类别 8：性能优化规范

**避免昂贵属性**:
```css
/* ❌ 不推荐：昂贵属性 */
.element {
  box-shadow: 0 0 50px rgba(0, 0, 0, 0.5);
  filter: blur(10px);
  transform: translateZ(0);
}

/* ✅ 推荐：优化性能 */
.element {
  will-change: transform;
  transform: translateZ(0);
}
```

**减少重绘**:
```css
/* ✅ 推荐：使用 transform 和 opacity */
.element {
  transition: transform 0.3s, opacity 0.3s;
}

.element:hover {
  transform: scale(1.1);
  opacity: 0.8;
}

/* ❌ 不推荐：触发重绘 */
.element {
  transition: width 0.3s, height 0.3s;
}

.element:hover {
  width: 200px;
  height: 200px;
}
```

**使用场景**: 编写动画和视觉效果时使用，确保性能

---

### 3.3 最佳实践建议

1. **命名语义化**: 使用有意义的类名
2. **避免过度嵌套**: 保持选择器扁平
3. **使用 CSS 变量**: 统一管理样式
4. **移动优先**: 响应式设计
5. **工具类优先**: 使用 Tailwind CSS
6. **性能优化**: 避免昂贵属性
7. **可访问性**: 确保颜色对比度和焦点样式
8. **代码组织**: 按功能分组，遵循属性顺序

---

## 文件四：git-rules.md

### 4.1 内容概览

**文件大小**: 430 行

**核心内容**: Git 提交和版本控制的完整规范指南

**主要章节**:
1. 提交消息格式
2. 提交示例
3. 提交规范检查
4. 分支命名规范
5. 提交最佳实践
6. Git Hooks
7. 工具配置
8. 最佳实践

---

### 4.2 主要规则分类

#### 类别 1：提交消息格式

**Conventional Commits 格式**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**类型 (type)**:
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整（不影响功能）
- `refactor`: 重构（不是新功能也不是 Bug 修复）
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具变动
- `ci`: CI 配置变动
- `build`: 构建系统或外部依赖变动
- `revert`: 回退提交

**范围 (scope)**:
- `core`: 核心功能
- `ui`: UI 相关
- `api`: API 相关
- `auth`: 认证相关
- `user`: 用户模块
- `order`: 订单模块
- `component`: 组件相关
- `style`: 样式相关
- `test`: 测试相关
- `config`: 配置相关

**主题 (subject)**:
- 简短描述，不超过 50 个字符
- 使用祈使句（如 "add" 而非 "added"）
- 首字母小写
- 结尾不加句号

**使用场景**: 编写 Git 提交消息时使用，确保提交历史清晰

---

#### 类别 2：提交示例

**新功能**:
```
feat(user): 添加用户头像上传功能

- 支持拖拽上传
- 支持裁剪功能
- 添加文件大小限制（最大 2MB）
- 支持格式：jpg、png、gif

Closes #123
```

**Bug 修复**:
```
fix(auth): 修复登录 Token 过期未刷新问题

问题：
- Token 过期后未自动刷新
- 导致用户需要重新登录

修复：
- 添加 Token 刷新逻辑
- 使用 Refresh Token 自动续期
- 刷新失败后跳转登录页

Fixes #456
```

**文档更新**:
```
docs(readme): 更新项目安装说明

- 添加 pnpm 安装方法
- 更新 Node.js 版本要求
- 添加常见问题解答
```

**代码格式化**:
```
style: 格式化代码

- 统一使用单引号
- 添加分号
- 调整缩进为 2 空格
```

**重构**:
```
refactor(user): 重构用户服务

变更：
- 提取用户服务为独立模块
- 优化代码结构
- 提高可测试性

影响：
- 无功能变更
- 提高代码可维护性
```

**性能优化**:
```
perf(list): 优化大列表渲染性能

优化：
- 使用虚拟滚动
- 实现懒加载
- 减少不必要的重渲染

效果：
- 1000 条数据渲染时间从 2s 降至 200ms
- 内存占用减少 50%
```

**测试**:
```
test(user): 添加用户服务单元测试

新增测试用例：
- 用户创建测试
- 用户更新测试
- 用户删除测试
- 异常情况测试

测试覆盖率：从 60% 提升至 85%
```

**构建配置**:
```
chore(build): 优化构建配置

优化：
- 启用代码压缩
- 配置代码分割
- 添加构建分析工具

效果：
- 构建体积减少 30%
- 构建时间缩短 20%
```

**Breaking Changes**:
```
feat(api)!: 重构 API 接口

Breaking Changes:
- 所有 API 接口路径从 /api/v1 更改为 /api/v2
- 响应格式统一调整
- 请求参数命名改为 camelCase

迁移指南：
- 更新 API 调用路径
- 调整响应处理逻辑
- 修改请求参数命名

Refs #789
```

**使用场景**: 编写各种类型的提交消息时参考

---

#### 类别 3：分支命名规范

**分支类型**:
- `main`: 主分支（生产环境）
- `develop`: 开发分支
- `feature/*`: 功能分支
- `bugfix/*`: Bug 修复分支
- `release/*`: 发布分支
- `hotfix/*`: 紧急修复分支

**命名格式**:
```
<type>/<issue-id>-<short-description>
```

**示例**:
```
feature/123-user-avatar-upload
bugfix/456-token-refresh-issue
release/v1.2.0
hotfix/789-critical-security-fix
```

**使用场景**: 创建新分支时使用，确保分支命名规范

---

#### 类别 4：提交最佳实践

**原子提交**:
```
✅ 推荐：一个提交解决一个问题
git commit -m "feat(user): 添加用户头像上传功能"
git commit -m "test(user): 添加头像上传测试用例"

❌ 不推荐：一个提交解决多个问题
git commit -m "feat(user): 添加头像上传功能，修复登录 Bug，更新文档"
```

**提交粒度**:
- **太小**: 一个提交只改了一行注释
- **合适**: 一个提交完成一个完整功能
- **太大**: 一个提交包含多个功能

**提交时机**:
```bash
# ✅ 推荐：功能完成并测试通过后提交
pnpm test:unit  # 运行测试
pnpm lint       # 代码检查
git add .
git commit -m "feat(user): 添加用户头像上传功能"

# ❌ 不推荐：未测试直接提交
git add .
git commit -m "feat(user): 添加用户头像上传功能"
```

**避免提交的内容**:
```
# .gitignore

# 依赖
node_modules/
dist/

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# 日志
*.log
npm-debug.log*

# 环境变量
.env
.env.local
.env.*.local

# 缓存
.cache/
*.tsbuildinfo

# 测试
coverage/
.nyc_output/
```

**使用场景**: 进行 Git 操作时使用，确保提交规范

---

#### 类别 5：Git Hooks

**pre-commit**:
```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# 运行 lint
pnpm lint

# 运行测试
pnpm test:unit
```

**commit-msg**:
```bash
#!/bin/sh

# 验证提交消息格式
commit_msg=$(cat "$1")
pattern="^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\(.+\))?: .{1,50}"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
  echo "Invalid commit message format!"
  echo "Format: <type>(<scope>): <subject>"
  echo "Example: feat(user): add user avatar upload"
  exit 1
fi
```

**使用场景**: 自动化 Git 提交检查

---

#### 类别 6：工具配置

**Commitlint**:
```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', 'ci', 'build', 'revert'],
    ],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-max-length': [2, 'always', 50],
  },
};
```

**Lefthook**:
```yaml
# lefthook.yml
pre-commit:
  commands:
    lint:
      run: pnpm lint
    test:
      run: pnpm test:unit

commit-msg:
  commands:
    commitlint:
      run: pnpm commitlint --edit {1}
```

**使用场景**: 配置自动化工具，强制执行提交规范

---

### 4.3 最佳实践建议

1. **遵循 Conventional Commits**: 统一提交格式
2. **原子提交**: 一个提交解决一个问题
3. **清晰描述**: 说明做了什么、为什么做
4. **关联 Issue**: 关闭或引用相关 Issue
5. **提交前检查**: 运行 lint 和测试
6. **避免提交无关文件**: 使用 .gitignore
7. **定期推送**: 避免本地积累过多提交
8. **及时同步**: 经常 pull 远程更新

---

## 各个 rules 文件之间的关系

### 关系图谱

```
┌─────────────────────────────────────────────────────────┐
│                    CLAUDE.md                             │
│            （项目核心指令文件）                             │
│           提供项目概述和开发指导                            │
└─────────────────────┬───────────────────────────────────┘
                      │
                      │ 提供概览
                      │
        ┌─────────────┼─────────────────────────────────────┐
        │             │                                      │
        ▼             ▼                                      ▼
┌───────────────┐  ┌──────────────┐                  ┌──────────────┐
│ vue-rules.md  │  │typescript-   │                  │style-rules.md│
│               │  │rules.md      │                  │              │
│ Vue 3 组件开发│  │TypeScript    │◄─────────────────┤CSS 样式编码  │
│               │  │编码规范      │                  │              │
└───────┬───────┘  └──────┬───────┘                  └──────┬───────┘
        │                 │                                  │
        │                 │                                  │
        │                 │                                  │
        │    Vue 组件使用  │                                  │
        │    TypeScript   │                                  │
        │                 │                                  │
        │                 │                                  │
        └─────────────────┼──────────────────────────────────┘
                          │
                          ▼
                   ┌──────────────┐
                   │ git-rules.md │
                   │              │
                   │ Git 提交规范 │
                   │              │
                   └──────────────┘
```

---

### 协作关系详解

#### 1. vue-rules.md 与 typescript-rules.md 的协作

**协作场景**: Vue 组件开发

**协作方式**:
- vue-rules.md 规定组件结构和 Props 定义
- typescript-rules.md 规定类型定义方式

**代码示例**:
```vue
<!-- Vue 组件 + TypeScript 类型定义 -->
<script setup lang="ts">
// TypeScript 规范：使用 interface 定义 Props
interface Props {
  userName: string;  // camelCase 命名（Vue 规范）
  isActive: boolean;
}

// Vue 规范：使用 defineProps
const props = defineProps<Props>();

// TypeScript 规范：使用 interface 定义 Emits
interface Emits {
  (e: 'update:modelValue', value: string): void;  // kebab-case 命名（Vue 规范）
}

// Vue 规范：使用 defineEmits
const emit = defineEmits<Emits>();
</script>
```

---

#### 2. vue-rules.md 与 style-rules.md 的协作

**协作场景**: Vue 组件样式开发

**协作方式**:
- vue-rules.md 规定组件样式使用 scoped
- style-rules.md 规定 CSS 命名和写法

**代码示例**:
```vue
<!-- Vue 组件样式 -->
<template>
  <div class="user-card">  <!-- BEM 命名（style-rules） -->
    <div class="user-card__avatar">  <!-- Element 命名 -->
      <img src="avatar.jpg" />
    </div>
    <div class="user-card__content">
      <h3 class="user-card__title">User Name</h3>
    </div>
  </div>
</template>

<style scoped>  /* scoped 样式（vue-rules） */
.user-card {  /* BEM Block（style-rules） */
  /* 按功能分组（style-rules） */
  display: flex;
  gap: var(--spacing-md);  /* CSS 变量（style-rules） */
  padding: var(--spacing-md);
  border-radius: var(--border-radius);
  background-color: var(--primary-color);
}

.user-card__avatar {  /* BEM Element（style-rules） */
  width: 60px;
  height: 60px;
  border-radius: 50%;
}

.user-card__title {  /* BEM Element（style-rules） */
  font-size: 16px;
  color: var(--text-color);
}
</style>
```

---

#### 3. typescript-rules.md 与 style-rules.md 的协作

**协作场景**: TypeScript + Tailwind CSS 开发

**协作方式**:
- typescript-rules.md 规定类型定义
- style-rules.md 规定 Tailwind CSS 使用

**代码示例**:
```vue
<script setup lang="ts">
// TypeScript 规范：定义 Props 类型
interface Props {
  variant: 'primary' | 'secondary' | 'danger';  // 联合类型
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  disabled: false,
});

// TypeScript 规范：使用类型推断
const buttonClasses = computed(() => {
  const baseClasses = 'px-4 py-2 rounded font-medium transition-colors';
  
  // 根据类型返回不同的 Tailwind 类
  const variantClasses = {
    primary: 'bg-blue-500 text-white hover:bg-blue-600',
    secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300',
    danger: 'bg-red-500 text-white hover:bg-red-600',
  };
  
  return `${baseClasses} ${variantClasses[props.variant]}`;
});
</script>

<template>
  <!-- style-rules：使用 Tailwind 工具类 -->
  <button :class="buttonClasses" :disabled="disabled">
    <slot />
  </button>
</template>
```

---

#### 4. 所有 rules 与 git-rules.md 的协作

**协作场景**: 提交代码

**协作方式**:
- vue-rules.md、typescript-rules.md、style-rules.md 确保代码质量
- git-rules.md 确保提交消息规范

**完整示例**:
```bash
# 1. 开发 Vue 组件（遵循 vue-rules.md）
# 2. 编写 TypeScript 代码（遵循 typescript-rules.md）
# 3. 添加样式（遵循 style-rules.md）
# 4. 提交代码（遵循 git-rules.md）

# 提交前检查
pnpm lint        # 代码检查
pnpm test:unit   # 运行测试

# 提交代码
git add .
git commit -m "feat(user): 添加用户卡片组件

- 使用 TypeScript 定义 Props 和 Emits
- 使用 scoped 样式避免污染
- 使用 BEM 命名规范
- 支持响应式设计

Closes #123"
```

---

### 层次化配置

```
Level 1: CLAUDE.md
         ├─ 项目概述
         ├─ 技术栈
         ├─ 目录结构
         └─ 开发流程

Level 2: vue-rules.md
         ├─ 组件定义
         ├─ Props/Emits
         ├─ 响应式数据
         └─ 模板规范

Level 3: typescript-rules.md
         ├─ 类型定义
         ├─ 接口/类型
         ├─ 泛型
         └─ 工具类型

Level 4: style-rules.md
         ├─ CSS 命名
         ├─ CSS 变量
         ├─ 布局
         └─ Tailwind CSS

Level 5: git-rules.md
         ├─ 提交格式
         ├─ 分支命名
         ├─ Git Hooks
         └─ 工具配置
```

---

## 使用场景总结

### 场景 1：新建 Vue 组件

**使用顺序**:
1. 参考 **vue-rules.md** 确定组件结构
2. 参考 **typescript-rules.md** 定义类型
3. 参考 **style-rules.md** 编写样式
4. 参考 **git-rules.md** 提交代码

---

### 场景 2：开发 API 接口

**使用顺序**:
1. 参考 **typescript-rules.md** 定义接口类型
2. 参考 **vue-rules.md** 使用响应式数据
3. 参考 **git-rules.md** 提交代码

---

### 场景 3：重构代码

**使用顺序**:
1. 参考 **typescript-rules.md** 优化类型定义
2. 参考 **vue-rules.md** 优化组件结构
3. 参考 **style-rules.md** 优化样式
4. 参考 **git-rules.md** 提交重构

---

### 场景 4：性能优化

**使用顺序**:
1. 参考 **vue-rules.md** 优化响应式数据
2. 参考 **style-rules.md** 优化样式性能
3. 参考 **git-rules.md** 提交优化

---

### 场景 5：团队协作

**使用顺序**:
1. 所有成员遵循相同的 **rules** 文件
2. 使用 **git-rules.md** 统一提交规范
3. 代码审查时参考 **rules** 检查代码

---

## 最佳实践建议

### 1. 理解规则的优先级

**优先级排序**:
1. **类型安全** > 代码简洁（TypeScript 规则）
2. **性能优化** > 功能实现（性能相关规则）
3. **可读性** > 简洁性（命名和格式规则）
4. **一致性** > 个人偏好（团队协作规则）

---

### 2. 根据场景选择规则

**开发新功能**:
- 优先参考 vue-rules.md 和 typescript-rules.md
- 确保组件结构正确、类型安全

**优化现有代码**:
- 参考 style-rules.md 和性能优化相关规则
- 确保性能和可维护性

**团队协作**:
- 严格执行所有 rules
- 特别是 git-rules.md 的提交规范

---

### 3. 避免 over-engineering

**不要过度应用规则**:
- 简单组件不需要复杂的 TypeScript 泛型
- 简单样式不需要复杂的 CSS 变量
- 小提交不需要复杂的提交消息

**平衡简洁性和规范性**:
- 在保证代码质量的前提下，保持代码简洁
- 不要为了遵循规则而增加不必要的复杂度

---

### 4. 持续学习和优化

**定期审查规则**:
- 随着项目发展，规则可能需要调整
- 收集团队反馈，优化规则内容

**更新规则文件**:
- 发现新的最佳实践时，及时更新
- 删除过时的规则
- 添加新的规则

---

### 5. 工具辅助

**配置自动化工具**:
- ESLint：自动检查代码规范
- Stylelint：自动检查样式规范
- Commitlint：自动检查提交消息
- Lefthook：自动运行 Git Hooks

**IDE 集成**:
- 配置 VS Code 插件
- 启用自动格式化
- 配置代码提示

---

## 总结

### 规则文件的价值

1. **vue-rules.md**: 确保 Vue 组件开发规范，提高组件质量和可维护性
2. **typescript-rules.md**: 确保 TypeScript 类型安全，减少运行时错误
3. **style-rules.md**: 确保样式代码质量，提高性能和可维护性
4. **git-rules.md**: 确保提交历史清晰，便于团队协作和版本管理

### 核心作用

**对于 AI 助手**:
- 提供详细的编码规范
- 确保生成符合项目标准的代码
- 避免常见的编码错误

**对于团队成员**:
- 统一编码风格
- 提高代码质量
- 降低学习曲线

**对于项目维护**:
- 减少 technical debt
- 提高代码可维护性
- 便于团队协作

### 建议

1. **深入学习**: 每个开发者都应仔细阅读所有 rules 文件
2. **严格执行**: 开发过程中严格遵守所有规则
3. **持续优化**: 根据项目实际情况优化规则内容
4. **团队协作**: 让所有成员参与规则的制定和维护

---

*文档生成时间: 2025-08-25*
*分析文件: 4 个*
*总行数: 1638 行*
*文件版本: v1.0*
