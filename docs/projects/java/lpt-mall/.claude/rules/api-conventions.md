# 规则：REST 接口约定

> 适用于所有 Controller。Knife4j + SpringDoc OpenAPI 3。

## 路径
- `@RequestMapping("/{module}/{feature}")`：模块名 + 功能名，小写。
- 后台端放 `controller/admin/`，App 端放 `controller/app/`。
- `/admin-api` 与 `/app-api` 前缀由 `yudao-spring-boot-starter-web` 统一拼接，Controller 内不写。

## 动词与 HTTP 方法
| 操作 | HTTP | 路径后缀 | 入参 | 返回 |
| --- | --- | --- | --- | --- |
| 新增 | POST | `create` | `{X}SaveReqVO` | `CommonResult<Long>` |
| 修改 | PUT | `update` | `{X}SaveReqVO` | `CommonResult<Boolean>` |
| 删除 | DELETE | `delete` | `id`（RequestParam） | `CommonResult<Boolean>` |
| 详情 | GET | `get` | `id` | `CommonResult<{X}RespVO>` |
| 分页 | GET | `page` | `{X}PageReqVO` | `CommonResult<PageResult<{X}RespVO>>` |
| 列表 | GET | `list` | `{X}ListReqVO` | `CommonResult<List<{X}SimpleRespVO>>` |
| 导出 | GET | `export` | `{X}PageReqVO` | void（写 Response） |

## 注解（必须）
- 类：`@Tag(name = "管理后台 - {中文名}")` 或 `@Tag(name = "用户 App - {中文名}")`、`@RestController`、`@Validated`。
- 方法：`@Operation(summary = "{中文动作}")`；路径参数/请求参数加 `@Parameter(name=..., description=..., required=..., example=...)`。
- 入参对象：`@Valid @RequestBody`；简单参数 `@RequestParam("id")` / `@PathVariable`。
- 权限：`@PreAuthorize("@ss.hasPermission('{module}:{feature}:{action}')")`，action ∈ `create|update|delete|query|export`。

## 返回
- 统一 `CommonResult<T>`（`success(data)` / `error(code, msg)`）。
- 分页 `PageResult<T>`（`PageResult.getList()`/`getTotalCount()`）。
- 精简列表/下拉用 `SimpleRespVO`，避免返回完整 `RespVO`。

## 导出
- EasyExcel 导出：`@GetMapping("export")`，`@PreAuthorize(...:export)`，用 `ExcelUtils.write(response, "{文件名}.xls", "sheet", {X}RespVO.class, list)`。

## 关联
- 审查代理：`.claude/agents/api-doc-reviewer.md`。
