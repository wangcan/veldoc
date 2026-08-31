# /check-i18n

检查国际化覆盖情况的命令。

## 用法

```bash
/check-i18n [options]
```

## 选项

- `--fix`: 自动修复发现的问题
- `--report`: 生成详细报告
- `--output`: 报告输出路径，默认 `./i18n-report.md`
- `--exclude`: 排除的目录或文件，支持 glob 模式

## 示例

### 检查国际化覆盖

```bash
/check-i18n
```

输出：
```
国际化检查报告
================

硬编码文本: 15 处
未翻译文本: 3 处
缺失 Key: 5 个

详细列表：
- views/user/index.vue:15 - "用户管理" (硬编码)
- views/order/list.vue:23 - "订单列表" (硬编码)
- components/Form.vue:42 - "提交成功" (未翻译)

建议：
1. 将硬编码文本提取到国际化文件
2. 为缺失的 Key 添加翻译
3. 使用 $t() 函数包裹文本
```

### 生成详细报告

```bash
/check-i18n --report --output=./reports/i18n.md
```

### 自动修复问题

```bash
/check-i18n --fix
```

自动修复：
- 提取硬编码文本到国际化文件
- 替换代码中的硬编码为 $t() 调用
- 生成缺失的国际化 Key

### 排除特定文件

```bash
/check-i18n --exclude="**/*.test.vue,**/node_modules/**"
```

## 检查内容

### 1. 硬编码文本

检测代码中的硬编码中文文本：

```vue
<!-- 检测前 -->
<template>
  <div>
    <h3>用户管理</h3>
    <el-button @click="handleCreate">新增用户</el-button>
    <p>操作成功</p>
  </div>
</template>

<!-- 修复后 -->
<template>
  <div>
    <h3>{{ $t('user.management.title') }}</h3>
    <el-button @click="handleCreate">{{ $t('user.action.create') }}</el-button>
    <p>{{ $t('common.success') }}</p>
  </div>
</template>
```

### 2. 未翻译文本

检测国际化文件中未翻译的文本：

```json
// zh-CN/user.json
{
  "user": {
    "management": {
      "title": "用户管理"
    }
  }
}

// en-US/user.json
{
  "user": {
    "management": {
      "title": "user.management.title" // 未翻译
    }
  }
}
```

### 3. 缺失 Key

检测使用了但未定义的国际化 Key：

```vue
<template>
  <div>
    <!-- 使用了 user.list.title 但未定义 -->
    <h3>{{ $t('user.list.title') }}</h3>
  </div>
</template>
```

### 4. 冗余 Key

检测定义了但未使用的国际化 Key：

```json
{
  "user": {
    "old": {
      "feature": "旧功能" // 未使用，可删除
    }
  }
}
```

## 报告内容

### 统计信息

```
国际化统计
==========

总文本数: 200
已国际化: 180 (90%)
未国际化: 20 (10%)

语言覆盖:
- 中文 (zh-CN): 100%
- 英文 (en-US): 85%
- 日文 (ja-JP): 60%
```

### 详细列表

```
硬编码文本列表
==============

1. views/user/index.vue:15
   文本: "用户管理"
   建议 Key: user.management.title

2. views/order/list.vue:23
   文本: "订单列表"
   建议 Key: order.list.title

3. components/Form.vue:42
   文本: "提交成功"
   建议 Key: common.success
```

### 修复建议

```
修复建议
========

1. 提取硬编码文本
   文件: views/user/index.vue
   原文: "用户管理"
   建议: {{ $t('user.management.title') }}

2. 添加缺失翻译
   Key: user.management.title
   en-US: "User Management"

3. 删除冗余 Key
   Key: user.old.feature
   原因: 未使用
```

## 自动修复

### 提取文本

自动提取硬编码文本到国际化文件：

```json
// 生成的国际化文件
{
  "user": {
    "management": {
      "title": "用户管理"
    }
  }
}
```

### 替换代码

自动替换代码中的硬编码：

```diff
- <h3>用户管理</h3>
+ <h3>{{ $t('user.management.title') }}</h3>

- ElMessage.success('操作成功');
+ ElMessage.success($t('common.success'));
```

### 翻译文本

使用翻译 API 自动翻译：

```bash
/check-i18n --fix --translate --translator=google
```

## 配置选项

创建配置文件自定义检查规则：

```javascript
// .i18n-check.js
module.exports = {
  // 检查目录
  include: ['src/**/*.{vue,ts,tsx}'],

  // 排除目录
  exclude: ['node_modules', '**/*.test.*'],

  // 语言列表
  languages: ['zh-CN', 'en-US', 'ja-JP'],

  // 默认语言
  defaultLanguage: 'zh-CN',

  // Key 命名规则
  keyNaming: 'module.field.action',

  // 自动翻译配置
  autoTranslate: {
    enabled: true,
    translator: 'google', // google | baidu | deepl
    apiKey: process.env.TRANSLATE_API_KEY,
  },
};
```

## 持续集成

在 CI/CD 中使用：

```yaml
# .github/workflows/i18n-check.yml
name: I18n Check

on: [pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check i18n
        run: pnpm check-i18n --report
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: i18n-report
          path: i18n-report.md
```

## 最佳实践

1. **定期检查**: 定期运行检查，及时发现问题
2. **提交前检查**: 在 git hook 中集成检查
3. **团队协作**: 将报告分享给团队成员
4. **自动化修复**: 使用自动修复功能提高效率
5. **持续改进**: 根据报告持续改进国际化覆盖

---

此命令可帮助团队保持国际化的完整性和一致性，提升应用的国际化水平。
