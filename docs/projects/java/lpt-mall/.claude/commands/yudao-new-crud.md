---
description: 在指定模块内为某功能生成完整 CRUD（DO/Mapper/Service/Controller/VO/Convert），符合芋道约定。
argument-hint: "<模块名> <功能名> [字段:类型 ...]"
---

为芋道项目生成一个完整 CRUD 功能。参数：$ARGUMENTS

请按以下步骤执行（遵循 CLAUDE.md 与 .claude/rules/ 的全部约定）：

1. 解析参数：模块名（如 system）、功能名（如 dept）、字段清单（字段名:Java类型，如 name:String, sort:Integer, status:Integer）。
2. 用 Glob/Grep 找到同模块下相似功能（如 `yudao-module-{module}/yudao-module-{module}-biz/src/main/java/cn/iocoder/yudao/module/{module}/controller/admin/dept`）作为模板。
3. 生成以下文件（仅 Java 源码，不连库）：
   - `dal/dataobject/{feature}/{X}DO.java`（extends TenantBaseDO 或 BaseDO，@TableName("{module}_{feature}")，@TableId，@Data + @EqualsAndHashCode(callSuper=true)）
   - `dal/mysql/{feature}/{X}Mapper.java`（extends BaseMapperX<DO>，@Mapper，selectPage/selectList 用 LambdaQueryWrapperX 的 *IfPresent）
   - `service/{feature}/{X}Service.java` + `{X}ServiceImpl.java`（createX/updateX/deleteX/getX/getXPage，校验唯一性抛 exception(ErrorCode)）
   - `controller/admin/{feature}/vo/{feature}/{X}SaveReqVO.java`、`{X}PageReqVO.java`（extends PageParam）、`{X}RespVO.java`、`{X}SimpleRespVO.java`
   - `controller/admin/{feature}/{X}Controller.java`（@Tag/@Operation/@Parameter/@PreAuthorize，返回 CommonResult/PageResult）
   - `enums` 中追加 ErrorCode 常量（如已存在 ErrorCodeConstants 则 Edit 追加）
4. 对象转换用 `BeanUtils.toBean`。
5. 生成对应建表 SQL 放到 `sql/{module}_{feature}.sql`（含 tenant_id、审计字段、utf8mb4），**不执行**，注明人工执行。
6. 用 `mvn clean compile -pl yudao-module-{module}/yudao-module-{module}-biz -am -T 1C` 自检编译。
7. 输出文件清单 + 权限码 + 需人工执行的 SQL 路径。

红线：不做任何数据库操作；不编辑 target/、*.class、generated-sources/。
