# 项目说明 - yudao-ui-admin-vben

## 项目简介

本项目是基于 [vue-vben-admin](https://github.com/vbenjs/vue-vben-admin) 的企业级管理系统，采用 Vue 3 + TypeScript 技术栈，支持多种 UI 框架（Element Plus、Ant Design Vue、Naive UI、TDesign），采用 Monorepo 架构管理多个应用和共享包。

## 技术栈

- **前端框架**: Vue 3.5.38 + TypeScript 6.0.3
- **构建工具**: Vite 8.0.10 + pnpm 11.7.0 + Turborepo
- **UI 框架**: Element Plus 2.14.2 | Ant Design Vue 4.2.6 | Naive UI 2.44.1 | TDesign 1.20.0
- **状态管理**: Pinia 3.0.4
- **路由**: Vue Router 5.1.0
- **CSS**: Tailwind CSS 4.3.0
- **工具库**: vueuse 14.3.0 | axios 1.18.0 | dayjs 1.11.21
- **表单验证**: vee-validate 4.15.1 + zod 3.25.76
- **国际化**: vue-i18n 11.4.5

## 项目结构

```
├── apps/                    # 应用目录
│   ├── web-antd            # Ant Design Vue 版本
│   ├── web-antdv-next      # Ant Design Vue Next 版本
│   ├── web-ele             # Element Plus 版本 ⭐ 推荐使用
│   ├── web-naive           # Naive UI 版本
│   └── web-tdesign         # TDesign 版本
├── packages/                # 共享包
│   ├── @core/              # 核心功能（UI组件、基础工具等）
│   ├── effects/            # 副作用相关（权限、请求等）
│   ├── constants/          # 常量定义
│   ├── icons/              # 图标库
│   ├── locales/            # 国际化文件
│   ├── preferences/        # 偏好设置
│   ├── stores/             # 全局状态存储
│   ├── styles/             # 全局样式
│   ├── types/              # 全局类型定义
│   └── utils/              # 工具函数
├── internal/                # 内部工具
│   ├── lint-configs/       # ESLint、Stylelint 等配置
│   ├── vite-config/        # Vite 构建配置
│   └── tsconfig/           # TypeScript 配置
└── .claude/                # Claude AI 助手配置
```

## 开发命令

```bash
# 安装依赖（必须使用 pnpm）
pnpm install

# 开发模式（Element Plus 版本）
pnpm dev:ele

# 开发模式（Ant Design Vue 版本）
pnpm dev:antd

# 构建生产版本
pnpm build:ele

# 类型检查
pnpm check:type

# 代码检查和修复
pnpm lint
pnpm format

# 运行测试
pnpm test:unit
```

## 业务模块

项目包含丰富的业务模块，支持多种企业级应用场景：

### 核心模块
- **system**: 系统管理（用户、角色、菜单、部门、岗位、字典等）
- **infra**: 基础设施（配置、文件、任务调度、代码生成等）
- **bpm**: 工作流程（流程定义、流程实例、任务管理等）
- **member**: 会员中心

### 业务系统
- **mall**: 电商系统
- **erp**: 企业资源计划
- **wms**: 仓库管理系统
- **crm**: 客户关系管理
- **mes**: 制造执行系统
- **hrm**: 人力资源管理
- **fms**: 财务管理
- **ai**: AI 大模型平台
- **iot**: 物联网系统
- **im**: 即时通讯
- **mp**: 微信公众号
- **pay**: 支付系统
- **report**: 数据报表

## 开发规范

### 编码风格

1. **TypeScript 优先**
   - 所有代码必须使用 TypeScript
   - 禁止使用 `any` 类型，使用 `unknown` 并进行类型守卫
   - 为所有函数添加返回类型注解
   - 使用 interface 定义对象结构，type 定义联合类型或交叉类型

2. **Vue 组件规范**
   - 使用 `<script setup lang="ts">` 语法
   - 组件命名：PascalCase（如 `UserList.vue`）
   - 组件文件结构：script -> template -> style
   - Props 必须定义类型，使用 `defineProps<T>()`
   - 事件使用 `defineEmits` 定义，并添加类型

3. **命名约定**
   - 文件名：kebab-case（如 `user-list.vue`）
   - 组件名：PascalCase（如 `UserList`）
   - 变量/函数：camelCase（如 `userName`）
   - 常量：UPPER_SNAKE_CASE（如 `MAX_COUNT`）
   - CSS 类名：使用 Tailwind CSS，自定义类使用 BEM 命名

4. **代码组织**
   - 单个文件不超过 500 行
   - 函数不超过 50 行
   - 使用 Composition API 组织代码
   - 相关逻辑使用 `useXxx` 组合式函数封装

### 目录结构规范

```
module-name/              # 业务模块
├── api/                  # API 接口
│   ├── index.ts         # 接口导出
│   └── model.ts         # 类型定义
├── views/                # 页面组件
│   ├── list/            # 列表页
│   │   ├── index.vue
│   │   └── data.ts      # 列表配置
│   └── form/            # 表单页
│       └── index.vue
├── components/           # 业务组件
└── hooks/               # 自定义 hooks
```

### API 调用规范

```typescript
// api/user/index.ts
import { requestClient } from '#/api/request';

export namespace UserApi {
  export interface UserInfo {
    id: number;
    username: string;
    // ...
  }
}

export function getUserList(params: any) {
  return requestClient.get<UserApi.UserInfo[]>('/system/user/list', { params });
}

export function getUserById(id: number) {
  return requestClient.get<UserApi.UserInfo>(`/system/user/${id}`);
}

export function createUser(data: UserApi.UserInfo) {
  return requestClient.post<UserApi.UserInfo>('/system/user', data);
}
```

### 组件开发规范

```vue
<script setup lang="ts">
import type { PropType } from 'vue';

// 1. 导入
import { ref, computed, onMounted } from 'vue';

// 2. Props 定义
interface Props {
  title: string;
  data?: UserApi.UserInfo[];
}

const props = withDefaults(defineProps<Props>(), {
  data: () => [],
});

// 3. Emits 定义
interface Emits {
  (e: 'update', value: string): void;
  (e: 'delete', id: number): void;
}

const emit = defineEmits<Emits>();

// 4. 响应式数据
const loading = ref(false);

// 5. 计算属性
const displayTitle = computed(() => props.title.toUpperCase());

// 6. 方法
function handleClick() {
  emit('update', 'value');
}

// 7. 生命周期
onMounted(() => {
  // 初始化逻辑
});
</script>

<template>
  <div class="user-component">
    <h3>{{ displayTitle }}</h3>
    <!-- 模板内容 -->
  </div>
</template>

<style scoped>
.user-component {
  /* 样式 */
}
</style>
```

## UI 框架使用指南

### Element Plus (web-ele)

推荐使用 Element Plus 版本进行开发。

```typescript
// 组件导入
import { ElButton, ElTable } from 'element-plus';

// 图标导入
import { Edit, Delete } from '@vben/icons';
```

### 常用组件

- **表格**: 使用 `useVbenVxeGrid` (基于 VxeTable)
- **表单**: 使用 `useVbenForm` (基于 VeeValidate + Zod)
- **弹窗**: 使用 `useVbenModal`
- **权限**: 使用 `v-access` 指令

### 国际化

```typescript
// 在组件中使用
import { $t } from '#/locales';

// 使用国际化
const text = $t('common.save');
```

## 最佳实践

### 性能优化

1. 使用 `v-show` 替代 `v-if` 频繁切换的元素
2. 大列表使用虚拟滚动（VxeTable 已内置）
3. 图片使用懒加载
4. 合理使用 `computed` 和 `watch`
5. 组件按需导入

### 安全性

1. 用户输入必须验证和清理
2. 敏感数据使用加密存储
3. API 请求使用拦截器统一处理错误
4. 权限检查在路由守卫和组件中双重验证

### 可维护性

1. 编写清晰的注释和文档
2. 遵循单一职责原则
3. 保持代码简洁，避免过度封装
4. 定期重构，消除重复代码
5. 使用 TypeScript 类型检查

## Claude 配置

项目已配置完整的 Claude AI 助手支持，详见 `.claude/` 目录：

- **agents/**: 自定义子代理（组件生成、API 创建等）
- **skills/**: 自定义技能（CRUD 页面生成、国际化等）
- **rules/**: 编码规范和最佳实践
- **commands/**: 自定义命令（模块创建、依赖分析等）
- **hooks/**: 自动化钩子（提交检查、推送验证等）

使用 Claude 开发时，请遵循本文件的指导原则，确保代码质量和一致性。

## 参考资源

- [Vue 3 文档](https://vuejs.org/)
- [Vite 文档](https://vitejs.dev/)
- [Element Plus 文档](https://element-plus.org/)
- [vue-vben-admin 文档](https://doc.vben.pro/)
- [项目启动文档](https://doc.iocoder.cn/quick-start/)
