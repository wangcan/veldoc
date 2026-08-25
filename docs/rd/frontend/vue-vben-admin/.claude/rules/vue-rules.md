# Vue 3 编码规范

## 组件定义

### 使用 `<script setup>`

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
    return {
      count: 0,
    };
  },
};
</script>
```

## 命名规范

### 组件命名

```typescript
// ✅ 推荐：PascalCase
UserProfile.vue
UserList.vue
BaseButton.vue

// ❌ 不推荐：camelCase
userProfile.vue
userList.vue
```

### Props 命名

```typescript
// ✅ 推荐：camelCase
interface Props {
  userName: string;
  isActive: boolean;
}

// ❌ 不推荐：kebab-case
interface Props {
  'user-name': string;
  'is-active': boolean;
}
```

### 事件命名

```typescript
// ✅ 推荐：kebab-case
emit('update:model-value', value);
emit('user-selected', user);

// ❌ 不推荐：camelCase
emit('updateModelValue', value);
emit('userSelected', user);
```

## Props 定义

### 类型定义

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

### 默认值

```typescript
// ✅ 推荐：使用 withDefaults
interface Props {
  title: string;
  count?: number;
  users?: User[];
}

const props = withDefaults(defineProps<Props>(), {
  count: 0,
  users: () => [],
});

// ❌ 不推荐：运行时 default
const props = defineProps({
  count: { type: Number, default: 0 },
});
```

### 必填验证

```typescript
// ✅ 推荐
interface Props {
  title: string; // 必填
  count?: number; // 可选
}

// ❌ 不推荐：运行时 required
const props = defineProps({
  title: { type: String, required: true },
});
```

## Emits 定义

### 类型定义

```typescript
// ✅ 推荐：使用类型定义
interface Emits {
  (e: 'update:modelValue', value: string): void;
  (e: 'change', newValue: string, oldValue: string): void;
}

const emit = defineEmits<Emits>();

// ❌ 不推荐：字符串数组
const emit = defineEmits(['update:modelValue', 'change']);
```

### 事件触发

```typescript
// ✅ 推荐
emit('update:modelValue', newValue);

// ❌ 不推荐：直接传递对象
emit('update', { value: newValue, timestamp: Date.now() });
```

## 响应式数据

### ref vs reactive

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

// ❌ 不推荐：对象使用 ref（除非需要替换整个对象）
const state = ref({
  users: [],
});
```

### 解构响应式对象

```typescript
// ✅ 推荐：使用 toRefs
const { users, loading } = toRefs(state);

// ✅ 推荐：使用 toRef
const loading = toRef(state, 'loading');

// ❌ 不推荐：直接解构（会失去响应性）
const { users, loading } = state;
```

## 计算属性

### 使用 computed

```typescript
// ✅ 推荐
const fullName = computed(() => `${firstName.value} ${lastName.value}`);

// ✅ 推荐：可写的计算属性
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: (value: string) => {
    [firstName.value, lastName.value] = value.split(' ');
  },
});

// ❌ 不推荐：使用方法
function getFullName() {
  return `${firstName.value} ${lastName.value}`;
}
```

## 生命周期

### 顺序

```typescript
// ✅ 推荐顺序
onBeforeMount(() => {});
onMounted(() => {});
onBeforeUpdate(() => {});
onUpdated(() => {});
onBeforeUnmount(() => {});
onUnmounted(() => {});
```

### 清理副作用

```typescript
// ✅ 推荐：使用 watchEffect 自动清理
watchEffect((onCleanup) => {
  const timer = setInterval(() => {}, 1000);
  onCleanup(() => clearInterval(timer));
});

// ❌ 不推荐：手动管理
const timer = setInterval(() => {}, 1000);
onUnmounted(() => clearInterval(timer));
```

## 模板规范

### 指令缩写

```vue
<!-- ✅ 推荐：统一使用缩写 -->
<div v-if="show">Content</div>
<button @click="handleClick">Click</button>
<input v-model="value" />

<!-- ❌ 不推荐：混用 -->
<div v-if="show">Content</div>
<button v-on:click="handleClick">Click</button>
```

### v-for 与 key

```vue
<!-- ✅ 推荐 -->
<div v-for="item in items" :key="item.id">
  {{ item.name }}
</div>

<!-- ❌ 不推荐：使用索引作为 key -->
<div v-for="(item, index) in items" :key="index">
  {{ item.name }}
</div>
```

### v-if 与 v-for

```vue
<!-- ✅ 推荐：使用计算属性过滤 -->
<div v-for="item in activeItems" :key="item.id">
  {{ item.name }}
</div>

<script setup>
const activeItems = computed(() => items.value.filter(item => item.active));
</script>

<!-- ❌ 不推荐：同时使用 v-if 和 v-for -->
<div v-for="item in items" v-if="item.active" :key="item.id">
  {{ item.name }}
</div>
```

### 多属性元素

```vue
<!-- ✅ 推荐：多行，每个属性一行 -->
<input
  id="name"
  v-model="name"
  type="text"
  placeholder="Enter name"
  @input="handleInput"
/>

<!-- ❌ 不推荐：单行 -->
<input id="name" v-model="name" type="text" placeholder="Enter name" @input="handleInput">
```

## 样式规范

### Scoped 样式

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

### 深度选择器

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

## 组件导入

### 自动导入

```typescript
// ✅ 推荐：自动导入（需配置）
const count = ref(0);
const state = reactive({});

// ❌ 不推荐：手动导入（除非必需）
import { ref, reactive } from 'vue';
const count = ref(0);
```

### 组件注册

```vue
<!-- ✅ 推荐：自动注册 -->
<template>
  <UserProfile />
</template>

<script setup>
// 无需导入，自动注册
</script>

<!-- ❌ 不推荐：手动注册 -->
<script>
import UserProfile from './UserProfile.vue';
export default {
  components: { UserProfile },
};
</script>
```

## 最佳实践

1. **组件职责单一**: 每个组件只做一件事
2. **Props 向下，Events 向上**: 数据单向流动
3. **合理使用 v-show/v-if**: 频繁切换用 v-show
4. **避免在模板中使用复杂表达式**: 使用计算属性
5. **及时清理副作用**: 使用 watchEffect 的清理函数
6. **类型安全**: 使用 TypeScript 类型定义
7. **文档完善**: 为复杂组件添加注释
