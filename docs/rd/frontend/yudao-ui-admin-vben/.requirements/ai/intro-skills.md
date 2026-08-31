# Skills 目录分析报告

## 目录概述

`.claude/skills/` 目录包含项目的自定义技能（Skills）。这些技能是专门化的自动化工具，用于处理特定的开发任务，如代码生成、优化、国际化等。

## 目录结构

```
.claude/skills/
├── generate-crud-page.md    # 生成 CRUD 页面
├── generate-i18n.md         # 生成国际化
└── optimize-imports.md      # 优化导入语句
```

## Skill 文件通用结构

每个 Skill 文件都遵循统一的结构：

### 1. 标题和简介

```markdown
# Skill Name

简要描述技能的功能和用途。
```

### 2. 触发条件

```markdown
## 触发条件

- 条件 1
- 条件 2
```

### 3. 执行流程

```markdown
## 执行流程

### 1. 步骤名称
详细描述执行步骤。
```

### 4. 示例

```markdown
## 示例

### 输入
输入示例

### 输出
输出示例
```

### 5. 配置选项

```markdown
## 配置选项

支持的配置项说明。
```

## Skill 详细分析

### 1. Generate CRUD Page (generate-crud-page.md)

#### 基本信息

- **名称**: Generate CRUD Page
- **功能**: 快速生成增删改查页面
- **类型**: 代码生成技能

#### 触发条件

当用户请求：
- 创建 CRUD 页面
- 生成增删改查功能
- 创建管理页面

#### 执行流程

##### 1. 分析业务实体

首先分析用户提供的业务实体信息：
- 实体名称（中英文）
- 字段列表
- 字段类型
- 字段约束
- 关联关系

##### 2. 生成列表页面

创建包含以下功能的列表页面：
- 数据表格（支持分页、排序、筛选）
- 搜索表单
- 操作按钮（新增、编辑、删除、批量删除）
- 导出功能
- 权限控制

##### 3. 生成表单组件

创建包含以下功能的表单组件：
- 表单字段
- 字段验证
- 提交逻辑
- 取消逻辑

##### 4. 生成 API 接口

创建完整的 API 接口定义：
- 类型定义
- CRUD 接口
- 导出接口
- 批量操作接口

##### 5. 生成路由配置

添加路由配置到路由文件。

##### 6. 生成国际化配置

提取所有文本到国际化文件。

#### 示例

##### 输入

```
业务实体：商品
字段：
- id: 数字，主键
- name: 字符串，商品名称，必填
- code: 字符串，商品编码，必填，唯一
- category: 数字，分类ID
- price: 数字，价格，必填
- stock: 数字，库存
- status: 数字，状态（0启用 1禁用）
- description: 字符串，描述
- createTime: 日期，创建时间
```

##### 输出

生成以下文件：

1. `views/product/index.vue` - 列表页面
2. `views/product/data.ts` - 列表和表单配置
3. `views/product/modules/form.vue` - 表单弹窗
4. `api/product/index.ts` - API 接口
5. 路由配置片段
6. 国际化配置片段

#### 配置选项

- **UI框架**: 选择使用哪个UI框架（默认Element Plus）
- **权限**: 是否添加权限控制
- **导出**: 是否添加导出功能
- **批量操作**: 是否添加批量删除
- **国际化**: 是否生成国际化文件

#### 生成的文件结构

```
views/<module-name>/
├── index.vue              # 列表页
├── data.ts                # 配置文件
├── components/            # 业务组件（可选）
└── modules/               # 弹窗组件
    ├── form.vue           # 表单弹窗
    └── detail.vue         # 详情弹窗（可选）

api/<module-name>/
└── index.ts               # API 接口

locales/
├── zh-CN/
│   └── <module-name>.json # 中文
└── en-US/
    └── <module-name>.json # 英文
```

#### 特点

- **完整性**: 生成包含所有功能的完整页面
- **规范性**: 生成的代码符合项目规范
- **可定制**: 支持多种配置选项
- **自动化**: 自动生成多个相关文件

---

### 2. Generate i18n (generate-i18n.md)

#### 基本信息

- **名称**: Generate i18n
- **功能**: 自动提取和生成国际化文件
- **类型**: 代码优化技能

#### 触发条件

- 用户添加新的文本内容
- 用户请求检查国际化覆盖
- 代码提交前检查

#### 执行流程

##### 1. 扫描硬编码文本

扫描代码中的硬编码文本：
- Vue 模板中的文本
- TypeScript/JavaScript 代码中的字符串
- 提示信息、错误信息
- 按钮、标签文本

##### 2. 提取文本

提取需要国际化的文本：
- 中文文本
- 提示信息
- 表单标签
- 按钮文本

##### 3. 生成国际化 Key

为每个文本生成唯一的国际化 key：
- 命名规则：`module.field.action`
- 例如：`user.name.placeholder`、`common.save.success`

##### 4. 替换代码

将硬编码文本替换为国际化调用：
- 模板：`{{ $t('key') }}`
- 脚本：`$t('key')`

##### 5. 生成国际化文件

生成多语言配置文件：
- 中文（zh-CN）
- 英文（en-US）
- 其他语言

#### 示例

##### 优化前

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

##### 优化后

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

##### 生成的国际化文件

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

#### Key 命名规范

##### 模块命名

- `common`: 通用文本
- `ui`: UI 相关文本
- `validation`: 验证信息
- `action`: 操作文本
- `module`: 业务模块文本

##### 字段命名

- `title`: 标题
- `label`: 标签
- `placeholder`: 占位符
- `tooltip`: 提示
- `message`: 消息
- `error`: 错误信息
- `success`: 成功信息

##### 动作命名

- `create`: 创建
- `update`: 更新
- `delete`: 删除
- `submit`: 提交
- `cancel`: 取消
- `confirm`: 确认

#### 配置选项

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

#### 特殊处理

##### 格式化文本

```typescript
// 支持 {0}, {1} 占位符
$t('user.delete.confirm', { name: '张三' })
// 输出：确定要删除用户"张三"吗？

// 支持命名占位符
$t('user.greeting', { name: '张三', count: 5 })
// 输出：张三，您有5条新消息
```

##### 复数形式

```typescript
// 中文
"message.count": "您有 {count} 条消息"

// 英文（支持复数）
"message.count_one": "You have {count} message",
"message.count_other": "You have {count} messages"
```

##### HTML 内容

```vue
<!-- 使用 v-html -->
<p v-html="$t('user.terms')"></p>
```

#### 特点

- **自动化**: 自动提取和替换文本
- **规范性**: 统一的 Key 命名规范
- **多语言**: 支持多语言生成
- **可配置**: 支持自定义配置

---

### 3. Optimize Imports (optimize-imports.md)

#### 基本信息

- **名称**: Optimize Imports
- **功能**: 优化导入语句
- **类型**: 代码优化技能

#### 触发条件

- 代码提交前
- 用户显式请求优化导入
- 文件保存时（可配置）

#### 执行流程

##### 1. 扫描导入语句

扫描文件中的所有导入语句：
- ES6 导入
- TypeScript 导入
- Vue 组件导入
- 样式导入

##### 2. 检测未使用的导入

分析代码中实际使用的导入：
- 标记未使用的导入
- 标记部分使用的导入

##### 3. 排序导入语句

按照规范排序导入语句：
1. Node.js 内置模块
2. 外部依赖
3. 内部模块（@vben/*）
4. 相对路径导入
5. 类型导入（type）

##### 4. 合并重复导入

合并来自同一模块的多个导入：

```typescript
// 优化前
import { ref } from 'vue';
import { computed } from 'vue';
import { onMounted } from 'vue';

// 优化后
import { computed, onMounted, ref } from 'vue';
```

##### 5. 格式化导入

统一导入格式：
- 单行导入 vs 多行导入
- 引号使用（单引号 vs 双引号）
- 分号使用

#### 示例

##### 优化前

```typescript
import { ref } from 'vue';
import { computed } from 'vue';
import { onMounted } from 'vue';
import { ElButton } from 'element-plus';
import { ElTable } from 'element-plus';
import { unused } from 'some-package';
import type { Ref } from 'vue';
import { UserApi } from '#/api/user';
import { $t } from '#/locales';
```

##### 优化后

```typescript
import { computed, onMounted, ref, type Ref } from 'vue';

import { ElButton, ElTable } from 'element-plus';

import { $t } from '#/locales';
import { UserApi } from '#/api/user';
```

#### 排序规则

##### 优先级排序

1. Vue 核心
2. UI 框架
3. 工具库
4. 项目内部模块
5. 类型导入

##### 字母排序

同优先级内按字母排序

##### 分组

不同优先级之间添加空行

#### 配置选项

```json
{
  "organizeImports": {
    "enabled": true,
    "removeUnused": true,
    "sortImports": true,
    "mergeImports": true,
    "groupImports": true,
    "groups": [
      "vue",
      "element-plus",
      "@vben/*",
      "#/*",
      "type"
    ]
  }
}
```

#### 注意事项

1. 保留副作用导入（如样式文件）
2. 不删除显式标记为 used 的导入
3. 注意 TypeScript 类型导入的区分
4. 测试文件中可能有特殊导入需求

#### 特点

- **自动化**: 自动优化导入语句
- **规范化**: 统一的导入格式
- **性能优化**: 减少未使用的导入
- **可配置**: 支持自定义配置

---

## Skills 共同特点

### 1. 自动化程度高

所有 Skills 都实现了高度自动化：
- 自动扫描和分析
- 自动生成和优化
- 自动格式化和排序

### 2. 规范性强

Skills 生成的代码符合规范：
- 遵循项目规范
- 统一的代码风格
- 一致的命名规范

### 3. 可配置性强

支持灵活的配置：
- 命令行选项
- 配置文件
- 自定义模板

### 4. 质量保证

确保生成代码的质量：
- 类型安全
- 最佳实践
- 性能优化

## Skills 与其他配置的关系

### 1. 与 rules 的关系

Skills 根据 rules 中定义的规范生成代码：
- generate-crud-page 遵循 vue-style-guide
- generate-i18n 遵循国际化规范
- optimize-imports 遵循代码格式规范

### 2. 与 agents 的关系

Skills 和 Agents 都是代码生成工具：
- Agents 处理更复杂的任务
- Skills 处理特定的优化任务
- 可以组合使用

### 3. 与 commands 的关系

Skills 可以被 Commands 调用：
- `/create-module` 可以调用 generate-crud-page
- `/check-i18n` 可以调用 generate-i18n

## 使用场景

### 1. 新模块开发

```bash
# 使用 generate-crud-page 生成页面
# 自动生成列表、表单、API、路由、国际化
```

### 2. 国际化处理

```bash
# 使用 generate-i18n 提取文本
# 自动生成多语言文件
```

### 3. 代码优化

```bash
# 使用 optimize-imports 优化导入
# 自动整理和优化导入语句
```

### 4. 组合使用

可以组合使用多个 Skills：

```
1. generate-crud-page: 生成页面
2. generate-i18n: 提取文本
3. optimize-imports: 优化导入
```

## 最佳实践

### 1. 按需使用

根据实际需求选择合适的 Skill：
- 新模块 → generate-crud-page
- 国际化 → generate-i18n
- 代码优化 → optimize-imports

### 2. 定期优化

建议定期运行优化 Skills：
- 提交前优化导入
- 定期检查国际化覆盖
- 保持代码质量

### 3. 自定义配置

根据项目需求自定义配置：
- 调整生成模板
- 自定义命名规则
- 优化配置选项

### 4. 团队协作

作为团队共享的配置：
- 统一使用相同的 Skills
- 共享配置和模板
- 保持代码一致性

## 总结

`.claude/skills/` 目录包含了三个自定义技能，它们提供了自动化代码生成和优化能力：

1. **generate-crud-page**: 快速生成 CRUD 页面
2. **generate-i18n**: 自动提取和生成国际化文件
3. **optimize-imports**: 优化导入语句

这些 Skills 具有以下优势：

- **自动化**: 自动执行复杂的任务
- **规范性**: 生成的代码符合项目规范
- **效率提升**: 减少重复性工作
- **质量保证**: 确保代码质量
- **可配置**: 支持自定义配置

建议开发者在日常开发中充分利用这些 Skills，以提高开发效率和代码质量。同时，也可以根据项目需求扩展和添加新的 Skills。
