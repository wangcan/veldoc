---
name: add-i18n
description: 添加新的国际化翻译键和语言支持
---

# 添加国际化支持

这个 skill 用于添加新的国际化翻译键和语言支持。

## 使用场景

当需要添加新的翻译或支持新语言时使用此 skill。

## 执行步骤

1. **确定翻译键**
   - 设计合理的键名层级结构
   - 确定需要翻译的文本

2. **更新所有语言文件**
   - 在所有现有的语言文件中添加翻译
   - 确保所有语言文件键名一致

3. **在组件中使用**
   - 使用 `useI18n()` 获取翻译函数
   - 使用 `t()` 函数进行翻译

## 翻译键设计原则

### 层级结构

使用层级结构组织翻译键：

```yaml
# 推荐
user:
  profile:
    title: 'User Profile'
    edit: 'Edit Profile'
    save: 'Save Changes'
  settings:
    title: 'Settings'
    language: 'Language'
    theme: 'Theme'
```

### 命名规范

- 使用点号分隔层级
- 键名使用 kebab-case
- 避免过深的嵌套（最多 3-4 层）
- 使用语义化的键名

### 常见前缀

- `button.*` - 按钮文本
- `label.*` - 标签文本
- `message.*` - 提示消息
- `error.*` - 错误消息
- `placeholder.*` - 占位符文本
- `title.*` - 标题文本

## 添加翻译键

### 示例：添加用户相关翻译

#### 1. 英文（en.yml）

```yaml
# locales/en.yml
user:
  profile:
    title: 'User Profile'
    edit: 'Edit Profile'
    save: 'Save Changes'
    cancel: 'Cancel'
  settings:
    title: 'Settings'
    language: 'Language'
    theme: 'Theme'
    dark_mode: 'Dark Mode'
    light_mode: 'Light Mode'
  messages:
    login_success: 'Login successful!'
    logout_success: 'Logout successful!'
    update_success: 'Profile updated successfully!'
    delete_confirm: 'Are you sure you want to delete this?'
```

#### 2. 中文（zh-CN.yml）

```yaml
# locales/zh-CN.yml
user:
  profile:
    title: '用户资料'
    edit: '编辑资料'
    save: '保存更改'
    cancel: '取消'
  settings:
    title: '设置'
    language: '语言'
    theme: '主题'
    dark_mode: '暗色模式'
    light_mode: '亮色模式'
  messages:
    login_success: '登录成功！'
    logout_success: '登出成功！'
    update_success: '资料更新成功！'
    delete_confirm: '确定要删除吗？'
```

#### 3. 其他语言

为所有支持的语言添加相同的键名和对应的翻译。

## 在组件中使用

### 基础使用

```vue
<script setup lang="ts">
const { t } = useI18n()
</script>

<template>
  <div>
    <h1>{{ t('user.profile.title') }}</h1>
    <button>{{ t('user.profile.save') }}</button>
  </div>
</template>
```

### 带参数的翻译

在 YAML 中定义占位符：

```yaml
greeting:
  hello: 'Hello, {name}!'
  items_count: 'You have {count} items'
```

在组件中使用：

```vue
<script setup lang="ts">
const { t } = useI18n()
const userName = 'John'
const itemCount = 5
</script>

<template>
  <p>{{ t('greeting.hello', { name: userName }) }}</p>
  <!-- 输出: Hello, John! -->
  
  <p>{{ t('greeting.items_count', { count: itemCount }) }}</p>
  <!-- 输出: You have 5 items -->
</template>
```

### 复数形式

```yaml
# locales/en.yml
items:
  zero: 'No items'
  one: 'One item'
  other: '{count} items'
```

```vue
<script setup lang="ts">
const { t } = useI18n()
const count = ref(0)
</script>

<template>
  <p>{{ t('items', count.value) }}</p>
</template>
```

### 在页面标题中使用

```vue
<script setup lang="ts">
const { t } = useI18n()

useHead({
  title: () => t('user.profile.title'),
})
</script>
```

## 添加新语言

### 1. 创建语言文件

在 `locales/` 目录下创建新的 YAML 文件：

```yaml
# locales/fr-FR.yml
intro:
  desc: 'Modèle de démarrage Vite obstiné'
  whats-your-name: 'Quel est votre nom ?'
button:
  about: 'À propos'
  back: 'Retour'
  go: 'ALLER'
  home: 'Accueil'
  toggle_dark: 'Basculer en mode sombre'
  toggle_langs: 'Changer de langue'
not-found: 'Non trouvé'

# 添加新的翻译键
user:
  profile:
    title: 'Profil utilisateur'
    edit: 'Modifier le profil'
    save: 'Enregistrer'
```

### 2. 注册新语言

在 `src/modules/i18n.ts` 中注册：

```typescript
import type { UserModule } from '~/types'
import messagesEn from '../../locales/en.yml'
import messagesZhCN from '../../locales/zh-CN.yml'
import messagesFrFR from '../../locales/fr-FR.yml' // 新增

export const install: UserModule = ({ app }) => {
  const i18n = createI18n({
    legacy: false,
    locale: 'en',
    fallbackLocale: 'en',
    messages: {
      en: messagesEn,
      'zh-CN': messagesZhCN,
      'fr-FR': messagesFrFR, // 新增
    },
  })
  
  app.use(i18n)
}
```

### 3. 创建语言切换功能

```vue
<script setup lang="ts">
const { locale, availableLocales } = useI18n()

const languageNames: Record<string, string> = {
  en: 'English',
  'zh-CN': '简体中文',
  'fr-FR': 'Français',
}

function changeLanguage(lang: string) {
  locale.value = lang
  // 持久化到 localStorage
  localStorage.setItem('language', lang)
}

// 初始化时恢复语言
onMounted(() => {
  const savedLanguage = localStorage.getItem('language')
  if (savedLanguage && availableLocales.includes(savedLanguage)) {
    locale.value = savedLanguage
  }
})
</script>

<template>
  <select
    v-model="locale"
    class="px-3 py-1 border rounded"
    @change="changeLanguage(locale)"
  >
    <option
      v-for="lang in availableLocales"
      :key="lang"
      :value="lang"
    >
      {{ languageNames[lang] || lang }}
    </option>
  </select>
</template>
```

## 组织翻译文件

### 按模块拆分（可选）

对于大型项目，可以按模块拆分翻译文件：

```
locales/
├── en/
│   ├── common.yml
│   ├── user.yml
│   └── admin.yml
├── zh-CN/
│   ├── common.yml
│   ├── user.yml
│   └── admin.yml
```

合并到主文件：

```typescript
// src/modules/i18n.ts
import commonEn from '../../locales/en/common.yml'
import userEn from '../../locales/en/user.yml'
import adminEn from '../../locales/en/admin.yml'

const messagesEn = {
  ...commonEn,
  ...userEn,
  ...adminEn,
}
```

## TypeScript 支持

### 添加类型定义

```typescript
// src/types/i18n.d.ts
export interface MessageSchema {
  user: {
    profile: {
      title: string
      edit: string
      save: string
      cancel: string
    }
    settings: {
      title: string
      language: string
      theme: string
      dark_mode: string
      light_mode: string
    }
    messages: {
      login_success: string
      logout_success: string
      update_success: string
      delete_confirm: string
    }
  }
}

declare module 'vue-i18n' {
  export interface DefineLocaleMessage extends MessageSchema {}
}
```

### 类型安全的翻译

```vue
<script setup lang="ts">
const { t } = useI18n()

// ✅ 类型安全
t('user.profile.title')

// ❌ 类型错误
t('user.profile.nonexistent')
</script>
```

## 最佳实践

1. **统一键名**: 所有语言文件使用相同的键名结构
2. **完整翻译**: 确保所有语言文件包含所有翻译键
3. **避免硬编码**: 不在代码中硬编码文本
4. **参数化**: 使用占位符而非字符串拼接
5. **语义化键名**: 使用描述性的键名而非通用名称
6. **层级组织**: 使用合理的层级结构
7. **复用翻译**: 避免重复定义相似的翻译

## 常见问题

### 1. 缺失翻译

确保所有语言文件包含相同的键：

```yaml
# ❌ 错误：部分语言缺失翻译
# en.yml
user.name: 'Name'

# zh-CN.yml
# 缺失 user.name

# ✅ 正确：所有语言都有翻译
# en.yml
user.name: 'Name'

# zh-CN.yml
user.name: '姓名'
```

### 2. 占位符不工作

确保使用正确的语法：

```vue
<!-- ❌ 错误 -->
<p>{{ t('greeting.hello') }}, {{ userName }}</p>

<!-- ✅ 正确 -->
<p>{{ t('greeting.hello', { name: userName }) }}</p>
```

### 3. 复数形式不正确

检查语言文件的复数规则：

```yaml
# 正确的复数形式
apple: 'apple | apples'
# 或使用 'one' 和 'other'
apple:
  one: 'apple'
  other: 'apples'
```

## 工具推荐

### VS Code 插件

- **i18n Ally**: 强大的 i18n VS Code 插件
  - 内联显示翻译文本
  - 自动补全翻译键
  - 批量编辑翻译
  - 检测缺失翻译

### 在线翻译工具

- **DeepL**: 高质量机器翻译
- **Google Translate**: 广泛支持的翻译服务
- **Crowdin**: 协作翻译平台

## 注意事项

1. 翻译文件放在 `locales/` 目录
2. 使用 YAML 格式
3. 所有语言文件保持键名一致
4. 使用 `useI18n()` 获取翻译函数
5. 避免在代码中硬编码文本
6. 遵循翻译键命名规范
7. 为组件级翻译使用命名空间
