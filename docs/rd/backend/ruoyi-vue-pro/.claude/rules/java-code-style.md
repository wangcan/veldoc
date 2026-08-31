# Java 代码风格规范

## 命名规范

### 类命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 类 | UpperCamelCase | `UserService` |
| 接口 | UpperCamelCase | `UserService` |
| 抽象类 | Abstract + UpperCamelCase | `AbstractUserService` |
| 枚举 | UpperCamelCase + Enum | `UserStatusEnum` |
| 常量类 | UpperCamelCase + Constants | `UserConstants` |

### 方法命名

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

### 变量命名

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

## 注释规范

### 类注释

```java
/**
 * 用户服务接口
 *
 * @author 芋道源码
 */
public interface UserService {
}
```

### 方法注释

```java
/**
 * 创建用户
 *
 * @param createReqVO 创建信息
 * @return 用户编号
 */
Long createUser(@Valid UserSaveReqVO createReqVO);
```

### 字段注释

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

## 代码格式

### 缩进

- 使用 4 个空格缩进
- 不使用 Tab

### 行长度

- 单行不超过 120 字符
- 超过时换行对齐

### 空行

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

## 导入规范

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
// ✅ import java.util.Map;
```

## 异常处理

```java
// ✅ 正确：使用 ServiceException
if (user == null) {
    throw exception(USER_NOT_EXISTS);
}

// ❌ 避免：直接抛出 RuntimeException
if (user == null) {
    throw new RuntimeException("用户不存在");
}

// ✅ 正确：记录异常日志
try {
    // 业务逻辑
} catch (Exception e) {
    log.error("[createUser] 创建用户失败", e);
    throw exception(USER_CREATE_FAILED);
}
```

## 日志规范

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

        // ❌ 避免：日志级别不当
        log.error("[createUser] 开始创建用户"); // 应该用 debug 或 info
    }
}
```

## Lombok 使用

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

## 参考

- 《阿里巴巴 Java 开发手册》
- Google Java Style Guide
