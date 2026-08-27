# Skills 目录分析

## 目录概述

`.claude/skills/` 目录存放自定义技能定义文件。技能是更高级的交互式任务模板，包含多步骤执行流程和详细模板。

## 文件列表

| 文件 | 触发器 | 描述 |
|------|--------|------|
| `create-component.md` | `/create-component` | 创建新的 Vue 组件 |
| `create-page.md` | `/create-page` | 创建新的页面 |
| `create-store.md` | `/create-store` | 创建 Pinia Store |

---

## 1. create-component.md

### 基本信息

```yaml
name: create-component
description: 创建新的 Vue 组件，支持自动生成模板和类型定义
trigger: /create-component
```

### 使用方法

```
/create-component <组件名称> [描述]
```

### 执行步骤

1. 确认组件名称和功能描述
2. 选择组件类型：
   - 全局组件 (The*)
   - 基础组件 (Base*)
   - 功能模块组件
3. 在 `src/components/` 目录创建组件文件
4. 生成符合规范的组件代码
5. 添加必要的类型定义
6. 确保响应式设计支持

### 提供的模板

#### 基础 UI 组件模板

包含 Props、Emits 定义和 slot 支持的完整模板。

#### 功能模块组件模板

包含响应式状态、计算属性、生命周期钩子的模板，使用 UnoCSS 响应式网格布局。

### 注意事项

- 组件文件自动全局注册
- UnoCSS 原子类优先
- 确保移动端和桌面端体验

### 作用

通过交互式流程创建符合规范的 Vue 组件，自动处理类型定义和响应式设计。

---

## 2. create-page.md

### 基本信息

```yaml
name: create-page
description: 创建新的页面，自动处理路由配置和布局选择
trigger: /create-page
```

### 使用方法

```
/create-page <页面路径> [描述]
```

### 示例

```
/create-page gallery/index 图片画廊列表页
/create-page gallery/[id] 图片详情页
/create-page books/[id]/[chapter] 书籍章节阅读页
```

### 执行步骤

1. 确认页面路径和功能描述
2. 确定路由类型：
   - 静态路由
   - 动态路由
   - 嵌套路由
3. 选择合适的布局
4. 在 `src/pages/` 目录创建页面文件
5. 生成页面代码，包括：
   - SEO 元信息
   - 响应式布局
   - 必要的组件引用

### 提供的模板

#### 列表页模板

包含 SEO 设置和响应式网格布局的列表页模板。

#### 详情页模板（动态路由）

包含路由参数获取和数据加载的详情页模板。

### 布局配置

使用 `definePage` 配置布局：
```vue
<route lang="yaml">
definePage:
  layout: home
</route>
```

### Markdown 页面

支持使用 Markdown 创建简单内容页面。

### 作用

简化页面创建流程，自动处理文件系统路由配置和布局选择。

---

## 3. create-store.md

### 基本信息

```yaml
name: create-store
description: 创建 Pinia Store，使用 Composition API 风格
trigger: /create-store
```

### 使用方法

```
/create-store <store名称> [描述]
```

### 示例

```
/create-store gallery 图片画廊状态管理
/create-store user 用户信息和认证状态
/create-store reading 阅读进度和书签管理
```

### 执行步骤

1. 确认 Store 名称和功能描述
2. 定义状态结构
3. 确定需要的 actions 和 getters
4. 在 `src/stores/` 目录创建 Store 文件
5. 添加 TypeScript 类型定义
6. 考虑 SSR 兼容性

### 提供的模板

#### 基础 Store

包含 State、Getters、Actions 的 Composition API 风格 Store。

#### 带持久化的 Store

使用 `watch` 和 `localStorage` 实现状态持久化。

#### 异步数据 Store

包含数据获取、加载状态、错误处理的完整 Store。

### 命名规范

- 文件名: `kebab-case-store.ts`
- Store ID: `kebab-case`
- 函数名: `useKebabCaseStore`
- 类型导出: `export type ExampleStore = ReturnType<typeof useExampleStore>`

### SSR 注意事项

- 避免初始化时访问 `window` 或 `document`
- 使用 `import.meta.client` 检查客户端环境

### 作用

快速生成符合 Pinia 最佳实践的 Store，处理 SSR 兼容性和持久化需求。

---

## 目录作用总结

### 1. 交互式任务执行

Skills 提供比 Commands 更复杂的交互式任务：
- 多步骤执行流程
- 用户确认和选择
- 详细的模板生成

### 2. 代码生成自动化

三个技能覆盖了 Vue 项目的核心代码生成：
- 组件生成 → `create-component`
- 页面生成 → `create-page`
- 状态管理生成 → `create-store`

### 3. 规范集成

每个 Skill 都集成了项目规范：
- 遵循 Vue/TypeScript 规范
- 支持响应式设计
- 考虑 SSR 兼容性

## Skills 与 Agents 的关系

| 特性 | Skills | Agents |
|------|--------|--------|
| 定义位置 | `.claude/skills/` | `.claude/agents/` |
| 触发方式 | `/skill名` 或自动 | 被 Skill 或其他 Agent 调用 |
| 执行模式 | 交互式流程 | 后台任务 |
| 复杂度 | 多步骤交互 | 单一任务执行 |
| 关系 | Skills 可调用 Agents | Agents 是执行单元 |

实际上，Skills 通常会调用 Agents 来执行具体的代码生成任务。

## 使用示例

```bash
# 创建组件
/create-component ImageGallery 图片画廊组件，支持网格展示和灯箱预览

# 创建页面
/create-page gallery/index 图片画廊列表页

# 创建 Store
/create-store gallery 图片画廊状态管理
```

## 扩展建议

可根据项目需要添加更多技能：

| 潜在技能 | 用途 |
|---------|------|
| `create-composable.md` | 创建组合式函数 |
| `create-api-service.md` | 创建 API 服务层 |
| `create-i18n.md` | 创建国际化语言包 |
| `create-test.md` | 创建测试文件 |
| `migrate-component.md` | 迁移组件到新规范 |
