# Agents 目录分析报告

## 目录概述

`.claude/agents/` 目录包含项目的自定义子代理（Subagents）。这些子代理是专门化的 AI 助手，用于处理特定类型的开发任务。每个代理都有明确的职责、工作流程和输出规范。

## 目录结构

```
.claude/agents/
├── api-module-creator.md       # API 模块创建代理
├── page-builder.md             # 页面构建代理
├── store-generator.md          # Store 生成代理
└── vue-component-generator.md  # Vue 组件生成代理
```

## Agent 通用结构

每个 Agent 文件都遵循统一的结构：

### 1. Frontmatter 元数据

```yaml
---
name: agent-name
description: Agent 描述
model: claude-sonnet-5
tools: Read, Edit, Write, Bash
---
```

**字段说明**:
- `name`: 代理的唯一标识符
- `description`: 代理的功能描述
- `model`: 使用的 Claude 模型
- `tools`: 代理可以使用的工具列表

### 2. 正文内容

- **核心能力**: 代理的主要功能
- **工作流程**: 详细的操作步骤
- **示例**: 使用示例和模板
- **注意事项**: 重要提醒和限制

## Agent 详细分析

### 1. API Module Creator (api-module-creator.md)

#### 基本信息

- **名称**: api-module-creator
- **描述**: 创建符合项目规范的 API 接口模块
- **模型**: claude-sonnet-5
- **工具**: Read, Edit, Write, Bash

#### 核心能力

1. **API 接口生成**: 根据接口文档或描述生成 API 调用代码
2. **类型定义**: 自动生成 TypeScript 类型定义
3. **错误处理**: 集成统一的错误处理机制
4. **请求拦截**: 支持请求/响应拦截器

#### 工作流程

##### 需求分析阶段

首先确认以下信息：
- 模块名称（如 user、order、product）
- 接口列表（URL、方法、参数、返回值）
- 是否需要分页支持
- 是否需要租户隔离
- 特殊的请求配置（超时、重试等）

##### 目录结构

```
src/api/module-name/
├── index.ts          # API 接口定义
└── model.ts          # 类型定义（可选）
```

##### 命名规范

- **Namespace**: PascalCase + Api 后缀（如 `UserApi`）
- **Interface**: PascalCase（如 `UserInfo`、`PageParams`）
- **Function**: camelCase，动词开头（如 `getUserPage`、`createUser`）
- **URL**: kebab-case（如 `/system/user/page`）

#### 代码模板

提供完整的 API 模块模板，包括：

1. **类型定义模板**
```typescript
export namespace UserApi {
  export interface UserInfo {
    id: number;
    username: string;
    // ...
  }
  
  export interface PageParams {
    pageNo: number;
    pageSize: number;
  }
}
```

2. **API 函数模板**
```typescript
export function getUserPage(params: UserApi.PageParams) {
  return requestClient.get<UserApi.PageResult>('/system/user/page', { params });
}
```

#### 常见模式

支持多种常见 API 模式：
- 分页查询
- CRUD 操作
- 批量操作
- 导入导出
- 租户隔离
- 请求超时
- 重试机制

#### 输出格式

生成 API 模块时提供：
1. 文件路径
2. 完整代码
3. 使用示例
4. 注意事项

#### 特点

- **规范性强**: 严格遵循项目的 API 规范
- **类型安全**: 自动生成完整的 TypeScript 类型
- **功能全面**: 覆盖常见的 API 使用场景
- **文档完善**: 提供详细的示例和说明

---

### 2. Page Builder (page-builder.md)

#### 基本信息

- **名称**: page-builder
- **描述**: 构建完整的业务页面（列表、表单、详情等）
- **模型**: claude-sonnet-5
- **工具**: Read, Edit, Write, Bash

#### 核心能力

1. **完整页面构建**: 根据业务需求生成完整页面
2. **CRUD 功能**: 包含增删改查完整功能
3. **权限集成**: 自动集成权限控制
4. **国际化支持**: 支持多语言

#### 工作流程

##### 需求分析阶段

确认以下信息：
- 页面类型（列表、表单、详情、混合）
- 业务实体和字段
- 功能需求（CRUD、导入导出、批量操作等）
- 权限配置
- 使用哪个 UI 框架版本

##### 页面结构

```
views/module-name/
├── index.vue              # 列表页（主页面）
├── data.ts               # 列表配置、表单配置
├── components/           # 业务组件（可选）
└── modules/              # 弹窗/抽屉组件
    ├── form.vue          # 表单弹窗
    └── detail.vue        # 详情弹窗
```

#### 代码模板

提供完整的页面模板：

1. **列表页面模板** (index.vue)
   - 数据表格（支持分页、排序、筛选）
   - 搜索表单
   - 操作按钮（新增、编辑、删除、批量删除）
   - 导出功能
   - 权限控制

2. **数据配置模板** (data.ts)
   - 列表列配置
   - 搜索表单配置
   - 表单字段配置

3. **表单弹窗模板** (modules/form.vue)
   - 表单字段
   - 字段验证
   - 提交逻辑
   - 取消逻辑

#### 功能特性

##### 权限控制

```vue
<ElButton v-access="'system:xxx:create'" type="primary" @click="handleCreate">
  新增
</ElButton>
```

##### 国际化

```typescript
import { $t } from '#/locales';
const title = $t('xxx.title');
```

#### 最佳实践

1. 组件拆分：复杂组件拆分为多个子组件
2. 状态管理：使用 ref 管理本地状态
3. 错误处理：统一处理 API 错误
4. 加载状态：显示加载状态
5. 权限验证：关键操作添加权限验证
6. 数据验证：表单提交前验证数据
7. 国际化：所有文本支持国际化
8. 性能优化：大列表使用虚拟滚动

#### 输出格式

生成页面时提供：
1. 目录结构
2. 完整代码
3. 路由配置
4. API 接口
5. 国际化配置
6. 权限配置

#### 特点

- **完整性**: 生成包含所有功能的完整页面
- **规范性**: 严格遵循项目规范
- **可扩展**: 支持自定义和扩展
- **用户友好**: 集成权限、国际化等

---

### 3. Store Generator (store-generator.md)

#### 基本信息

- **名称**: store-generator
- **描述**: 生成符合项目规范的 Pinia store 模块
- **模型**: claude-sonnet-5
- **工具**: Read, Edit, Write, Bash

#### 核心能力

1. **Store 创建**: 生成符合项目规范的 Pinia store
2. **持久化配置**: 支持状态持久化
3. **类型安全**: 完整的 TypeScript 类型支持
4. **最佳实践**: 遵循 Pinia 和 Vue 3 最佳实践

#### 工作流程

##### 需求分析阶段

确认以下信息：
- Store 名称和用途
- 需要管理的状态（state）
- 需要的 actions（同步/异步）
- 是否需要持久化
- 是否需要 getters

#### Store 结构

##### 基础结构

```typescript
interface XxxState {
  data: any[];
  loading: boolean;
  error: string | null;
}

export const useXxxStore = defineStore('xxx', {
  state: (): XxxState => ({
    data: [],
    loading: false,
    error: null,
  }),
  
  getters: {
    hasData: (state) => state.data.length > 0,
  },
  
  actions: {
    async fetchData() {
      this.loading = true;
      try {
        const result = await api.getXxx();
        this.data = result;
      } finally {
        this.loading = false;
      }
    },
  },
});
```

#### 命名规范

- **Store 名称**: camelCase，以 Store 结尾（如 `useUserStore`）
- **State 接口**: PascalCase，以 State 结尾（如 `UserState`）
- **Actions**: camelCase，动词开头（如 `fetchUser`、`updateUser`）
- **Getters**: camelCase，布尔值以 is/has 开头（如 `hasUser`、`isActive`）

#### 常见模式

支持多种 Store 模式：

1. **简单计数器**
2. **异步数据加载**
3. **持久化存储**
4. **组合式 Store**
5. **Store 间协作**

#### 最佳实践

1. 单一职责：每个 store 只负责一个领域
2. 命名清晰：使用描述性的名称
3. 类型安全：为所有状态和 actions 添加类型
4. 错误处理：异步 actions 要处理错误
5. 重置功能：提供重置状态的方法
6. 避免直接修改：通过 actions 修改状态
7. 合理使用 getters：避免在 getters 中进行复杂计算

#### 输出格式

生成 Store 时提供：
1. 文件路径
2. 完整代码
3. 使用示例
4. 持久化配置说明
5. 相关依赖

#### 特点

- **类型安全**: 完整的 TypeScript 支持
- **模式丰富**: 支持多种常见模式
- **最佳实践**: 遵循 Pinia 最佳实践
- **可扩展**: 支持持久化和组合

---

### 4. Vue Component Generator (vue-component-generator.md)

#### 基本信息

- **名称**: vue-component-generator
- **描述**: 生成符合项目规范的 Vue 3 组件
- **模型**: claude-sonnet-5
- **工具**: Read, Edit, Write, Bash

#### 核心能力

1. **组件生成**: 根据业务场景生成 Vue 3 组件
2. **类型定义**: 自动生成 TypeScript 类型定义
3. **UI 框架支持**: 支持 Element Plus、Ant Design Vue、Naive UI、TDesign
4. **代码规范**: 遵循项目编码规范和最佳实践

#### 工作流程

##### 需求分析阶段

确认以下信息：
- 组件名称和用途
- 使用哪个 UI 框架版本（默认 Element Plus）
- 组件类型（展示型、表单型、业务组件等）
- 是否需要 Props、Events、Slots
- 是否需要状态管理

#### 组件结构

遵循统一的文件结构：

```vue
<script setup lang="ts">
// 1. 类型导入
import type { PropType } from 'vue';

// 2. 外部导入
import { ref, computed, onMounted } from 'vue';

// 3. Props 定义
interface Props {
  title: string;
  data?: any[];
}
const props = withDefaults(defineProps<Props>(), {
  data: () => [],
});

// 4. Emits 定义
interface Emits {
  (e: 'update', value: string): void;
}
const emit = defineEmits<Emits>();

// 5. 响应式数据
const localData = ref<any[]>([]);

// 6. 计算属性
const displayData = computed(() => /* ... */);

// 7. 方法
function handleSubmit() { /* ... */ }

// 8. 生命周期
onMounted(() => { /* ... */ });
</script>

<template>
  <div class="component-name">
    <!-- 模板内容 -->
  </div>
</template>

<style scoped>
.component-name {
  /* 使用 Tailwind CSS 优先 */
}
</style>
```

#### 命名规范

- **文件名**: kebab-case（如 `user-list.vue`）
- **组件名**: PascalCase（如 `UserList`）
- **Props**: camelCase（如 `userName`）
- **Events**: kebab-case（如 `update-user`）
- **Slots**: kebab-case（如 `header-content`）

#### UI 框架适配

支持多种 UI 框架：

1. **Element Plus (web-ele)** - 推荐
2. **Ant Design Vue (web-antd)**
3. **Naive UI (web-naive)**
4. **TDesign (web-tdesign)**

#### 最佳实践

1. **TypeScript 严格类型**
   - 所有 Props 必须定义类型
   - 避免使用 `any`
   - 为复杂类型创建 interface

2. **组合式 API**
   - 使用 `<script setup>` 语法
   - 使用 `ref` 和 `reactive` 管理状态
   - 使用 `computed` 处理派生状态

3. **性能优化**
   - 合理使用 `v-show` 和 `v-if`
   - 使用 `v-for` 时必须提供 `key`
   - 大列表使用虚拟滚动

4. **可访问性**
   - 为交互元素添加 `aria-*` 属性
   - 使用语义化 HTML
   - 支持键盘导航

#### 示例组件

提供多种类型组件的示例：

1. **展示型组件**: 简单的数据展示
2. **表单组件**: 包含表单验证和提交

#### 输出格式

生成组件时提供：
1. 文件路径
2. 完整代码
3. 使用说明
4. 依赖说明
5. 类型定义

#### 特点

- **规范性强**: 严格遵循 Vue 3 最佳实践
- **类型安全**: 完整的 TypeScript 支持
- **框架支持**: 支持多种 UI 框架
- **性能优化**: 内置性能优化建议

---

## Agent 协作关系

这些 Agent 之间存在协作关系：

### 典型工作流

1. **API Module Creator**: 首先创建 API 接口和类型定义
2. **Store Generator**: 基于 API 创建状态管理
3. **Vue Component Generator**: 创建独立的 UI 组件
4. **Page Builder**: 组装 API、Store 和组件，构建完整页面

### 依赖关系

```
Page Builder
├── 依赖 API Module Creator（提供 API 接口）
├── 依赖 Store Generator（提供状态管理）
└── 依赖 Vue Component Generator（提供组件）
```

## Agent 共同特点

### 1. 规范性强

所有 Agent 都严格遵循项目规范：
- TypeScript 类型安全
- 命名规范统一
- 目录结构一致
- 代码风格统一

### 2. 功能完整

每个 Agent 都提供完整的功能：
- 需求分析
- 代码生成
- 使用示例
- 注意事项

### 3. 最佳实践

所有 Agent 都遵循最佳实践：
- 性能优化
- 错误处理
- 安全考虑
- 可维护性

### 4. 可扩展性

支持灵活的扩展：
- 自定义模板
- 特殊配置
- 业务定制

## 使用场景

### 1. 新模块开发

使用流程：
1. 使用 **API Module Creator** 创建 API 接口
2. 使用 **Store Generator** 创建状态管理
3. 使用 **Page Builder** 创建完整页面
4. 使用 **Vue Component Generator** 创建业务组件

### 2. 单个功能添加

根据需求选择：
- 添加 API 接口 → API Module Creator
- 添加状态管理 → Store Generator
- 添加页面 → Page Builder
- 添加组件 → Vue Component Generator

### 3. 代码重构

使用 Agent 重构现有代码：
- 重构 API 接口
- 重构状态管理
- 重构组件
- 重构页面

## 最佳实践建议

### 1. 按需使用

根据实际需求选择合适的 Agent：
- 不需要为简单任务使用 Agent
- 复杂任务优先使用 Agent
- 可以组合使用多个 Agent

### 2. 定制调整

生成的代码可能需要调整：
- 根据实际业务调整字段
- 根据项目规范调整配置
- 根据团队习惯调整风格

### 3. 持续优化

定期优化 Agent：
- 更新模板和规范
- 添加新的模式
- 改进生成质量

## 总结

`.claude/agents/` 目录包含了四个专门化的子代理，它们共同构成了项目的自动化开发工具链：

1. **API Module Creator**: 负责创建 API 接口模块
2. **Page Builder**: 负责构建完整的业务页面
3. **Store Generator**: 负责生成 Pinia 状态管理
4. **Vue Component Generator**: 负责生成 Vue 3 组件

这些 Agent 具有以下优势：

- **提高效率**: 自动生成大量样板代码
- **保证质量**: 严格遵循项目规范和最佳实践
- **减少错误**: 类型安全、规范统一
- **易于维护**: 代码风格一致、结构清晰
- **支持协作**: Agent 之间可以协作完成复杂任务

建议开发者在日常开发中充分利用这些 Agent，以提高开发效率和代码质量。同时，也可以根据项目需求扩展和定制这些 Agent。
