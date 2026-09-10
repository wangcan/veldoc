# ruoyi-vue-pro 角色权限模块移植结果

> 对应需求：`.requirements/develop/user-center.txt` 需求 4
> 参考项目：[ruoyi-vue-pro](https://github.com/YunaiV/ruoyi-vue-pro)（部署于 `/data/java/ruoyi-vue-pro/`）后台角色权限模块
> 落地位置：`Modules/UserCenter`（所有功能归入用户中心模块）
> RBAC 引擎：`spatie/laravel-permission`（角色权限基于 Spatie）

## 1. 总览

将 ruoyi-vue-pro（yudao）后台的「菜单 / 角色 / 角色权限」模块移植到 UserCenter 模块，保留 Spatie 作为底层 RBAC 引擎。核心思路：

- **菜单（Menu）**：独立建表 `system_menu`，承载 ruoyi 的目录/菜单/按钮三级树与 `permission` 标识符。
- **角色（Role）**：复用 Spatie 的 `roles` 表并扩展 ruoyi 字段（显示名、排序、状态、类型、数据范围等），角色 `code` 存入 Spatie 的 `name` 列。
- **角色↔菜单**：新增 `system_role_menu` 关联表；给角色分配菜单时，自动从菜单的 `permission` 标识符派生出 Spatie `Permission` 并 `syncPermissions` 到角色——从而让 ruoyi 的菜单权限模型与 Spatie 的权限校验无缝衔接。
- **超管绕过**：`Gate::before` 钩子，持有 `super_admin` 角色的用户通过所有授权检查（对应 ruoyi `hasAnySuperAdmin`）。

## 2. 数据库表

### 2.1 `system_menu`（新增）

迁移：`Modules/UserCenter/database/migrations/2026_09_09_000002_create_system_menu_table.php`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint unsigned PK | |
| name | varchar(50) | 菜单名称 |
| permission | varchar(100) default '' | 权限标识符，如 `system:user:create` |
| type | tinyint | 1=目录 2=菜单 3=按钮（`MenuTypeEnum`） |
| sort | int | 排序 |
| parent_id | bigint unsigned default 0 | 父级 ID，0 为根 |
| path | varchar(200) | 路由路径 |
| icon | varchar(100) default '#' | 图标 |
| component | varchar(255) nullable | 前端组件路径 |
| component_name | varchar(255) nullable | 组件名 |
| status | tinyint default 0 | 0=开启 1=禁用（`CommonStatusEnum`） |
| visible / keep_alive / always_show | boolean default true | 菜单展示属性 |
| created_at / updated_at | datetime | |
| deleted_at | datetime nullable | 软删除 |

索引：`parent_id`、`permission`。

### 2.2 `system_role_menu`（新增，关联表）

迁移：`2026_09_09_000003_create_system_role_menu_table.php`

| 字段 | 类型 |
| --- | --- |
| id | bigint PK |
| role_id | bigint unsigned |
| menu_id | bigint unsigned |
| created_at / updated_at | datetime |

约束：`unique(role_id, menu_id)`、`index(menu_id)`。

### 2.3 `roles` 表扩展（在 Spatie 原表上加列）

迁移：`2026_09_09_000001_add_ruoyi_fields_to_roles_table.php`

新增列：`display_name(30)`、`sort(int default 0)`、`status(tinyint default 0)`、`type(tinyint default 2)`、`remark(500 nullable)`、`data_scope(tinyint default 1)`、`data_scope_dept_ids(json nullable)`。

> `roles.name` 仍由 Spatie 使用，存放角色 `code`（如 `super_admin`、`common`、`test_role`）。

## 3. 枚举

`Modules/UserCenter/app/Enums/`

| 枚举 | 值 | 对应 ruoyi |
| --- | --- | --- |
| `MenuTypeEnum` | Dir=1, Menu=2, Button=3 | MenuTypeEnum（含 `isDirOrMenu()`） |
| `RoleTypeEnum` | System=1, Custom=2 | RoleTypeEnum |
| `DataScopeEnum` | All=1, DeptCustom=2, DeptOnly=3, DeptAndSub=4, Self=5 | DataScopeEnum |
| `CommonStatusEnum` | Enable=0, Disable=1 | CommonStatusEnum（含 `isEnable()/isDisable()`） |

## 4. 模型

`Modules/UserCenter/app/Models/`

- **`Menu`**（`$table = 'system_menu'`）：`const ID_ROOT = 0`；`parent`/`children` 自关联；`roles()` belongsToMany → `config('permission.models.role')` 经 `system_role_menu`；`enabled` scope；type/status/visible/keep_alive/always_show 类型转换。
- **`Role`**（`extends Spatie\Permission\Models\Role`）：status/type/data_scope 枚举转换，`data_scope_dept_ids` 转 array；`menus()` belongsToMany Menu；`isSystem()`/`isSuperAdmin()`；`static superAdminCode()` 返回 `'super_admin'`。
- `config/permission.php` 的 `models.role` 已指向 `Modules\UserCenter\Models\Role`。

## 5. 服务层

`Modules/UserCenter/app/Services/`

- **`MenuService`**：菜单 CRUD、列表/简单列表、树构建（`buildTree` 递归）、父级与同级校验、按钮类型清理 component/icon/path（`initMenuProperty`）。
- **`RoleService`**：角色 CRUD（禁止创建 `super_admin` code、禁止删除系统角色）、分页查询（按 name/code/status/时间过滤）、数据范围更新、超管检测。
- **`PermissionService`**：核心桥接逻辑
  - `getRoleMenuListByRoleId($roleIds)`：超管返回全部菜单 ID，否则取角色关联菜单。
  - `assignRoleMenu(roleId, menuIds)`：同步 `system_role_menu`，再调 `syncRolePermissions`。
  - `syncRolePermissions(roleId)`：join `system_menu` + `system_role_menu`，收集非空 `permission` 标识符，`Permission::firstOrCreate` 后 `role->syncPermissions`。
  - `processRoleDeleted` / `processMenuDeleted`：清理关联表并重新同步受影响角色的 Spatie 权限。
  - `assignUserRole(userId, roleIds)`：role id → code，`user->syncRoles(codes)`。
  - `getMenuTreeByUserId` / `getUserPermissions`：超管权限返回 `['*']`，否则取用户 Spatie 权限。
  - `assignRoleDataScope`：更新角色数据范围。

## 6. API 端点

前缀 `/api/v1/user-center`，除 `auth/permission-info` 外均经 `auth:api` + 对应 `permission:` 中间件。

### 菜单 `menus`
| 方法 | 路径 | 权限 |
| --- | --- | --- |
| GET | `/menus` | `system:menu:query` |
| GET | `/menus/simple-list` | （登录即可） |
| GET | `/menus/{id}` | `system:menu:query` |
| POST | `/menus` | `system:menu:create` |
| PUT | `/menus/{id}` | `system:menu:update` |
| DELETE | `/menus/{id}` | `system:menu:delete` |

### 角色 `roles`
| 方法 | 路径 | 权限 |
| --- | --- | --- |
| GET | `/roles`（分页+meta） | `system:role:query` |
| GET | `/roles/simple-list` | （登录即可） |
| GET | `/roles/{id}` | `system:role:query` |
| POST | `/roles` | `system:role:create` |
| PUT | `/roles/{id}` | `system:role:update` |
| DELETE | `/roles/{id}` | `system:role:delete` |

### 权限分配 `permissions`
| 方法 | 路径 | 权限 |
| --- | --- | --- |
| GET | `/permissions/role-menus?roleId=` | `system:permission:assign-role-menu` |
| POST | `/permissions/assign-role-menu` | `system:permission:assign-role-menu` |
| POST | `/permissions/assign-role-data-scope` | `system:permission:assign-role-data-scope` |
| GET | `/permissions/user-roles?userId=` | `system:permission:assign-user-role` |
| POST | `/permissions/assign-user-role` | `system:permission:assign-user-role` |

### 当前用户权限信息
| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/auth/permission-info` | 返回 `user` / `roles` / `permissions` / `menus(树)`，超管权限为 `['*']` |

## 7. Spatie 桥接设计

```
system_menu.permission  ──派生──▶  Spatie Permission (name = 标识符)
        │
system_role_menu ──关联──▶ Role
        │
assignRoleMenu() ──▶ syncRolePermissions() ──▶ role->syncPermissions(派生权限)
```

- ruoyi 角色 `code` ↔ Spatie `roles.name`；`display_name` 等扩展字段在额外列。
- 给角色分配菜单 ⇒ 自动同步派生 Spatie 权限，因此路由上的 `permission:system:xxx:yyy` 中间件可直接生效。
- 用户分配角色 ⇒ `user->syncRoles(codes)`，沿用 Spatie 的 `role_user` pivot。
- 超管走 `Gate::before` 绕过，不依赖权限明细。

## 8. 关键设计决策：RBAC 守卫固定为 `web`

> 本节记录移植过程中发现并修复的既有缺陷。

**问题**：认证使用 `api`（JWT）守卫，`auth:api` 中间件会在请求期把 `config('auth.defaults.guard')` 运行时改为 `api`（`Auth::shouldUse('api')`）。Spatie 的 `Guard::getDefaultName()` 读取该配置，于是 HTTP 请求内 `$user->syncRoles()` / `hasPermissionTo()` 会在 `api` 守卫下查找角色权限；但所有角色/权限是在 CLI/PHP 上下文按 `web` 守卫种子的。结果：非超管用户在 HTTP 内一律 403（既有 `UserApiTest` 已有 4 个 403 失败），`assignUserRole` 抛 `RoleDoesNotExist ... for guard api`。

**修复**：在 `app/Models/User.php` 增加 `protected $guard_name = 'web';`，把 Spatie 的角色/权限查找固定到 `web` 守卫命名空间，与认证守卫 `api` 解耦。

**效果**：
- `RuoyiPermissionTest` 13/13 通过。
- 既有 `UserApiTest` 由 4/8 → 8/8 全通过（修复了 4 个既有 403 失败）。
- 全量测试 38/40，剩余 2 个为**与本次需求无关的既有失败**（见下）。

## 9. 种子数据

`Modules/UserCenter/database/seeders/RuoyiPermissionSeeder.php`（已加入 `UserCenterDatabaseSeeder`）：

- 20 条 `system_menu`（系统管理目录 + 用户/角色/菜单管理 + 按钮级权限，如 `system:user:query/create/update/delete`、`system:role:*`、`system:menu:*`、`system:permission:assign-role-menu` 等）。
- 由菜单标识符派生的 Spatie `Permission`。
- 内置角色：`super_admin`（System 类型，分配全部菜单/权限）、`common`（System 类型，分配用户管理相关菜单）。
- 经 `PermissionService::assignRoleMenu` 分配，自动同步 Spatie 权限。

## 10. 移植范围与取舍

**已移植**：菜单树与 CRUD、角色 CRUD、角色-菜单分配、用户-角色分配、角色数据范围元数据、超管绕过、当前用户权限信息接口。

**未移植/存根**：
- **数据权限（DataScope）查询过滤**：`data_scope` 字段已落库并可更新，但 ruoyi 的「按部门/本人过滤数据」依赖部门（dept）模块，当前项目无部门模块，故数据范围的运行时查询过滤为存根，待部门模块就绪后补齐。
- ruoyi 的 `PermissionController.assignRoleDataScope` 仅更新角色 `data_scope` / `data_scope_dept_ids` 元数据。
- 前端组件路径（`component`/`component_name`）仅作存储，无前端渲染。

## 11. 测试

`tests/Feature/UserCenter/RuoyiPermissionTest.php`（13 个用例，`RefreshDatabase` + `RuoyiPermissionSeeder`）：

菜单：列表、新增、修改、无子级删除、有子级禁止删除（400）。
角色：分页列表、新增自定义角色、禁止创建 `super_admin` code。
权限分配：角色-菜单分配并断言 Spatie 权限已同步、用户-角色分配、获取角色菜单 ID。
权限信息：超管 `permission-info` 返回菜单树且权限含 `['*']`。
鉴权：普通用户访问菜单管理返回 403。

运行：
```bash
php artisan test --compact tests/Feature/UserCenter/RuoyiPermissionTest.php
```

## 12. 既有失败（与本次需求无关）

全量 `php artisan test --compact` 为 38/40，剩余 2 个在本次改动前已失败（已通过 `git stash` 验证）：

1. `Tests\Feature\ExampleTest` — `GET /` 渲染 `welcome` 视图，但 `resources/views/` 已随「remove frontend」提交移除。属遗留样板测试。
2. `Tests\Feature\UserCenter\AuthApiTest::test_token_can_be_refreshed` — JWT `TokenBlacklistedException`，属 JWT 黑名单/测试隔离问题，与 RBAC 无关。

## 13. 变更文件清单

新增：
- `Modules/UserCenter/app/Enums/{MenuTypeEnum,RoleTypeEnum,DataScopeEnum,CommonStatusEnum}.php`
- `Modules/UserCenter/app/Models/{Menu,Role}.php`
- `Modules/UserCenter/app/Http/Resources/{MenuResource,MenuSimpleResource,RoleResource,RoleSimpleResource}.php`
- `Modules/UserCenter/app/Services/{MenuService,RoleService,PermissionService}.php`
- `Modules/UserCenter/app/Http/Controllers/Api/V1/{MenuController,RoleController,PermissionController}.php`
- `Modules/UserCenter/database/migrations/2026_09_09_00000{1,2,3}_*.php`
- `Modules/UserCenter/database/seeders/RuoyiPermissionSeeder.php`
- `tests/Feature/UserCenter/RuoyiPermissionTest.php`

修改：
- `app/Models/User.php`（新增 `$guard_name = 'web'`）
- `config/permission.php`（`models.role` 指向本模块 Role）
- `Modules/UserCenter/routes/api.php`（菜单/角色/权限路由组 + `auth/permission-info`）
- `Modules/UserCenter/app/Http/Controllers/Api/V1/AuthController.php`（`permissionInfo` 方法）
- `Modules/UserCenter/app/Providers/UserCenterServiceProvider.php`（`Gate::before` 超管绕过）
- `Modules/UserCenter/database/seeders/UserCenterDatabaseSeeder.php`（调用 `RuoyiPermissionSeeder`）

## 14. 验证方式

```bash
# 迁移 + 种子
php artisan migrate
php artisan db:seed --class=Modules\\UserCenter\\Database\\Seeders\\RuoyiPermissionSeeder

# 路由
php artisan route:list | grep -iE "menus|roles|permissions"

# 测试
php artisan test --compact tests/Feature/UserCenter/RuoyiPermissionTest.php
```
