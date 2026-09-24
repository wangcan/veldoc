# job_passport 数据清空事故与恢复记录

> 对应需求：`.requirements/modules/usercenter/task.txt` 需求3（角色/权限合并接口）
> 完成日期：2026-09-22
> 性质：测试误清生产库数据的事故记录、恢复过程、根因修复。

## 一、事故概述

在实现需求3（给用户分配和收回角色/权限合并成一个接口）过程中，运行 PHPUnit 测试时，
`UserApiTest` 等用例使用的 `RefreshDatabase` trait 触发了 `migrate:fresh`，
清空了默认 MySQL 连接 `job_passport`（生产/开发共用库）的全部业务数据——
包括 `users`、`roles`、`permissions`、`system_menu`、`system_role_menu`、
`role_has_permissions`、`model_has_roles`、`model_has_permissions` 8 张表。

表结构被 `migrate:fresh` 重建为空表，数据全部丢失。其他模块（Jushuitan / Knowledge / Platform）
的业务表位于各自独立库（`job_jushuitan` / `job_knowledge` / `job_platform`），未受影响。

## 二、根因

1. **`phpunit.xml` 把测试库指向生产库**：
   `<env name="DB_DATABASE" value="job_passport"/>` ——
   与 `CLAUDE.md` 描述的「测试用 in-memory SQLite」不符，实际测试连的就是生产 `job_passport`。
   运行测试前未核对测试库实际配置，直接跑 `php artisan test`。

2. **UserCenter 测试沿用 `RefreshDatabase`**：
   `RefreshDatabase` 首次运行会执行 `migrate:fresh`（删库全部表再重建）。
   其他模块（Jushuitan / Knowledge / Platform）的测试注释中早有警告，并改用
   `DatabaseTransactions` + `truncate` 策略绕开共享库的 `migrate:fresh`，
   但 UserCenter 的 6 个测试文件（`UserApiTest`、`SuperAdminTest`、`AuthApiTest`、
   `RuoyiPermissionTest`、`UnauthenticatedAccessTest`、`ApiResponseContractTest`）
   仍使用 `RefreshDatabase`，触发清库。

## 三、数据恢复

### 1. 备份库定位

MySQL 中存在 3 个 `job_passport` 的 9-17 快照备份库（均为 24 张表）：
`job_passport0917`、`job_passport_0917_14`、`job_passport_0917_21`。
其中 `job_passport_0917_21`（9-17 21:00）数据最完整，作为恢复源。

| 表 | 备份库 `job_passport_0917_21` 行数 |
| --- | --- |
| users | 1 |
| roles | 6 |
| permissions | 94 |
| system_menu | 76 |
| system_role_menu | 82 |
| role_has_permissions | 125 |
| model_has_roles | 1 |
| model_has_permissions | 0 |

### 2. 恢复前校验

通过 `information_schema.columns` 比对 `job_passport` 与 `job_passport_0917_21`
上述 8 张表的列定义，结果**完全一致**（无新增/缺失/类型不匹配列），可安全 `INSERT...SELECT`。

### 3. 恢复执行

跨库 `INSERT...SELECT` 复制备份库数据回 `job_passport`（恢复前 8 张表已为空，
无需 `TRUNCATE`；按依赖顺序先 parent 后 child，并临时禁用 `FOREIGN_KEY_CHECKS` 保险）：

```sql
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO job_passport.users           SELECT * FROM job_passport_0917_21.users;
INSERT INTO job_passport.roles           SELECT * FROM job_passport_0917_21.roles;
INSERT INTO job_passport.permissions     SELECT * FROM job_passport_0917_21.permissions;
INSERT INTO job_passport.system_menu     SELECT * FROM job_passport_0917_21.system_menu;
INSERT INTO job_passport.role_has_permissions   SELECT * FROM job_passport_0917_21.role_has_permissions;
INSERT INTO job_passport.model_has_roles        SELECT * FROM job_passport_0917_21.model_has_roles;
INSERT INTO job_passport.model_has_permissions  SELECT * FROM job_passport_0917_21.model_has_permissions;
INSERT INTO job_passport.system_role_menu       SELECT * FROM job_passport_0917_21.system_role_menu;
SET FOREIGN_KEY_CHECKS=1;
```

### 4. 恢复结果

恢复后 `job_passport` 8 张表行数与备份库完全一致。super_admin 账号完整：

| 字段 | 值 |
| --- | --- |
| id | 1 |
| name | superadmin |
| phone | 13811974106 |
| status | active |
| role | super_admin |

> **注意**：数据恢复到 **2026-09-17 21:00** 状态。9-17 之后若有手录的新角色/权限/菜单/用户，
> 需从更近的备份补回——本次未找到比 `job_passport_0917_21` 更新的备份。

## 四、根因修复（双重保险）

### 1. `phpunit.xml` 改用独立测试库

新增独立测试库 `job_passport_testing`（已建库并 migrate），`phpunit.xml` 中：

```xml
<!-- Tests run against an ISOLATED database, never the shared
     job_passport. RefreshDatabase triggers migrate:fresh here,
     which would otherwise wipe the production/dev RBAC data. -->
<env name="DB_CONNECTION" value="mysql"/>
<env name="DB_DATABASE" value="job_passport_testing"/>
```

测试从此连隔离库，不再触碰生产 `job_passport`。如隔离库结构缺失，需先执行一次：

```bash
DB_DATABASE=job_passport_testing php artisan migrate
```

### 2. UserCenter 测试改用 `DatabaseTransactions`

6 个测试文件的 `RefreshDatabase` → `DatabaseTransactions`，对齐 Jushuitan / Knowledge /
Platform 既有模式。`DatabaseTransactions` 在事务中回滚，不执行 `migrate:fresh`，
即便将来测试库配置再出错，也只回滚事务，不会清库。

涉及文件：

- `tests/Feature/UserCenter/UserApiTest.php`
- `tests/Feature/UserCenter/SuperAdminTest.php`
- `tests/Feature/UserCenter/AuthApiTest.php`
- `tests/Feature/UserCenter/RuoyiPermissionTest.php`
- `tests/Feature/UserCenter/UnauthenticatedAccessTest.php`
- `tests/Feature/ApiResponseContractTest.php`

### 3. Pint hook 陷阱（实现过程踩到并修复）

替换 trait 时踩了 `.ai/rules/routes.md` 已记录的同类陷阱：
post-tool Pint hook 在**每次 Edit 后**运行。若把 `use ...DatabaseTransactions;` import
与 `use DatabaseTransactions;` trait 行分两次 Edit，Pint 在中间态会把 import 当作未使用删除，
导致 trait 引用断裂（`Trait "...\DatabaseTransactions" not found`）。

正确做法：import 与 usage 必须在**同一次 Edit** 中加入，或在加 usage 后补回 import。
本次已按此修复。

### 4. 规则沉淀

已通过 `record-rule` 写入 `.ai/rules/feature.md`：
「Tests run on isolated job_passport_testing, use DatabaseTransactions not RefreshDatabase」，
覆盖 `tests/Feature/**` 与 `phpunit.xml`，后续 agent 会继承。

## 五、验证结果

| 验证项 | 结果 |
| --- | --- |
| 生产库 `job_passport` 跑全量测试前后行数 | 完全一致（1/6/94/76/82/125/1），未被触碰 |
| `php artisan test --compact tests/Feature/UserCenter tests/Feature/ApiResponseContractTest.php` | 67 通过 |
| `php artisan test --compact`（全量） | 288 通过，0 失败 |
| `vendor/bin/pint --dirty --format agent` | 通过 |

## 六、教训

- 运行测试前**必须先核对测试库实际配置**（`phpunit.xml` 的 `DB_DATABASE`），
  不能仅凭 `CLAUDE.md` 描述假定测试用 in-memory SQLite。
- `RefreshDatabase` 在共享库上是危险操作；UserCenter 测试应与其他模块一致使用
  `DatabaseTransactions`，隔离库 + 事务回滚是双重防线。
- 跨库恢复前必须先比对列定义一致性，避免 `INSERT...SELECT` 列不匹配。
