---
name: run-tests
description: 运行项目测试，包括单元测试、集成测试
triggers: ["运行测试", "执行测试", "run tests", "mvn test"]
---

# 运行测试

## 使用方式

```
/run-tests [模块名] [选项]
```

示例：
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

## 测试类型

### 1. 单元测试

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

### 2. 集成测试

使用 `@SpringBootTest` 进行集成测试：

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

### 3. 测试配置

使用 `application-unit-test.yaml` 配置测试环境：

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

## Maven 命令

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

## 测试覆盖率

使用 JaCoCo 生成测试覆盖率报告：

```bash
mvn jacoco:prepare-agent test jacoco:report
```

报告位置: `target/site/jacoco/index.html`

## 测试最佳实践

1. **命名规范**: 测试方法使用 `test<Xxx>` 或 `should<Xxx>`
2. **Given-When-Then**: 测试代码结构清晰
3. **独立性**: 测试之间互不影响
4. **可重复**: 测试可以重复执行
5. **覆盖边界**: 测试正常、异常、边界情况

## 测试报告

运行测试后生成：

- 控制台输出测试结果
- `target/surefire-reports/` 详细报告
- 测试失败时打印详细错误信息
