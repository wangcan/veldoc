---
name: create-crud
description: 快速创建标准 CRUD 功能代码（Controller、Service、Mapper、VO、DO）
triggers: ["创建CRUD", "生成CRUD", "create crud", "新增接口"]
---

# 创建 CRUD 功能

## 使用方式

```
/create-crud <业务名> <表名>
```

示例：
```
/create-crud order system_order
```

## 生成的文件

### 1. DO 实体类

位置: `yudao-module-xxx-biz/src/main/java/.../dal/dataobject/XxxDO.java`

```java
@TableName("system_order")
@KeySequence("system_order_seq")
@Data
@EqualsAndHashCode(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderDO extends BaseDO {

    @TableId
    private Long id;

    // 业务字段...

    /**
     * 状态
     *
     * 枚举 {@link CommonStatusEnum}
     */
    private Integer status;
}
```

### 2. Mapper 接口

位置: `yudao-module-xxx-biz/src/main/java/.../dal/mysql/XxxMapper.java`

```java
@Mapper
public interface OrderMapper extends BaseMapperX<OrderDO> {

    default PageResult<OrderDO> selectPage(OrderPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<OrderDO>()
            .likeIfPresent(OrderDO::getName, reqVO.getName())
            .eqIfPresent(OrderDO::getStatus, reqVO.getStatus())
            .orderByDesc(OrderDO::getId));
    }
}
```

### 3. Service 接口和实现

接口: `.../service/XxxService.java`
实现: `.../service/XxxServiceImpl.java`

```java
public interface OrderService {

    Long createOrder(@Valid OrderSaveReqVO createReqVO);

    void updateOrder(@Valid OrderSaveReqVO updateReqVO);

    void deleteOrder(Long id);

    OrderDO getOrder(Long id);

    PageResult<OrderDO> getOrderPage(OrderPageReqVO pageReqVO);
}
```

### 4. Controller

位置: `.../controller/admin/XxxController.java`

```java
@RestController
@RequestMapping("/order")
@Tag(name = "管理后台 - 订单")
@Validated
public class OrderController {

    @PostMapping("/create")
    @Operation(summary = "创建订单")
    @PreAuthorize("@ss.hasPermission('system:order:create')")
    public CommonResult<Long> createOrder(@Valid @RequestBody OrderSaveReqVO createReqVO) {
        return success(orderService.createOrder(createReqVO));
    }

    // ... 其他 CRUD 方法
}
```

### 5. VO 类

- `XxxSaveReqVO` - 创建/更新请求
- `XxxPageReqVO` - 分页查询请求
- `XxxRespVO` - 响应 VO

## 执行步骤

1. 分析表结构获取字段信息
2. 生成 DO 实体类
3. 生成 Mapper 接口
4. 生成 Service 接口和实现
5. 生成 Controller
6. 生成 VO 类
7. 添加权限配置

## 配置项

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `--vo` | 是否生成 VO 类 | true |
| `--permission` | 是否添加权限注解 | true |
| `--page` | 是否生成分页接口 | true |
