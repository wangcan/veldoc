# 规则：Java 编码约定

> 适用于所有 `*.java` 源码。Java 8 + Spring Boot 2.7.18。

## 语法与版本
- **Java 8**：禁用 `var`、`record`、`switch` 表达式、`Stream.toList()`、`Optional.orElseThrow()` 无参重载等 Java 9+ 特性。
- 集合：`Collectors.toList()`；优先 Hutool `CollUtil`/`ListUtil`/`StrUtil`。
- 日期：`LocalDateTime` + `LocalDateTimeUtils`；Jackson 已配置时间戳输出。

## Lombok
- DO/VO/DTO/DTO：`@Data`；继承基类时 `@EqualsAndHashCode(callSuper = true)`。
- 构造器按需 `@AllArgsConstructor`/`@NoArgsConstructor`。
- 日志 `@Slf4j`。

## 依赖注入
- 统一 `@Resource`（项目默认），不使用 `@Autowired`。

## MyBatis-Plus / DAL
- Mapper：`extends BaseMapperX<DO>`（自研增强） + `@Mapper`。
- 条件构造：`LambdaQueryWrapperX` 的 `likeIfPresent`/`eqIfPresent`/`inIfPresent`/`betweenIfPresent` 等，自动忽略空值。
- DO：`@TableName("m_x")`、`@TableId`；多租户 `extends TenantBaseDO`，否则 `extends BaseDO`；序列 `@KeySequence`（非 MySQL 库）。
- 禁止在 Mapper 手写 XML，除非复杂多表联查；联查优先 `mybatis-plus-join`。

## 对象转换
- 优先 `BeanUtils.toBean(src, TargetVO.class)`（`yudao-common`）。
- 复杂映射用 MapStruct `Convert` 接口（`@Mapper(componentModel="spring")`）。
- **禁止**逐字段 `dest.setX(src.getX())` 手写转换。

## Controller
- `@Tag` + `@Operation` + `@Parameter`（Knife4j/SpringDoc）。
- 返回 `CommonResult<T>`；分页 `PageResult<T>`；分页入参继承 `PageParam`。
- 权限 `@PreAuthorize("@ss.hasPermission('{module}:{feature}:{action}')")`。
- 后台端 `controller/admin/`，App 端 `controller/app/`；`@RequestMapping("/{module}/{feature}")`（前缀 `/admin-api`、`/app-api` 由 starter-web 统一加）。

## 异常
- `throw exception(ErrorCode)`；错误码集中 `enums/ErrorCodeConstants`，`ErrorCode` 定义在 `yudao-common`。
- 参数校验用 `@Valid` + JSR303；全局异常由 `yudao-spring-boot-starter-web` 处理。

## 多租户
- 租户表 DO `extends TenantBaseDO`；跨租户/忽略租户用 `TenantUtils.executeIgnore(() -> ...)`。
- 数据权限用 `yudao-spring-boot-starter-biz-data-permission`。

## 注释
- 类与公有方法写 Javadoc，`@author` 标注；复杂逻辑加中文行注释，风格与现有代码一致。

## 关联
- 审查代理：`.claude/agents/conventions-reviewer.md`。
