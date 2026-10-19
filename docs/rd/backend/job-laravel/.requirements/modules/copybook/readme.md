# Copybook 定制字帖模块 — 功能介绍与使用手册

> 文档基于模块源码（分支 `dev-copybook`，2026-10-19）整理，覆盖模块全部功能、接口、命令、配置与部署运维说明。

## 目录

- [1. 模块简介](#1-模块简介)
- [2. 技术架构](#2-技术架构)
- [3. 环境配置](#3-环境配置)
- [4. 功能总览](#4-功能总览)
- [5. 接口使用说明](#5-接口使用说明)
- [6. Artisan 命令](#6-artisan-命令)
- [7. 配置文件说明](#7-配置文件说明)
- [8. 数据模型与表结构](#8-数据模型与表结构)
- [9. 核心业务流程](#9-核心业务流程)
- [10. 状态定义与流转](#10-状态定义与流转)
- [11. 部署与运维](#11-部署与运维)
- [12. 测试](#12-测试)

---

## 1. 模块简介

Copybook（定制字帖）是一个**定制姓名字帖业务后台模块**。

业务核心：根据用户提供的**姓名、性别、版式**，为用户生成相应的姓名字帖 PDF 文件，供打印装订成册。男生、女生可选用不同的封面与内容页纸张（对应版式上的男/女商品编码）。

模块提供的能力：

| 能力 | 说明 |
| --- | --- |
| 管理员认证 | JWT 登录/登出/刷新/个人信息维护 |
| 管理员管理 | 管理员的列表、新增、编辑（无详情/删除） |
| 角色权限 | 极简版角色权限管理（软删除、权限选项） |
| 字库管理 | 汉字字库的扫描同步、查询、字体文件下载 |
| 版本版式 | 版本与版式配置的只读明细接口（数据由命令维护） |
| 姓名字帖登记 | 多音字单条登记、批量登记、重新登记 |
| 姓名字帖查询 | 进行进行中列表、已完结列表、详情 |
| PDF 生成 | 单页 PDF 生成命令（调 node 脚本）、整本 PDF 合并命令 |

模块定位为**纯后端 API 服务**：不渲染任何服务端页面，所有响应均为 JSON，前端为独立应用，通过 `/api/v1/*` 消费本模块接口。

## 2. 技术架构

| 项 | 说明 |
| --- | --- |
| 框架 | Laravel 13（PHP 8.4），模块化基于 `nwidart/laravel-modules` v13 |
| 模块位置 | `Modules/Copybook`（根 composer.json 经 `wikimedia/composer-merge-plugin` 合并模块 autoload） |
| 数据库 | 独立 MySQL 连接 `mysql_copybook` → 数据库 `job_copybook`（与应用主库隔离） |
| 认证 | JWT（`php-open-source-saver/jwt-auth` v2.9），guard 名 `admin`，中间件 `auth:admin` |
| PDF 合并 | `iio/libmergepdf` ^4.0（依赖 tecknickcom/tcpdf + setasign/fpdi） |
| 单页 PDF 生成 | 外部 node 脚本，由命令以 `Illuminate\Support\Facades\Process` 调用 |
| 响应规范 | 全局中间件 `App\Http\Middleware\NormalizeApiResponse` 统一信封化（见 [5.1](#51-统一响应格式)） |
| 测试 | PHPUnit（模块测试位于 `Modules/Copybook/tests/Feature`，纳入根 phpunit.xml，SQLite 内存库） |

## 3. 环境配置

### 3.1 数据库连接（config/database.php → `mysql_copybook`）

```php
'mysql_copybook' => [
    'driver' => 'mysql',
    'host' => env('DB_COPYBOOK_HOST', env('DB_HOST', '127.0.0.1')),
    'port' => env('DB_COPYBOOK_PORT', env('DB_PORT', '3306')),
    'database' => env('DB_COPYBOOK_DATABASE', 'job_copybook'),
    'username' => env('DB_COPYBOOK_USERNAME', env('DB_USERNAME', 'root')),
    'password' => env('DB_COPYBOOK_PASSWORD', env('DB_PASSWORD', '')),
    // charset/collation 默认 utf8mb4 / utf8mb4_unicode_ci
],
```

`.env` 可独立配置 `DB_COPYBOOK_*`，未配置时回退主库 `DB_*`：

```dotenv
DB_COPYBOOK_HOST=127.0.0.1
DB_COPYBOOK_PORT=3306
DB_COPYBOOK_DATABASE=job_copybook
DB_COPYBOOK_USERNAME=root
DB_COPYBOOK_PASSWORD=
```

### 3.2 业务路径配置（Modules/Copybook/config/config.php）

| 环境变量 | 配置键 | 用途 |
| --- | --- | --- |
| `COPYBOOK_STANDARD_FONT_PATH` | `copybook.standard_font_path` | 标准体（楷体）字库目录，目录内每个文件名（去扩展名）= 一个汉字 |
| `COPYBOOK_HANDWRITTEN_FONT_PATH` | `copybook.handwritten_font_path` | 手写体字库目录，同上 |
| `COPYBOOK_NODE_SCRIPT_PATH` | `copybook.node_script_path` | node 生成脚本根目录，脚本相对路径 `{根目录}/{版本代码}/{字体}/index_single.js`（单字页）或 `index.js`（组合页） |
| `COPYBOOK_PAGE_PDF_PATH` | `copybook.page_pdf_path` | 单页 pdf 文件根目录（作为 `--pdf_root` 参数传给 node 脚本；整本 pdf 输出到其下 `final/` 子目录） |

### 3.3 JWT 配置

`config/jwt.php` 读取 `JWT_SECRET` / `JWT_ALGO` / `JWT_TTL`；`config/auth.php` 定义 `admin` guard（driver `jwt`，provider `admins` → `Modules\Copybook\Models\Admin`）。

### 3.4 单页 PDF 文件路径约定（node 脚本必须遵守）

```
{COPYBOOK_PAGE_PDF_PATH}/{版本代码}/{字体}/{汉字}_{多音字编码}_{笔顺}.pdf
```

- 文件名三段直接下划线拼接；多音字编码为空时**保留空段**（如 `王__1.pdf`）；
- 整本 pdf 输出：`{COPYBOOK_PAGE_PDF_PATH}/final/{批次码}_{批次内序号}_{姓名}.pdf`（重新生成同名覆盖）。

## 4. 功能总览

```
Modules/Copybook
├── 认证（AuthController）        登录 / 我的信息 / 编辑自己 / 登出 / 刷新token
├── 管理员管理（AdminController）  列表(含角色选项) / 新增 / 编辑
├── 角色权限（RoleController）    列表(含权限选项) / 新增 / 编辑 / 删除(软删除)
├── 字库（CharacterLibraryController） 列表(多条件筛选) / 详情(base64字体内容)
├── 版本版式（NameCopybookVersionController）
│   ├── 接口1 version-layout-details  按性别分组的版本+版式明细
│   └── 接口2 version-layout-list     按版本分组、版式附带 demo_files
├── 姓名字帖（NameCopybookController）
│   ├── 多音字单条登记 / 批量登记
│   ├── 进行中列表 / 已完结列表（含筛选与下拉选项）
│   └── 详情（版式快照 + pdf单页关联 + 生成日志）
└── 命令（Console）
    ├── copybook:sync-fonts               扫描字库目录同步字库表
    ├── copybook:sync-version-layouts     按配置文件维护版式表
    ├── copybook:sync-layout-char-configs 按字数配置维护版式字数配置代码
    ├── copybook:generate-page-pdfs       调 node 脚本生成未完成单页 pdf
    └── copybook:generate-final-pdfs      合并单页 pdf 生成整本字帖 pdf
```

## 5. 接口使用说明

所有接口统一前缀 **`/api/v1`**。除 `POST admin/login` 外全部需要 JWT 认证（请求头 `Authorization: Bearer {token}`）。

### 5.1 统一响应格式

全局中间件对所有 `api/*` JSON 响应追加信封字段：

```jsonc
{
    "http_code": 201,   // 原始 HTTP 状态码
    "status": 0,        // 0 = 成功（原始码 2xx）；1 = 失败
    ...原始响应体
}
```

**HTTP 状态码映射**：200/401/403/404/500 原样返回；5xx 统一 500；其余（201/204/405/409/422 等）一律返回 **HTTP 200**，业务码看 `http_code`。

| http_code | status | 场景 |
| --- | --- | --- |
| 200 | 0 | 查询/更新成功 |
| 201 | 0 | 创建成功 |
| 204 | 0 | 删除成功（响应体仅剩信封字段） |
| 401 | 1 | 未登录 / token 失效 / 账号密码错误 / 账号被禁用 |
| 404 | 1 | 路径不存在或资源不存在 |
| 409 | 1 | 冲突（如删除已分配的角色） |
| 422 | 1 | 参数校验失败（`errors` 字段带中文提示） |
| 500 | 1 | 服务端异常 |

### 5.2 认证接口

#### POST /api/v1/admin/login — 登录（公开）

请求体：

```json
{ "account": "admin", "password": "123456" }
```

成功响应（200）：

```json
{
    "http_code": 200, "status": 0,
    "success": true,
    "data": {
        "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
        "token_type": "bearer",
        "expires_in": 3600
    }
}
```

失败（401）：仅 `status=1` + `message: "账号或密码错误"`。被禁用（status=0）的管理员无法登录。

#### GET /api/v1/admin/me — 我的信息

返回当前管理员（含 `role` 关联）。字段见 [5.3 管理员结构](#53-管理员管理接口)。

#### PUT|PATCH /api/v1/admin/profile — 编辑自己的账号

仅可修改自己的头像/昵称/手机号/密码，**不能**修改 account/status/role_id 等管理字段。参数均可选（`sometimes`）；`password` 可传 null 表示不修改（min:6）。

```json
{ "nickname": "新昵称", "phone": "13800000000", "avatar": "https://...", "password": "newpass123" }
```

#### POST /api/v1/admin/logout — 登出

使当前 token 失效。响应 `message: "退出成功"`。

#### POST /api/v1/admin/refresh — 刷新 token

返回结构与登录一致（新 access_token）。

### 5.3 管理员管理接口

**管理员数据结构**（AdminResource，时间格式 `Y-m-d H:i:s`）：

```jsonc
{
    "id": 1,
    "account": "admin",
    "avatar": "",
    "nickname": "管理员",
    "phone": "",
    "status": 1,
    "status_label": "启用",          // 1→启用 / 0→禁用
    "role_id": 2,
    "role": { ... },                 // whenLoaded；role_id=0 时为 null
    "created_at": "2026-10-15 10:00:00",
    "updated_at": "2026-10-15 10:00:00"
}
```

#### GET /api/v1/admins — 管理员列表

筛选参数（均可选）：`account`（模糊）、`nickname`（模糊）、`role_id`（精确）、`status`（精确，0/1，**传 0 也生效**）、`per_page`（默认 15）。

响应：`data`（管理员数组）+ `meta`（分页：current_page/from/last_page/per_page/to/total）+ 顶层 `role_options`（id => name，排除已删除角色）。

#### POST /api/v1/admins — 新增管理员（201）

| 参数 | 规则 | 说明 |
| --- | --- | --- |
| account | 必填，唯一（跨连接 `mysql_copybook.admins`） | 登录账号 |
| password | 必填，min:6 | 自动哈希 |
| phone / avatar / nickname | 可选字符串 | null 入参归一化为 '' |
| status | 可选，0/1 | 默认 1 |
| role_id | 可选，>=0，RoleExists 校验 | 0 = 未分配角色；null 归一化为 0 |

#### PUT|PATCH /api/v1/admins/{id} — 编辑管理员（200）

规则同新增，但 `account` 唯一性校验忽略自身；`password` 传 null 时保持原密码。

> 管理员**详情（GET /admins/{id}）与删除（DELETE /admins/{id}）接口已移除**，命中 405。

### 5.4 角色权限接口

**角色数据结构**（RoleResource）：

```jsonc
{
    "id": 1,
    "name": "运营",
    "description": "",
    "permissions": ["namecopybook", "fontmanage"],
    "permissions_label": "姓名字帖,字库管理",   // 权限键→中文名，逗号连接
    "created_at": "2026-10-15 10:00:00",
    "updated_at": "2026-10-15 10:00:00"
}
```

权限选项词汇表（`config('copybook.permissions.options')`，列表接口以顶层 `permission_options` 返回）：

| 键 | 名称 |
| --- | --- |
| index | 首页 |
| namecopybook | 姓名字帖 |
| childrenstamp | 儿童印章 |
| nametag | 姓名贴 |
| fontmanage | 字库管理 |
| system | 系统管理 |

#### GET /api/v1/roles — 角色列表

筛选：`name`（模糊）、`per_page`（默认 15，按 id 倒序）。软删除角色自动排除。响应含顶层 `permission_options`。

#### POST /api/v1/roles — 新增角色（201）

| 参数 | 规则 |
| --- | --- |
| name | 必填、唯一（**含软删除行**，删除后的名称不可复用） |
| description | 可选，max:255 |
| permissions | 必填数组，至少 1 项、不重复、值必须在权限选项键内 |

#### PUT|PATCH /api/v1/roles/{id} — 编辑角色（200）

规则同新增（name 唯一性忽略自身）。

#### DELETE /api/v1/roles/{id} — 删除角色（204，软删除）

仍有管理员引用该角色时返回 **409**（`该角色已分配给管理员，无法删除`），需先调整这些管理员的角色分配。

### 5.5 字库接口

**字库数据结构**（CharacterResource，时间 ISO 格式）：

```jsonc
{
    "id": 1,
    "character": "王",
    "has_standard_font": true,      // 有标准体（楷体）字库文件
    "has_handwritten_font": false,  // 有手写体字库文件
    "standard_font_used": true,     // 标准体已使用
    "handwritten_font_used": false, // 手写体已使用
    "created_at": "2026-10-10T12:40:59.000000Z",
    "updated_at": "2026-10-10T12:40:59.000000Z"
}
```

#### GET /api/v1/characters — 字库列表

筛选参数（存在且为真值时生效）：`character`（模糊）、`has_standard`、`has_handwritten`、`has_both`（两种都有）、`standard_used`、`handwritten_used`、`both_used`（两种都已使用）；`per_page` 默认 15，按 id 排序。

#### GET /api/v1/characters/{character} — 字库详情

返回上述结构并额外携带字体文件内容：

| 字段 | 说明 |
| --- | --- |
| standard_content | 标准体字体文件 bytes 的 **base64**（无字库标记或文件缺失时 null） |
| handwritten_content | 手写体字体文件 bytes 的 **base64**（同上） |

字库不存在时 404（`字库不存在`）。文件按"文件名（去扩展名）= 汉字"在配置目录中查找。

### 5.6 版本版式配置接口

版本与版式**没有任何 CRUD 接口**：版本行通过迁移/命令/直接操作数据库维护，版式数据由 `copybook:sync-version-layouts` 命令维护。前端经以下两个只读接口消费。两个接口均**不过滤版本 status**（是否过滤由前端按返回数据处理）。

#### GET /api/v1/version-layout-details — 接口1：按性别分组的版本版式明细

版式过滤 `status=99`（已弃用），版式按 `sort,id` 排序，版本按 `sort,code` 排序：

```jsonc
{
    "http_code": 200, "status": 0,
    "data": {
        "male": {
            "name": "男", "gender": "male",
            "versions": {
                "ncv_1": {
                    "version_code": "ncv_1",
                    "preview_url": "https://.../male-preview.png",   // 版本男生预览图
                    "name": "第一版本",
                    "layouts": [
                        { "id": 65, "name": "36页有笔顺手写体", "status": "1" },
                        { "id": 66, "name": "36页有笔顺楷体", "status": "1" }
                    ]
                }
            }
        },
        "female": { "name": "女", "gender": "female", "versions": { ... } }
    }
}
```

> `status` 为**字符串**形式（"1" 使用中 / "0" 停用；99 已弃用被过滤）。

#### GET /api/v1/version-layout-list — 接口2：按版本分组的版式列表（含 demo 文件）

以版本 code 为键 → male/female 两节（各带 `preview_url`）→ layouts 附加 `demo_files`：

```jsonc
{
    "http_code": 200, "status": 0,
    "data": {
        "ncv_1": {
            "code": "ncv_1",
            "name": "第一版本",
            "male": {
                "preview_url": "https://...",
                "name": "男", "gender": "male",
                "layouts": [
                    {
                        "id": 65, "name": "36页有笔顺手写体", "status": "1",
                        "demo_files": { "示例文件名.png": "http://.../示例文件名.png" }
                    }
                ]
            },
            "female": { "...": "同上" }
        }
    }
}
```

`demo_files` 取 `config('copybook.version_layout_demos')` 中键 `{version_code}_{版式ID}` 下 male/**famale**（famale 为需求原文拼写，非笔误）的配置，无配置返回 `[]`。

### 5.7 姓名字帖接口

> 历史接口已移除（命中 404）：合并式 `POST name-copybooks`、合并列表 `GET name-copybooks`、`name-copybook-versions` 全部方法、版式 5 个接口、字数配置 2 个接口。

#### POST /api/v1/name-copybooks/polyphonic — 多音字姓名单条登记（201）

| 参数 | 规则（中文报错） | 说明 |
| --- | --- | --- |
| batch_code | 必填，max:64 | 批次码（同批次内序号递增） |
| gender | 必填，male/female | 性别 |
| layout_id | 必填，LayoutInUse | 版式 ID（须存在且 status=1；0 已停用 / 99 已弃用均 422 拒绝） |
| name | 必填，max:64 | 单个姓名 |
| polyphonic_code | 必填，max:64 | 多音字编码，按下划线按姓名位置拼接（如 `2_4` = 首字取第 2 读音、第二字取第 4 读音） |

#### POST /api/v1/name-copybooks/batch — 姓名批量登记（201）

| 参数 | 规则 | 说明 |
| --- | --- | --- |
| batch_code / gender / layout_id | 同上 | — |
| names | 必填数组，至少 1 项 | 姓名列表，服务层去重后逐条处理，多音字编码固定 `''` |
| names.* | 必填字符串，max:64 | 空串会被转为 null 触发 required 校验 |

**登记响应**（两个接口一致）：

```jsonc
{
    "http_code": 201, "status": 0,
    "success": true,
    "data": {
        "total": 5,            // 本次处理信息总数（批量按未去重条数）
        "unique_count": 4,     // 去重后的数量
        "new_count": 3,        // 新增记录数
        "running_count": 3,    // 涉及记录中 pending+processing 的数量
        "completed_count": 1,  // 涉及记录中 completed 的数量
        "exception_count": 0   // 涉及记录中其余（异常）状态的数量
    },
    "message": "姓名字帖批量添加成功：新增 3 条，重新登记 1 条"
}
```

**登记语义**（详见 [9.1](#91-登记流程-createpolyphonicrecord--createbatchrecords)）：

- **重新登记**：已存在相同记录（批次码+姓名+性别+多音字编码+版式ID 五字段唯一）时不新增，只生成一条生成日志并把 `last_record_at` 置为当前时间，沿用记录当前状态；
- **新记录**：创建记录（初始 pending）+ 生成日志，然后走校验与单页展开流程，正常生成关联后进入 `processing`；异常时进入对应异常状态并记录 `exception_message`。

#### GET /api/v1/name-copybooks/in-progress — 进行中列表

`status ∈ {pending, processing}`，默认每页 **20** 条，按 id 倒序。

#### GET /api/v1/name-copybooks/finished — 已完结列表

`status ∉ {pending, processing}`（completed + 各异常状态），默认每页 **200** 条，按 id 倒序。额外支持 `status_group` 精确筛选：

| status_group | 含义 |
| --- | --- |
| completed | 仅 completed |
| exception | completed/pending/processing 之外的异常状态 |

**共用筛选参数**（两个列表一致，均可选）：

| 参数 | 匹配方式 |
| --- | --- |
| batch_code | 模糊 |
| gender | 精确（male/female） |
| version_code | 精确（版本代码） |
| product_code | 模糊 |
| name | 模糊 |
| creator | 精确（生成日志操作者账号） |
| per_page | 每页条数 |

**共用响应**：`data` + `meta`（分页）+ 顶层下拉选项：

```jsonc
{
    "version_options": { "ncv_1": "第一版本", "ncv_2": "第二版本" },  // 按 sort,code 全量，不过滤 status
    "gender_options": { "male": "男", "female": "女" },
    "creator_options": { "admin": "管理员", "op01": "op01" }          // 管理员 account => nickname（空则回退 account）
}
```

**列表项结构**（两列表共用基础字段，时间格式 `Y-m-d H:i:s`）：

```jsonc
{
    "id": 1,
    "batch_code": "B20261019",
    "batch_sequence": 1,
    "name": "王小明",
    "gender": "male",
    "name_length": 3,
    "polyphonic_code": "",
    "layout_id": 65,
    "version_code": "ncv_1",
    "version_code_label": "第一版本",     // 经 version 关联取名称
    "layout_name": "36页有笔顺手写体",     // 版式名称快照
    "product_code": "lztycl519",          // 按性别取男/女商品编码快照
    "status": "processing",
    "status_label": "处理中",
    // —— 已完结列表额外返回：
    "exception_message": "",
    "download_count": 0,
    // —— 日志聚合：
    "record_count": 2,                    // 登记次数（生成日志条数）
    "record_admins": "admin,op01",        // 操作者账号去重逗号连接
    "created_at": "2026-10-19 10:00:00",
    "last_record_at": "2026-10-19 12:00:00"
}
```

> 进行中列表**不返回** `exception_message` / `download_count`。

#### GET /api/v1/name-copybooks/{id} — 记录详情

预载 `layout`（版式快照全字段）+ `pdfRelations.pdfPage`（单页关联及单页）+ `logs`（生成日志）。时间 ISO 格式：

```jsonc
{
    "http_code": 200, "status": 0,
    "success": true,
    "data": {
        "id": 1, "batch_code": "B20261019", "batch_sequence": 1,
        "name": "王小明", "gender": "male", "name_length": 3,
        "polyphonic_code": "", "layout_id": 65,
        "version_code": "ncv_1", "layout_name": "36页有笔顺手写体",
        "product_code": "lztycl519",
        "status": "processing", "status_label": "处理中",
        "exception_message": "", "download_count": 0,
        "layout": { /* NameCopybookLayoutResource：含字数配置代码、商品编码、remark 等 */ },
        "pdf_relations": [
            {
                "id": 1, "name_copybook_id": 1, "sort": 1,
                "page_code": "first",           // 本条关联对应的单页代码
                "pdf_page_id": 10,
                "status": "", "status_label": "未生成",  // 与单页状态同步
                "pdf_page": {
                    "id": 10, "character": "王",
                    "font_library_id": 3,        // 单字页=字库表ID；组合页=0
                    "is_single_character": true,
                    "name_length": 3, "polyphonic_code": "",
                    "layout_id": 65, "version_code": "ncv_1",
                    "font": "handwritten", "has_stroke_order": true,
                    "page_code": "first",
                    "status": "", "status_label": "未生成",
                    "exception_message": "",
                    "created_at": "...", "updated_at": "..."
                }
            }
        ],
        "logs": [
            { "id": 1, "name_copybook_id": 1, "operator_id": 1, "operator_account": "admin", "operated_at": "..." }
        ],
        "created_at": "2026-10-19T02:00:00.000000Z",
        "updated_at": "2026-10-19T02:00:00.000000Z"
    }
}
```

> 记录**不可编辑和删除**：无 update/destroy 接口（重新登记仅更新 last_record_at）。

## 6. Artisan 命令

命令在 `CopybookServiceProvider::$commands` 以 FQCN 注册。

### 6.1 copybook:sync-fonts — 字库同步

```bash
php artisan copybook:sync-fonts
```

扫描 `COPYBOOK_STANDARD_FONT_PATH` 与 `COPYBOOK_HANDWRITTEN_FONT_PATH` 两个目录，文件名（去扩展名）即汉字，对每个文件 `Character::updateOrCreate` 置位对应 has 标记（**不会**重置其他标记）。两个路径均未配置时报错并返回 FAILURE。

### 6.2 copybook:sync-version-layouts — 版式表维护

```bash
php artisan copybook:sync-version-layouts
```

读取 `config('copybook.version_layouts')`（以版本代码为键，每项含 content_page_count/has_stroke_order/remark/male_product_code/female_product_code）：

- 每个配置项按 font 生成/更新 **handwritten（手写体）与 standard（楷体）两条**版式记录；
- 匹配键 `(version_code, content_page_count, font, has_stroke_order)`——同页数不同笔顺各自成条互不覆盖（如 ncv_4 的两个 18 页配置）；
- `name` 按 `{页数}页{有|无}笔顺{手写体|楷体}` 生成（如 `36页有笔顺手写体`）；命令只维护 name/has_stroke_order/男/女商品编码/remark，**status 保持原值**；
- `sort` 仅对新增记录赋值：每个版本内本次新增按配置项顺序（每项先手写体后楷体）从 1 逐条 +1；重跑不会重新编号存量记录（需重编号时清空版式表后重跑）；
- 版本代码不存在 → warn 跳过并整体返回 FAILURE；配置为空 → no-op SUCCESS。

> 命令创建的版式 `two/three/four_char_config_code` 为 `''`，需接着运行 `copybook:sync-layout-char-configs` 维护。

### 6.3 copybook:sync-layout-char-configs — 版式字数配置代码维护

```bash
php artisan copybook:sync-layout-char-configs
```

基于 `config('copybook.name_page_configs')` 更新版式表三个字数配置代码字段：

- 按页数键 `p{N}` 匹配 content_page_count，批量 update 同页数的**全部**版式；
- 每个姓名字数维度取规则：优先 standard；无 standard 且仅一个规则时用该规则；多规则无 standard 或缺维度 → warn 并保持原值；
- 配置未覆盖的页数 → warn 保持原值；页数键非法 → warn 跳过；恒返回 SUCCESS。

### 6.4 copybook:generate-page-pdfs — 单页 pdf 生成

```bash
php artisan copybook:generate-page-pdfs
```

- 取 `name_copybook_pdf_pages` 中 **status 为空串**（未生成）的记录，按 id 排序逐个处理；
- 脚本路径：`{COPYBOOK_NODE_SCRIPT_PATH}/{version_code}/{font}/index_single.js`（单字页）/ `index.js`（组合页）；
- 以 `Process` 调 `node`（**数组传参**避免中文/空格转义问题，单脚本 60 秒超时），参数：`--character`、`--polyphonic_code`、`--has_stroke_order`、`--pdf_root`；
- 成功 → 单页 `completed` + exception_message 置空；失败（非零退出或超时）→ `other_abnormal` + 异常描述（exit code 与 stderr，截断 500 字）；
- 两种结果都同步 update 到 `name_copybook_pdf_relations`（where pdf_page_id，同事务）；
- 任一失败命令返回 FAILURE；两个根目录未配置 → error + FAILURE；
- `force_regenerate` / `need_regenerate`（关联表）标记本期**仅建字段未启用**（获取条件只有 status 为空串）。

### 6.5 copybook:generate-final-pdfs — 整本 pdf 生成

```bash
php artisan copybook:generate-final-pdfs
```

- 取 `name_copybooks` 中 `status=processing` 或（`status=completed` 且 `need_regenerate=1`）的记录（need_regenerate 本批启用为触发条件）；
- **前置条件**：关联单页（pdfRelations）状态须全部 `completed`，否则跳过（非失败，等待单页生成）；
- **文件校验**：任一关联单页的 pdf 文件缺失 → 该单页与对应关联（whereIn pdf_page_id 全局同步）标记 `pdf_abnormal` + exception_message「生成pdf异常」，字帖记录标记 `pdf_abnormal`；
- **配置解析**：按版式字数配置的分组顺序与 repeat 重复次数展开单页文件列表；配置代码不存在/引用未关联的单页代码/未展开任何单页 → 记录 `other_abnormal`（沿用服务层文案）；
- **合并**：iio/libmergepdf 合并输出 `{COPYBOOK_PAGE_PDF_PATH}/final/{批次码}_{批次内序号}_{姓名}.pdf`（同名覆盖）；合并异常 → `other_abnormal`「整本pdf合并失败：…」截断 500 字；
- 成功 → 记录 `completed`、exception_message 置空、need_regenerate 重置 0；
- 有失败记录时命令返回 FAILURE；根目录未配置 → error + FAILURE。

> ⚠️ FPDI 免费版无法解析压缩 xref stream 的 PDF（PDF 1.5+ 对象流）——node 脚本输出的单页 pdf 若为该格式，会在合并时失败并记为 other_abnormal。node 脚本应输出兼容格式。

**生产建议执行顺序**：

```bash
php artisan copybook:generate-page-pdfs && php artisan copybook:generate-final-pdfs
```

可由 crontab / 调度器周期执行，形成"登记 → 单页生成 → 整本合并"的流水线。

## 7. 配置文件说明

模块配置位于 `Modules/Copybook/config/`，统一以 `copybook.` 前缀访问：

| 文件 | 配置键 | 说明 |
| --- | --- | --- |
| config.php | `copybook.standard_font_path` 等 | 字库/脚本/pdf 路径（见 [3.2](#32-业务路径配置modulescopybookconfigconfigphp)） |
| permissions.php | `copybook.permissions.options` | 权限选项词汇表（键=>中文名），角色表单数据源 |
| version_layouts.php | `copybook.version_layouts` | 版式表数据源：以版本代码为键的配置项列表（content_page_count 允许字符串 '36' 形式），`copybook:sync-version-layouts` 消费 |
| name_base_pages.php | `copybook.name_base_pages` | 基础单页代码表：page = {name, type: single/partial/full, position(single), offset/length(partial, 负 offset 从姓名末尾数起)}；代码含 first/second/third/fourth/part1/part2/full/fullext |
| name_page_configs.php | `copybook.name_page_configs` | 单页拼装规则，三维度：页数键 `p{N}` → 姓名字数 two/three/four → 规则代码（standard）→ 分组列表 `[{repeat, pages:[单页代码]}]`；覆盖页数 13/15/16/18/24/32/36/40/52/60/64 |
| version_layout_demos.php | `copybook.version_layout_demos` | 版式 demo 文件配置：键 `{version_code}_{版式ID}` → male/famale（原文拼写）→ {文件名=>地址}；接口2 读取 |

**基础单页代码语义**（name_base_pages.php）：

| 代码 | 名称 | 内容 |
| --- | --- | --- |
| first / second / third / fourth | 姓名第N字 | 单字页（type=single，position 0-3） |
| part1 | 部分组合1 | 姓名前两字（offset 0, length 2） |
| part2 | 部分组合2 | 姓名后两字（offset -2, length 2） |
| full | 全名 | 整个姓名 |
| fullext | 全名拓展 | 整个姓名（与 full 内容相同但为独立单页代码） |

**标准规则生成公式**（name_page_configs.php）：`r = max(1, round(页数/18))`

| 姓名字数 | 分组模板 |
| --- | --- |
| two | 首字×r / 第二字×r / 全名×r / 全名拓展×(r+1) |
| three | 3 个单字×r / [part1,part2]×r / 全名×(r+1) |
| four | 4 个单字×r / [part1,part2]×r / 全名×(r+1) |

字数配置代码 = 三维标识拼接 `{页数}_{姓名字数}_{规则代码}`（如 `p32_two_standard`），存版式表 `two/three/four_char_config_code` 字段。

## 8. 数据模型与表结构

全部表位于 `job_copybook` 库；除主键与时间戳外所有字段 **NOT NULL 且有默认值**（数值 0、字符 ''；JSON/TEXT 默认值用表达式形式）。

### 8.1 表清单与关系

```
admins ──(role_id, 0=未分配)──> roles (软删除)
characters（字库，单字唯一）
name_copybook_versions（版本，code 字符串主键）
name_copybook_layouts（版式）──(version_code FK)──> versions.code
name_copybooks（姓名字帖记录）──(layout_id FK restrict)──> layouts
name_copybook_generation_logs（生成日志）──(name_copybook_id FK cascade)──> name_copybooks
name_copybook_pdf_pages（pdf单页，跨记录复用）
name_copybook_pdf_relations（pdf关联）──(name_copybook_id FK cascade / pdf_page_id FK restrict)──> name_copybooks / pdf_pages
```

### 8.2 admins — 管理员

| 字段 | 类型/默认 | 说明 |
| --- | --- | --- |
| id | PK | — |
| account | unique, '' | 登录账号 |
| password | ''（模型 hashed cast，资源层隐藏） | 密码 |
| phone / avatar / nickname | '' | 资料 |
| status | tinyint 1 | 1 启用 / 0 禁用（禁用不能登录） |
| role_id | 0 | 单一角色；0=未分配（无 FK，应用层 RoleExists 校验） |

### 8.3 roles — 角色

| 字段 | 类型/默认 | 说明 |
| --- | --- | --- |
| id | PK | — |
| name | unique, '' | 角色名（唯一索引含软删除行，名称删除后不可复用） |
| description | '' | 描述 |
| permissions | JSON `('[]')` | 权限键数组（cast array） |
| deleted_at | 软删除 | 删除前须无管理员引用 |

### 8.4 characters — 字库

| 字段 | 说明 |
| --- | --- |
| character | unique，单字 |
| has_standard_font / has_handwritten_font | 是否有标准体/手写体字库文件 |
| standard_font_used / handwritten_font_used | 是否已使用 |

### 8.5 name_copybook_versions — 姓名字帖版本

| 字段 | 说明 |
| --- | --- |
| code | 字符串主键（如 ncv_1） |
| name | 版本名 |
| male_preview_url / female_preview_url | 男/女预览图 |
| sort / status | 排序；bool 状态（true 启用） |

> 版本已无任何 CRUD 接口，只能通过迁移/命令/直接操作数据库维护。

### 8.6 name_copybook_layouts — 姓名字帖版式

| 字段 | 说明 |
| --- | --- |
| id | PK |
| version_code | FK → versions.code（cascade） |
| name | 如「36页有笔顺手写体」 |
| content_page_count | 内容页数 |
| font | standard（楷体）/ handwritten（手写体） |
| has_stroke_order | tinyint 0 无笔顺 / 1 有笔顺（integer cast，保留 0/1 语义） |
| two/three/four_char_config_code | 2/3/4 字姓名的字数配置代码（如 p32_two_standard），由命令维护 |
| male/female_product_code | 男/女商品编码 |
| status | tinyint：1 使用中 / 0 停用 / 99 已弃用（integer cast；LayoutInUse 只放行 1） |
| sort / remark | 排序 / 备注 |

匹配键 `(version_code, content_page_count, font, has_stroke_order)`。

### 8.7 name_copybooks — 姓名字帖记录

| 字段 | 说明 |
| --- | --- |
| batch_code / batch_sequence | 批次码 + 批内序号（联合唯一；序号 = 批内 max+1，lockForUpdate 下分配） |
| name / gender / name_length | 姓名 / male|female / 中文字数 |
| polyphonic_code | 多音字编码，'' = 非多音字 |
| layout_id | FK → layouts（restrict 删除） |
| version_code / layout_name / product_code | 版式快照（product_code 按性别取男/女商品编码） |
| status | 默认 pending（见 [10](#10-状态定义与流转)） |
| exception_message | 异常描述，默认 '' |
| need_regenerate | 1 = 需重新生成整本 pdf（整本命令的重新生成触发条件，成功后重置 0） |
| download_count | 下载次数 |
| last_record_at | 最后登记时间（登记/重新登记时置当前时间） |

唯一索引：`(batch_code, name, gender, polyphonic_code, layout_id)` = identity；`(batch_code, batch_sequence)` 联合唯一。记录不可变更（重新登记仅更新 last_record_at）。

### 8.8 name_copybook_generation_logs — 生成日志

| 字段 | 说明 |
| --- | --- |
| name_copybook_id | FK cascade |
| operator_id / operator_account | 操作者 ID 与账号快照（无 FK——快照语义，删除管理员不受阻） |
| operated_at | 操作时间 |

每条记录至少一条日志（创建与重新登记时各写一条）。

### 8.9 name_copybook_pdf_pages — pdf 单页（共享复用）

| 字段 | 说明 |
| --- | --- |
| character | 汉字内容：单字或姓名组合 |
| font_library_id | 单字页=字库表 ID；组合页恒 0（无 FK，应用层维护） |
| is_single_character | 是否单字页 |
| name_length / polyphonic_code | 单字页的编码=记录编码按下划线拆分后对应位置部分（如 2_4 → first 取 2）；组合页=完整编码 |
| layout_id / version_code / font / has_stroke_order | 生成上下文（boolean cast） |
| page_code | 创建本单页时关联的单页代码 |
| status | 初始**空串**=未生成（列默认值） |
| exception_message / force_regenerate | 异常描述 / 强制重新生成标记（未启用） |

唯一索引 `(version_code, font, has_stroke_order, character, font_library_id, page_code, polyphonic_code)`：

- 单字页实际唯一键 = 版本+字体+笔顺+汉字+**字库ID**+多音字编码（page_code 不参与）；
- 组合页（font_library_id 恒 0）= 版本+字体+笔顺+汉字+**单页代码**+多音字编码（full 与 fullext 同内容不同代码各自成单页）；
- 唯一键基于 version_code 不含 layout_id——**同版本同字体同笔顺的单页跨版式复用**；单页经 firstOrCreate 全局共享，被多条记录/关联引用。

### 8.10 name_copybook_pdf_relations — pdf 关联

| 字段 | 说明 |
| --- | --- |
| name_copybook_id | FK cascade |
| sort | 1-based，单页代码去重后首次出现顺序 |
| page_code | 每条记录每个单页代码一条关联（repeat 不展开为多条） |
| pdf_page_id | FK → pdf_pages（restrict） |
| status | 创建时同步单页状态；初始空串=未生成 |
| need_regenerate | 重新生成标记（未启用） |

## 9. 核心业务流程

### 9.1 登记流程（createPolyphonicRecord / createBatchRecords）

```
请求（batch_code + gender + layout_id + name(s) [+ polyphonic_code]）
  │  FormRequest 校验（LayoutInUse：版式须存在且 status=1）
  ▼
事务（mysql_copybook 连接，一次请求共用一个 now() 作为登记时间）
  │  lockForUpdate 取批内 max(batch_sequence)
  ▼
逐个姓名处理：
  ├─ 已存在相同记录（五字段唯一）→ 重新登记：
  │     写生成日志 + last_record_at = now()，状态保持不变
  └─ 不存在 → 新建记录（pending）+ 写生成日志，随后：
        ① 姓名含非中文字符 → name_abnormal「有字母/数字/特殊字符」（终止）
        ② 中文字数 ∉ [2,4] → name_abnormal「超出4个字」/「少于两个字」（终止）
        ③ 拆分单字并补全字库表（缺失则新增、字库标识全 0）；
           按版式 font 逐字验证字库 → 缺失 → font_abnormal「缺少字：X、Y」（终止）
        ④ 解析版式字数配置 → 代码不存在/引用未定义单页代码/取不到内容
           → other_abnormal（终止）
        ⑤ 分组单页代码去重（保留首现顺序，repeat 不展开）逐个 firstOrCreate pdf 单页
           （初始 status 空串）+ 每个单页代码一条 relation（sort=去重顺序、status 同步单页）
        ⑥ 全部成功 → 记录 processing、exception_message 置空
  ▼
响应 201：本次涉及记录（重新登记 + 新增）的状态汇总
```

多音字编码拆分规则：单字页取记录编码按下划线拆分后对应位置部分（`2_4` → first 取 `2`、second 取 `4`，超界为空串）；组合页使用完整编码。

### 9.2 单页 pdf 生成流程（generate-page-pdfs）

```
pdf_pages 中 status='' 的记录
  → node {script_root}/{version_code}/{font}/index_single.js|index.js
       --character --polyphonic_code --has_stroke_order --pdf_root
  → 退出码 0：page=completed，关联表同步
  → 非零/超时：page=other_abnormal（exit code+stderr，截断500字），关联表同步
```

### 9.3 整本 pdf 生成流程（generate-final-pdfs）

```
name_copybooks 中 processing 或 (completed 且 need_regenerate=1)
  → 关联单页未全部 completed → 跳过（等下一轮）
  → 任一单页 pdf 文件缺失 → 单页/关联/记录 三处 pdf_abnormal「生成pdf异常」
  → 按字数配置分组与 repeat 展开文件序列
       配置异常 → 记录 other_abnormal
  → libmergepdf 合并 → {pdf_root}/final/{batch_code}_{batch_sequence}_{name}.pdf
       合并异常 → 记录 other_abnormal「整本pdf合并失败：…」
  → 成功 → 记录 completed、need_regenerate=0
```

### 9.4 配置数据维护流程

```
调整 version_layouts.php / name_page_configs.php
  → php artisan copybook:sync-version-layouts        （建/改版式，含商品编码）
  → php artisan copybook:sync-layout-char-configs    （补字数配置代码）
  → php artisan copybook:sync-fonts                   （新字库文件入库）
```

## 10. 状态定义与流转

`Modules\Copybook\Enums\NameCopybookStatus`（记录 / 单页 / 关联共用，列为普通字符串）：

| 值 | 标签 | 使用位置 | 说明 |
| --- | --- | --- | --- |
| `''`（空串） | 未生成 | 单页/关联 | 单页初始状态；生成命令取空串记录 |
| pending | 未处理 | 记录 | 新记录初始状态（登记后即走校验，通常立即离开） |
| processing | 处理中 | 记录 | 关联生成完毕，等待单页/整本 pdf 生成 |
| completed | 已完成 | 记录/单页/关联 | 整本 pdf 已生成（单页 completed = 单页文件已生成） |
| name_abnormal | 姓名字数异常 | 记录 | 非中文/字数不在 2-4 |
| font_abnormal | 无字库异常 | 记录 | 姓名单字缺字库 |
| pdf_abnormal | 生成pdf异常 | 记录/单页/关联 | 单页 pdf 文件缺失 |
| other_abnormal | 其他异常 | 记录/单页/关联 | 配置异常、node 失败、合并失败等 |

**记录状态流转**：

```
                 ┌────────────── 登记校验异常 ──────────────┐
                 │ name_abnormal / font_abnormal / other_abnormal
                 ▼
新建 → pending ──→ processing ──→ 单页+文件+合并全部成功 → completed
                      │
                      ├─ 单页文件缺失 ──────────────→ pdf_abnormal
                      ├─ 配置异常/node失败/合并失败 → other_abnormal
                      └─ need_regenerate=1 的 completed 记录可重新进入合并流程
```

**单页/关联状态流转**：`''`（未生成）→ `completed`（node 成功）/ `other_abnormal`（node 失败）；整本命令发现文件缺失时改 `pdf_abnormal`。关联表状态始终与单页保持同步。

列表分组：**正在进行中** = pending + processing；**已完结** = 其余（completed + 各异常）。

## 11. 部署与运维

### 11.1 迁移

```bash
php artisan migrate --database=mysql_copybook --path=Modules/Copybook/database/migrations --no-interaction
```

> ⚠️ **不要**用 `php artisan module:migrate Copybook`——nwidart 在默认连接（job_passport）的迁移仓库记录执行状态，会导致整条迁移链重跑报"table already exists"。

### 11.2 存量库注意

job_copybook 实际执行 2026-10-18 060745 重设计迁移时的文件版本与提交版本不一致：存量库 `name_copybook_pdf_pages` 仍保留 page_code 字段（提交版本已删除），090000 迁移用 `hasColumn` 守卫兼容。**不要假设存量库结构完全等于迁移链产物**，写数据迁移前先 `SHOW COLUMNS` 核对实际结构。

### 11.3 新增依赖

整本 pdf 合并使用 `iio/libmergepdf` ^4.0（用户已批准，依赖 teckickcom/tcpdf + setasign/fpdi），部署时需 `composer install` 完整安装。运行环境需可执行 `node`。

### 11.4 周期任务建议

```cron
# 每 5 分钟：单页生成 + 整本合并（串行，单页成功才可能合并）
*/5 * * * * cd /path/to/job-laravel && php artisan copybook:generate-page-pdfs; php artisan copybook:generate-final-pdfs
```

## 12. 测试

- 模块测试位于 `Modules/Copybook/tests/Feature`，纳入根 `phpunit.xml` 的 Feature 套件；
- 基类 `Modules\Copybook\Tests\TestCase` 继承 `\Tests\TestCase`（FQCN 避免 use 冲突），使用 RefreshDatabase；`beforeRefreshingDatabase()` 把 `mysql_copybook` 重绑为框架完整 sqlite 配置并设为默认连接（模块与应用模型共享同一内存库）；
- 生成命令测试（GeneratePagePdfsCommandTest）在临时目录写真实 node 脚本验证传参，node 不可用时 markTestSkipped；GenerateFinalPdfsCommandTest 覆盖合并成功/文件缺失/配置异常路径；
- 运行：

```bash
php artisan test --compact Modules/Copybook/tests/Feature/NameCopybookTest.php   # 单文件
php artisan test --compact                                                       # 全量
```

已知测试陷阱：JWT guard 单例缓存已登录用户，同一测试内多操作者需按"登录→发完该操作者请求→再登录下一位"顺序调用。
