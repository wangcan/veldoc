# 安全规范

## 权限控制

### 使用 @PreAuthorize

```java
@RestController
@RequestMapping("/user")
public class UserController {

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

    @GetMapping("/profile")
    public CommonResult<UserProfileVO> getProfile() {
        Long userId = getLoginUserId();
        return success(userService.getUserProfile(userId));
    }
}
```

### 权限表达式

| 表达式 | 说明 |
|-------|------|
| `@ss.hasPermission` | 拥有指定权限 |
| `@ss.hasRole` | 拥有指定角色 |
| `@ss.hasAnyPermission` | 拥有任一权限 |
| `@ss.hasAnyRole` | 拥有任一角色 |

## 数据权限

### @DataPermission 注解

```java
@DataPermission({
    @DataColumn(alias = "u", name = "dept_id")
})
default List<UserDO> selectList() {
    return selectList(new LambdaQueryWrapperX<UserDO>());
}
```

## 敏感数据保护

### 密码加密

```java
// 注册/修改密码时加密
String encodedPassword = passwordEncoder.encode(rawPassword);
user.setPassword(encodedPassword);

// 登录时验证
boolean matches = passwordEncoder.matches(rawPassword, encodedPassword);
```

### 数据脱敏

```java
@Data
public class UserRespVO {

    @JsonSerialize(using = PhoneDesensitizeSerializer.class)
    private String mobile;

    @JsonSerialize(using = EmailDesensitizeSerializer.class)
    private String email;
}
```

## SQL 注入防护

### 使用参数化查询

```java
// ✅ 正确：参数化查询
@Select("SELECT * FROM system_user WHERE username = #{username}")
UserDO selectByUsername(@Param("username") String username);

// ❌ 错误：字符串拼接
@Select("SELECT * FROM system_user WHERE username = '" + username + "'")
UserDO selectByUsername(String username);
```

## 安全最佳实践

1. **最小权限原则**：只授予必要的权限
2. **输入验证**：所有输入都是不可信的
3. **敏感数据加密**：密码、身份证等敏感数据加密存储
4. **日志审计**：记录关键操作日志
5. **定期安全扫描**：使用工具扫描安全漏洞
