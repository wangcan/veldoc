# 响应式设计规范

## 设计原则

### 移动优先

默认样式针对移动端，使用断点逐步增强桌面端体验。

```vue
<template>
  <div class="p-4 md:p-6 lg:p-8">
    <!-- 移动端: p-4 -->
    <!-- 平板: p-6 (≥768px) -->
    <!-- 桌面: p-8 (≥1024px) -->
  </div>
</template>
```

### 断点系统

UnoCSS 默认断点（与 Tailwind CSS 一致）：

| 断点 | 最小宽度 | 典型设备 |
|------|---------|---------|
| `sm` | 640px | 大手机/小平板 |
| `md` | 768px | 平板竖屏 |
| `lg` | 1024px | 平板横屏/笔记本 |
| `xl` | 1280px | 桌面显示器 |
| `2xl` | 1536px | 大屏显示器 |

## 布局模式

### 弹性布局

```vue
<template>
  <!-- 水平堆叠 -> 水平排列 -->
  <div class="flex flex-col md:flex-row gap-4">
    <div class="flex-1">内容 A</div>
    <div class="flex-1">内容 B</div>
  </div>
</template>
```

### 网格布局

```vue
<template>
  <!-- 单列 -> 双列 -> 三列 -->
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
    <div>卡片 1</div>
    <div>卡片 2</div>
    <div>卡片 3</div>
  </div>
</template>
```

### 容器宽度

```vue
<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- 响应式容器 -->
    <!-- 最大宽度: 1280px -->
    <!-- 水平居中 -->
    <!-- 响应式内边距 -->
  </div>
</template>
```

## 字体大小

### 响应式排版

```vue
<template>
  <!-- 标题 -->
  <h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold">
    响应式标题
  </h1>
  
  <!-- 正文 -->
  <p class="text-base sm:text-lg leading-relaxed">
    响应式正文内容
  </p>
</template>
```

### 推荐字号

| 元素 | 移动端 | 桌面端 |
|------|--------|--------|
| H1 | text-2xl (24px) | text-4xl (36px) |
| H2 | text-xl (20px) | text-3xl (30px) |
| H3 | text-lg (18px) | text-2xl (24px) |
| 正文 | text-base (16px) | text-lg (18px) |
| 小字 | text-sm (14px) | text-base (16px) |

## 间距系统

### 响应式间距

```vue
<template>
  <!-- 区块间距 -->
  <section class="py-8 md:py-12 lg:py-16">
    <!-- 内容 -->
  </section>
  
  <!-- 卡片间距 -->
  <div class="gap-4 md:gap-6 lg:gap-8">
    <!-- 卡片 -->
  </div>
</template>
```

## 图片处理

### 响应式图片

```vue
<template>
  <!-- 固定比例 -->
  <div class="aspect-video">
    <img 
      src="/image.jpg" 
      alt="描述"
      class="w-full h-full object-cover"
    >
  </div>
  
  <!-- 响应式尺寸 -->
  <img 
    src="/image.jpg" 
    alt="描述"
    class="w-full max-w-md lg:max-w-lg mx-auto"
  >
</template>
```

### 图片网格

```vue
<template>
  <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2 md:gap-4">
    <div v-for="image in images" :key="image.id" class="aspect-square">
      <img :src="image.url" alt="" class="w-full h-full object-cover">
    </div>
  </div>
</template>
```

## 导航设计

### 移动端导航

```vue
<template>
  <!-- 移动端: 汉堡菜单 -->
  <!-- 桌面端: 水平导航 -->
  <nav>
    <!-- 移动端菜单按钮 -->
    <button class="md:hidden" @click="toggleMenu">
      <MenuIcon />
    </button>
    
    <!-- 导航链接 -->
    <ul class="hidden md:flex gap-6">
      <li><a href="/">首页</a></li>
      <li><a href="/gallery">画廊</a></li>
      <li><a href="/books">阅读</a></li>
    </ul>
    
    <!-- 移动端菜单 -->
    <div v-show="isMenuOpen" class="md:hidden fixed inset-0 bg-white z-50">
      <!-- 移动端菜单内容 -->
    </div>
  </nav>
</template>
```

## 表单设计

### 移动端友好表单

```vue
<template>
  <form class="space-y-4">
    <!-- 输入框 -->
    <div>
      <label class="block text-sm font-medium mb-1">用户名</label>
      <input 
        type="text"
        class="w-full px-4 py-3 text-base border rounded-lg"
        placeholder="请输入用户名"
      >
    </div>
    
    <!-- 按钮 - 触摸友好 -->
    <button 
      type="submit"
      class="w-full md:w-auto px-6 py-3 text-base btn"
    >
      提交
    </button>
  </form>
</template>
```

### 触摸友好尺寸

- 最小点击区域: 44×44px
- 按钮最小高度: 44px (py-3)
- 输入框最小高度: 44px
- 链接最小间距: 8px

## 表格响应式

### 卡片视图转表格

```vue
<template>
  <!-- 移动端: 卡片列表 -->
  <div class="md:hidden space-y-4">
    <div v-for="item in items" :key="item.id" class="p-4 border rounded-lg">
      <div class="font-bold">{{ item.name }}</div>
      <div class="text-sm text-gray-500">{{ item.value }}</div>
    </div>
  </div>
  
  <!-- 桌面端: 表格 -->
  <table class="hidden md:table w-full">
    <thead>
      <tr>
        <th>名称</th>
        <th>值</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="item in items" :key="item.id">
        <td>{{ item.name }}</td>
        <td>{{ item.value }}</td>
      </tr>
    </tbody>
  </table>
</template>
```

## 阅读模块设计

### 阅读器响应式布局

```vue
<template>
  <div class="reading-container max-w-4xl mx-auto px-4 py-8">
    <!-- 章节标题 -->
    <h1 class="text-xl sm:text-2xl font-bold mb-6">{{ chapter.title }}</h1>
    
    <!-- 阅读内容 -->
    <article class="prose prose-sm sm:prose lg:prose-lg max-w-none">
      <!-- 内容 -->
    </article>
    
    <!-- 翻页按钮 -->
    <div class="flex justify-between mt-8 gap-4">
      <button class="flex-1 py-3 btn">上一章</button>
      <button class="flex-1 py-3 btn">下一章</button>
    </div>
  </div>
</template>
```

## 测试清单

响应式设计测试要点：

- [ ] 320px - 小屏手机
- [ ] 375px - 标准手机
- [ ] 768px - 平板竖屏
- [ ] 1024px - 平板横屏/笔记本
- [ ] 1280px - 桌面显示器
- [ ] 1920px - 大屏显示器

测试内容：
- [ ] 导航是否正常显示
- [ ] 图片是否正确加载
- [ ] 表单是否可用
- [ ] 按钮是否可点击
- [ ] 文字是否可读
- [ ] 交互是否流畅
