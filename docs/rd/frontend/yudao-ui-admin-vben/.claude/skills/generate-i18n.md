# Generate i18n Skill

自动提取和生成国际化文件的技能。

## 触发条件

- 用户添加新的文本内容
- 用户请求检查国际化覆盖
- 代码提交前检查

## 执行流程

### 1. 扫描硬编码文本

扫描代码中的硬编码文本：
- Vue 模板中的文本
- TypeScript/JavaScript 代码中的字符串
- 提示信息、错误信息
- 按钮、标签文本

### 2. 提取文本

提取需要国际化的文本：
- 中文文本
- 提示信息
- 表单标签
- 按钮文本

### 3. 生成国际化 Key

为每个文本生成唯一的国际化 key：
- 命名规则：`module.field.action`
- 例如：`user.name.placeholder`、`common.save.success`

### 4. 替换代码

将硬编码文本替换为国际化调用：
- 模板：`{{ $t('key') }}`
- 脚本：`$t('key')`

### 5. 生成国际化文件

生成多语言配置文件：
- 中文（zh-CN）
- 英文（en-US）
- 其他语言

## 示例

### 优化前

```vue
<template>
  <div>
    <h3>用户管理</h3>
    <el-button @click="handleCreate">新增用户</el-button>
    <el-input placeholder="请输入用户名" />
    <p v-if="error">操作失败，请重试</p>
  </div>
</template>

<script setup lang="ts">
import { ElMessage } from 'element-plus';

function handleCreate() {
  ElMessage.success('创建成功');
}
</script>
```

### 优化后

```vue
<template>
  <div>
    <h3>{{ $t('user.management.title') }}</h3>
    <el-button @click="handleCreate">
      {{ $t('user.action.create') }}
    </el-button>
    <el-input :placeholder="$t('user.name.placeholder')" />
    <p v-if="error">{{ $t('common.error.retry') }}</p>
  </div>
</template>

<script setup lang="ts">
import { $t } from '#/locales';
import { ElMessage } from 'element-plus';

function handleCreate() {
  ElMessage.success($t('user.create.success'));
}
</script>
```

### 生成的国际化文件

```typescript
// locales/zh-CN/user.json
{
  "user": {
    "management": {
      "title": "用户管理"
    },
    "action": {
      "create": "新增用户"
    },
    "name": {
      "placeholder": "请输入用户名"
    },
    "create": {
      "success": "创建成功"
    }
  }
}

// locales/en-US/user.json
{
  "user": {
    "management": {
      "title": "User Management"
    },
    "action": {
      "create": "Create User"
    },
    "name": {
      "placeholder": "Please enter username"
    },
    "create": {
      "success": "Created successfully"
    }
  }
}
```

## Key 命名规范

### 模块命名

- `common`: 通用文本
- `ui`: UI 相关文本
- `validation`: 验证信息
- `action`: 操作文本
- `module`: 业务模块文本

### 字段命名

- `title`: 标题
- `label`: 标签
- `placeholder`: 占位符
- `tooltip`: 提示
- `message`: 消息
- `error`: 错误信息
- `success`: 成功信息

### 动作命名

- `create`: 创建
- `update`: 更新
- `delete`: 删除
- `submit`: 提交
- `cancel`: 取消
- `confirm`: 确认

## 配置选项

```json
{
  "i18n": {
    "enabled": true,
    "defaultLanguage": "zh-CN",
    "languages": ["zh-CN", "en-US"],
    "keyNaming": "module.field.action",
    "extractOnSave": false,
    "autoTranslate": true
  }
}
```

## 特殊处理

### 格式化文本

```typescript
// 支持 {0}, {1} 占位符
$t('user.delete.confirm', { name: '张三' })
// 输出：确定要删除用户"张三"吗？

// 支持命名占位符
$t('user.greeting', { name: '张三', count: 5 })
// 输出：张三，您有5条新消息
```

### 复数形式

```typescript
// 中文
"message.count": "您有 {count} 条消息"

// 英文（支持复数）
"message.count_one": "You have {count} message",
"message.count_other": "You have {count} messages"
```

### HTML 内容

```vue
<!-- 使用 v-html -->
<p v-html="$t('user.terms')"></p>
```

## 注意事项

1. 不要提取代码逻辑中的变量
2. 保留专有名词和技术术语
3. 注意上下文差异（同一词不同含义）
4. 确保翻译准确性和一致性
5. 定期审查和更新翻译

---

使用此技能可自动完成国际化工作，提升应用的国际化水平。
