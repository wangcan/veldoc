# /create-module

快速创建业务模块的命令。

## 用法

```bash
/create-module <module-name> [options]
```

## 参数

- `module-name`: 模块名称（必填），使用 kebab-case（如 user-management）

## 选项

- `--type`: 模块类型（crud|form|detail），默认 crud
- `--app`: 目标应用（web-antd|web-ele|web-naive|web-tdesign），默认 web-ele
- `--with-api`: 是否生成 API 文件，默认 true
- `--with-route`: 是否生成路由配置，默认 true
- `--with-i18n`: 是否生成国际化文件，默认 true

## 示例

### 创建基本 CRUD 模块

```bash
/create-module product
```

这将创建：
- `views/product/index.vue` - 列表页面
- `views/product/data.ts` - 列表和表单配置
- `views/product/modules/form.vue` - 表单弹窗
- `api/product/index.ts` - API 接口
- 路由配置片段
- 国际化配置片段

### 创建表单模块

```bash
/create-module feedback --type=form
```

### 为不同应用创建模块

```bash
/create-module order --app=web-antd
```

### 仅创建视图文件

```bash
/create-module report --with-api=false --with-route=false
```

## 交互流程

执行命令后，会询问以下信息：

1. **模块中文名称**: 如"商品管理"
2. **业务实体字段**: 如 id, name, code, status
3. **功能需求**:
   - 是否需要搜索
   - 是否需要导入导出
   - 是否需要批量操作
4. **权限配置**:
   - 模块权限标识
   - 操作权限列表

## 生成的文件结构

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

## 配置模板

命令使用预定义的模板，遵循项目规范：

- Vue 3 Composition API
- TypeScript 类型定义
- Element Plus UI 组件
- VxeTable 表格组件
- VeeValidate + Zod 表单验证

## 后续操作

创建模块后，需要：

1. **添加路由**: 将生成的路由配置添加到路由文件
2. **添加菜单**: 在系统管理中添加菜单项
3. **配置权限**: 配置角色权限
4. **调整字段**: 根据实际需求调整字段定义

## 注意事项

- 模块名必须使用 kebab-case
- 生成的代码需要根据实际业务调整
- API 接口需要根据后端接口调整
- 权限标识需要统一规划

---

此命令可快速创建符合项目规范的业务模块，提升开发效率。
