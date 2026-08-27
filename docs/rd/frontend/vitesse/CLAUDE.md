# Vitesse 项目开发指南

## 项目概述

本项目基于 [Vitesse](https://github.com/antfu/vitesse) 模板，是一个现代化的 Vue 3 应用开发框架。项目目标是在此基础上扩展开发多种功能模块，包括但不限于：

- 图片展示浏览模块
- 古籍/小说阅读模块
- 简易百科页面
- 各类表格展示
- 各类图表可视化

**重要**: 网站需同时支持 PC 端和移动端响应式布局。

## 技术栈

| 技术 | 用途 | 文档链接 |
|------|------|----------|
| Vue 3 | 前端框架 | https://vuejs.org/ |
| Vue Router v5 | 路由管理（文件系统路由） | https://github.com/vuejs/router |
| Pinia | 状态管理 | https://pinia.vuejs.org/ |
| Vue I18n | 国际化 | https://vue-i18n.intlify.dev/ |
| UnoCSS | 原子化 CSS | https://unocss.dev/ |
| Vite | 构建工具 | https://vitejs.dev/ |
| vite-ssg | 静态站点生成 | https://github.com/antfu/vite-ssg |
| VueUse | 组合式函数工具库 | https://vueuse.org/ |
| TypeScript | 类型安全 | https://www.typescriptlang.org/ |
| Vitest | 单元测试 | https://vitest.dev/ |
| Cypress | E2E 测试 | https://www.cypress.io/ |

## 项目结构

```
src/
├── components/          # 通用组件（自动注册）
├── composables/         # 组合式函数（自动导入）
├── layouts/             # 布局组件
├── modules/             # 应用模块（自动加载）
├── pages/               # 页面路由（文件系统路由）
│   ├── index.vue        # 首页
│   ├── about.md         # 关于页面（Markdown）
│   └── [...all].vue     # 404 页面
├── stores/              # Pinia 状态管理（自动导入）
├── styles/              # 全局样式
├── App.vue              # 根组件
├── main.ts              # 入口文件
├── types.ts             # 类型定义
├── auto-imports.d.ts    # 自动导入类型声明
├── components.d.ts      # 组件类型声明
└── route-map.d.ts       # 路由类型声明
locales/                 # 国际化语言包（YAML 格式）
```

## 开发规范

### 1. 组件开发

- 组件放置在 `src/components/` 目录，自动全局注册
- 组件命名使用 PascalCase，以功能模块前缀区分：
  - `The*.vue` - 全局单例组件（如 TheFooter, TheHeader）
  - `Base*.vue` - 基础可复用组件
  - `[Module]*.vue` - 功能模块组件（如 ImageGallery, BookReader）

### 2. 页面开发

- 页面放置在 `src/pages/` 目录，自动生成路由
- 支持 `.vue` 和 `.md` 文件格式
- 动态路由使用 `[id].vue` 语法
- 嵌套路由使用目录结构

### 3. 样式规范

- 优先使用 UnoCSS 原子化类名
- 自定义样式使用 scoped CSS
- 响应式设计断点：
  ```css
  /* 移动端优先 */
  sm: 640px   /* 平板 */
  md: 768px   /* 小屏桌面 */
  lg: 1024px  /* 桌面 */
  xl: 1280px  /* 大屏桌面 */
  ```

### 4. 状态管理

- Store 放置在 `src/stores/` 目录
- 使用 Composition API 风格定义 store
- 遵循 Pinia 最佳实践

### 5. 国际化

- 语言包放置在 `locales/` 目录，使用 YAML 格式
- 支持 `vue-i18n` 的 `$t()` 函数（自动导入）

### 6. 响应式设计原则

- **移动优先**: 默认样式针对移动端，使用断点逐步增强
- **触摸友好**: 确保按钮、链接等交互元素有足够大的点击区域
- **图片适配**: 使用 `srcset` 或 UnoCSS 的响应式类
- **布局弹性**: 使用 Flexbox/Grid 实现弹性布局

## 常用命令

```bash
# 开发
pnpm dev          # 启动开发服务器 (端口 3333)

# 构建
pnpm build        # 构建生产版本 (SSG)
pnpm preview      # 预览构建结果

# 代码质量
pnpm lint         # 代码检查
pnpm typecheck    # 类型检查

# 测试
pnpm test         # 运行测试
pnpm test:e2e     # E2E 测试
```

## 扩展模块规划

### 图片浏览模块
- 组件: `ImageGallery.vue`, `ImagePreview.vue`, `ImageUploader.vue`
- 页面: `pages/gallery/index.vue`, `pages/gallery/[id].vue`
- 功能: 图片网格展示、灯箱预览、图片上传

### 阅读模块
- 组件: `BookReader.vue`, `ChapterList.vue`, `BookmarkManager.vue`
- 页面: `pages/books/index.vue`, `pages/books/[id]/[chapter].vue`
- 功能: 翻页阅读、章节导航、书签管理、阅读进度

### 百科模块
- 组件: `WikiCard.vue`, `WikiSearch.vue`, `WikiCategory.vue`
- 页面: `pages/wiki/index.vue`, `pages/wiki/[category]/[slug].vue`
- 功能: 分类浏览、搜索、词条展示

### 表格模块
- 组件: `DataTable.vue`, `TableFilter.vue`, `TablePagination.vue`
- 功能: 数据展示、排序、筛选、分页

### 图表模块
- 组件: `LineChart.vue`, `BarChart.vue`, `PieChart.vue`
- 推荐: 集成 ECharts 或 Chart.js
- 功能: 数据可视化、响应式图表

## 相关链接

- [Vitesse 文档](https://github.com/antfu/vitesse)
- [Vue 3 文档](https://vuejs.org/)
- [UnoCSS 文档](https://unocss.dev/)
- [VueUse 函数库](https://vueuse.org/)
- [Vite 插件](https://vitejs.dev/plugins/)
