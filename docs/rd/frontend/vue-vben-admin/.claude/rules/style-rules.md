# 样式编码规范

## CSS 命名规范

### BEM 命名法

```css
/* ✅ 推荐：BEM 命名 */
.user-profile { /* Block */ }
.user-profile__avatar { /* Element */ }
.user-profile--active { /* Modifier */ }

/* ❌ 不推荐：无语义命名 */
.container { }
.item1 { }
.red { }
```

### 命名约定

```css
/* ✅ 推荐：语义化命名 */
.header { }
.sidebar { }
.user-list { }
.submit-button { }

/* ❌ 不推荐：表现层命名 */
.red-text { }
.big-font { }
.margin-top-20 { }
```

## 选择器

### 避免深层嵌套

```css
/* ✅ 推荐：扁平化选择器 */
.user-card { }
.user-card-title { }
.user-card-content { }

/* ❌ 不推荐：深层嵌套 */
.user .card .header .title { }
.container .wrapper .content .item { }
```

### 避免通用选择器

```css
/* ✅ 推荐：具体选择器 */
.user-list > li { }
.card .title { }

/* ❌ 不推荐：通用选择器 */
* { margin: 0; }
.user-list * { }
```

## CSS 变量

### 使用 CSS 变量

```css
/* ✅ 推荐：定义变量 */
:root {
  --primary-color: #1890ff;
  --success-color: #52c41a;
  --warning-color: #faad14;
  --error-color: #f5222d;
  --text-color: #333;
  --border-radius: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
}

.user-card {
  background-color: var(--primary-color);
  padding: var(--spacing-md);
  border-radius: var(--border-radius);
}

/* ❌ 不推荐：硬编码值 */
.user-card {
  background-color: #1890ff;
  padding: 16px;
  border-radius: 4px;
}
```

### 响应式变量

```css
/* ✅ 推荐：响应式变量 */
:root {
  --container-width: 1200px;
}

@media (max-width: 768px) {
  :root {
    --container-width: 100%;
  }
}

.container {
  width: var(--container-width);
}
```

## 布局

### Flexbox 布局

```css
/* ✅ 推荐：使用 Flexbox */
.container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

/* ❌ 不推荐：传统布局 */
.container {
  overflow: hidden;
}

.item {
  float: left;
  margin-right: 16px;
}
```

### Grid 布局

```css
/* ✅ 推荐：使用 Grid */
.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

/* ❌ 不推荐：手动计算 */
.grid-container {
  overflow: hidden;
}

.grid-item {
  width: calc(25% - 12px);
  margin-right: 16px;
  margin-bottom: 16px;
}
```

## 响应式设计

### 移动优先

```css
/* ✅ 推荐：移动优先 */
.container {
  width: 100%;
  padding: 16px;
}

@media (min-width: 768px) {
  .container {
    width: 750px;
  }
}

@media (min-width: 1200px) {
  .container {
    width: 1170px;
  }
}
```

### 媒体查询

```css
/* ✅ 推荐：使用 CSS 变量 */
:root {
  --breakpoint-sm: 576px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 992px;
  --breakpoint-xl: 1200px;
}

@media (min-width: 768px) {
  /* 样式 */
}
```

## Tailwind CSS

### 工具类优先

```vue
<!-- ✅ 推荐：使用工具类 -->
<div class="flex items-center justify-between p-4 bg-white rounded-lg shadow-md">
  <span class="text-lg font-semibold text-gray-900">Title</span>
  <button class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
    Button
  </button>
</div>

<!-- ❌ 不推荐：自定义样式 -->
<div class="custom-container">
  <span class="custom-title">Title</span>
  <button class="custom-button">Button</button>
</div>

<style scoped>
.custom-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  /* ... */
}
</style>
```

### 提取组件类

```vue
<!-- ✅ 推荐：复杂样式提取组件类 -->
<button class="btn-primary">
  Submit
</button>

<style scoped>
.btn-primary {
  @apply px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors duration-200;
}
</style>
```

### 响应式前缀

```vue
<!-- ✅ 推荐：响应式前缀 -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <div class="p-4">Item 1</div>
  <div class="p-4">Item 2</div>
  <div class="p-4">Item 3</div>
</div>
```

## 样式组织

### 按功能分组

```css
/* ✅ 推荐：按功能分组 */
.user-card {
  /* 布局 */
  display: flex;
  flex-direction: column;
  gap: 16px;

  /* 盒模型 */
  width: 100%;
  padding: 16px;
  border-radius: 8px;

  /* 视觉 */
  background-color: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

  /* 排版 */
  font-size: 14px;
  line-height: 1.5;
  color: #333;
}
```

### 属性顺序

```css
/* ✅ 推荐：属性顺序 */
.element {
  /* 1. 定位 */
  position: relative;
  top: 0;
  left: 0;
  z-index: 1;

  /* 2. 盒模型 */
  display: flex;
  width: 100px;
  height: 100px;
  padding: 16px;
  margin: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;

  /* 3. 视觉 */
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  opacity: 1;

  /* 4. 排版 */
  font-size: 14px;
  line-height: 1.5;
  text-align: center;
  color: #333;

  /* 5. 动画 */
  transition: all 0.3s ease;
  animation: fadeIn 0.5s;

  /* 6. 其他 */
  cursor: pointer;
  user-select: none;
}
```

## 性能优化

### 避免昂贵属性

```css
/* ❌ 不推荐：昂贵属性 */
.element {
  box-shadow: 0 0 50px rgba(0, 0, 0, 0.5);
  filter: blur(10px);
  transform: translateZ(0);
}

/* ✅ 推荐：优化性能 */
.element {
  will-change: transform;
  transform: translateZ(0);
}
```

### 减少重绘

```css
/* ✅ 推荐：使用 transform 和 opacity */
.element {
  transition: transform 0.3s, opacity 0.3s;
}

.element:hover {
  transform: scale(1.1);
  opacity: 0.8;
}

/* ❌ 不推荐：触发重绘 */
.element {
  transition: width 0.3s, height 0.3s;
}

.element:hover {
  width: 200px;
  height: 200px;
}
```

## 可访问性

### 颜色对比度

```css
/* ✅ 推荐：足够对比度 */
.text {
  color: #333; /* 深色文字 */
  background-color: #fff; /* 浅色背景 */
}

/* ❌ 不推荐：对比度不足 */
.text {
  color: #999;
  background-color: #eee;
}
```

### 焦点样式

```css
/* ✅ 推荐：清晰的焦点样式 */
button:focus {
  outline: 2px solid #1890ff;
  outline-offset: 2px;
}

/* ❌ 不推荐：移除焦点样式 */
button:focus {
  outline: none;
}
```

## 最佳实践

1. **命名语义化**: 使用有意义的类名
2. **避免过度嵌套**: 保持选择器扁平
3. **使用 CSS 变量**: 统一管理样式
4. **移动优先**: 响应式设计
5. **工具类优先**: 使用 Tailwind CSS
6. **性能优化**: 避免昂贵属性
7. **可访问性**: 确保颜色对比度和焦点样式
8. **代码组织**: 按功能分组，遵循属性顺序
