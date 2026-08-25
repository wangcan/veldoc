---
name: create-component
description: 快速创建 Vue 3 组件，包含模板、脚本、样式和测试文件
triggers:
  - "创建组件"
  - "新建组件"
  - "add component"
---

# 快速创建 Vue 组件

这个技能帮助你快速创建标准化的 Vue 3 组件，包含所有必要的文件。

## 使用方法

```
/create-component <组件名称> [选项]
```

### 参数

- `组件名称`: 组件的名称（PascalCase）
- `选项`:
  - `--type=base`: 创建基础组件
  - `--type=business`: 创建业务组件
  - `--type=page`: 创建页面组件
  - `--ui=antd`: 使用 Ant Design Vue
  - `--ui=naive`: 使用 Naive UI
  - `--ui=ele`: 使用 Element Plus
  - `--ui=tdesign`: 使用 TDesign

### 示例

```bash
# 创建基础按钮组件
/create-component BaseButton --type=base

# 创建业务组件
/create-component UserForm --type=business --ui=antd

# 创建页面组件
/create-component UserList --type=page
```

## 生成的文件

### 组件文件 (ComponentName.vue)

```vue
<template>
  <div class="component-name">
    <!-- 组件内容 -->
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

interface Props {
  // Props 定义
}

const props = defineProps<Props>();

// 组件逻辑
</script>

<style scoped>
.component-name {
  /* 样式 */
}
</style>
```

### 类型文件 (types.ts)

```typescript
export interface ComponentNameProps {
  // Props 类型定义
}

export interface ComponentNameEmits {
  // Emits 类型定义
}
```

### 测试文件 (ComponentName.test.ts)

```typescript
import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import ComponentName from './ComponentName.vue';

describe('ComponentName', () => {
  it('should render correctly', () => {
    const wrapper = mount(ComponentName);
    expect(wrapper.exists()).toBe(true);
  });
});
```

### 文档文件 (README.md)

```markdown
# ComponentName 组件

## 用法

\`\`\`vue
<template>
  <ComponentName />
</template>
\`\`\`

## Props

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| - | - | - | - |

## Events

| 事件 | 参数 | 说明 |
|------|------|------|
| - | - | - |

## Slots

| 插槽 | 说明 |
|------|------|
| default | 默认插槽 |
```

## 组件类型

### 基础组件 (Base)

- 纯展示组件
- 高度可复用
- 无业务逻辑
- Props 驱动

### 业务组件 (Business)

- 包含业务逻辑
- 可能有 API 调用
- 可能有状态管理
- 特定场景使用

### 页面组件 (Page)

- 路由级别组件
- 完整页面布局
- 包含多个子组件
- 可能有权限控制

## 最佳实践

1. **命名清晰**: 组件名应准确描述其功能
2. **单一职责**: 每个组件只做一件事
3. **Props 验证**: 为所有 Props 添加类型和验证
4. **事件命名**: 使用 kebab-case 命名事件
5. **文档完善**: 为组件添加使用文档
