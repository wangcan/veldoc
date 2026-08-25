# /component - 快速创建 Vue 组件

## 描述

快速创建标准化的 Vue 3 组件，包含所有必要文件。

## 用法

```
/component <组件名称> [选项]
```

## 参数

### 组件名称
- 格式：PascalCase（如 `UserProfile`）
- 必须：是

### 选项

- `--type=<类型>`: 组件类型
  - `base`: 基础组件
  - `business`: 业务组件
  - `page`: 页面组件
  - 默认：`business`

- `--ui=<框架>`: UI 框架
  - `antd`: Ant Design Vue
  - `naive`: Naive UI
  - `ele`: Element Plus
  - `tdesign`: TDesign
  - 默认：`antd`

- `--path=<路径>`: 自定义路径
  - 默认：`src/components/`

- `--test`: 生成测试文件
  - 默认：`true`

- `--no-test`: 不生成测试文件

## 示例

### 创建基础组件

```bash
/component BaseButton --type=base
```

生成文件：
- `src/components/BaseButton.vue`
- `src/components/BaseButton.test.ts`
- `src/components/README.md`

### 创建业务组件

```bash
/component UserForm --type=business --ui=antd
```

生成文件：
- `src/components/UserForm.vue`
- `src/components/UserForm.test.ts`
- `src/components/README.md`

### 创建页面组件

```bash
/component UserList --type=page
```

生成文件：
- `src/views/user-list/index.vue`
- `src/views/user-list/UserList.test.ts`

### 自定义路径

```bash
/component UserCard --path=src/components/user
```

生成文件：
- `src/components/user/UserCard.vue`
- `src/components/user/UserCard.test.ts`

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
# ComponentName

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
```

## 组件类型

### Base（基础组件）

特点：
- 纯展示组件
- 高度可复用
- 无业务逻辑
- Props 驱动

示例：
- BaseButton
- BaseInput
- BaseModal
- BaseTable

### Business（业务组件）

特点：
- 包含业务逻辑
- 可能有 API 调用
- 可能有状态管理
- 特定场景使用

示例：
- UserForm
- UserList
- OrderCard
- ProductFilter

### Page（页面组件）

特点：
- 路由级别组件
- 完整页面布局
- 包含多个子组件
- 可能有权限控制

示例：
- UserList
- UserDetail
- Dashboard
- Settings

## 工作流程

1. **解析参数**: 获取组件名称和选项
2. **确定路径**: 根据类型确定生成路径
3. **生成文件**: 创建组件、测试、文档文件
4. **更新索引**: 如需要，更新导出文件

## 注意事项

1. 组件名称必须是 PascalCase
2. 路径必须是相对于项目根目录
3. 如果文件已存在，会询问是否覆盖
4. 生成的代码遵循项目编码规范

## 相关命令

- `/page`: 创建页面组件
- `/api`: 创建 API 接口
- `/test`: 创建测试用例
- `/route`: 添加路由配置
