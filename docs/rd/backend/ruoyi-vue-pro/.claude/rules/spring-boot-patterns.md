# Spring Boot 最佳实践

## 配置管理

### 使用 @ConfigurationProperties

```java
// ✅ 推荐：类型安全的配置
@Data
@ConfigurationProperties(prefix = "yudao.security")
public class SecurityProperties {

    private String tokenHeader = "Authorization";

    private String tokenSecret = "abc";

    private int tokenTimeout = 30 * 60;
}

// 在配置类中启用
@EnableConfigurationProperties(SecurityProperties.class)
@Configuration
public class SecurityConfiguration {
}
```

### 配置文件

```yaml
# application.yaml - 公共配置
spring:
  application:
    name: yudao-server

# application-dev.yaml - 开发环境配置
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ruoyi-vue-pro
    username: root
    password: ${MYSQL_PASSWORD}

# 使用环境变量覆盖敏感配置
```

## 依赖注入

### 构造器注入（推荐）

```java
// ✅ 推荐：构造器注入
@Service
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final RoleService roleService;

    public UserServiceImpl(UserMapper userMapper, RoleService roleService) {
        this.userMapper = userMapper;
        this.roleService = roleService;
    }
}

// 使用 Lombok 简化
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final RoleService roleService;
}
```

### 字段注入（不推荐）

```java
// ❌ 不推荐：字段注入
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private RoleService roleService;
}
```

## 事务管理

### 正确使用 @Transactional

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

// ✅ 正确：指定传播行为
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void sendNotification(Long userId) {
    // 独立事务，不受外层事务影响
}
```

### 事务失效场景

```java
// ❌ 错误：方法不是 public
@Transactional
private void createUser() { }

// ❌ 错误：同类内调用，AOP 不生效
public void methodA() {
    this.methodB(); // methodB 的事务不生效
}

@Transactional
public void methodB() { }

// ✅ 正确：注入自身或使用 AopContext
@Service
public class UserServiceImpl implements UserService {

    @Resource
    private UserService self; // 注入自身

    public void methodA() {
        self.methodB(); // 事务生效
    }
}
```

## 异常处理

### 全局异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ServiceException.class)
    public CommonResult<?> handleServiceException(ServiceException e) {
        return CommonResult.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public CommonResult<?> handleValidationException(MethodArgumentNotValidException e) {
        return CommonResult.error(BAD_REQUEST.getCode(), e.getMessage());
    }
}
```

### 业务异常

```java
// ✅ 正确：使用 ServiceException
if (user == null) {
    throw exception(USER_NOT_EXISTS);
}

// ServiceException 工具方法
public static ServiceException exception(ErrorCode errorCode) {
    return new ServiceException(errorCode);
}

// 错误码定义
public interface ErrorCodeConstants {
    ErrorCode USER_NOT_EXISTS = new ErrorCode(1002000000, "用户不存在");
}
```

## 参数校验

### Controller 参数校验

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

### Service 参数校验

```java
// ✅ 正确：Service 方法也需要校验
public Long createUser(UserSaveReqVO reqVO) {
    // 业务校验
    validateUserUnique(reqVO.getUsername());
    // ...
}

private void validateUserUnique(String username) {
    UserDO user = userMapper.selectByUsername(username);
    if (user != null) {
        throw exception(USER_USERNAME_EXISTS);
    }
}
```

## 条件装配

### @ConditionalOnXxx

```java
@Configuration
@ConditionalOnClass(RedissonClient.class)
@ConditionalOnProperty(prefix = "yudao.redis", name = "enabled", havingValue = "true")
public class RedisConfiguration {

    @Bean
    public RedissonClient redissonClient() {
        // ...
    }
}
```

## Actuator 监控

### 启用端点

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
```

### 自定义健康检查

```java
@Component
public class CustomHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        // 检查逻辑
        boolean healthy = checkHealth();
        if (healthy) {
            return Health.up().withDetail("status", "ok").build();
        }
        return Health.down().withDetail("status", "error").build();
    }
}
```
