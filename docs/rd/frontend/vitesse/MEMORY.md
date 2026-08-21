# Vitesse Project Memory Index

这个文件索引了 Vitesse 项目的重要记忆文档，供 Claude 在开发过程中参考。

## 项目文档

- [CLAUDE.md](CLAUDE.md) — 项目技术架构总览、核心特性、开发工作流和最佳实践

## 开发规则

- [coding-standards](.claude/rules/coding-standards.md) — 代码规范、ESLint 规则、命名约定、TypeScript 使用、UnoCSS 规范等
- [component-architecture](.claude/rules/component-architecture.md) — 组件架构设计、目录结构、组件分类、设计原则、通信模式等

## 开发 Agent

- [vue-component-developer](.claude/agents/vue-component-developer.md) — Vue 3 组件开发专家，精通 Composition API、UnoCSS 和自动导入
- [route-page-developer](.claude/agents/route-page-developer.md) — 路由页面开发专家，精通文件系统路由、布局系统和页面元信息配置
- [pinia-store-developer](.claude/agents/pinia-store-developer.md) — Pinia 状态管理专家，精通 Composition API 风格的 store 定义
- [i18n-specialist](.claude/agents/i18n-specialist.md) — 国际化专家，精通 Vue I18n、多语言配置和本地化最佳实践

## 开发 Skills

- [create-component](.claude/skills/create-component.md) — 创建新的 Vue 组件，遵循项目规范
- [create-page](.claude/skills/create-page.md) — 创建新的页面组件，配置路由和布局
- [create-store](.claude/skills/create-store.md) — 创建新的 Pinia store，管理应用状态
- [add-i18n](.claude/skills/add-i18n.md) — 添加新的国际化翻译键和语言支持
- [create-composable](.claude/skills/create-composable.md) — 创建新的组合式函数，封装可复用逻辑

---

## 使用指南

### 1. 查看项目架构
阅读 [CLAUDE.md](CLAUDE.md) 了解项目的整体技术架构、目录结构和核心特性。

### 2. 遵循开发规范
在进行开发时，参考 [coding-standards](.claude/rules/coding-standards.md) 确保代码质量和一致性。

### 3. 理解组件架构
设计和开发组件时，参考 [component-architecture](.claude/rules/component-architecture.md) 了解组件分类和设计原则。

### 4. 使用专用 Agent
根据开发任务类型，使用对应的专用 Agent：
- 创建组件 → 使用 `vue-component-developer`
- 创建页面 → 使用 `route-page-developer`
- 创建 Store → 使用 `pinia-store-developer`
- 处理国际化 → 使用 `i18n-specialist`

### 5. 使用 Skill 快速开发
使用预定义的 Skill 快速创建常用代码：
- `/create-component` — 创建 Vue 组件
- `/create-page` — 创建页面
- `/create-store` — 创建 Store
- `/add-i18n` — 添加国际化
- `/create-composable` — 创建组合式函数

---

**最后更新**: 2026-08-05
