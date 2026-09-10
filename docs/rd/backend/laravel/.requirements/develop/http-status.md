# API 接口返回规则整改结果

> 对应需求：`.requirements/develop/dev.txt` 需求1
> 完成日期：2026-09-09
> 更新：2026-09-09 —— 404 状态码改为保持不变（业务 `code` 仍为 1）；顺带修复既有 `ExampleTest` 失败。

## 一、实现的规则

### 1. 业务层 `code` 字段（所有 JSON 接口响应新增）

- `code` 取值基于**归一化前的原始 HTTP 状态码**计算（这样 422 被归一化成 200 后仍能正确报告 `code=1`）。
- 原始状态为 **2xx（200/201/204）** → `code = 0`（业务成功）
- 原始状态为 **4xx / 5xx** → `code = 1`（业务失败）

> 说明：需求原文为「HTTP 200 时 code=0，其他 code=1」。因需求2会把 201/422/403 等都归一化成 HTTP 200，若 `code` 基于归一化后的状态计算，422（校验失败）会误判为 `code=0`。故 `code` 一律基于**原始**状态计算；对于 201/204 这类成功创建响应，按业务语义归为 `code=0`（与既有 `success:true` 一致）。此口径已与需求方确认。

### 2. HTTP 状态码归一化

| 原始 HTTP 状态 | 归一化后 HTTP 状态 | `code` |
| --- | --- | --- |
| 200 | 200（保持） | 0 |
| 201 | 200 | 0 |
| 204 | 200 | 0 |
| 3xx（如 301） | 200 | 1 |
| 401 | 401（保持） | 1 |
| 403 | 200 | 1 |
| 404 | 404（保持） | 1 |
| 422 | 200 | 1 |
| 429 | 200 | 1 |
| 500 | 500（保持） | 1 |
| 502 / 503 等其他 5xx | 500 | 1 |

归一化规则：`200/401/404/500` 保持不变；其他 `5xx` 调整为 `500`；其余所有状态码调整为 `200`。

## 二、实现方式

核心逻辑集中在 `App\Http\Middleware\NormalizeApiResponse`，提供：

- `normalizeStatus(int): int` —— HTTP 状态归一化
- `businessCode(int): int` —— 业务 `code` 计算
- `transform(JsonResponse, ?Request): JsonResponse` —— 注入 `code` 并归一化状态（**幂等**）

两条执行路径都复用同一个 `transform`，因此不会出现字段不一致：

1. **正常控制器响应**（200/201/204/422 等直接返回）：由全局中间件 `NormalizeApiResponse`（`bootstrap/app.php` 中 `prepend`，置于最外层）处理。
2. **异常渲染响应**（抛出异常产生的 401/403/404/422/429/500 等）：由 `bootstrap/app.php` 中 `$exceptions->respond(...)` 回调处理（Laravel 已将异常映射为正确的状态码与 JSON 体，回调只负责注入 `code` 并归一化状态）。

**幂等保护**：在 Laravel 13 中，部分异常会在中间件管道内被渲染，导致同一响应可能同时经过「中间件」和「respond 回调」两个入口。`transform` 通过请求级标志（`Request::attributes` 的 `_api_response_normalized`）保证每个响应只被转换一次，避免二次归一化把 `code:1` 误改回 `code:0`。

**作用范围**：仅对 JSON API 响应生效（`$request->is('api/*') || $request->expectsJson()` 且响应为 `JsonResponse`）。非 JSON 响应（如 `/up` 健康检查、Web 路由）不受影响。

## 三、改动文件

| 文件 | 说明 |
| --- | --- |
| `app/Http/Middleware/NormalizeApiResponse.php` | 新增。归一化中间件 + `transform/normalizeStatus/businessCode`（`normalizeStatus` 保持 `200/401/404/500`） |
| `bootstrap/app.php` | 全局注册中间件；新增 `$exceptions->respond` 回调 |
| `routes/web.php` | 根路由 `/` 由返回缺失的 `welcome` 视图改为返回 JSON 健康/信息响应（纯 API 后端无服务端模板） |
| `tests/Feature/ExampleTest.php` | 改为 `getJson('/')` 校验 JSON 健康响应，修复既有失败 |
| `tests/Feature/ApiResponseContractTest.php` | 新增。20 个用例覆盖状态映射与端到端契约（含 404 保持 404） |
| `tests/Feature/BaseTool/{CaptchaApiTest,SmsApiTest,QrCodeApiTest}.php` | 断言更新：422→200 + `code:1` |
| `tests/Feature/UserCenter/{AuthApiTest,SuperAdminTest,UserApiTest,RuoyiPermissionTest}.php` | 断言更新：201/400/403/422→200 并校验 `code`；401/404/500 保持 |

控制器代码**无需改动**——规则在中间件/异常层统一生效，新接口自动遵循。

## 四、测试结果

`php artisan test --compact`：

- 73 个测试，73 通过，0 失败。
- `vendor/bin/pint --dirty --format agent`：通过。
