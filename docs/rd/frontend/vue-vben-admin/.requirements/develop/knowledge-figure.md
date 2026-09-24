# 需求3 执行结果：知识库人物管理（动态路由 + 后台 CRUD 维护）

> 需求来源：`.requirements/develop/task.txt` 中的「需求3」。
>
> task.txt 在「需求3」之后有明确指令「忽略以下所有需求描述」，因此其后的「需求2」（记录到 permission.md）未执行。本文档沿用需求1（`auth-permission.md`）的做法，记录需求3 的执行结果。

## 一、需求描述

结合 7 个后台接口，完成动态路由「知识库 / 人物管理」的后台管理维护功能（分页列表、查询、新增、编辑、删除、Excel 模板下载、Excel 批量导入）。

| # | 接口 | 方法 | 路径（`{{host}} = http://49.235.53.53:9001`） | 权限码 |
| - | --- | --- | --- | --- |
| 1 | 人物分页列表 | GET | `/api/v1/knowledge/figures` | `knowledge:figure:query` |
| 2 | 新建人物 | POST | `/api/v1/knowledge/figures` | `knowledge:figure:create` |
| 3 | 下载导入模板 | GET | `/api/v1/knowledge/figures/import-template` | — |
| 4 | Excel 批量导入 | POST | `/api/v1/knowledge/figures/import`（multipart `file`） | `knowledge:figure:import` |
| 5 | 人物详情 | GET | `/api/v1/knowledge/figures/{id}` | `knowledge:figure:query` |
| 6 | 修改人物 | PUT | `/api/v1/knowledge/figures/{id}` | `knowledge:figure:update` |
| 7 | 删除人物 | DELETE | `/api/v1/knowledge/figures/{id}` | `knowledge:figure:delete` |

## 二、接口契约（已 curl 实测）

响应统一为 `{success, code:0成功, data, message?}`；删除返回 `{success:true, code:0}`；不存在记录返回 `{success:false, message:"Figure not found", code:1}`。

### 字段命名差异（重要）

- **列表接口**返回 Laravel 分页器结构，字段为 **snake_case**：`id, code, name, aliases[], description, dynasty, birth_year, death_year, occupation, birth_place, attributes, tags[], status, created_at, updated_at, deleted_at`；分页器含 `data[]/total/per_page/current_page/last_page` 等。
- **详情/新建/修改接口**返回值字段为 **camelCase**：`birthYear, deathYear, birthPlace, createdAt, updatedAt`（经资源转换）。
- **请求体**字段为 **snake_case**（与列表一致）：`birth_year, death_year, birth_place`。

据此：`Figure` 类型（表格数据源）采用 snake_case；提交体 `FigurePayload` 同样采用 snake_case；编辑表单直接用列表行数据回填，避免详情接口的 camelCase 转换。

### 分页器 → vxe-grid 适配

vxe-grid `proxyConfig.response` 配置为 `{result:'items', total:'total'}`，故 `getFigureList` 将 Laravel 分页器转换为 `{items: data.data, total: data.total}` 返回。

### 导入接口

- 模板下载：GET 返回 `.xlsx`（`Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`，`Content-Disposition: attachment; filename=figures_template.xlsx`），表头为 `code, name, aliases, description, dynasty, birth_year, death_year, occupation, birth_place, tags`（`aliases`/`tags` 单元格内逗号分隔）。
- 批量导入：POST `multipart/form-data` 字段 `file`，支持 `.xlsx/.xls/.csv`；返回 `{created, updated, skipped, failed, errors[]}`。

## 三、改动文件清单

| 文件 | 类型 | 改动 |
| --- | --- | --- |
| `apps/web-antd/src/api/knowledge/figure.ts` | 新建 | 7 个接口 + `FigureApi` 命名空间（Figure/FigureDetail/FigurePayload/FigureListParams/FigurePageResult/ImportResult 类型） |
| `apps/web-antd/src/api/knowledge/index.ts` | 新建 | `export * from './figure'` |
| `apps/web-antd/src/api/index.ts` | 修改 | 增加 `export * from './knowledge'` |
| `apps/web-antd/src/adapter/vxe-table.ts` | 修改 | 移植 playground 的 `CellTag`/`CellSwitch`/`CellTags`/`CellOperation` 渲染器 + `OnActionClickParams`/`OnActionClickFn` 类型（适配 `ant-design-vue`） |
| `apps/web-antd/src/views/knowledge/figure/data.ts` | 新建 | 表单 schema、搜索表单 schema、列定义（含状态 CellTag、标签 CellTags、操作 CellOperation） |
| `apps/web-antd/src/views/knowledge/figure/modules/form.vue` | 新建 | 新建/编辑表单 Modal（含扩展属性 JSON 解析、生卒年校验） |
| `apps/web-antd/src/views/knowledge/figure/modules/import-modal.vue` | 新建 | Excel 批量导入 Modal（模板下载 + 拖拽上传 + 结果汇总展示） |
| `apps/web-antd/src/views/knowledge/figure/index.vue` | 新建 | 列表页（动态路由组件 `knowledge/figure/index`，vxe-grid 分页 + 搜索 + 按钮级权限） |

## 四、关键设计点

### 1. 动态路由（后端菜单驱动）

后端 `permission-info` 已返回「知识库」目录（`path:/knowledge`）+「人物管理」菜单（`path:figure, component:'knowledge/figure/index', permission:'knowledge:figure:list'`）及 5 个按钮权限点（`knowledge:figure:query/create/update/delete/import`）。

需求1 已实现的 `transformBackendMenusToRoutes`（`api/core/permission.ts`）将 `component:'knowledge/figure/index'` 经 `normalizeViewPath` 映射到 `views/knowledge/figure/index.vue`，自动生成动态路由 `/knowledge/figure`。**本需求只需在前端创建该视图组件即可被动态路由加载**，无需新增前端静态路由模块（避免与后端菜单在 mixed 模式下按 name 合并冲突）。

### 2. vxe-grid 表格

- `proxyConfig.ajax.query` 将 `{page:{currentPage,pageSize}, formValues}` 映射为 `{page, per_page, ...filters}` 调用 `getFigureList`，返回 `{items, total}`。
- `pagerConfig`：默认每页 15 条（与后端默认一致），可选 15/30/50/100。
- 搜索表单：`keyword`（姓名/简介/编码模糊）、`code`、`name`、`dynasty`、`status`，`submitOnChange` 即时查询。
- 列：编码、姓名、别名（逗号拼接）、朝代、职业、生卒年（拼接）、标签（`CellTags` 多 Tag）、状态（`CellTag` enabled=success/disabled=error）、创建时间（去毫秒）、操作（`CellOperation` 编辑/删除，删除带 Popconfirm）。

### 3. 表单（新建/编辑）

- 使用 `useVbenModal` + `connectedComponent` 模式（与 playground `system/dept` 一致），列表页 `formModalApi.setData(row).open()` 打开。
- `aliases`/`tags`：`Select` `mode:'tags'`，回车添加，逗号分隔，值即字符串数组，直接匹配后端。
- `attributes`：`Textarea` 编辑 JSON 文本；回填时 `JSON.stringify`，提交时 `JSON.parse` 为对象（空则 null，非对象/格式错误时阻断提交并提示）。
- `birth_year`/`death_year`：`InputNumber`；提交前校验「卒年不得早于生年」。
- 可选字符串字段空值转 `undefined`，避免后端空串问题。

### 4. Excel 导入

- 模板下载：`requestClient.download<Blob>` 取 Blob，`URL.createObjectURL` + `<a download>` 触发浏览器下载（文件名 `figures_template.xlsx`）。
- 文件上传：`Upload.Dragger` + `beforeUpload` 拦截（仅 `.xlsx/.xls/.csv`），暂存 `File`；点击「开始导入」调用 `requestClient.upload('/v1/knowledge/figures/import', { file })`（内部构造 `multipart/form-data`）。
- 结果展示：`Statistic` 展示 created/updated/skipped/failed，失败详情列表展示 `errors[]`。

### 5. 按钮级权限

「新增人物」`v-access:code="['knowledge:figure:create']"`、「批量导入」`v-access:code="['knowledge:figure:import']"`；操作列编辑/删除由 `CellOperation` 渲染。superadmin（`permissions:["*"]`）经需求1 的 `hasAccessByCodes` 通配放行，全部可见。

## 五、验证结果

| 验证项 | 结果 |
| --- | --- |
| `pnpm -F @vben/web-antd run typecheck` | ✅ 通过，无类型错误 |
| `oxlint`（全部改动文件） | ✅ 无报错 |
| `oxfmt --check`（全部改动文件） | ✅ 格式正确 |
| `stylelint`（新增 .vue） | ✅ 无报错 |
| `cspell`（新增 .ts） | ✅ 无拼写错误 |
| 后端联调-list（经 Vite 代理 `localhost:5666/api`） | ✅ code:0，返回分页数据（total:2） |
| 后端联调-create（JSON snake_case body） | ✅ code:0，返回 camelCase 人物（id=5） |
| 后端联调-update（PUT） | ✅ code:0，name 更新成功 |
| 后端联调-delete（DELETE） | ✅ {success:true, code:0}，再查详情返回 Figure not found |
| 后端联调-detail（GET /{id}） | ✅ code:0，返回 camelCase 人物 |
| 后端联调-import-template（GET） | ✅ 返回 .xlsx（6407 字节，Content-Type 正确） |
| 后端联调-import（POST multipart file） | ✅ code:0，返回 {created:1, updated:0, skipped:0, failed:0, errors:[]} |
| 动态路由组件编译 | ✅ `views/knowledge/figure/index.vue` 等 4 模块经 Vite 编译返回 HTTP 200 |
| API 代理联调 | ✅ 经 `localhost:5666/api` 登录 + 列表均成功 |
| dev 启动 | ✅ VITE v8.0.13 ready，无编译错误 |

> 联调期间创建的测试数据（`_verify_libai` id=5、`csvtest` id=4）已清理，仅保留联调前已存在的 `id=2 (code=test)`。

## 六、使用方式

1. 确保后端服务 `http://49.235.53.53:9001` 可达（dev 代理已配置）。
2. **清空浏览器 localStorage**（accessStore 持久化缓存了旧 accessMode/enableRefreshToken，不清缓存新配置不生效）。
3. `pnpm dev:antd` 启动前端。
4. 登录页选择 `Super Admin`（自动填入 `superadmin` / `123456`），完成滑动验证 → 跳转 `/analytics`。
5. 侧边栏可见后端动态渲染的「知识库」→「人物管理」；点击进入 `/knowledge/figure` 列表页。
6. 顶部「新增人物」打开表单 Modal（code/姓名必填，别名/标签回车添加，扩展属性填 JSON）；「批量导入」打开导入 Modal（先下载模板，填写后上传）。
7. 操作列「编辑」回填表单修改、「删除」带二次确认软删除。
8. 搜索表单关键字/编码/姓名/朝代/状态即时过滤；分页可切换每页条数。

## 七、未执行项

- 「需求2」（执行结果记录到 `.requirements/develop/permission.md`）依据 task.txt「忽略以下所有需求描述」指令，未执行。本结果改为记录在 `knowledge-figure.md`。
- 未新增前端静态路由模块（`router/routes/modules/knowledge.ts`），因后端 `permission-info` 已提供动态菜单，mixed 模式下二者按 name 合并可能冲突；动态路由由后端菜单驱动即可。
