# 小说阅读器模块需求文档

## 项目概述

在 Vitesse 项目基础上，新增一个功能完整的 Web 小说阅读器模块，支持 PC 端和移动端访问，提供优质的阅读体验。

## 需求列表

### 1. 核心需求

#### 1.1 小说阅读器模块
**需求描述：** 在当前 Vitesse 项目的基础上，新增一个完整的 Web 应用小说阅读器模块。

**实现内容：**
- ✅ 书籍列表功能
- ✅ 书籍详情页面
- ✅ 章节阅读功能
- ✅ 书架管理功能
- ✅ 阅读设置功能

**技术方案：**
- 使用 Vue 3 + TypeScript + Vite 构建
- 采用文件系统路由（unplugin-vue-router）
- 使用 Pinia 进行状态管理
- 使用 UnoCSS 实现响应式布局

**实现文件：**
- 页面：`src/pages/novel/` 目录下的 4 个页面
- 组件：`src/components/Novel*.vue` 组件
- Store：`src/stores/` 目录下的 4 个 store 文件

**验收标准：**
- ✅ 可以浏览书籍列表
- ✅ 可以查看书籍详情
- ✅ 可以阅读章节内容
- ✅ 可以管理书架
- ✅ 可以调整阅读设置

---

#### 1.2 响应式设计
**需求描述：** Web 页面要支持 PC 端和移动端访问，确保在不同设备上都有良好的用户体验。

**实现方案：**

**PC 端布局 (> 768px):**
- 书籍列表：3-4 列网格布局
- 书籍详情：左侧封面 + 右侧信息
- 阅读器：居中显示（max-width: 800px），侧边章节导航
- 书架：4-6 列网格布局

**移动端布局 (< 768px):**
- 书籍列表：单列卡片布局
- 书籍详情：垂直布局，封面在上
- 阅读器：全屏显示，底部导航按钮
- 书架：2 列网格布局

**技术实现：**
- 使用 UnoCSS 响应式类：`grid-cols-1 md:grid-cols-2 lg:grid-cols-3`
- 媒体查询适配不同屏幕尺寸
- 触摸友好的交互设计

**实现文件：**
- 所有页面组件都使用了响应式 UnoCSS 类
- 阅读器组件针对移动端优化了底部导航

**验收标准：**
- ✅ PC 端布局美观、功能完整
- ✅ 移动端布局合理、易于操作
- ✅ 响应式过渡平滑

---

#### 1.3 示例书籍和章节
**需求描述：** 创建若干示例书籍和章节内容，用于展示阅读器功能。

**实现内容：**

**书籍数量：** 5 本不同类型的小说

**书籍列表：**
1. **《修仙传说》** - 玄幻类
   - 作者：云中仙
   - 字数：120 万字
   - 状态：连载中
   - 章节：10 章（完整内容）

2. **《都市最强系统》** - 都市类
   - 作者：逍遥子
   - 字数：98 万字
   - 状态：连载中
   - 章节：10 章

3. **《星际征途》** - 科幻类
   - 作者：星河旅者
   - 字数：150 万字
   - 状态：已完结
   - 章节：10 章

4. **《大明风华》** - 历史类
   - 作者：墨香书生
   - 字数：180 万字
   - 状态：已完结
   - 章节：10 章

5. **《剑道独尊》** - 武侠类
   - 作者：剑客行
   - 字数：135 万字
   - 状态：连载中
   - 章节：10 章

**章节内容：**
- 每本书包含 10 个章节
- 每章节 600-900 字
- 第一本书《修仙传说》包含完整的章节内容
- 其他书籍使用简化生成的内容

**实现文件：**
- `src/data/novels.ts` - 包含所有示例数据

**验收标准：**
- ✅ 包含 5 本不同类型的书籍
- ✅ 每本书包含多个章节
- ✅ 章节内容质量良好

---

## 功能详细说明

### 2. 书籍列表功能

**页面路径：** `/novel`

**功能特性：**
- ✅ 显示所有书籍的网格视图
- ✅ 按分类筛选（全部、玄幻、都市、科幻、历史、武侠）
- ✅ 搜索功能（支持标题、作者、标签搜索）
- ✅ 显示书籍基本信息（封面、标题、作者、简介、分类、状态）
- ✅ 加入/移出书架快捷操作
- ✅ 点击进入书籍详情

**技术实现：**
- 使用 `useNovelStore` 管理书籍数据
- 使用 `useShelfStore` 管理书架状态
- 使用 computed 计算属性实现筛选和搜索
- 响应式网格布局

---

### 3. 书籍详情功能

**页面路径：** `/novel/book/[id]`

**功能特性：**
- ✅ 显示书籍详细信息（封面、标题、作者、简介、标签、统计）
- ✅ 显示章节列表（支持正序/倒序切换）
- ✅ 显示阅读进度（如果存在）
- ✅ 开始阅读/继续阅读按钮
- ✅ 加入/移出书架按钮
- ✅ 返回书籍列表按钮

**技术实现：**
- 使用路由参数 `id` 获取书籍信息
- 使用 `useReadingProgressStore` 获取阅读进度
- 动态计算继续阅读的章节

---

### 4. 章节阅读功能

**页面路径：** `/novel/read/[bookId]/[chapterId]`

**功能特性：**
- ✅ 显示章节内容
- ✅ 上一章/下一章导航
- ✅ 章节列表抽屉（快速跳转）
- ✅ 阅读设置面板
- ✅ 自动保存阅读进度
- ✅ 键盘快捷键支持（左右箭头翻页）
- ✅ 顶部工具栏（返回、书籍信息、操作按钮）

**阅读设置：**
- ✅ 字体大小调节（14-24px）
- ✅ 行距调节（1.4-2.0）
- ✅ 主题切换（日间、夜间、护眼）
- ✅ 字体选择（宋体、黑体、等宽）
- ✅ 阅读模式（滚动、翻页）

**技术实现：**
- 使用 `NovelReader` 组件渲染内容
- 使用 `NovelReaderSettings` 组件调整设置
- 使用 `useDebounceFn` 防抖保存进度
- 监听滚动事件计算阅读百分比

---

### 5. 书架管理功能

**页面路径：** `/novel/shelf`

**功能特性：**
- ✅ 显示收藏的书籍
- ✅ 显示阅读进度
- ✅ 快速继续阅读
- ✅ 移出书架
- ✅ 空书架提示

**技术实现：**
- 使用 `useShelfStore` 管理书架状态
- 使用 `useReadingProgressStore` 获取进度
- 使用 localStorage 持久化数据

---

## 技术架构

### 技术栈
- **前端框架：** Vue 3 + TypeScript
- **构建工具：** Vite
- **路由：** Vue Router v5 + unplugin-vue-router（文件系统路由）
- **状态管理：** Pinia
- **样式方案：** UnoCSS（原子化 CSS）
- **国际化：** Vue I18n

### 文件结构
```
src/
├── data/
│   └── novels.ts                    # 示例数据
├── types.ts                         # 类型定义（扩展）
├── stores/
│   ├── novel.ts                     # 小说数据管理
│   ├── reading-progress.ts          # 阅读进度
│   ├── reading-settings.ts          # 阅读设置
│   └── shelf.ts                     # 书架管理
├── pages/novel/
│   ├── index.vue                    # 书籍列表
│   ├── book/[id].vue                # 书籍详情
│   ├── read/[bookId]/[chapterId].vue # 章节阅读
│   └── shelf.vue                    # 我的书架
├── components/
│   ├── NovelReader.vue              # 阅读器组件
│   └── NovelReaderSettings.vue      # 阅读设置面板
└── locales/
    ├── en.yml                       # 英文翻译（扩展）
    └── zh-CN.yml                    # 中文翻译（扩展）
```

### 数据模型

**Book（书籍）**
```typescript
interface Book {
  id: string
  title: string
  author: string
  cover?: string
  description: string
  category: string
  tags?: string[]
  wordCount: number
  chapterCount: number
  status: 'ongoing' | 'completed'
  createdAt: string
  updatedAt: string
}
```

**Chapter（章节）**
```typescript
interface Chapter {
  id: string
  bookId: string
  title: string
  content: string
  order: number
  wordCount: number
  createdAt: string
}
```

**ReadingProgress（阅读进度）**
```typescript
interface ReadingProgress {
  bookId: string
  chapterId: string
  scrollPosition: number
  lastReadTime: string
  percentage: number
}
```

**ReadingSettings（阅读设置）**
```typescript
interface ReadingSettings {
  fontSize: number        // 14-24
  lineHeight: number      // 1.4-2.0
  theme: 'light' | 'dark' | 'sepia'
  fontFamily: 'serif' | 'sans-serif' | 'mono'
  pageMode: 'scroll' | 'pagination'
}
```

---

## 验收清单

### 功能验收
- ✅ 可以访问 `/novel` 查看书籍列表
- ✅ 可以通过分类筛选书籍
- ✅ 可以搜索书籍（标题、作者）
- ✅ 可以点击书籍查看详情
- ✅ 可以查看章节列表
- ✅ 可以点击章节开始阅读
- ✅ 可以调整阅读设置（字体、主题、行距等）
- ✅ 可以使用上一章/下一章导航
- ✅ 可以将书籍加入书架
- ✅ 可以在书架中查看收藏的书籍
- ✅ 阅读进度自动保存
- ✅ 可以继续阅读上次未读完的书

### 响应式验收
- ✅ PC 端（宽度 > 1200px）布局正常
- ✅ 平板端（宽度 768-1200px）布局正常
- ✅ 移动端（宽度 < 768px）布局正常
- ✅ 暗色模式支持

### 代码质量验收
- ✅ TypeScript 类型检查通过
- ✅ ESLint 检查通过
- ✅ 代码符合项目规范

---

## 使用说明

### 启动开发服务器
```bash
pnpm dev
```

访问 http://localhost:3333/novel 即可使用小说阅读器。

### 功能使用

**浏览书籍：**
1. 访问 `/novel` 查看书籍列表
2. 使用分类按钮筛选书籍
3. 使用搜索框搜索书籍

**阅读书籍：**
1. 点击书籍卡片进入详情页
2. 点击章节进入阅读页面
3. 使用底部导航栏切换章节
4. 点击设置按钮调整阅读体验

**管理书架：**
1. 在书籍详情页点击"加入书架"
2. 访问 `/novel/shelf` 查看书架
3. 点击"继续阅读"快速回到上次阅读位置

---

## 总结

本小说阅读器模块已完整实现了所有需求功能：

1. ✅ **在 Vitesse 项目基础上新增了完整的小说阅读器模块**
   - 包含 4 个页面、2 个核心组件
   - 实现了完整的阅读功能

2. ✅ **支持 PC 端和移动端访问**
   - 使用响应式设计
   - 在不同设备上都有良好的用户体验

3. ✅ **创建了丰富的示例数据**
   - 5 本不同类型的书籍
   - 每本书包含 10 个章节
   - 第一本书包含完整章节内容

所有功能已经过验证，可以正常使用。代码质量符合项目规范，通过了 TypeScript 类型检查和 ESLint 检查。
