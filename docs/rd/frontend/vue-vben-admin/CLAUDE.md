# Vue Vben Admin 项目指南

## 项目概述

Vue Vben Admin 是一个基于 Vue 3 的现代化企业级管理后台框架，采用 Monorepo 架构，支持多种 UI 框架（Ant Design Vue、Naive UI、Element Plus、TDesign）。

## 技术栈

### 核心技术
- **Vue 3.5+**: 渐进式 JavaScript 框架
- **TypeScript 5.x**: 类型安全的 JavaScript 超集
- **Vite 6.x**: 新一代前端构建工具
- **Pinia**: Vue 3 状态管理库
- **Vue Router**: Vue.js 官方路由

### UI 框架支持
- **Ant Design Vue**: 企业级 UI 组件库
- **Naive UI**: Vue 3 组件库
- **Element Plus**: Vue 3 组件库
- **TDesign**: 腾讯开源的企业级设计体系

### 构建工具
- **Turbo**: 高性能构建系统
- **pnpm**: 快速、节省磁盘空间的包管理器
- **TypeScript**: 类型检查和编译
- **Vite**: 开发服务器和打包

### 代码质量
- **ESLint**: JavaScript 代码检查
- **Oxlint**: 更快的 Linter（Rust 实现）
- **Stylelint**: CSS/SCSS 代码检查
- **Prettier**: 代码格式化
- **Lefthook**: Git hooks 管理

### 测试
- **Vitest**: 单元测试框架
- **Playwright**: E2E 测试框架
- **Happy DOM**: 测试环境 DOM 模拟

## 项目结构

```
vue-vben-admin/
├── apps/                    # 应用目录
│   ├── web-antd/           # Ant Design Vue 版本
│   ├── web-naive/          # Naive UI 版本
│   ├── web-ele/            # Element Plus 版本
│   ├── web-tdesign/        # TDesign 版本
│   └── docs/               # 文档站点
├── packages/               # 共享包
│   ├── effects/            # 公共效果/插件
│   ├── icons/              # 图标库
│   ├── locales/            # 国际化
│   ├── preferences/        # 偏好设置
│   ├── stores/             # 状态管理
│   ├── styles/             # 样式
│   ├── types/              # 类型定义
│   └── utils/              # 工具函数
├── internal/               # 内部工具
│   ├── lint-configs/       # Lint 配置
│   ├── vite-config/        # Vite 配置
│   └── turbo-run/          # Turbo 运行脚本
└── playground/             # 播放场/示例
```

## 开发规范

### 命名约定

#### 文件命名
- **Vue 组件**: PascalCase（如 `UserProfile.vue`）
- **TypeScript 文件**: camelCase（如 `useUserService.ts`）
- **常量文件**: UPPER_CASE（如 `API_ROUTES.ts`）
- **类型定义**: PascalCase + .ts（如 `UserTypes.ts`）

#### 变量命名
- **组件**: PascalCase
- **函数/变量**: camelCase
- **常量**: UPPER_SNAKE_CASE
- **类型/接口**: PascalCase
- **枚举**: PascalCase，成员 UPPER_SNAKE_CASE

#### 组件命名
- **页面组件**: `Page` 后缀（如 `UserListPage.vue`）
- **布局组件**: `Layout` 后缀（如 `MainLayout.vue`）
- **业务组件**: 功能名（如 `UserForm.vue`）
- **基础组件**: `Base` 前缀（如 `BaseButton.vue`）

### 代码风格

#### Vue 组件结构
```vue
<template>
  <!-- 模板内容 -->
</template>

<script setup lang="ts">
// 1. 导入
import { ref } from 'vue';

// 2. 类型定义
interface Props {
  title: string;
}

// 3. Props 定义
const props = defineProps<Props>();

// 4. 响应式状态
const loading = ref(false);

// 5. 计算属性
const computed = computed(() => {});

// 6. 方法
const handleClick = () => {};

// 7. 生命周期
onMounted(() => {});
</script>

<style scoped>
/* 样式 */
</style>
```

#### TypeScript 规范
- 优先使用 `interface` 定义对象类型
- 使用 `type` 定义联合类型、交叉类型
- 明确声明函数返回类型
- 避免使用 `any`，使用 `unknown` 或具体类型
- 使用泛型提高代码复用性

#### 样式规范
- 优先使用 Tailwind CSS 工具类
- 组件样式使用 `scoped`
- 使用 CSS 变量管理主题色
- 响应式设计遵循移动优先原则

### Git 提交规范

使用 Conventional Commits 规范：

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type 类型
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具变动
- `ci`: CI 配置变动

#### 示例
```
feat(user): 添加用户头像上传功能

- 支持拖拽上传
- 支持裁剪功能
- 添加文件大小限制

Closes #123
```

## 常用命令

### 开发
```bash
# 安装依赖
pnpm install

# 启动开发服务器（Ant Design 版本）
pnpm dev:antd

# 启动开发服务器（Naive UI 版本）
pnpm dev:naive

# 构建生产版本
pnpm build

# 代码格式化
pnpm format

# 代码检查
pnpm lint
```

### 测试
```bash
# 运行单元测试
pnpm test:unit

# 运行 E2E 测试
pnpm test:e2e

# 类型检查
pnpm check:type
```

### 其他
```bash
# 清理项目
pnpm clean

# 更新依赖
pnpm update:deps

# 预览构建结果
pnpm preview
```

## 开发流程

### 新建页面
1. 在 `apps/web-*/src/views/` 下创建页面组件
2. 在 `router/routes/modules/` 下添加路由配置
3. 在 `locales/` 下添加国际化文案
4. 如需 API，在 `api/` 下添加接口定义

### 新建组件
1. 在 `packages/` 或 `apps/web-*/src/components/` 下创建组件
2. 编写组件文档和示例
3. 添加单元测试
4. 导出组件供其他模块使用

### API 集成
1. 在 `api/` 目录下定义接口类型
2. 使用 `request` 工具发送请求
3. 处理响应和错误
4. 添加缓存策略（如需要）

### 状态管理
1. 在 `stores/` 下创建 Store
2. 定义 State、Getters、Actions
3. 在组件中使用 `useStore` 获取状态
4. 使用持久化存储（如需要）

## 性能优化

### 首屏优化
- 路由懒加载
- 组件异步加载
- 图片懒加载
- 代码分割

### 运行时优化
- 虚拟滚动
- 防抖节流
- 计算属性缓存
- 合理使用 v-show/v-if

### 构建优化
- Tree Shaking
- 压缩代码
- 提取公共代码
- 使用 CDN 加速

## 安全规范

### XSS 防护
- 使用 `v-html` 时进行 sanitize
- 对用户输入进行转义
- 设置 CSP 策略

### CSRF 防护
- 使用 CSRF Token
- 验证 Referer 头
- SameSite Cookie

### 数据安全
- 敏感数据加密存储
- 不在前端存储敏感信息
- 使用 HTTPS
- Token 定期刷新

## 最佳实践

### 组件设计
- 单一职责原则
- 可配置性
- 可测试性
- 文档完善

### 代码质量
- 保持函数简短
- 避免深层嵌套
- 注释复杂逻辑
- 编写单元测试

### 可维护性
- 模块化设计
- 统一的代码风格
- 完善的文档
- 版本控制规范

## 常见问题

### 依赖安装失败
```bash
# 清理缓存
pnpm clean

# 删除 node_modules
rm -rf node_modules

# 重新安装
pnpm install
```

### 类型错误
```bash
# 检查类型
pnpm check:type

# 重启 TS 服务（IDE）
```

### 样式不生效
- 检查是否使用 scoped
- 确认样式优先级
- 清除缓存重新编译

## 相关资源

- [Vue 3 文档](https://vuejs.org/)
- [Vite 文档](https://vitejs.dev/)
- [Pinia 文档](https://pinia.vuejs.org/)
- [Vue Router 文档](https://router.vuejs.org/)
- [Ant Design Vue](https://antdv.com/)
- [Naive UI](https://www.naiveui.com/)
- [Tailwind CSS](https://tailwindcss.com/)
- [TypeScript](https://www.typescriptlang.org/)
