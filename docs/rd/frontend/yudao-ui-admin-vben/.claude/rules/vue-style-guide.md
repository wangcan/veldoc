# Vue 组件编写规范

本文档定义了项目中 Vue 组件的编写规范和最佳实践。

## 组件命名

### 文件命名

- **使用 kebab-case**: 组件文件名使用小写字母和连字符
- **多个单词**: 组件名应该是多个单词，避免与 HTML 元素冲突
- **语义化**: 文件名应清楚表达组件的用途

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

### 组件注册

- **使用 PascalCase**: 在模板和 JSX 中使用 PascalCase

```vue
<script setup lang="ts">
import UserList from './user-list.vue';
</script>

<template>
  <UserList />
</template>
```

## Props 定义

### 类型定义

- **必须定义类型**: 所有 Props 必须定义类型
- **使用 TypeScript interface**: 使用 interface 定义 Props 类型
- **避免 any**: 不要使用 any 类型

```typescript
// ✅ 推荐
interface Props {
  title: string;
  data?: UserInfo[];
  loading?: boolean;
  count: number;
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

### 默认值

- **使用 withDefaults**: 为可选 props 提供默认值
- **对象/数组**: 对象和数组的默认值必须使用工厂函数

```typescript
// ✅ 推荐
const props = withDefaults(defineProps<Props>(), {
  data: () => [],
  config: () => ({ theme: 'light' }),
});

// ❌ 不推荐
const props = defineProps<Props>();
```

### Props 验证

- **必需的 props**: 不要标记为可选，让 TypeScript 检查
- **自定义验证**: 使用 validator 进行复杂验证

```typescript
interface Props {
  status: 'active' | 'inactive';
  age: number;
}

const props = defineProps<Props>();

// 或使用运行时验证
const props = defineProps({
  status: {
    type: String as PropType<'active' | 'inactive'>,
    required: true,
    validator: (value: string) => ['active', 'inactive'].includes(value),
  },
});
```

## Events 定义

### 类型定义

- **使用 TypeScript**: 为所有事件定义类型
- **明确参数类型**: 明确事件的参数类型

```typescript
// ✅ 推荐
interface Emits {
  (e: 'update', value: string): void;
  (e: 'submit', data: FormData): void;
  (e: 'delete', id: number): void;
}

const emit = defineEmits<Emits>();

// ❌ 不推荐
const emit = defineEmits(['update', 'submit', 'delete']);
```

### 事件命名

- **使用 kebab-case**: 事件名使用小写字母和连字符
- **动词开头**: 以动词开头，表达动作意图

```typescript
// ✅ 推荐
emit('update-user', user);
emit('delete-item', id);
emit('submit-form', data);

// ❌ 不推荐
emit('updateUser', user);
emit('deleteItem', id);
emit('submit', data);
```

## 插槽使用

### 插槽命名

- **使用 kebab-case**: 插槽名使用小写字母和连字符
- **语义化命名**: 插槽名应清楚表达用途

```vue
<!-- ✅ 推荐 -->
<template #header-content>
  <h1>标题</h1>
</template>

<template #item-actions="{ item }">
  <button @click="handleEdit(item)">编辑</button>
</template>

<!-- ❌ 不推荐 -->
<template #headerContent>
  <h1>标题</h1>
</template>
```

### 默认插槽

- **提供默认内容**: 为插槽提供合理的默认内容
- **作用域插槽**: 传递必要的数据

```vue
<!-- ✅ 推荐 -->
<slot name="header">
  <h3>默认标题</h3>
</slot>

<slot name="item" :data="item" :index="index">
  {{ item.name }}
</slot>
```

## 组件结构

### 文件顺序

按照以下顺序组织代码：

1. **script setup** - 逻辑代码
2. **template** - 模板代码
3. **style** - 样式代码

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

### 代码组织

- **组合式函数**: 将相关逻辑封装成 `useXxx` 函数
- **功能分组**: 按功能分组代码，添加注释分隔

```typescript
<script setup lang="ts">
// ========== 状态管理 ==========
const state = reactive({
  loading: false,
  data: [],
});

// ========== 表单处理 ==========
function handleSubmit() { /* ... */ }

// ========== API 调用 ==========
async function fetchData() { /* ... */ }
</script>
```

## Composition API

### ref vs reactive

- **简单值**: 使用 `ref`
- **对象**: 使用 `reactive`
- **保持一致性**: 在一个模块中保持一致

```typescript
// ✅ 推荐 - 简单值用 ref
const count = ref(0);
const name = ref('Vue');

// ✅ 推荐 - 复杂对象用 reactive
const form = reactive({
  username: '',
  email: '',
  age: 0,
});
```

### computed

- **只读计算属性**: 使用 getter 函数
- **可写计算属性**: 提供 getter 和 setter

```typescript
// ✅ 推荐 - 只读
const doubleCount = computed(() => count.value * 2);

// ✅ 推荐 - 可写
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: (value) => {
    [firstName.value, lastName.value] = value.split(' ');
  },
});
```

### watch

- **明确依赖**: 明确指定要监听的源
- **避免深度监听**: 避免不必要的 deep: true

```typescript
// ✅ 推荐
watch(count, (newValue, oldValue) => {
  console.log(`count changed from ${oldValue} to ${newValue}`);
});

// ✅ 推荐 - 监听多个源
watch([firstName, lastName], ([newFirst, newLast]) => {
  console.log(`Full name: ${newFirst} ${newLast}`);
});

// ❌ 不推荐 - 不必要的深度监听
watch(obj, () => {}, { deep: true });
```

## 模板规范

### 指令使用

- **v-if vs v-show**: 频繁切换用 v-show，条件渲染用 v-if
- **v-for**: 必须提供 key，避免与 v-if 同时使用

```vue
<!-- ✅ 推荐 -->
<div v-if="isLoggedIn">欢迎</div>
<div v-show="isExpanded">内容</div>

<ul>
  <li v-for="item in items" :key="item.id">
    {{ item.name }}
  </li>
</ul>

<!-- ❌ 不推荐 -->
<ul>
  <li v-for="item in items" :key="item.id" v-if="item.visible">
    {{ item.name }}
  </li>
</ul>
```

### 属性顺序

按照以下顺序组织属性：

1. `is` / `v-for`
2. `v-if` / `v-else-if` / `v-else` / `v-show` / `v-cloak`
3. `id` / `ref` / `key`
4. `v-model`
5. `v-on` (简写为 `@`)
6. `v-bind` (简写为 `:`)
7. `v-text` / `v-html`
8. 其他属性

```vue
<!-- ✅ 推荐 -->
<div
  v-if="show"
  :id="elementId"
  ref="container"
  v-model="value"
  @click="handleClick"
  :class="{ active: isActive }"
  :style="{ color: textColor }"
>
  内容
</div>
```

## 样式规范

### Scoped 样式

- **使用 scoped**: 为组件样式添加 scoped 属性
- **避免深度选择器**: 尽量避免使用 `>>>` 或 `/deep/`

```vue
<style scoped>
.user-list {
  /* 样式 */
}
</style>
```

### Tailwind CSS

- **优先使用 Tailwind**: 优先使用 Tailwind CSS 工具类
- **自定义样式**: 仅在 Tailwind 无法满足时添加自定义样式

```vue
<template>
  <!-- ✅ 推荐 - 使用 Tailwind -->
  <div class="flex items-center justify-between p-4 bg-white rounded-lg shadow">
    <span class="text-lg font-semibold text-gray-900">{{ title }}</span>
    <button class="px-4 py-2 text-white bg-blue-500 rounded hover:bg-blue-600">
      操作
    </button>
  </div>

  <!-- ❌ 不推荐 - 不必要的自定义样式 -->
  <div class="custom-container">
    <span class="custom-title">{{ title }}</span>
    <button class="custom-button">操作</button>
  </div>
</template>
```

## 最佳实践

### 单一职责

- **一个组件一个职责**: 每个组件只负责一件事
- **拆分复杂组件**: 将复杂组件拆分为多个子组件

### 性能优化

- **懒加载**: 使用 `defineAsyncComponent` 懒加载大型组件
- **虚拟滚动**: 大列表使用虚拟滚动
- **防抖节流**: 为频繁触发的事件添加防抖或节流

### 可访问性

- **语义化 HTML**: 使用语义化的 HTML 标签
- **ARIA 属性**: 为交互元素添加 ARIA 属性
- **键盘导航**: 支持键盘导航

### 测试

- **单元测试**: 为核心逻辑编写单元测试
- **集成测试**: 为组件交互编写集成测试

---

遵循这些规范，可以确保 Vue 组件代码的一致性、可维护性和可读性。
