# BaseTool 短信平台扩展 + 验证码场景支持 — 执行结果

> 对应需求：`.requirements/modules/basetool/task.txt`
> 执行日期：2026-09-11

## 一、需求与完成情况

| # | 需求 | 状态 |
| --- | --- | --- |
| 1 | 新增对螺丝帽(luosimao)短信平台的支持 | ✅ 完成 |
| 2 | 短信验证码支持使用场景（登录/注册、注销，可扩展） | ✅ 完成 |
| 3 | 在 `sms_templates` 表中为 aliyun/tencent/luosimao 增加若干测试模板 | ✅ 完成（9 条） |

## 二、实现概述

### 1. 螺丝帽(luosimao)平台支持
- `overtrue/easy-sms` v3.3.0 已内置 `LuosimaoGateway`，无需新增网关类。
- `Modules/BaseTool/config/sms.php` 新增 `luosimao` 网关配置：`['api_key' => env('SMS_LUOSIMAO_API_KEY')]`。
- 螺丝帽为 **content-based** 发送（无平台模板 ID），与 aliyun/tencent（template-based）不同。`SmsService::sendViaGateway` 在一次发送中同时携带 `content` 与 `template`+`data`，各网关按需取用 → 三种平台统一兼容。

### 2. 验证码场景支持
- 场景在 `config/sms.php` 的 `scenes` 中配置，新增场景只需加一项，无需改代码：
  - `login_register`（登录/注册）
  - `cancellation`（注销）
- 验证码与场景绑定：缓存键 `sms_code:{scene}:{phone}`，不同场景的验证码互不可用（场景隔离）。
- `SmsService`：
  - `sendVerificationCode(string $phone, string $scene, int $length = 6)`：校验场景 → 生成码 → 按 scene+默认网关查 `sms_templates` 模板（找到则用模板，否则用 scenes 兜底文案）→ 发送。
  - `verifyCode(string $phone, string $code, string $scene): bool`：按场景键校验，成功后清除。**对缓存值强制 `(string)` 转换后再比较**（部分缓存驱动会把数字串还原成 int，而 HTTP 入参恒为 string，故防御性转换）。
  - `getScenes()` / `isValidScene()`。
- `UserCenter` 的 `AuthService::loginWithPhoneCode` 同步传入 `'login_register'` 场景（手机号登录即此场景）。

### 3. 测试模板（sms_templates）
- 新增 seeder `Modules\BaseTool\Database\Seeders\SmsTemplateSeeder`（`updateOrCreate` 幂等），并在 `BaseToolDatabaseSeeder` 中注册。
- 共 **9 条**模板（3 平台 × 3 模板），已填充到 MySQL `job_passport.sms_templates`：

| gateway | scene | code | gateway_template_code |
| --- | --- | --- | --- |
| aliyun | login_register | aliyun_verify_login_register | SMS_0000001 |
| aliyun | cancellation | aliyun_verify_cancellation | SMS_0000002 |
| aliyun | null | aliyun_notify | SMS_0000003 |
| tencent | login_register | tencent_verify_login_register | 1000001 |
| tencent | cancellation | tencent_verify_cancellation | 1000002 |
| tencent | null | tencent_notify | 1000003 |
| luosimao | login_register | luosimao_verify_login_register | null（content-based） |
| luosimao | cancellation | luosimao_verify_cancellation | null |
| luosimao | null | luosimao_notify | null |

## 三、顺带修复的问题

探索中发现现有实现存在阻断性缺陷，一并修复（否则 luosimao 不可用、现有平台也实际不通）：

1. **`SmsService` 构造错误**：原 `new EasySms(config('basetool.sms.gateways'))` 只传 gateways 数组、缺 `default.gateways` 键，`send()` 无法解析默认网关。已改为完整 EasySms 配置结构（含 `default.strategy` + `default.gateways`）。
2. **`tencent` 非合法 easy-sms 网关名**：easy-sms 网关类为 `QcloudGateway`（网关名 `qcloud`），原 `tencent` 配置从未真正可用。保持 `tencent` 命名（与任务原文一致），通过 `EasySms::extend('tencent', fn => new QcloudGateway($config))` 注册别名，配置取自 `gateways.tencent`，现已可实际发送。
3. **`sendTemplate` 不传 content、不按模板 gateway 路由**：luosimao 必失败。已抽 `sendViaGateway` 统一处理 content + template + data，并按模板 `gateway` 路由。
4. **`sms_templates`/`sms_logs` 缺 `scene` 列**：新增迁移 `2026_09_11_000000_add_scene_to_sms_tables`（nullable，向后兼容；`sms_templates` 加 `scene+gateway` 复合索引）。

## 四、接口

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/v1/base-tool/sms/scenes` | 列出支持的验证码场景 |
| POST | `/api/v1/base-tool/sms/send` | 发送原始短信（content-based） |
| POST | `/api/v1/base-tool/sms/send-code` | 发送场景验证码（入参 `phone`、`scene`） |
| POST | `/api/v1/base-tool/sms/verify-code` | 校验场景验证码（入参 `phone`、`code`、`scene`） |

- 响应由 `NormalizeApiResponse` 中间件统一加 `code`（成功 0、失败 1），控制器不手写。
- `send-code` 每分钟冷却键按 `(scene,phone)` 隔离（不同场景互不阻塞）；日限额仍按手机号总额度（`rate_limit.per_day`）。限流键前缀 `sms_sendcode:` 与验证码缓存键 `sms_code:` 区分，避免碰撞。

## 五、改动文件清单

- 配置：`Modules/BaseTool/config/sms.php`、`.env.example`
- 服务：`Modules/BaseTool/app/Services/SmsService.php`
- 控制器/路由：`Modules/BaseTool/app/Http/Controllers/Api/V1/SmsController.php`、`Modules/BaseTool/routes/api.php`
- 模型：`Modules/BaseTool/app/Models/SmsTemplate.php`、`Modules/BaseTool/app/Models/SmsLog.php`
- 迁移：`Modules/BaseTool/database/migrations/2026_09_11_000000_add_scene_to_sms_tables.php`
- Seeder：`Modules/BaseTool/database/seeders/SmsTemplateSeeder.php`、`BaseToolDatabaseSeeder.php`
- 跨模块：`Modules/UserCenter/app/Services/AuthService.php`
- 测试：`tests/Feature/BaseTool/SmsApiTest.php`、`phpunit.xml`

## 六、测试

- **测试库**：按用户要求，测试使用 MySQL `job_passport`（非 SQLite）。`phpunit.xml` 已设 `DB_CONNECTION=mysql`、`DB_DATABASE=job_passport`、`SMS_GATEWAY=errorlog`（测试走 errorlog 网关，不连外网）。
- ⚠️ **重要提示**：测试使用 `RefreshDatabase`，**首次执行会 `migrate:fresh` 清空 `job_passport` 中所有表并重建**（用户已知并接受）。运行测试后，`sms_templates` 等表数据会被回滚清空，需重新执行 `php artisan db:seed --class='Modules\BaseTool\Database\Seeders\SmsTemplateSeeder'` 恢复模板。本次已重新填充 9 条模板。
- `tests/Feature/BaseTool/SmsApiTest.php`（10 个用例全绿）：含场景校验、发送-校验往返、场景隔离、场景列表、模板填充校验等。
- 运行：`php artisan test tests/Feature/BaseTool/SmsApiTest.php` → passed (10/10)。
- 全量套件 `php artisan test --compact` 未运行（会重置 `job_passport`，且其他用例切 MySQL 后可能需调整）——待用户确认是否执行。

## 七、配置说明（生产部署）

`.env` 需配置对应平台凭证（参见 `.env.example`）：
- aliyun：`SMS_ACCESS_KEY_ID`、`SMS_ACCESS_KEY_SECRET`、`SMS_SIGN_NAME`
- tencent：`SMS_SECRET_ID`、`SMS_SECRET_KEY`、`SMS_SDK_APP_ID`、`SMS_SIGN_NAME`
- luosimao：`SMS_LUOSIMAO_API_KEY`
- `SMS_GATEWAY` 选择默认网关（aliyun/tencent/luosimao/errorlog）。

注：模板中的 `gateway_template_code`（如 `SMS_0000001`）为测试占位值，生产需替换为各平台真实审批通过的模板 ID。
