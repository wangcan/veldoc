# Headers 参数 `authorization` 与 `system` 的处理与使用分析

> 分析范围：`liupin-api-gateway`（网关）与 `liupin-service/liupin-custom-service`（毛笔定制服务）。
> 涉及公共模块：`liupin-common`。

## 一、两个 Header 的来源与约定

| Header 名 | 常量定义 | 取值示例 | 作用 |
|---|---|---|---|
| `Authorization` | `org.apache.http.HttpHeaders.AUTHORIZATION` | `Bearer eyJhbGciOiJIUzI1NiJ9....` | 携带 JWT 登录令牌，必须以 `Bearer ` 前缀开头 |
| `System` | `com.liupin.common.constant.TokenConstant.SYSTEM`（值为 `"System"`） | `maobiCustom` / `customTaobao` / `tablet` 等 | 标识令牌所属的业务系统，决定验签密钥与 platId |

常量定义见 `liupin-common/.../constant/TokenConstant.java`：

```java
public static final String SYSTEM = "System";
public static final String BEARER = "Bearer ";
```

`System` 的合法取值注册表为 `com.liupin.common.constant.SystemPlatEnum`，每个枚举项维护三元组：
`system 字符串` / `tokenSecret(验签密钥)` / `platId(平台ID)`。

## 二、Token 的签发（以淘宝毛笔定制渠道为例）

签发入口：`liupin-custom-service` 的 `TaobaoUserService.taoBaoLogin` 与 `controller/taobao/LoginController`。

```java
// TaobaoUserService.java:43
TokenInfo token = JWTUtils.createToken(
        Long.valueOf(taobaoUser.getId()),
        payload,
        SystemPlatEnum.CUSTOM_TAOBAO.getSystem());   // "maobiCustom"
```

`JWTUtils.createToken` 内部：
1. `secret = secretBySystem(system)` → 查 `SystemPlatEnum` 得到 `maobiCustom` 对应的密钥 `v36H61bB9mLW/d1s5TFctw==`；
2. 用 `HS256 + TextCodec.BASE64.encode(secret)` 签发 JWT，subject=uid，payload 里携带 `id/openid/userType`；
3. 返回 `Bearer <token>`。

因此淘宝渠道签发的 token，其验签密钥来自 `SystemPlatEnum.CUSTOM_TAOBAO`（platId=15）。

## 三、网关侧处理：`JwtTokenGatewayFilter`

文件：`liupin-api-gateway/.../filter/JwtTokenGatewayFilter.java`。

请求进入下游服务前，网关统一鉴权：

```java
String system = request.getHeaders().getFirst(SYSTEM);      // System 头
String token  = getToken(request);                           // Authorization 头，去掉 "Bearer " 前缀

LoginInfo loginInfo = parseToken(token, system);             // 用 system 查密钥验签
if (loginInfo == null) {
    throwJwtException(UNAUTHORIZED, "您的登录已过期，请重新登录");   // 401
}
if (!checkLoginVersion(loginInfo)) {
    throwJwtException(UNAUTHORIZED, "您的登录已无效，请重新登录");   // 401
}
return chain.filter(exchange);
```

- `parseToken(token, system)`（`JWTUtils`）核心逻辑：
  ```java
  String secret = secretBySystem(system);        // 关键：按 system 字符串查密钥
  Claims claims = Jwts.parser()
          .setSigningKey(TextCodec.BASE64.encode(secret))
          .parseClaimsJws(token).getBody();       // 密钥不对/过期/格式错 → 抛异常 → 返回 null
  loginInfo.setPlatId(platIdBySystem(system));    // 按 system 字符串查 platId
  loginInfo.setUid(Long.valueOf(claims.getSubject()));
  ```
- `secretBySystem` / `platIdBySystem` 的兜底逻辑（关键风险点）：
  ```java
  return Arrays.stream(values())
          .filter(e -> e.system.equals(system))
          .findFirst()
          .orElse(SystemPlatEnum.DEFAULT)   // 查不到就回落到 DEFAULT
          .tokenSecret / .platId;
  ```
  即：**`system` 取值未在 `SystemPlatEnum` 注册时，会回落到 `DEFAULT`（platId=0），而不是直接报错。**
- `checkLoginVersion`：token payload 中带 `loginVersion` 时才校验 Redis 中的登录版本；淘宝渠道 token 不带该字段，跳过。

> 注：`RouteConfiguration.java` 整体被注释，网关路由由 `DynamicRouteListener`（Nacos/DB）动态下发。`/api/taobaoCustom/**` 路由到 `liupin-custom-service` 时会挂载 `JwtTokenGatewayFilter`。

## 四、服务侧处理：`LoginInfoInterceptor`

文件：`liupin-common/.../component/intercepter/LoginInfoInterceptor.java`，由 `CommonMvcConfiguration` 注册到 `/**`。

```java
String token  = request.getHeader(AUTHORIZATION);
String system = request.getHeader(SYSTEM);
if (StringUtils.isEmpty(token) || StringUtils.isEmpty(system)) {
    return true;                                   // 头缺失则不解析，LoginContext 保持 null
}
token = token.substring(BEARER.length()).trim();
LoginInfo loginInfo = parseToken(token, system);   // 同样按 system 查密钥验签
if (Objects.nonNull(loginInfo)) {
    LoginContext.add(loginInfo);                   // 写入 ThreadLocal
}
return true;
// postHandle / afterCompletion 中 LoginContext.remove()
```

`LoginContext` 为 ThreadLocal，提供 `getUserId()`、`getPlatId()`、`getUserType()` 等给业务代码使用。

## 五、Controller 侧使用：`CustomerAssert.checkLogin()`

文件：`liupin-common/.../utils/CustomerAssert.java`。

```java
public static void checkLogin() {
    if (LoginContext.get() == null) {
        throw new BizException(UNAUTHORIZED);      // 401
    }
}
```

新增的淘宝镜像接口（`/api/taobaoCustom/setting/customerDetail`、`/api/taobaoCustom/listWithProducts`、`/api/taobaoCustom/detail`、`/api/taobaoCustom/userFocusNumIncrease`）均调用 `CustomerAssert.checkLogin()`，并通过 `LoginContext.getPlatId()` 获取 platId 用于业务查询（如推荐商品按 platId 过滤）。

## 六、完整链路时序

```
客户端
  │  Authorization: Bearer <jwt>
  │  System: maobiCustom   (或 customTaobao)
  ▼
网关 JwtTokenGatewayFilter
  │  parseToken(token, system)
  │    └ secretBySystem(system) → 查 SystemPlatEnum 取密钥
  │    └ 验签成功 → LoginInfo(platId=platIdBySystem(system), uid=subject)
  │    └ 失败/为空 → 401
  │  checkLoginVersion(loginInfo) → 不通过则 401
  ▼
liupin-custom-service  LoginInfoInterceptor (/**)
  │  parseToken(token, system) → LoginContext.add(loginInfo)
  ▼
Controller
  │  CustomerAssert.checkLogin()  → LoginContext 为空则 401
  │  LoginContext.getPlatId()     → 业务查询用
```

## 七、401 问题定位与修复

### 现象
新增的淘宝接口，`System` 头为 `maobiCustom` 时请求正常；改为 `customTaobao`（需求原文 `custokmTaobao`，按 `CUSTOM_TAOBAO` 枚举名的驼峰形式理解为 `customTaobao`）时返回 401。

### 根因
`customTaobao` **未在 `SystemPlatEnum` 中注册**：

- `secretBySystem("customTaobao")` 找不到匹配项 → 兜底到 `DEFAULT`；
- `platIdBySystem("customTaobao")` 找不到匹配项 → 兜底到 `DEFAULT`，platId = **0**（毛笔定制应为 15）。

当前仓库里 `DEFAULT` 的密钥恰好与 `maobiCustom` 的密钥相同（均为 `v36H61bB9mLW/d1s5TFctw==`），所以验签「碰巧」能过；但：
1. platId 被置为 0，导致按 platId 过滤的接口（推荐商品列表/详情/分类-商品）取不到数据，表现为接口不可用；
2. 该成功完全依赖 `DEFAULT` 密钥碰巧相等这一**巧合**。一旦 `DEFAULT` 密钥变更，或各环境密钥不一致，验签会失败 → `parseToken` 返回 null → 网关/`checkLogin` 直接 401。

### 修复
在 `SystemPlatEnum` 中为 `customTaobao` 显式注册一个与 `maobiCustom` 等价的别名项（相同 platId=15、相同密钥）：

```java
//毛笔定制
CUSTOM_TAOBAO("maobiCustom", "v36H61bB9mLW/d1s5TFctw==", Byte.valueOf("15"), "毛笔定制"),

//毛笔定制(淘宝) customTaobao 与 maobiCustom 等价，均为毛笔定制渠道，新增别名避免按 DEFAULT 兜底导致 platId 错误/鉴权 401
CUSTOM_TAOBAO_ALIAS("customTaobao", "v36H61bB9mLW/d1s5TFctw==", Byte.valueOf("15"), "毛笔定制(淘宝)"),
```

修复后：
- `secretBySystem("customTaobao")` 显式返回正确密钥 → 验签稳定通过，不再依赖 `DEFAULT` 兜底巧合；
- `platIdBySystem("customTaobao")` 显式返回 15 → 业务按 platId 查询正确；
- `customTaobao` 与 `maobiCustom` 行为完全一致，401 消除。

### 影响面
- 仅新增一个枚举项，不修改任何既有项，向后兼容。
- `getSystem(platId)` / `getSystemName(platId)` 取首个匹配，`CUSTOM_TAOBAO` 在前，仍返回 `maobiCustom`，不受影响。
- `secretBySystem` / `platIdBySystem` 按 system 字符串精确匹配，新增项为独立合法取值。
- 改动位于 `liupin-common`，所有引用该枚举的服务（网关、custom-service、usercenter 等）均生效。

## 八、涉及文件清单

| 文件 | 作用 |
|---|---|
| `liupin-common/.../constant/TokenConstant.java` | `SYSTEM`、`BEARER` 常量 |
| `liupin-common/.../constant/SystemPlatEnum.java` | system→密钥/platId 注册表（**修复点**） |
| `liupin-common/.../utils/JWTUtils.java` | token 签发与 `parseToken` 验签 |
| `liupin-common/.../component/intercepter/LoginInfoInterceptor.java` | 服务侧解析头并写入 `LoginContext` |
| `liupin-common/.../configuration/CommonMvcConfiguration.java` | 注册拦截器到 `/**` |
| `liupin-common/.../component/LoginContext.java` | ThreadLocal 登录信息 |
| `liupin-common/.../utils/CustomerAssert.java` | `checkLogin()` 抛 401 |
| `liupin-api-gateway/.../filter/JwtTokenGatewayFilter.java` | 网关统一鉴权，401 入口 |
| `liupin-custom-service/.../service/TaobaoUserService.java` | 淘宝渠道 token 签发 |
| `liupin-custom-service/.../controller/taobao/LoginController.java` | 淘宝登录/刷新 token |
