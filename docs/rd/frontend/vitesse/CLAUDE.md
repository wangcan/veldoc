---
name: vitesse-project
description: Vitesse Vue 3 项目技术架构和开发指南
metadata:
  type: project
---

# Vitesse 项目技术架构

## 项目概述

Vitesse 是一个基于 Vue 3 和 Vite 的现代前端开发模板项目，采用了一系列现代化技术栈和最佳实践。本项目在此基础上进行应用开发扩展。

**相关文档：** [[coding-standards]] [[component-architecture]]

## 核心技术栈

### 前端框架
- **Vue 3** - 渐进式 JavaScript 框架，使用 Composition API
- **TypeScript** - 类型安全的 JavaScript 超集
- **Vite** - 新一代前端构建工具，提供极速的开发体验

### 状态管理
- **Pinia** - Vue 3 官方推荐的状态管理库，基于 Composition API

### 路由
- **Vue Router v5** - Vue.js 官方路由
- **unplugin-vue-router** - 文件系统路由，自动生成路由配置
- **vite-plugin-vue-layouts** - 页面布局系统

### 样式方案
- **UnoCSS** - 即时原子化 CSS 引擎，支持 Tailwind/Windi CSS 兼容语法
  - presetUno：默认预设
  - presetAttributify：属性化模式
  - presetIcons：图标支持
  - presetTypography：排版预设
  - presetWebFonts：Web 字体支持

### 工具库
- **VueUse** - Vue Composition API 工具集，提供大量实用函数
- **@vueuse/core** - 自动导入，无需手动 import

### 国际化
- **Vue I18n** - Vue.js 国际化插件
- **@intlify/unplugin-vue-i18n** - I18n 构建优化插件

### 静态站点生成
- **vite-ssg** - Vite 驱动的静态站点生成器
- **beasties** - 关键 CSS 提取优化

### PWA
- **vite-plugin-pwa** - PWA 支持，提供离线能力

### 测试
- **Vitest** - 基于 Vite 的单元测试框架
- **Cypress** - E2E 测试框架

### 代码质量
- **ESLint** - JavaScript 代码检查工具
- **@antfu/eslint-config** - Anthony Fu 的 ESLint 配置预设
  - 单引号
  - 无分号
  - 自动格式化

## 项目结构

```
vitesse/
├── src/
│   ├── components/        # 自动导入的组件
│   ├── composables/       # 组合式函数（自动导入）
│   ├── layouts/           # 布局组件
│   │   ├── default.vue    # 默认布局
│   │   ├── home.vue       # 首页布局
│   │   └── 404.vue        # 404 页面布局
│   ├── modules/           # 应用模块（自动加载）
│   │   ├── i18n.ts        # 国际化配置
│   │   ├── nprogress.ts   # 进度条
│   │   ├── pinia.ts       # 状态管理
│   │   └── pwa.ts         # PWA 配置
│   ├── pages/             # 页面组件（文件系统路由）
│   │   ├── index.vue      # 首页
│   │   ├── hi/[name].vue  # 动态路由
│   │   └── [...all].vue   # 404 页面
│   ├── stores/            # Pinia 状态管理
│   ├── styles/            # 全局样式
│   ├── App.vue            # 根组件
│   ├── main.ts            # 应用入口
│   └── types.ts           # 类型定义
├── locales/               # 国际化语言文件
├── public/                # 静态资源
├── test/                  # 测试文件
├── vite.config.ts         # Vite 配置
├── uno.config.ts          # UnoCSS 配置
├── tsconfig.json          # TypeScript 配置
├── eslint.config.js       # ESLint 配置
└── cypress.config.ts      # Cypress 配置
```

## 核心特性

### 1. 文件系统路由

通过 `unplugin-vue-router` 实现，路由基于 `src/pages` 目录结构自动生成。

- `src/pages/index.vue` → `/`
- `src/pages/hi/[name].vue` → `/hi/:name`
- `src/pages/[...all].vue` → 捕获所有未匹配的路由（404）

页面可通过 `<route>` 块定义路由元信息：

```vue
<route lang="yaml">
meta:
  layout: home
</route>
```

**Why:** 无需手动配置路由，减少样板代码，提高开发效率。

**How to apply:** 新增页面时只需在 `src/pages` 下创建对应文件即可。

### 2. 自动导入

#### API 自动导入
通过 `unplugin-auto-import` 实现，以下 API 无需手动 import：

- Vue 3 Composition API（ref, computed, watch 等）
- Vue Router API（useRouter, useRoute 等）
- VueUse API（useDark, useToggle 等）
- Vue I18n API（useI18n 等）
- `src/composables/` 下的组合式函数
- `src/stores/` 下的 store

#### 组件自动导入
通过 `unplugin-vue-components` 实现，`src/components/` 下的组件自动全局注册。

**Why:** 减少重复的 import 语句，提升开发体验。

**How to apply:** 直接在代码中使用这些 API 和组件，无需 import。

### 3. 布局系统

通过 `vite-plugin-vue-layouts` 实现，支持在 `src/layouts` 目录下定义布局组件。

在页面中通过 route meta 指定布局：

```vue
<route lang="yaml">
meta:
  layout: home
</route>
```

**Why:** 统一页面布局管理，支持多种布局模式。

**How to apply:** 创建新布局时在 `src/layouts` 下创建对应组件。

### 4. UnoCSS 原子化 CSS

使用原子化 CSS，通过简短的类名组合实现样式。

#### 常用配置
- **shortcuts**: 预定义的样式组合
  - `btn`: 按钮基础样式
  - `icon-btn`: 图标按钮样式

#### 预设
- `presetUno`: Tailwind CSS 兼容
- `presetAttributify`: 属性化模式（`<div text="center red">`）
- `presetIcons`: 图标支持（`<div i-carbon-campsite />`）
- `presetTypography`: 排版预设（`prose` 类）
- `presetWebFonts`: Web 字体（DM Sans, DM Serif Display, DM Mono）

**Why:** 原子化 CSS 提供高性能和优秀的开发体验。

**How to apply:** 使用 UnoCSS 类名，参考 [UnoCSS 文档](https://unocss.dev/)。

### 5. 模块化架构

`src/modules/` 下的模块会在应用启动时自动加载。每个模块导出 `install` 函数：

```typescript
export const install: UserModule = ({ app, router, pinia }) => {
  // 模块初始化逻辑
}
```

**Why:** 模块化组织应用功能，便于扩展和维护。

**How to apply:** 新增功能模块时在 `src/modules` 下创建对应文件。

### 6. 静态站点生成（SSG）

使用 `vite-ssg` 实现，支持预渲染页面为静态 HTML。

配置位于 `vite.config.ts` 的 `ssgOptions`。

**Why:** 提升首屏加载性能，SEO 友好。

**How to apply:** 运行 `pnpm build` 生成静态文件到 `dist` 目录。

### 7. Markdown 支持

通过 `unplugin-vue-markdown` 支持 Markdown 文件作为组件。

- 支持 Vue 组件在 Markdown 中使用
- 支持 Shiki 语法高亮
- 自动应用排版样式

**Why:** 适合文档站点和内容驱动的页面。

**How to apply:** 创建 `.md` 文件作为页面或组件。

### 8. 国际化（I18n）

多语言文件位于 `locales/` 目录，支持：
- ar（阿拉伯语）
- de（德语）
- en（英语）
- es（西班牙语）
- fr（法语）
- id（印尼语）
- it（意大利语）
- ja（日语）
- ka（格鲁吉亚语）
- ko（韩语）
- pl（波兰语）
- pt-BR（巴西葡萄牙语）
- ru（俄语）
- tr（土耳其语）
- uk（乌克兰语）
- uz（乌兹别克语）
- vi（越南语）
- zh-CN（简体中文）

**Why:** 支持全球化应用开发。

**How to apply:** 在 `locales/` 下添加或修改语言文件。

## 开发工作流

### 开发环境
```bash
pnpm dev
```
启动开发服务器，访问 http://localhost:3333

### 构建生产版本
```bash
pnpm build
```
生成静态文件到 `dist` 目录

### 代码检查
```bash
pnpm lint
```
运行 ESLint 检查代码

### 类型检查
```bash
pnpm typecheck
```
运行 TypeScript 类型检查

### 单元测试
```bash
pnpm test:unit
```
运行 Vitest 单元测试

### E2E 测试
```bash
pnpm test:e2e
```
运行 Cypress E2E 测试

### 预览生产版本
```bash
pnpm preview
```
预览构建后的应用

## 最佳实践

### 组件开发
1. 使用 `<script setup>` 语法
2. 使用 Composition API
3. 遵循自动导入规则
4. 组件命名使用 PascalCase
5. 使用 TypeScript 类型定义

### 状态管理
1. 使用 Pinia store
2. Store 文件放在 `src/stores/`
3. 使用 Composition API 风格定义 store

### 路由
1. 页面组件放在 `src/pages/`
2. 使用动态路由参数 `[param]`
3. 通过 route meta 配置布局

### 样式
1. 优先使用 UnoCSS 原子类
2. 自定义样式使用 scoped CSS
3. 使用预定义的 shortcuts

### 性能优化
1. 使用 SSG 预渲染页面
2. 组件按需加载
3. 使用 `vite-ssg` 的 beasties 优化 CSS
4. PWA 缓存策略

## 注意事项

1. **Node 版本要求**: Node.js >= 14.18
2. **包管理器**: 推荐使用 pnpm
3. **ESLint 配置**: 使用 @antfu/eslint-config，强制单引号、无分号
4. **类型安全**: TypeScript 严格模式开启
5. **构建目标**: ESNext

## 相关链接

- [Vitesse GitHub](https://github.com/antfu-collective/vitesse)
- [Vue 3 文档](https://vuejs.org/)
- [Vite 文档](https://vitejs.dev/)
- [UnoCSS 文档](https://unocss.dev/)
- [Pinia 文档](https://pinia.vuejs.org/)
- [VueUse 文档](https://vueuse.org/)
- [Vue Router 文档](https://router.vuejs.org/)
