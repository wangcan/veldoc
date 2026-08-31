# MyBatis Plus 使用规范

## 基础配置

### 配置项

```yaml
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.slf4j.Slf4jImpl
  global-config:
    db-config:
      id-type: AUTO
      logic-delete-value: 1
      logic-not-delete-value: 0
    banner: false
  type-aliases-package: cn.iocoder.yudao.module.*.dal.dataobject
```

## DO 实体类

### 基础实体

```java
@TableName("system_user")
@Data
@EqualsAndHashCode(callSuper = true)
public class UserDO extends BaseDO {

    @TableId
    private Long id;

    private String username;

    private String password;

    private Integer status;
}
```

### BaseDO 基类

```java
@Data
public abstract class BaseDO {

    private String creator;

    private LocalDateTime createTime;

    private String updater;

    private LocalDateTime updateTime;

    @TableLogic
    private Boolean deleted;
}
```

## Mapper 接口

### 继承 BaseMapperX

```java
@Mapper
public interface UserMapper extends BaseMapperX<UserDO> {
    // BaseMapperX 提供了丰富的 CRUD 方法
}
```

### 自定义查询方法

```java
@Mapper
public interface UserMapper extends BaseMapperX<UserDO> {

    // 根据用户名查询
    default UserDO selectByUsername(String username) {
        return selectOne(UserDO::getUsername, username);
    }

    // 分页查询
    default PageResult<UserDO> selectPage(UserPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<UserDO>()
            .likeIfPresent(UserDO::getUsername, reqVO.getUsername())
            .eqIfPresent(UserDO::getStatus, reqVO.getStatus())
            .orderByDesc(UserDO::getId));
    }

    // 批量插入
    default void insertBatch(List<UserDO> list) {
        saveBatch(list);
    }
}
```

## LambdaQueryWrapperX 使用

### 条件构造

```java
// likeIfPresent: 值为空时不添加条件
.likeIfPresent(UserDO::getUsername, reqVO.getUsername())

// eqIfPresent: 值为空时不添加条件
.eqIfPresent(UserDO::getStatus, reqVO.getStatus())

// betweenIfPresent: 开始或结束时间为空时不添加条件
.betweenIfPresent(UserDO::getCreateTime, reqVO.getBeginTime(), reqVO.getEndTime())

// inIfPresent: 集合为空时不添加条件
.inIfPresent(UserDO::getId, reqVO.getIds())
```

### 排序

```java
// 降序
.orderByDesc(UserDO::getId)

// 升序
.orderByAsc(UserDO::getCreateTime)

// 多字段排序
.orderByDesc(UserDO::getStatus)
.orderByDesc(UserDO::getId)
```

## 分页查询

### 使用 PageResult

```java
// Controller
@GetMapping("/page")
public CommonResult<PageResult<UserRespVO>> getUserPage(@Valid UserPageReqVO pageReqVO) {
    PageResult<UserDO> pageResult = userService.getUserPage(pageReqVO);
    return success(BeanUtils.toBean(pageResult, UserRespVO.class));
}

// Service
PageResult<UserDO> getUserPage(UserPageReqVO pageReqVO);

// ServiceImpl
@Override
public PageResult<UserDO> getUserPage(UserPageReqVO pageReqVO) {
    return userMapper.selectPage(pageReqVO);
}

// Mapper
default PageResult<UserDO> selectPage(UserPageReqVO reqVO) {
    return selectPage(reqVO, new LambdaQueryWrapperX<UserDO>()
        // 条件...
    );
}
```

## 数据权限

### 使用 @DataPermission

```java
@DataPermission({
    @DataColumn(alias = "u", name = "dept_id")
})
default List<UserDO> selectList() {
    return selectList(new LambdaQueryWrapperX<UserDO>()
        .eq(UserDO::getStatus, CommonStatusEnum.ENABLE.getStatus()));
}
```

## 多租户

### TenantBaseDO

```java
@Data
@EqualsAndHashCode(callSuper = true)
public class UserDO extends TenantBaseDO {
    // 自动添加 tenant_id 条件
}
```

### 忽略多租户

```java
// 方法级别忽略
@TenantIgnore
public List<UserDO> selectAllUsers() {
    return userMapper.selectList();
}
```

## 性能优化

### 避免 N+1 查询

```java
// ❌ 错误：N+1 查询
List<OrderDO> orders = orderMapper.selectList();
for (OrderDO order : orders) {
    UserDO user = userMapper.selectById(order.getUserId()); // N 次查询
}

// ✅ 正确：批量查询
List<OrderDO> orders = orderMapper.selectList();
Set<Long> userIds = convertSet(orders, OrderDO::getUserId);
Map<Long, UserDO> userMap = userMapper.selectBatchIds(userIds)
    .stream()
    .collect(Collectors.toMap(UserDO::getId, Function.identity()));
```

### 索引使用

```java
// 确保查询条件有索引
.eq(UserDO::getStatus, status)  // status 字段有索引

// 避免索引失效
// ❌ 错误：使用函数导致索引失效
.apply("DATE(create_time) = DATE(NOW())")

// ✅ 正确：范围查询使用索引
.between(UserDO::getCreateTime, beginTime, endTime)
```
