# UserCenter 模块产品需求文档（反向整理）

> 本文档基于 UserCenter 模块当前的**数据表结构、接口实现与业务代码**反向整理而成，描述模块「现在是什么、能做什么、遵循哪些规则」，作为后续需求演进与团队对齐的基线。
>
 - 技术栈：Laravel 13 + PHP 8.4，纯后端 API（无服务端模板），前端为独立应用消费 API。
 - 权限引擎：`spatie/laravel-permission`，并桥接 ruoyi-vue-pro 的菜单授权模型。
 - 认证：`php-open-source-saver/jwt-auth`（JWT）。
 - 模块化：基于 `nwidart/laravel-modules`，所有功能归属 UserCenter 模块。

---

## 1. 模块概述

UserCenter 是系统的用户与权限中心，承担四大职责：

1. **认证（Authentication）**：账号密码登录、手机号验证码登录、注册、登出、Token 刷新、当前用户信息获取。
2. **用户管理（User Management）**：用户的增删改查、个人资料、修改密码、状态流转（激活/停用/封禁）、逻辑删除。
3. **角色管理（Role Management）**：角色的增删改查、精简列表、数据权限范围分配。
4. **菜单与权限管理（Menu & Permission Management）**：菜单树增删改查、角色-菜单分配、角色数据权限分配、用户-角色分配、登录用户的菜单/权限聚合信息。

---

## 2. 数据模型

### 2.1 `users` 用户表

| 字段 | 类型 | 可空 | 默认 | 说明 |
| --- | --- | --- | --- | --- |
| id | bigint unsigned PK | 否 | auto | 主键 |
| name | varchar(255) | 否 | — | 登录账号；**DB 唯一索引**，可用 name+password 登录 |
| nickname | varchar(50) | 是 | null | 昵称 |
| email | varchar(255) | 是 | null | 邮箱；**允许为空**，无 DB 唯一索引，非空时由应用层 `unique:users,email` 校验全表唯一 |
| phone | varchar(50) | 是 | null | 手机号；DB 唯一索引（加宽至 50 以容纳删除后缀） |
| email_verified_at | timestamp | 是 | null | 邮箱验证时间 |
| phone_verified_at | timestamp | 是 | null | 手机验证时间 |
| password | varchar(255) | 否 | — | 密码（hashed cast，bcrypt） |
| status | enum('active','inactive','banned') | 否 | 'active' | 用户状态 |
| is_deleted | tinyint(1) | 否 | 0 | **逻辑删除标记位**（非 SoftDeletes）；=1 时禁止登录，但状态/角色/权限保留 |
| token_version | int unsigned | 否 | 0 | **JWT 版本号**；改密码时 +1，用于吊销历史 Token |
| avatar | varchar(255) | 是 | null | 头像 URL |
| remember_token | varchar(100) | 是 | null | — |
| created_at / updated_at | timestamp | 是 | null | — |

**索引**：主键、`users_name_unique`（name 唯一）、`users_phone_unique`（phone 唯一）、`users_is_deleted_index`。

> 注意：`email` **没有** DB 唯一索引，唯一性仅在非空时由应用层校验保证，允许多个 NULL 邮箱共存。

### 2.2 `roles` 角色表（扩展 Spatie）

在 Spatie 原 `roles` 表（id、name、guard_name、timestamps）基础上扩展 ruoyi 字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| name | varchar(255) | **角色编码（code）**，存入 Spatie 的 `name` 列，供 assignRole/hasRole/中间件使用 |
| display_name | varchar(30) | 角色显示名称（人类可读） |
| sort | int | 显示顺序，默认 0 |
| status | tinyint | 角色状态（0 正常 / 1 停用） |
| type | tinyint | 角色类型（1 内置系统角色 / 2 自定义角色） |
| remark | varchar(500) | 备注 |
| data_scope | tinyint | 数据范围（1 全部 / 2 自定义部门 / 3 本部门 / 4 本部门及以下 / 5 仅本人） |
| data_scope_dept_ids | json | 数据范围指定的部门 ID 数组（仅 data_scope=2 时使用） |
| guard_name | varchar(255) | Spatie 守卫名（固定 `web`） |

**唯一索引**：`roles_name_guard_name_unique`（name + guard_name）。

> 角色的「编码」与「显示名」分离：`name` 存编码（如 `super_admin`），`display_name` 存中文名（如「超级管理员」）。

### 2.3 `system_menu` 菜单表

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint unsigned PK | 菜单 ID |
| name | varchar(50) | 菜单名称 |
| permission | varchar(100) | 权限标识（如 `system:user:list`），按钮/菜单可空 |
| type | tinyint | 菜单类型（1 目录 / 2 菜单 / 3 按钮） |
| sort | int | 显示顺序 |
| parent_id | bigint unsigned | 父菜单 ID（0 = 根） |
| path | varchar(200) | 前端路由地址 |
| icon | varchar(100) | 菜单图标 |
| component | varchar(255) | 前端组件路径（可空，按钮类型清空） |
| component_name | varchar(255) | 前端组件名（可空） |
| status | tinyint | 菜单状态（0 开启 / 1 关闭） |
| visible | tinyint(1) | 是否可见，默认 1 |
| keep_alive | tinyint(1) | 是否缓存，默认 1 |
| always_show | tinyint(1) | 是否总是显示，默认 1 |
| created_at / updated_at | timestamp | — |
| deleted_at | timestamp | **软删除**（SoftDeletes） |

**索引**：`parent_id`、`permission`。

### 2.4 `system_role_menu` 角色-菜单关联表

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint unsigned PK | — |
| role_id | bigint unsigned | 角色 ID |
| menu_id | bigint unsigned | 菜单 ID |
| created_at / updated_at | timestamp | — |

**唯一索引**：`(role_id, menu_id)`；**普通索引**：`menu_id`。

### 2.5 Spatie 标准权限表

- `permissions`：id、name（权限标识）、guard_name、timestamps。唯一索引 `(name, guard_name)`。
- `role_has_permissions`：permission_id + role_id 联合主键，外键级联删除。
- `model_has_roles`：role_id + model_id + model_type 联合主键（用户-角色绑定），role_id 外键级联删除。
- `model_has_permissions`：permission_id + model_id + model_type（用户直接权限绑定）。

> **桥接设计**：给角色分配菜单时，会从各菜单的 `permission` 标识派生出 Spatie 权限，同步写入 `role_has_permissions`，使 `permission` 中间件按标识鉴权生效。

---

## 3. 认证与授权设计

### 3.1 JWT 认证

- 守卫：`api`（`config/auth.php`），驱动为自定义 `jwt-version`，provider 为 Eloquent `users`。
- 登录方式：支持 **email / phone / name** 三种账号 + 密码登录，也支持手机号 + 短信验证码登录。
- Token 签发：`JWTAuth::fromUser($user)`，将用户的 `token_version` 作为自定义声明（claim）写入 payload。
- Token 校验：除签名与过期校验外，自定义守卫 `TokenVersionJwtGuard` 比对 payload 中 `token_version` 与用户当前值，**不一致直接拒绝（401）**。
- Token 刷新：`token_version` 列入 `jwt.persistent_claims`，刷新后保留版本号，避免刷新即失效。
- Token 版本号默认 0；**用户修改密码时 `token_version` +1**，从而吊销所有此前签发的 Token。
- 旧 Token（无 `token_version` 声明）视为版本 0，与从未改密的用户兼容。

### 3.2 RBAC 授权

- 角色权限基于 `spatie/laravel-permission`。
- **超级管理员旁路**：持有 `super_admin` 角色的用户通过 `Gate::before` 放行所有鉴权（`hasAnySuperAdmin` 语义）。
- **守卫锁定**：`User` 模型声明 `protected $guard_name = 'web';`，将 Spatie 角色权限查询固定到 `web` 命名空间，与 JWT 的 `api` 守卫解耦，避免 `auth:api` 中间件运行时改写默认守卫导致角色查不到（403 / `RoleDoesNotExist ... for guard api`）。
- 菜单授权模型（ruoyi 风格）：菜单带 `permission` 标识，角色通过 `system_role_menu` 关联菜单；派生权限同步到 Spatie `role_has_permissions`。
- 超级管理员拥有全部菜单，权限标识返回 `['*']`。

### 3.3 登录凭证查找与删除用户

- 凭证查找顺序：email → phone → name，均经 `notDeleted()` 作用域过滤（`is_deleted=0`）。
- **逻辑删除（tombstone）**：删除用户时 `is_deleted` 置 1，**不硬删**；同时给 name、非空 email、phone 追加 `__deleted_{id}` 后缀，释放原值供新用户复用，同时保持各删除行的值唯一。删除用户的状态、角色、权限保留，但禁止登录。

---

## 4. 功能需求

### 4.1 认证模块（Auth）

| 接口 | 方法 | 路径 | 鉴权 | 权限 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 账号密码登录 | POST | `/auth/login` | 公开 | — | 入参 `login`（email/phone/name）、`password` |
| 手机验证码登录 | POST | `/auth/login-phone` | 公开 | — | 入参 `phone`（正则 `^1[3-9]\d{9}$`）、`code`（6 位）；校验 `login_register` 场景短信码，用户不存在则自动创建 |
| 注册 | POST | `/auth/register` | 公开 | — | name 唯一、email 可空且唯一、phone 可空且唯一、password confirmed；注册后分配默认角色 `user` 并签发 Token |
| 当前用户 | GET | `/auth/me` | 需登录 | — | 返回当前登录用户 |
| 权限信息 | GET | `/auth/permission-info` | 需登录 | — | 返回用户基本信息、角色列表、权限标识列表、菜单树（供前端构建侧边栏与按钮守卫） |
| 登出 | POST | `/auth/logout` | 需登录 | — | 失效当前 Token（加入黑名单） |
| 刷新 Token | POST | `/auth/refresh` | 需登录 | — | 旧 Token 入黑名单，签发新 Token；保留 `token_version` |

**登录响应数据结构**：`access_token`、`token_type`（bearer）、`expires_in`（秒）、`user`（id、name、email、phone、status、roles、permissions）。

**业务规则**：
- 凭证错误 / 用户已删除 → 返回「Invalid credentials」（不泄露具体原因）。
- 用户状态非 active → 返回「Account is not active」。
- 手机验证码登录：用户不存在时 `firstOrCreate`，随机生成密码，标记 `phone_verified_at`。

### 4.2 用户管理模块（User）

| 接口 | 方法 | 路径 | 鉴权 | 权限 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 用户列表 | GET | `/users` | 需登录 | `manage-users` | 分页；筛选 status/search/role；`per_page` 用 `integer()` 取值 |
| 创建用户 | POST | `/users` | 需登录 | `manage-users` | name 必填唯一、email 可空唯一、phone 可空唯一、password 必填、roles 可选 |
| 用户详情 | GET | `/users/{id}` | 需登录 | `manage-users` | — |
| 更新用户 | PUT | `/users/{id}` | 需登录 | `manage-users` | 含改密（password 存在时触发 `token_version` +1）；roles 存在时同步 |
| 删除用户 | DELETE | `/users/{id}` | 需登录 | `manage-users` | 逻辑删除：`is_deleted=1` + 唯一字段加后缀；幂等 |
| 激活用户 | POST | `/users/{id}/activate` | 需登录 | `manage-users` | status → active |
| 停用用户 | POST | `/users/{id}/deactivate` | 需登录 | `manage-users` | status → inactive |
| 封禁用户 | POST | `/users/{id}/ban` | 需登录 | `manage-users` | status → banned |
| 个人资料 | GET | `/users/profile` | 需登录 | — | 返回当前用户 |
| 更新资料 | PUT | `/users/profile` | 需登录 | — | name/nickname/avatar |
| 修改密码 | POST | `/users/change-password` | 需登录 | — | 校验 `current_password`；新密码 confirmed；改密后 `token_version` +1 |
| 同步用户角色 | POST | `/users/{id}/roles` | 需登录 | `manage-users` | 入参 `roles`（角色名数组，可空）；先收回全部角色再分配提交的，空数组 = 无角色 |
| 同步用户权限 | POST | `/users/{id}/permissions` | 需登录 | `manage-users` | 入参 `permissions`（权限名数组，可空）；先收回全部权限再分配，空数组 = 无权限 |

**业务规则**：
- name 全表唯一（DB 索引）；email 非空时全表唯一（应用层校验，排除自身 id）；phone 全表唯一（DB 索引，排除自身 id）。
- `per_page` 等数值入参用 `$request->integer()`，避免空串被转 null 后触发类型错误。
- 角色/权限同步为「合并接口」：`syncRoles` / `syncPermissions`，空入参即清空。

### 4.3 角色管理模块（Role）

| 接口 | 方法 | 路径 | 鉴权 | 权限 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 角色分页列表 | GET | `/roles` | 需登录 | `system:role:query` | 筛选 name/code/status/start_time/end_time；分页 |
| 创建角色 | POST | `/roles` | 需登录 | `system:role:create` | 入参 name（显示名）、code（编码）、sort、remark |
| 角色详情 | GET | `/roles/{id}` | 需登录 | `system:role:query` | — |
| 更新角色 | PUT | `/roles/{id}` | 需登录 | `system:role:update` | — |
| 删除角色 | DELETE | `/roles/{id}` | 需登录 | `system:role:delete` | 仅自定义角色可删；删除后清理角色-菜单与用户-角色关联 |
| 角色精简列表 | GET | `/roles/simple-list` | 需登录 | — | 返回启用状态角色（id/name/code），供下拉选项 |

**业务规则**：
- 角色 code 存入 Spatie `name` 列，display_name 存显示名。
- **禁止创建编码为 `super_admin` 的角色**。
- 角色编码（code）与显示名（display_name）各自全表唯一（排除自身 id）。
- **内置系统角色（type=1）不可修改、不可删除**。
- 删除角色时联动清理 `system_role_menu`，并重算受影响角色的派生权限。

### 4.4 菜单管理模块（Menu）

| 接口 | 方法 | 路径 | 鉴权 | 权限 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 菜单列表 | GET | `/menus` | 需登录 | `system:menu:query` | 筛选 name/status；按 sort 排序，返回集合（非分页） |
| 创建菜单 | POST | `/menus` | 需登录 | `system:menu:create` | 见下方字段校验 |
| 菜单详情 | GET | `/menus/{id}` | 需登录 | `system:menu:query` | — |
| 更新菜单 | PUT | `/menus/{id}` | 需登录 | `system:menu:update` | — |
| 删除菜单 | DELETE | `/menus/{id}` | 需登录 | `system:menu:delete` | 软删除；有子菜单不可删 |
| 菜单精简列表 | GET | `/menus/simple-list` | 需登录 | — | 返回启用菜单（id/name/parentId/type） |

**菜单字段校验**：name（必填，max 50）、permission（可空，max 100）、type（必填，1/2/3）、sort（必填整数）、parent_id（必填，≥0）、path、icon、component、component_name、status（必填，0/1）、visible/keep_alive/always_show（可空布尔）。

**业务规则**：
- 菜单类型：1 目录、2 菜单、3 按钮。
- **同级同父菜单名唯一**（同一 parent_id 下 name 不可重复，排除自身 id）。
- 父菜单校验：不能设自己为父；父菜单须存在（根 0 除外）；父菜单须为目录或菜单类型（按钮不可为父）。
- 按钮类型菜单不携带 component/component_name/icon/path（初始化时清空）。
- **有子菜单的菜单不可删除**；删除菜单后联动清理 `system_role_menu` 并重算受影响角色派生权限。

### 4.5 权限管理模块（Permission）

| 接口 | 方法 | 路径 | 鉴权 | 权限 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 角色菜单列表 | GET | `/permissions/role-menus` | 需登录 | `system:permission:assign-role-menu` | 入参 `roleId`；返回该角色的菜单 id 数组（超管返回全部） |
| 分配角色菜单 | POST | `/permissions/assign-role-menu` | 需登录 | `system:permission:assign-role-menu` | 入参 `role_id`、`menu_ids`（可空）；同步角色-菜单，并重算派生 Spatie 权限 |
| 分配角色数据权限 | POST | `/permissions/assign-role-data-scope` | 需登录 | `system:permission:assign-role-data-scope` | 入参 `role_id`、`data_scope`（1-5）、`data_scope_dept_ids`（可空，仅 data_scope=2 生效） |
| 用户角色列表 | GET | `/permissions/user-roles` | 需登录 | `system:permission:assign-user-role` | 入参 `userId`；返回用户角色 id 数组 |
| 分配用户角色 | POST | `/permissions/assign-user-role` | 需登录 | `system:permission:assign-user-role` | 入参 `user_id`、`role_ids`（可空）；同步用户角色 |

**业务规则**：
- 角色菜单分配：同步 `system_role_menu` 后，从所分配菜单的 `permission` 标识派生 Spatie 权限记录（不存在则创建），并 `syncPermissions` 到角色。
- 数据范围 `data_scope`：1 全部、2 自定义部门、3 本部门、4 本部门及以下、5 仅本人；仅 2 时写入 `data_scope_dept_ids`，其余置 null。
- 用户角色分配：将角色 id 解析为编码（Spatie `name`）后 `syncRoles`。

---

## 5. 内置种子数据

### 5.1 菜单树（`RuoyiPermissionSeeder`）

```
1  系统管理（目录）
├─ 100 用户管理（菜单, system:user:list）
│   ├─ 1001 用户查询（按钮, system:user:query）
│   ├─ 1002 用户新增（按钮, system:user:create）
│   ├─ 1003 用户修改（按钮, system:user:update）
│   ├─ 1004 用户删除（按钮, system:user:delete）
│   └─ 1005 重置密码（按钮, system:user:update-password）
├─ 101 角色管理（菜单, system:role:list）
│   ├─ 1008 角色查询 / 1009 角色新增 / 1010 角色修改 / 1011 角色删除
│   ├─ 1012 角色菜单分配（system:permission:assign-role-menu）
│   ├─ 1013 角色数据权限（system:permission:assign-role-data-scope）
│   └─ 1014 用户角色分配（system:permission:assign-user-role）
└─ 102 菜单管理（菜单, system:menu:list）
    └─ 1015 菜单查询 / 1016 菜单新增 / 1017 菜单修改 / 1018 菜单删除
```

### 5.2 内置角色

| 编码 | 显示名 | 类型 | 菜单范围 |
| --- | --- | --- | --- |
| `super_admin` | 超级管理员 | 内置系统 | 全部菜单（→ 全部权限，旁路 Gate） |
| `common` | 普通角色 | 内置系统 | 用户管理菜单（100 及其按钮） |

### 5.3 超级管理员账号（`SuperAdminSeeder`）

- 预置账号：phone `13811974106`，name `superadmin`，email `superadmin@example.com`，初始密码 `123456`，分配 `super_admin` 角色。

### 5.4 通用角色权限（`RolePermissionSeeder`，兼容旧 RBAC）

另维护一套通用权限标识（view/create/update/delete-users、manage-users、view-roles … 等）与角色 `super-admin`、`admin`、`manager`、`user`，供非 ruoyi 风格的鉴权使用。

---

## 6. 统一响应契约

所有 API 响应经 `NormalizeApiResponse` 中间件归一化：

- **成功**：HTTP 200，`{ "success": true, "code": 0, "data": ..., ... }`（201/204 等成功状态归一为 200，code 0）。
- **业务失败**：HTTP 200，`{ "success": false, "code": 1, "message": "..." }`（4xx 业务错误归一为 200，code 1，错误信息用 `message` 返回）。
- **保留原始状态**的特殊情况：401（未认证）、404（未找到）、500（服务端错误）保持原状态码，code 1。
- 未认证请求返回 401 `{"message":"Unauthenticated."}`（纯 API 后台无 `login` 路由，guest 重定向置空，避免 500）。
- 验证失败（422）归一为 200 + code 1 + `errors`。
- 分页响应附 `meta`（current_page/last_page/per_page/total）与可选 `links`。

> 业务校验类错误（如「Menu with the same name already exists under this parent」「Built-in system roles cannot be modified or deleted」）以 `\DomainException` 抛出，控制器统一捕获后走 `errorResponse`，遵循上述失败契约。

---

## 7. 关键业务规则汇总

1. **用户登录账号**：name（DB 唯一）、email（可空、非空时应用层唯一）、phone（DB 唯一）三选一登录。
2. **逻辑删除**：`is_deleted=1` 禁止登录，状态/角色/权限保留，唯一字段加 `__deleted_{id}` 后缀释放原值。
3. **Token 版本管理**：JWT payload 携带 `token_version`；改密 +1；校验不一致即拒；刷新保留版本；旧 Token 视为 0。
4. **角色编码隔离**：角色 code 存 Spatie `name`，`super_admin` 编码禁止手动创建；内置角色不可改删。
5. **菜单同级唯一**：同一父菜单下 name 不可重复；按钮类型无组件；有子菜单不可删。
6. **权限派生桥接**：角色分配菜单 → 派生 Spatie 权限标识 → 同步 `role_has_permissions`；`permission` 中间件按标识鉴权。
7. **守卫锁定**：`User::$guard_name = 'web'`，Spatie 查询与 JWT `api` 守卫解耦。
8. **数值入参**：分页等数值用 `$request->integer()`，避免空串转 null 触发类型错误。

---

## 8. 接口清单（全量 37 条）

| # | 方法 | 路径 | 鉴权 | 权限标识 |
| --- | --- | --- | --- | --- |
| 1 | POST | `/api/v1/user-center/auth/login` | 公开 | — |
| 2 | POST | `/api/v1/user-center/auth/login-phone` | 公开 | — |
| 3 | POST | `/api/v1/user-center/auth/register` | 公开 | — |
| 4 | GET | `/api/v1/user-center/auth/me` | 需登录 | — |
| 5 | GET | `/api/v1/user-center/auth/permission-info` | 需登录 | — |
| 6 | POST | `/api/v1/user-center/auth/logout` | 需登录 | — |
| 7 | POST | `/api/v1/user-center/auth/refresh` | 需登录 | — |
| 8 | GET | `/api/v1/user-center/users` | 需登录 | `manage-users` |
| 9 | POST | `/api/v1/user-center/users` | 需登录 | `manage-users` |
| 10 | GET | `/api/v1/user-center/users/profile` | 需登录 | — |
| 11 | PUT | `/api/v1/user-center/users/profile` | 需登录 | — |
| 12 | POST | `/api/v1/user-center/users/change-password` | 需登录 | — |
| 13 | GET | `/api/v1/user-center/users/{id}` | 需登录 | `manage-users` |
| 14 | PUT | `/api/v1/user-center/users/{id}` | 需登录 | `manage-users` |
| 15 | DELETE | `/api/v1/user-center/users/{id}` | 需登录 | `manage-users` |
| 16 | POST | `/api/v1/user-center/users/{id}/activate` | 需登录 | `manage-users` |
| 17 | POST | `/api/v1/user-center/users/{id}/deactivate` | 需登录 | `manage-users` |
| 18 | POST | `/api/v1/user-center/users/{id}/ban` | 需登录 | `manage-users` |
| 19 | POST | `/api/v1/user-center/users/{id}/roles` | 需登录 | `manage-users` |
| 20 | POST | `/api/v1/user-center/users/{id}/permissions` | 需登录 | `manage-users` |
| 21 | GET | `/api/v1/user-center/roles` | 需登录 | `system:role:query` |
| 22 | POST | `/api/v1/user-center/roles` | 需登录 | `system:role:create` |
| 23 | GET | `/api/v1/user-center/roles/simple-list` | 需登录 | — |
| 24 | GET | `/api/v1/user-center/roles/{id}` | 需登录 | `system:role:query` |
| 25 | PUT | `/api/v1/user-center/roles/{id}` | 需登录 | `system:role:update` |
| 26 | DELETE | `/api/v1/user-center/roles/{id}` | 需登录 | `system:role:delete` |
| 27 | GET | `/api/v1/user-center/menus` | 需登录 | `system:menu:query` |
| 28 | POST | `/api/v1/user-center/menus` | 需登录 | `system:menu:create` |
| 29 | GET | `/api/v1/user-center/menus/simple-list` | 需登录 | — |
| 30 | GET | `/api/v1/user-center/menus/{id}` | 需登录 | `system:menu:query` |
| 31 | PUT | `/api/v1/user-center/menus/{id}` | 需登录 | `system:menu:update` |
| 32 | DELETE | `/api/v1/user-center/menus/{id}` | 需登录 | `system:menu:delete` |
| 33 | GET | `/api/v1/user-center/permissions/role-menus` | 需登录 | `system:permission:assign-role-menu` |
| 34 | POST | `/api/v1/user-center/permissions/assign-role-menu` | 需登录 | `system:permission:assign-role-menu` |
| 35 | POST | `/api/v1/user-center/permissions/assign-role-data-scope` | 需登录 | `system:permission:assign-role-data-scope` |
| 36 | GET | `/api/v1/user-center/permissions/user-roles` | 需登录 | `system:permission:assign-user-role` |
| 37 | POST | `/api/v1/user-center/permissions/assign-user-role` | 需登录 | `system:permission:assign-user-role` |

---

*本文档由代码与数据表反向整理，反映当前实现现状，后续需求变更应以本文档为基线迭代。*
