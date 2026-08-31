# .claude/skills/ 目录文件分析

## 目录概述

`.claude/skills/` 目录存放技能（Skills）定义文件。技能是可复用的操作流程，用于快速执行复杂的多步骤任务。与命令不同，技能通常包含更复杂的逻辑和多个执行步骤。

## 文件列表

```
.claude/skills/
├── create-crud.md    # 快速创建标准 CRUD 功能代码
├── create-module.md  # 创建新的业务模块
└── run-tests.md      # 运行项目测试
```

---

## 1. create-crud.md - 创建 CRUD 功能

### 基本信息

| 属性 | 值 |
|------|-----|
| 名称 | `create-crud` |
| 描述 | 快速创建标准 CRUD 功能代码（Controller、Service、Mapper、VO、DO） |
| 触发词 | "创建CRUD", "生成CRUD", "create crud", "新增接口" |

### 使用方式

```bash
/create-crud <业务名> <表名>
```

**示例**

```bash
/create-crud order system_order
```

### 生成的文件

#### 1. DO 实体类

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

#### 2. Mapper 接口

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

#### 3. Service 接口和实现

**接口**: `.../service/XxxService.java`

```java
public interface OrderService {

    Long createOrder(@Valid OrderSaveReqVO createReqVO);

    void updateOrder(@Valid OrderSaveReqVO updateReqVO);

    void deleteOrder(Long id);

    OrderDO getOrder(Long id);

    PageResult<OrderDO> getOrderPage(OrderPageReqVO pageReqVO);
}
```

**实现**: `.../service/XxxServiceImpl.java`

#### 4. Controller

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

#### 5. VO 类

| VO 类型 | 用途 |
|---------|------|
| `XxxSaveReqVO` | 创建/更新请求 |
| `XxxPageReqVO` | 分页查询请求 |
| `XxxRespVO` | 响应 VO |

### 执行步骤

1. 分析表结构获取字段信息
2. 生成 DO 实体类
3. 生成 Mapper 接口
4. 生成 Service 接口和实现
5. 生成 Controller
6. 生成 VO 类
7. 添加权限配置

### 配置项

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `--vo` | 是否生成 VO 类 | true |
| `--permission` | 是否添加权限注解 | true |
| `--page` | 是否生成分页接口 | true |

### 使用场景

- 快速创建标准 CRUD 功能
- 根据数据库表生成代码
- 减少重复编码工作

---

## 2. create-module.md - 创建业务模块

### 基本信息

| 属性 | 值 |
|------|-----|
| 名称 | `create-module` |
| 描述 | 创建新的业务模块，包含完整的目录结构和基础代码 |
| 触发词 | "创建模块", "新建模块", "create module" |

### 使用方式

```bash
/create-module <模块名> <模块描述>
```

**示例**

```bash
/create-module notification 通知模块
```

### 模块结构

```
yudao-module-xxx/
├── pom.xml                              # Maven 配置
├── yudao-module-xxx-api/                # API 层
│   ├── pom.xml
│   └── src/main/java/cn/iocoder/yudao/module/xxx/
│       ├── api/                         # API 接口定义
│       ├── enums/                       # 枚举类
│       ├── dto/                         # DTO 类
│       └── constants/                   # 常量类
└── yudao-module-xxx-biz/                # 业务层
    ├── pom.xml
    └── src/main/java/cn/iocoder/yudao/module/xxx/
        ├── controller/
        │   └── admin/                   # 管理后台接口
        │       └── vo/                  # VO 类
        ├── service/                     # Service 接口
        │   └── dal/
        │       ├── dataobject/          # DO 实体
        │       └── mysql/               # Mapper
        └── convert/                     # 对象转换
    └── src/main/resources/
        └── application.yaml             # 配置文件
```

### 目录结构说明

#### API 层 (yudao-module-xxx-api)

| 目录 | 用途 |
|------|------|
| `api/` | API 接口定义，供其他模块调用 |
| `enums/` | 枚举类定义 |
| `dto/` | 数据传输对象 |
| `constants/` | 常量定义 |

#### 业务层 (yudao-module-xxx-biz)

| 目录 | 用途 |
|------|------|
| `controller/admin/` | 管理后台接口 |
| `controller/app/` | App 端接口 |
| `service/` | 业务服务接口和实现 |
| `service/dal/dataobject/` | DO 实体类 |
| `service/dal/mysql/` | Mapper 接口 |
| `convert/` | 对象转换器 |

### 执行步骤

1. 确认模块名称和描述
2. 创建目录结构
3. 生成 pom.xml 文件
4. 生成基础代码模板
5. 更新父 pom.xml 添加模块

### 注意事项

- 模块名使用小写字母和连字符，如 `user-profile`
- 需要在父 pom.xml 中添加新模块
- API 层用于定义接口和 DTO，供其他模块调用
- BIZ 层包含具体业务实现

### 使用场景

- 创建新的业务模块
- 标准化模块结构
- 快速搭建项目骨架

---

## 3. run-tests.md - 运行项目测试

### 基本信息

| 属性 | 值 |
|------|-----|
| 名称 | `run-tests` |
| 描述 | 运行项目测试，包括单元测试、集成测试 |
| 触发词 | "运行测试", "执行测试", "run tests", "mvn test" |

### 使用方式

```bash
/run-tests [模块名] [选项]
```

**示例**

```bash
# 运行所有测试
/run-tests

# 运行指定模块测试
/run-tests yudao-module-system

# 运行指定测试类
/run-tests --class UserServiceTest

# 跳过集成测试
/run-tests --skip-integration
```

### 测试类型

#### 1. 单元测试

位置: `src/test/java/.../*Test.java`

使用 JUnit 5 + Mockito：

```java
@SpringBootTest
class UserServiceTest {

    @Autowired
    private UserService userService;

    @Test
    void testCreateUser() {
        // given
        UserSaveReqVO reqVO = new UserSaveReqVO();
        reqVO.setUsername("test");

        // when
        Long userId = userService.createUser(reqVO);

        // then
        assertNotNull(userId);
    }
}
```

#### 2. 集成测试

使用 `@SpringBootTest`：

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserControllerIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void testCreateUser() {
        // given
        UserSaveReqVO reqVO = new UserSaveReqVO();
        reqVO.setUsername("test");

        // when
        ResponseEntity<CommonResult> response = restTemplate.postForEntity(
            "/user/create", reqVO, CommonResult.class);

        // then
        assertEquals(200, response.getStatusCode().value());
    }
}
```

#### 3. 测试配置

使用 `application-unit-test.yaml`：

```yaml
spring:
  datasource:
    driver-class-name: org.h2.Driver
    url: jdbc:h2:mem:testdb
    username: sa
    password:
  redis:
    host: localhost
    port: 6379
```

### Maven 命令

```bash
# 运行所有测试
mvn test

# 运行指定模块测试
mvn test -pl yudao-module-system

# 运行指定测试类
mvn test -Dtest=UserServiceTest

# 运行指定测试方法
mvn test -Dtest=UserServiceTest#testCreateUser

# 跳过测试
mvn package -DskipTests
```

### 测试覆盖率

使用 JaCoCo 生成测试覆盖率报告：

```bash
mvn jacoco:prepare-agent test jacoco:report
```

报告位置: `target/site/jacoco/index.html`

### 测试最佳实践

1. **命名规范**: 测试方法使用 `test<Xxx>` 或 `should<Xxx>`
2. **Given-When-Then**: 测试代码结构清晰
3. **独立性**: 测试之间互不影响
4. **可重复**: 测试可以重复执行
5. **覆盖边界**: 测试正常、异常、边界情况

### 测试报告

运行测试后生成：

- 控制台输出测试结果
- `target/surefire-reports/` 详细报告
- 测试失败时打印详细错误信息

### 使用场景

- 运行单元测试验证功能
- 运行集成测试验证系统
- 生成测试覆盖率报告
- 持续集成测试

---

## 技能设计模式

### 1. 参数化操作

每个技能都支持参数：

| 技能 | 参数 |
|------|------|
| create-crud | `<业务名> <表名>` |
| create-module | `<模块名> <模块描述>` |
| run-tests | `[模块名] [选项]` |

### 2. 多步骤流程

技能通常包含多个执行步骤：

**create-crud**
1. 分析表结构
2. 生成 DO
3. 生成 Mapper
4. 生成 Service
5. 生成 Controller
6. 生成 VO
7. 配置权限

**create-module**
1. 确认信息
2. 创建目录
3. 生成配置
4. 生成模板
5. 更新父 POM

### 3. 文件格式

每个技能文件包含：

1. **Front Matter** - 元数据配置
   ```yaml
   ---
   name: skill-name
   description: 技能描述
   triggers: ["触发词1", "触发词2"]
   ---
   ```

2. **使用方式** - 调用语法和示例

3. **详细说明** - 功能详解

4. **执行步骤** - 操作流程

5. **配置项** - 可选配置

---

## 使用方式

### 调用技能

```bash
# 直接调用
/create-crud user system_user

# 通过触发词自动识别
"创建一个用户管理的CRUD功能"
→ 自动触发 create-crud 技能
```

### 与 Commands 的区别

| 特性 | Skills | Commands |
|------|--------|----------|
| 复杂度 | 多步骤流程 | 单一操作 |
| 参数 | 复杂参数 | 简单参数 |
| 输出 | 生成多个文件 | 执行命令 |
| 触发 | 关键词触发 | 显式调用 |

---

## 扩展建议

可以根据项目需要添加更多技能：

| 建议技能 | 功能 |
|---------|------|
| `create-api` | 创建 API 接口文档 |
| `create-test` | 生成测试用例 |
| `migrate-data` | 数据迁移 |
| `code-refactor` | 代码重构 |

---

## 总结

`.claude/skills/` 目录定义了三个核心技能：

1. **create-crud** - 快速创建 CRUD 功能，生成完整的增删改查代码
2. **create-module** - 创建新的业务模块，包含完整目录结构
3. **run-tests** - 运行项目测试，支持单元测试和集成测试

这些技能通过参数化配置和多步骤流程，实现了复杂任务的自动化执行，大大提高了开发效率。
