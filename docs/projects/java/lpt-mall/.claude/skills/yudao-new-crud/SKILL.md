---
name: yudao-new-crud
description: 在 yudao 某业务模块内为指定功能生成完整 CRUD 代码（DO/Mapper/Service/ServiceImpl/Controller/VO/Convert + ErrorCode + 建表 SQL），严格遵循芋道分层与命名约定，自动编译自检。当用户要求「新增一个功能的增删改查」「生成 CRUD」「做一个 xxx 管理」时触发。
---

# 技能：生成完整 CRUD 功能

## 触发场景
- 「在 system 模块加一个岗位的增删改查」
- 「给 mall 加商品分类 CRUD」
- 「生成 xxx 管理（含分页、导出）」

## 输入
- 模块名 `module`（如 `system`/`mall`/`erp`）
- 功能名 `feature` + 实体名 `X`（如 feature=dept, X=Dept）
- 字段清单：`字段名:Java类型`（如 `name:String, sort:Integer, status:Integer, parentId:Long`）

## 执行步骤
1. **定位模板**：Glob `yudao-module-{module}/yudao-module-{module}-biz/src/main/java/cn/iocoder/yudao/module/{module}/controller/admin/**`，找最相似的功能作为参照（命名、权限码前缀、VO 结构）。
2. **生成文件**（包根 `cn.iocoder.yudao.module.{module}`）：
   - `dal/dataobject/{feature}/{X}DO.java`：`@TableName("{module}_{feature}")`、`@TableId`、`@Data` + `@EqualsAndHashCode(callSuper=true)`；含 `tenantId` 的继承 `TenantBaseDO`，否则 `BaseDO`。
   - `dal/mysql/{feature}/{X}Mapper.java`：`@Mapper` `extends BaseMapperX<{X}DO>`；`selectPage({X}PageReqVO)` 用 `LambdaQueryWrapperX.likeIfPresent/eqIfPresent/inIfPresent`；`selectByXxx` 唯一性查询。
   - `service/{feature}/{X}Service.java` + `{X}ServiceImpl.java`：`@Resource` 注入 Mapper；`createX`/`updateX`/`deleteX`/`getX`/`getXPage`；唯一性校验 `throw exception(ErrorCode)`。
   - `controller/admin/{feature}/vo/{feature}/{X}SaveReqVO.java`、`{X}PageReqVO.java`（`extends PageParam`）、`{X}RespVO.java`、`{X}SimpleRespVO.java`：JSR303 校验注解。
   - `controller/admin/{feature}/{X}Controller.java`：`@Tag("管理后台 - {中文}")`、每方法 `@Operation`+`@Parameter`+`@PreAuthorize("@ss.hasPermission('{module}:{feature}:{action}')")`，返回 `CommonResult`/`PageResult`。
   - `enums/ErrorCodeConstants.java`：追加 `ErrorCode` 常量（如 `{X}_NOT_EXISTS`、`{X}_NAME_DUPLICATE`）。
3. **转换**：`BeanUtils.toBean(src, {X}RespVO.class)`；列表用 `{X}SimpleRespVO`。
4. **SQL**：生成 `sql/{module}_{feature}.sql`（`CREATE TABLE IF NOT EXISTS {module}_{feature}`，含 `id BIGINT`、业务字段、`tenant_id`、`creator`/`create_time`/`updater`/`update_time`/`deleted`，`utf8mb4`，索引），**不执行**，顶部注明「人工执行」。
5. **自检**：`mvn clean compile -pl yudao-module-{module}/yudao-module-{module}-biz -am -T 1C`。
6. **输出**：文件清单 + 权限码列表 + SQL 路径 + 人工配置菜单提示。

## 约束
- Java 8 语法；`@Resource` 注入；`*IfPresent` 条件构造；禁止手写转换、禁止直传 DO 跨模块。
- 红线：不做数据库操作；不编辑 `target/`、`*.class`、`generated-sources/`。

## 关联
- 规则：`.claude/rules/java-conventions.md`、`api-conventions.md`、`module-structure.md`。
- 代理：`.claude/agents/java-backend-dev.md`。
- 命令：`/yudao-new-crud`。
