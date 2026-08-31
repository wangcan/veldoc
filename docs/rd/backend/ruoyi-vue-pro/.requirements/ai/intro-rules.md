# .claude/rules/ 目录文件分析

## 目录概述

`.claude/rules/` 目录存放代码规范和最佳实践规则文件。这些规则指导 Claude Code 生成符合项目标准的代码，确保代码风格一致性和质量。

## 文件列表

```
.claude/rules/
├── java-code-style.md       # Java 代码风格规范
├── mybatis-plus-patterns.md # MyBatis Plus 使用规范
├── security-patterns.md     # 安全规范
└── spring-boot-patterns.md  # Spring Boot 最佳实践
```

---

## 1. java-code-style.md - Java 代码风格规范

### 基本信息

| 属性 | 值 |
|------|-----|
| 文件名 | `java-code-style.md` |
| 作用域 | Java 代码风格 |
| 参考标准 | 《阿里巴巴 Java 开发手册》 |

### 规范内容

#### 命名规范

**类命名**

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 类 | UpperCamelCase | `UserService` |
| 接口 | UpperCamelCase | `UserService` |
| 抽象类 | Abstract + UpperCamelCase | `AbstractUserService` |
| 枚举 | UpperCamelCase + Enum | `UserStatusEnum` |
| 常量类 | UpperCamelCase + Constants | `UserConstants` |

**方法命名**

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 查询单个 | get + 实体名 | `getUser` |
| 查询列表 | list + 实体名 | `listUser` |
| 查询分页 | page + 实体名 | `pageUser` |
| 创建 | create + 实体名 | `createUser` |
| 更新 | update + 实体名 | `updateUser` |
| 删除 | delete + 实体名 | `deleteUser` |
| 校验 | validate + 描述 | `validateUserExists` |
| 转换 | convert + 描述 | `convertToVO` |

**变量命名**

```java
// 成员变量 - lowerCamelCase
private String userName;

// 常量 - UPPER_SNAKE_CASE
public static final int MAX_RETRY_COUNT = 3;

// 局部变量 - lowerCamelCase
String orderNo = generateOrderNo();

// 集合变量 - 使用复数或加 List/Map 后缀
List<UserDO> users = new ArrayList<>();
Map<Long, UserDO> userMap = new HashMap<>();
```

#### 注释规范

**类注释**

```java
/**
 * 用户服务接口
 *
 * @author 芋道源码
 */
public interface UserService {
}
```

**方法注释**

```java
/**
 * 创建用户
 *
 * @param createReqVO 创建信息
 * @return 用户编号
 */
Long createUser(@Valid UserSaveReqVO createReqVO);
```

**字段注释**

```java
/**
 * 用户名
 */
private String username;

/**
 * 状态
 *
 * 枚举 {@link CommonStatusEnum}
 */
private Integer status;
```

#### 代码格式

**缩进与行长度**

- 使用 4 个空格缩进
- 不使用 Tab
- 单行不超过 120 字符

**空行规范**

```java
// 方法之间保留一个空行
public void method1() {
}

public void method2() {
}

// 逻辑块之间保留一个空行
// 1. 校验数据
validateUser(user);

// 2. 保存数据
userMapper.insert(user);

// 3. 发送通知
sendNotification(user);
```

#### 导入规范

```java
// 导入顺序
import java.*;           // JDK 标准库
import javax.*;          // JDK 扩展库
import org.*;            // 第三方库
import com.*;            // 第三方库
import cn.iocoder.*;     // 项目内部包

// 避免使用通配符导入
// ❌ import java.util.*
// ✅ import java.util.List;
```

#### 异常处理

```java
// ✅ 正确：使用 ServiceException
if (user == null) {
    throw exception(USER_NOT_EXISTS);
}

// ❌ 避免：直接抛出 RuntimeException
if (user == null) {
    throw new RuntimeException("用户不存在");
}
```

#### 日志规范

```java
// 使用 Slf4j
@Slf4j
@Service
public class UserServiceImpl {

    public void createUser(UserSaveReqVO reqVO) {
        // ✅ 正确：记录关键操作
        log.info("[createUser] 创建用户: {}", reqVO.getUsername());

        // ✅ 正确：记录异常
        log.error("[createUser] 创建用户失败", e);
    }
}
```

#### Lombok 使用

```java
// ✅ 推荐使用的注解
@Data                    // getter/setter/toString/equals/hashCode
@Builder                 // 构建器模式
@NoArgsConstructor       // 无参构造
@AllArgsConstructor      // 全参构造
@Slf4j                   // 日志
@EqualsAndHashCode(callSuper = true)  // 继承时使用

// ❌ 避免使用
@Value                   // 不可变类，项目中很少使用
```

---

## 2. spring-boot-patterns.md - Spring Boot 最佳实践

### 基本信息

| 属性 | 值 |
|------|-----|
| 文件名 | `spring-boot-patterns.md` |
| 作用域 | Spring Boot 开发模式 |

### 规范内容

#### 配置管理

**使用 @ConfigurationProperties**

```java
// ✅ 推荐：类型安全的配置
@Data
@ConfigurationProperties(prefix = "yudao.security")
public class SecurityProperties {
    private String tokenHeader = "Authorization";
    private String tokenSecret = "abc";
    private int tokenTimeout = 30 * 60;
}
```

**配置文件结构**

```yaml
# application.yaml - 公共配置
# application-dev.yaml - 开发环境配置
# 使用环境变量覆盖敏感配置
```

#### 依赖注入

**构造器注入（推荐）**

```java
// ✅ 推荐：构造器注入
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserMapper userMapper;
    private final RoleService roleService;
}

// ❌ 不推荐：字段注入
@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;
}
```

#### 事务管理

**正确使用 @Transactional**

```java
// ✅ 正确：只读事务
@Transactional(readOnly = true)
public UserDO getUser(Long id) {
    return userMapper.selectById(id);
}

// ✅ 正确：写事务，指定回滚异常
@Transactional(rollbackFor = Exception.class)
public Long createUser(UserSaveReqVO reqVO) {
    // 业务逻辑
}
```

**事务失效场景**

```java
// ❌ 错误：方法不是 public
@Transactional
private void createUser() { }

// ❌ 错误：同类内调用
public void methodA() {
    this.methodB(); // methodB 的事务不生效
}

// ✅ 正确：注入自身
public void methodA() {
    self.methodB(); // 事务生效
}
```

#### 异常处理

**全局异常处理**

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ServiceException.class)
    public CommonResult<?> handleServiceException(ServiceException e) {
        return CommonResult.error(e.getCode(), e.getMessage());
    }
}
```

**业务异常**

```java
// ✅ 正确：使用 ServiceException
if (user == null) {
    throw exception(USER_NOT_EXISTS);
}
```

#### 参数校验

**Controller 参数校验**

```java
@PostMapping("/create")
public CommonResult<Long> createUser(@Valid @RequestBody UserSaveReqVO reqVO) {
    return success(userService.createUser(reqVO));
}

// VO 类
@Data
public class UserSaveReqVO {
    @NotBlank(message = "用户名不能为空")
    @Size(min = 4, max = 30, message = "用户名长度为 4-30 个字符")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 16, message = "密码长度为 6-16 个字符")
    private String password;

    @Email(message = "邮箱格式不正确")
    private String email;
}
```

#### 条件装配

```java
@Configuration
@ConditionalOnClass(RedissonClient.class)
@ConditionalOnProperty(prefix = "yudao.redis", name = "enabled", havingValue = "true")
public class RedisConfiguration {
    // ...
}
```

---

## 3. mybatis-plus-patterns.md - MyBatis Plus 使用规范

### 基本信息

| 属性 | 值 |
|------|-----|
| 文件名 | `mybatis-plus-patterns.md` |
| 作用域 | MyBatis Plus ORM 框架 |

### 规范内容

#### 基础配置

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
```

#### DO 实体类

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

#### Mapper 接口

**继承 BaseMapperX**

```java
@Mapper
public interface UserMapper extends BaseMapperX<UserDO> {
    // BaseMapperX 提供了丰富的 CRUD 方法
}
```

**自定义查询方法**

```java
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
```

#### LambdaQueryWrapperX 使用

```java
// 条件构造 - 值为空时不添加条件
.likeIfPresent(UserDO::getUsername, reqVO.getUsername())
.eqIfPresent(UserDO::getStatus, reqVO.getStatus())
.betweenIfPresent(UserDO::getCreateTime, reqVO.getBeginTime(), reqVO.getEndTime())
.inIfPresent(UserDO::getId, reqVO.getIds())

// 排序
.orderByDesc(UserDO::getId)
```

#### 数据权限

```java
@DataPermission({
    @DataColumn(alias = "u", name = "dept_id")
})
default List<UserDO> selectList() {
    return selectList(new LambdaQueryWrapperX<UserDO>());
}
```

#### 多租户

```java
@Data
@EqualsAndHashCode(callSuper = true)
public class UserDO extends TenantBaseDO {
    // 自动添加 tenant_id 条件
}
```

#### 性能优化

**避免 N+1 查询**

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

---

## 4. security-patterns.md - 安全规范

### 基本信息

| 属性 | 值 |
|------|-----|
| 文件名 | `security-patterns.md` |
| 作用域 | 应用安全 |

### 规范内容

#### 权限控制

**使用 @PreAuthorize**

```java
@PostMapping("/create")
@PreAuthorize("@ss.hasPermission('system:user:create')")
public CommonResult<Long> createUser(@RequestBody UserSaveReqVO reqVO) {
    return success(userService.createUser(reqVO));
}

@GetMapping("/admin")
@PreAuthorize("@ss.hasRole('admin')")
public CommonResult<List<UserDO>> getAdminUsers() {
    return success(userService.getAdminUsers());
}
```

**权限表达式**

| 表达式 | 说明 |
|-------|------|
| `@ss.hasPermission` | 拥有指定权限 |
| `@ss.hasRole` | 拥有指定角色 |
| `@ss.hasAnyPermission` | 拥有任一权限 |
| `@ss.hasAnyRole` | 拥有任一角色 |

#### 数据权限

```java
@DataPermission({
    @DataColumn(alias = "u", name = "dept_id")
})
default List<UserDO> selectList() {
    return selectList(new LambdaQueryWrapperX<UserDO>());
}
```

#### 敏感数据保护

**密码加密**

```java
// 注册/修改密码时加密
String encodedPassword = passwordEncoder.encode(rawPassword);
user.setPassword(encodedPassword);

// 登录时验证
boolean matches = passwordEncoder.matches(rawPassword, encodedPassword);
```

**数据脱敏**

```java
@Data
public class UserRespVO {
    @JsonSerialize(using = PhoneDesensitizeSerializer.class)
    private String mobile;

    @JsonSerialize(using = EmailDesensitizeSerializer.class)
    private String email;
}
```

#### SQL 注入防护

```java
// ✅ 正确：参数化查询
@Select("SELECT * FROM system_user WHERE username = #{username}")
UserDO selectByUsername(@Param("username") String username);

// ❌ 错误：字符串拼接
@Select("SELECT * FROM system_user WHERE username = '" + username + "'")
UserDO selectByUsername(String username);
```

#### 安全最佳实践

1. **最小权限原则**：只授予必要的权限
2. **输入验证**：所有输入都是不可信的
3. **敏感数据加密**：密码、身份证等敏感数据加密存储
4. **日志审计**：记录关键操作日志
5. **定期安全扫描**：使用工具扫描安全漏洞

---

## 规则设计模式

### 1. 覆盖面

| 规则文件 | 覆盖领域 |
|---------|---------|
| java-code-style | 代码风格、命名规范 |
| spring-boot-patterns | 框架使用、配置管理 |
| mybatis-plus-patterns | 数据访问、ORM 使用 |
| security-patterns | 安全控制、数据保护 |

### 2. 规范格式

每个规则文件包含：
1. **分类表格** - 明确分类和规则
2. **正确示例** - 使用 ✅ 标记
3. **错误示例** - 使用 ❌ 标记
4. **最佳实践** - 提供推荐做法

### 3. 代码示例驱动

通过大量代码示例说明规范：
- 正确做法示例
- 错误做法示例
- 对比说明原因

---

## 使用方式

### 自动注入

Claude Code 会自动读取 `settings.json` 中引用的规则文件：

```json
{
  "rules": [
    ".claude/rules/java-code-style.md",
    ".claude/rules/spring-boot-patterns.md",
    ".claude/rules/mybatis-plus-patterns.md",
    ".claude/rules/security-patterns.md"
  ]
}
```

### 指导 AI 生成代码

这些规则会指导 Claude Code：
- 使用正确的命名规范
- 遵循最佳实践
- 避免常见错误
- 添加必要的注释

---

## 扩展建议

可以根据项目需要添加更多规则：

| 建议规则 | 覆盖领域 |
|---------|---------|
| api-design.md | API 设计规范 |
| logging-patterns.md | 日志使用规范 |
| exception-handling.md | 异常处理规范 |
| test-guidelines.md | 测试编写指南 |

---

## 总结

`.claude/rules/` 目录定义了四个核心规范文件：

1. **java-code-style.md** - Java 代码风格，定义命名、注释、格式规范
2. **spring-boot-patterns.md** - Spring Boot 最佳实践，涵盖配置、注入、事务、异常
3. **mybatis-plus-patterns.md** - MyBatis Plus 使用规范，包括 Mapper、查询、性能优化
4. **security-patterns.md** - 安全规范，涵盖权限、加密、防注入

这些规则文件共同构成了项目的代码规范体系，确保 Claude Code 生成的代码符合项目标准。
