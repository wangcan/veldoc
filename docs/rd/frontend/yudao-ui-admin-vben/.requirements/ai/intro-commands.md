# Commands 目录分析报告

## 目录概述

`.claude/commands/` 目录包含项目的自定义斜杠命令（Slash Commands）。这些命令提供了快速执行常见开发任务的能力，通过简短的命令即可触发复杂的操作流程。

## 目录结构

```
.claude/commands/
├── check-i18n.md      # 检查国际化覆盖
├── create-module.md   # 创建业务模块
└── generate-api.md    # 从 Swagger 生成 API
```

## Command 通用结构

每个 Command 文件都遵循统一的结构：

### 1. 命令头部

```markdown
# /command-name

简短的命令描述。
```

### 2. 用法说明

```markdown
## 用法

```bash
/command-name <参数> [选项]
```
```

### 3. 参数说明

```markdown
## 参数

- `参数名`: 参数描述
```

### 4. 选项说明

```markdown
## 选项

- `--option`: 选项描述，默认值
```

### 5. 使用示例

```markdown
## 示例

### 示例标题

```bash
/command-name example
```
```

### 6. 详细说明

- 执行流程
- 生成内容
- 配置选项
- 注意事项

## Command 详细分析

### 1. check-i18n (check-i18n.md)

#### 基本信息

- **命令**: `/check-i18n`
- **功能**: 检查国际化覆盖情况
- **类型**: 质量检查命令

#### 用法

```bash
/check-i18n [options]
```

#### 选项

- `--fix`: 自动修复发现的问题
- `--report`: 生成详细报告
- `--output`: 报告输出路径，默认 `./i18n-report.md`
- `--exclude`: 排除的目录或文件，支持 glob 模式

#### 功能特性

##### 检查内容

1. **硬编码文本检测**
   - 扫描代码中的硬编码中文文本
   - 标记需要国际化的文本
   - 提供修复建议

2. **未翻译文本检测**
   - 检测国际化文件中未翻译的文本
   - 对比不同语言的覆盖情况
   - 标记缺失的翻译

3. **缺失 Key 检测**
   - 检测使用了但未定义的国际化 Key
   - 标记引用错误
   - 提供修复建议

4. **冗余 Key 检测**
   - 检测定义了但未使用的国际化 Key
   - 清理无效配置
   - 优化国际化文件

#### 示例

##### 基本检查

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

建议：
1. 将硬编码文本提取到国际化文件
2. 为缺失的 Key 添加翻译
```

##### 生成报告

```bash
/check-i18n --report --output=./reports/i18n.md
```

##### 自动修复

```bash
/check-i18n --fix
```

自动执行：
- 提取硬编码文本到国际化文件
- 替换代码中的硬编码为 $t() 调用
- 生成缺失的国际化 Key

#### 检测示例

##### 硬编码检测

**检测前**:
```vue
<template>
  <div>
    <h3>用户管理</h3>
    <el-button @click="handleCreate">新增用户</el-button>
  </div>
</template>
```

**修复后**:
```vue
<template>
  <div>
    <h3>{{ $t('user.management.title') }}</h3>
    <el-button @click="handleCreate">{{ $t('user.action.create') }}</el-button>
  </div>
</template>
```

#### 配置选项

支持配置文件 `.i18n-check.js`:

```javascript
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
    translator: 'google',
    apiKey: process.env.TRANSLATE_API_KEY,
  },
};
```

#### 持续集成

支持在 CI/CD 中使用：

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
```

#### 特点

- **全面检测**: 覆盖所有国际化问题
- **自动修复**: 支持自动修复问题
- **报告详细**: 提供详细的检查报告
- **CI 支持**: 支持持续集成

---

### 2. create-module (create-module.md)

#### 基本信息

- **命令**: `/create-module`
- **功能**: 快速创建业务模块
- **类型**: 代码生成命令

#### 用法

```bash
/create-module <module-name> [options]
```

#### 参数

- `module-name`: 模块名称（必填），使用 kebab-case（如 user-management）

#### 选项

- `--type`: 模块类型（crud|form|detail），默认 crud
- `--app`: 目标应用（web-antd|web-ele|web-naive|web-tdesign），默认 web-ele
- `--with-api`: 是否生成 API 文件，默认 true
- `--with-route`: 是否生成路由配置，默认 true
- `--with-i18n`: 是否生成国际化文件，默认 true

#### 示例

##### 创建基本 CRUD 模块

```bash
/create-module product
```

生成文件：
- `views/product/index.vue` - 列表页面
- `views/product/data.ts` - 列表和表单配置
- `views/product/modules/form.vue` - 表单弹窗
- `api/product/index.ts` - API 接口
- 路由配置片段
- 国际化配置片段

##### 创建表单模块

```bash
/create-module feedback --type=form
```

##### 为不同应用创建模块

```bash
/create-module order --app=web-antd
```

##### 仅创建视图文件

```bash
/create-module report --with-api=false --with-route=false
```

#### 交互流程

执行命令后会询问：

1. **模块中文名称**: 如"商品管理"
2. **业务实体字段**: 如 id, name, code, status
3. **功能需求**:
   - 是否需要搜索
   - 是否需要导入导出
   - 是否需要批量操作
4. **权限配置**:
   - 模块权限标识
   - 操作权限列表

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

#### 配置模板

使用预定义的模板，遵循项目规范：

- Vue 3 Composition API
- TypeScript 类型定义
- Element Plus UI 组件
- VxeTable 表格组件
- VeeValidate + Zod 表单验证

#### 后续操作

创建模块后需要：

1. **添加路由**: 将生成的路由配置添加到路由文件
2. **添加菜单**: 在系统管理中添加菜单项
3. **配置权限**: 配置角色权限
4. **调整字段**: 根据实际需求调整字段定义

#### 特点

- **快速生成**: 一键生成完整模块
- **规范统一**: 生成的代码符合项目规范
- **可定制**: 支持多种配置选项
- **交互友好**: 提供清晰的交互流程

---

### 3. generate-api (generate-api.md)

#### 基本信息

- **命令**: `/generate-api`
- **功能**: 从 Swagger 文档生成 API 代码
- **类型**: 代码生成命令

#### 用法

```bash
/generate-api <swagger-url|swagger-file> [options]
```

#### 参数

- `swagger-url|swagger-file`: Swagger 文档 URL 或本地文件路径（必填）

#### 选项

- `--output`: 输出目录，默认 `src/api`
- `--module`: 模块名称，自动从 Swagger 解析
- `--typescript`: 是否生成 TypeScript 类型，默认 true
- `--axios`: 是否生成 axios 请求代码，默认 true
- `--format`: 是否格式化代码，默认 true

#### 示例

##### 从 URL 生成

```bash
/generate-api https://api.example.com/swagger.json
```

##### 从本地文件生成

```bash
/generate-api ./swagger.json
```

##### 指定输出目录

```bash
/generate-api https://api.example.com/swagger.json --output=src/api/v2
```

##### 仅生成类型定义

```bash
/generate-api ./swagger.json --axios=false
```

#### 生成内容

##### 1. 类型定义

根据 Swagger schema 生成 TypeScript 类型：

```typescript
// api/user/model.ts
export namespace UserApi {
  export interface UserInfo {
    /** 用户ID */
    id: number;
    /** 用户名 */
    username: string;
    /** 邮箱 */
    email: string;
    /** 状态：0-禁用 1-启用 */
    status: number;
    /** 创建时间 */
    createTime: string;
  }

  export interface PageParams {
    /** 页码 */
    pageNo: number;
    /** 每页数量 */
    pageSize: number;
    /** 用户名 */
    username?: string;
  }

  export interface PageResult {
    list: UserInfo[];
    total: number;
  }
}
```

##### 2. API 函数

根据 Swagger paths 生成 API 函数：

```typescript
// api/user/index.ts
import { requestClient } from '#/api/request';
import type * as Model from './model';

/**
 * 获取用户分页列表
 */
export function getUserPage(params: Model.UserApi.PageParams) {
  return requestClient.get<Model.UserApi.PageResult>('/system/user/page', { params });
}

/**
 * 获取用户详情
 */
export function getUserById(id: number) {
  return requestClient.get<Model.UserApi.UserInfo>(`/system/user/${id}`);
}

/**
 * 创建用户
 */
export function createUser(data: Model.UserApi.UserInfo) {
  return requestClient.post<Model.UserApi.UserInfo>('/system/user', data);
}
```

##### 3. 枚举定义

根据 Swagger enum 生成枚举或常量：

```typescript
// api/user/model.ts
export enum UserStatus {
  /** 禁用 */
  Disabled = 0,
  /** 启用 */
  Enabled = 1,
}

export const USER_STATUS_OPTIONS = [
  { label: '禁用', value: UserStatus.Disabled },
  { label: '启用', value: UserStatus.Enabled },
];
```

#### Swagger 规范要求

##### Tags 分组

```json
{
  "tags": [
    { "name": "user", "description": "用户管理" },
    { "name": "order", "description": "订单管理" }
  ]
}
```

##### 描述信息

```json
{
  "paths": {
    "/user/{id}": {
      "get": {
        "summary": "获取用户详情",
        "description": "根据用户ID获取用户详细信息",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "用户ID",
            "required": true,
            "schema": { "type": "integer" }
          }
        ]
      }
    }
  }
}
```

##### Schema 定义

```json
{
  "components": {
    "schemas": {
      "UserInfo": {
        "type": "object",
        "properties": {
          "id": { "type": "integer", "description": "用户ID" },
          "username": { "type": "string", "description": "用户名" }
        }
      }
    }
  }
}
```

#### 生成规则

##### 命名转换

- **URL**: `/system/user/get-page` → `getUserPage`
- **Type**: `UserInfo` → `UserInfo`（保持原样）
- **Property**: `user_name` → `userName`（camelCase）

##### 类型映射

| Swagger Type | TypeScript Type |
|--------------|----------------|
| string | string |
| integer | number |
| number | number |
| boolean | boolean |
| array | T[] |
| object | Record<string, any> |
| date-time | string |
| file | File |

##### 路径处理

- **GET**: 使用 params 传递参数
- **POST/PUT**: 使用 data 传递参数
- **DELETE**: 单个用路径参数，批量用 data
- **文件上传**: 使用 FormData

#### 自定义配置

创建配置文件 `.api-generator.js`:

```javascript
module.exports = {
  // 输出目录
  output: 'src/api',
  
  // 类型映射
  typeMap: {
    'date-time': 'Date',
    'file': 'File',
  },
  
  // 命名转换
  naming: {
    operationId: (id) => camelCase(id),
    schema: (name) => pascalCase(name),
  },
  
  // 模板自定义
  templates: {
    api: './templates/api.ts.ejs',
    model: './templates/model.ts.ejs',
  },
};
```

#### 后续操作

生成代码后需要：

1. **检查类型**: 验证生成的类型是否正确
2. **调整接口**: 根据实际需求调整接口参数
3. **添加注释**: 为复杂的接口添加使用说明
4. **测试接口**: 测试生成的接口是否正常工作

#### 特点

- **自动化**: 自动从 Swagger 生成代码
- **类型安全**: 生成完整的 TypeScript 类型
- **规范统一**: 遵循项目 API 规范
- **可定制**: 支持自定义配置和模板

---

## Commands 共同特点

### 1. 提高效率

- 快速执行常见任务
- 减少重复性工作
- 自动化代码生成

### 2. 规范统一

- 生成的代码符合项目规范
- 统一的代码风格
- 一致的目录结构

### 3. 质量保证

- 自动检查代码质量
- 发现潜在问题
- 提供修复建议

### 4. 可配置

- 支持命令行选项
- 支持配置文件
- 支持自定义模板

## 使用场景

### 1. 新项目初始化

```bash
# 创建新模块
/create-module user

# 从 Swagger 生成 API
/generate-api https://api.example.com/swagger.json

# 检查国际化
/check-i18n --fix
```

### 2. 日常开发

```bash
# 创建新模块
/create-module product

# 检查并修复国际化问题
/check-i18n --fix
```

### 3. 代码维护

```bash
# 检查国际化覆盖
/check-i18n --report

# 更新 API 定义
/generate-api https://api.example.com/swagger.json
```

## 最佳实践

### 1. 命令组合

可以组合使用多个命令：

```bash
# 创建模块并生成 API
/create-module user
/generate-api https://api.example.com/swagger.json

# 创建模块并检查国际化
/create-module product
/check-i18n --fix
```

### 2. CI/CD 集成

在持续集成中使用命令：

```yaml
- name: Check i18n
  run: pnpm check-i18n --report

- name: Generate API
  run: pnpm generate-api ${{ env.SWAGGER_URL }}
```

### 3. 定期执行

建议定期执行检查命令：

- 每次提交前检查国际化
- 定期更新 API 定义
- 生成报告审查代码质量

## 总结

`.claude/commands/` 目录包含了三个自定义斜杠命令，它们提供了快速执行常见开发任务的能力：

1. **check-i18n**: 检查和修复国际化问题
2. **create-module**: 快速创建业务模块
3. **generate-api**: 从 Swagger 生成 API 代码

这些 Command 具有以下优势：

- **效率提升**: 快速执行复杂任务
- **规范保证**: 生成的代码符合项目规范
- **质量保证**: 自动检查和修复问题
- **易于使用**: 简单的命令语法
- **可配置**: 支持多种选项和配置

建议开发者在日常开发中充分利用这些命令，以提高开发效率和代码质量。同时，也可以根据项目需求添加新的自定义命令。
