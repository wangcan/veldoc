# 登录和认证流程

本文档详细介绍系统如何配合后端接口完成登录、认证的全流程，包括多种登录方式、Token 管理、Token 刷新、登出等机制。

## 概述

系统采用 **JWT (JSON Web Token)** 作为认证方案，支持多种登录方式：
- **用户名密码登录**
- **手机验证码登录**
- **社交账号登录**（微信、钉钉等）
- **SSO 单点登录**
- **二维码登录**

认证流程包括：登录验证、Token 获取、Token 存储、Token 刷新、权限获取、登出处理等环节。

## 一、登录流程

### 1.1 登录方式概览

系统支持多种登录方式，位于 `apps/web-ele/src/views/_core/authentication/` 目录：

| 登录方式 | 文件 | API 接口 |
|---------|------|---------|
| 用户名密码 | `login.vue` | `/system/auth/login` |
| 手机验证码 | `code-login.vue` | `/system/auth/sms-login` |
| 社交账号 | `social-login.vue` | `/system/auth/social-login` |
| 注册 | `register.vue` | `/system/auth/register` |
| SSO 登录 | `sso-login.vue` | 自定义 SSO 接口 |
| 二维码 | `qrcode-login.vue` | 自定义扫码接口 |

### 1.2 用户名密码登录流程

#### 步骤 1: 登录表单展示

登录页面组件：`apps/web-ele/src/views/_core/authentication/login.vue`

**表单字段：**
```typescript
const formSchema = computed((): VbenFormSchema[] => {
  return [
    {
      component: 'VbenSelect',
      fieldName: 'tenantId',         // 租户选择（可选）
      label: $t('authentication.tenant'),
    },
    {
      component: 'VbenInput',
      fieldName: 'username',         // 用户名
      label: $t('authentication.username'),
    },
    {
      component: 'VbenInputPassword',
      fieldName: 'password',         // 密码
      label: $t('authentication.password'),
    },
  ];
});
```

**租户支持：**
- 如果启用多租户，会先获取租户列表
- 支持根据域名自动选择租户
- 用户也可以手动选择租户

**验证码支持：**
- 如果启用验证码，需要先完成验证码验证
- 支持滑块验证码、文字点选验证码

#### 步骤 2: 提交登录请求

用户点击登录按钮后，触发 `handleLogin` 函数：

```typescript
async function handleLogin(values: any) {
  // 如果开启验证码，则先验证验证码
  if (captchaEnable) {
    verifyRef.value.show();
    return;
  }
  // 无验证码，直接登录
  await authStore.authLogin('username', values);
}
```

#### 步骤 3: 调用登录 API

`authStore.authLogin` 函数位于 `apps/web-ele/src/store/auth.ts`：

```typescript
async function authLogin(
  type: 'mobile' | 'register' | 'social' | 'username',
  params: Recordable<any>,
  onSuccess?: () => Promise<void> | void,
) {
  let userInfo: null | UserInfo = null;
  try {
    let loginResult: AuthApi.LoginResult;
    loginLoading.value = true;

    // 根据登录类型调用不同的 API
    switch (type) {
      case 'mobile': {
        loginResult = await smsLogin(params);
        break;
      }
      case 'register': {
        loginResult = await register(params);
        break;
      }
      case 'social': {
        loginResult = await socialLogin(params);
        break;
      }
      default: {
        loginResult = await loginApi(params);  // 用户名密码登录
      }
    }

    const { accessToken, refreshToken } = loginResult;

    // 如果成功获取到 accessToken
    if (accessToken) {
      // 1. 存储 Token
      accessStore.setAccessToken(accessToken);
      accessStore.setRefreshToken(refreshToken);

      // 2. 获取用户信息和权限
      const fetchUserInfoResult = await fetchUserInfo();
      userInfo = fetchUserInfoResult.user;

      // 3. 跳转到首页或指定页面
      if (accessStore.loginExpired) {
        accessStore.setLoginExpired(false);
      } else {
        await router.push(
          userInfo.homePath || preferences.app.defaultHomePath,
        );
      }

      // 4. 显示登录成功提示
      if (userInfo?.nickname) {
        ElNotification.success({
          message: `${$t('authentication.loginSuccessDesc')}:${userInfo?.nickname}`,
          title: $t('authentication.loginSuccess'),
        });
      }
    }
  } finally {
    loginLoading.value = false;
  }

  return { userInfo };
}
```

#### 步骤 4: 登录 API 接口

`apps/web-ele/src/api/core/auth.ts`：

```typescript
/** 登录 */
export async function loginApi(data: AuthApi.LoginParams) {
  return requestClient.post<AuthApi.LoginResult>('/system/auth/login', data, {
    headers: {
      isEncrypt: false,  // 是否加密
    },
  });
}
```

**请求参数：**
```typescript
interface LoginParams {
  username?: string;
  password?: string;
  captchaVerification?: string;  // 验证码验证结果
  socialType?: number;           // 社交登录类型
  socialCode?: string;           // 社交登录授权码
  socialState?: string;          // 社交登录状态
}
```

**响应数据：**
```typescript
interface LoginResult {
  accessToken: string;    // 访问令牌
  refreshToken: string;   // 刷新令牌
  userId: number;         // 用户ID
  expiresTime: number;    // 过期时间
}
```

#### 步骤 5: 获取用户信息和权限

登录成功后，立即调用 `fetchUserInfo` 获取用户详细信息：

```typescript
async function fetchUserInfo() {
  const authPermissionInfo = await getAuthPermissionInfoApi();
  
  // 存储用户信息
  userStore.setUserInfo(authPermissionInfo.user);
  userStore.setUserRoles(authPermissionInfo.roles);
  
  // 存储权限信息
  accessStore.setAccessMenus(authPermissionInfo.menus);
  accessStore.setAccessCodes(authPermissionInfo.permissions);
  
  return authPermissionInfo;
}
```

**API 接口：**
```typescript
export async function getAuthPermissionInfoApi() {
  return requestClient.get<AuthPermissionInfo>(
    '/system/auth/get-permission-info',
  );
}
```

**响应数据：**
```typescript
interface AuthPermissionInfo {
  user: UserInfo;           // 用户信息
  roles: string[];          // 角色列表
  menus: Menu[];            // 菜单列表
  permissions: string[];    // 权限列表
}
```

### 1.3 其他登录方式

#### 手机验证码登录

```typescript
// 1. 发送验证码
await sendSmsCode({ mobile: '13800138000', scene: 1 });

// 2. 验证码登录
await authStore.authLogin('mobile', {
  mobile: '13800138000',
  code: '123456',
});
```

#### 社交账号登录

```typescript
// 1. 获取授权跳转 URL
const redirectUri = `${location.origin}/auth/social-login?type=${type}&redirect=${redirect}`;
const authUrl = await socialAuthRedirect(type, redirectUri);

// 2. 跳转到第三方授权页面
window.location.href = authUrl;

// 3. 授权成功后回调，获取 accessToken
await authStore.authLogin('social', {
  type: 1,
  code: 'xxx',
  state: 'xxx',
});
```

## 二、Token 管理机制

### 2.1 Token 存储

Token 存储在 Pinia Store 中，并通过持久化插件保存到本地存储：

**Store 定义：** `packages/stores/src/modules/access.ts`

```typescript
interface AccessState {
  accessToken: null | string;      // 访问令牌
  refreshToken: null | string;     // 刷新令牌
  loginExpired: boolean;           // 登录是否过期
  tenantId: null | number;         // 租户编号
  visitTenantId: null | number;    // 访问租户编号
}

export const useAccessStore = defineStore('core-access', {
  state: (): AccessState => ({
    accessToken: null,
    refreshToken: null,
    loginExpired: false,
    tenantId: null,
    visitTenantId: null,
  }),
  
  persist: {
    // 持久化配置
    pick: [
      'accessToken',
      'refreshToken',
      'tenantId',
      'visitTenantId',
    ],
  },
});
```

**存储方式：**
- **默认**: 使用 `localStorage` 持久化存储
- **安全模式**: 使用 `sessionStorage` 或内存存储（不持久化）

### 2.2 Token 使用

每次发送请求时，通过请求拦截器自动添加 Token 到请求头：

**请求拦截器：** `apps/web-ele/src/api/request.ts`

```typescript
client.addRequestInterceptor({
  fulfilled: async (config) => {
    const accessStore = useAccessStore();

    // 1. 添加 Authorization 头
    config.headers.Authorization = formatToken(accessStore.accessToken);
    
    // 2. 添加语言设置
    config.headers['Accept-Language'] = preferences.app.locale;
    
    // 3. 添加租户编号
    config.headers['tenant-id'] = tenantEnable
      ? accessStore.tenantId
      : undefined;
    
    // 4. 添加访问租户编号
    config.headers['visit-tenant-id'] = tenantEnable
      ? accessStore.visitTenantId
      : undefined;

    return config;
  },
});

function formatToken(token: null | string) {
  return token ? `Bearer ${token}` : null;
}
```

**请求头示例：**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
tenant-id: 1
Accept-Language: zh-CN
```

### 2.3 Token 刷新机制

当 Token 过期时（401 错误），系统会自动使用 Refresh Token 刷新：

#### 刷新流程

**响应拦截器：** `packages/effects/request/src/request-client/preset-interceptors.ts`

```typescript
export const authenticateResponseInterceptor = ({
  client,
  doReAuthenticate,
  doRefreshToken,
  enableRefreshToken,
  formatToken,
}: {
  client: RequestClient;
  doReAuthenticate: () => Promise<void>;
  doRefreshToken: () => Promise<string>;
  enableRefreshToken: boolean;
  formatToken: (token: string) => null | string;
}): ResponseInterceptorConfig => {
  return {
    rejected: async (error) => {
      const { config, response, data: responseData } = error;
      
      // 1. 检查是否为 401 错误
      if (response?.status !== 401 && responseData?.code !== 401) {
        throw error;
      }
      
      // 2. 判断是否启用了 refreshToken 功能
      if (!enableRefreshToken || config.__isRetryRequest) {
        await doReAuthenticate();
        throw error;
      }
      
      // 3. 如果正在刷新 token，将请求加入队列
      if (client.isRefreshing) {
        return new Promise((resolve) => {
          client.refreshTokenQueue.push((newToken: string) => {
            config.headers.Authorization = formatToken(newToken);
            resolve(client.request(config.url, { ...config }));
          });
        });
      }

      // 4. 标记开始刷新 token
      client.isRefreshing = true;
      config.__isRetryRequest = true;

      try {
        // 5. 调用刷新 token 接口
        const newToken = await doRefreshToken();

        // 6. 处理队列中的请求
        client.refreshTokenQueue.forEach((callback) => callback(newToken));
        client.refreshTokenQueue = [];

        // 7. 重试当前请求
        return client.request(error.config.url, { ...error.config });
      } catch (refreshError) {
        // 8. 刷新失败，清除队列，重新认证
        client.refreshTokenQueue.forEach((callback) => callback(''));
        client.refreshTokenQueue = [];
        await doReAuthenticate();
        throw refreshError;
      } finally {
        client.isRefreshing = false;
      }
    },
  };
};
```

#### Token 刷新实现

**刷新函数：** `apps/web-ele/src/api/request.ts`

```typescript
async function doRefreshToken() {
  const accessStore = useAccessStore();
  const refreshToken = accessStore.refreshToken as string;
  
  if (!refreshToken) {
    throw new Error('Refresh token is null!');
  }
  
  // 调用刷新接口
  const resp = await refreshTokenApi(refreshToken);
  const newToken = resp?.data?.data?.accessToken;
  
  if (!newToken) {
    throw resp.data;
  }
  
  // 存储新 Token
  accessStore.setAccessToken(newToken);
  return newToken;
}
```

**API 接口：**
```typescript
export async function refreshTokenApi(refreshToken: string) {
  return baseRequestClient.post(
    `/system/auth/refresh-token?refreshToken=${refreshToken}`,
  );
}
```

#### 并发请求处理

当多个请求同时收到 401 错误时，系统会：
1. **第一个请求** 触发 Token 刷新
2. **其他请求** 加入等待队列
3. **刷新完成后** 统一处理队列中的请求

```typescript
// 请求队列
client.refreshTokenQueue = [];

// 刷新完成后处理队列
client.refreshTokenQueue.forEach((callback) => callback(newToken));
client.refreshTokenQueue = [];
```

### 2.4 Token 过期处理

Token 刷新失败后，触发重新认证：

```typescript
async function doReAuthenticate() {
  console.warn('Access token or refresh token is invalid or expired. ');
  const accessStore = useAccessStore();
  const authStore = useAuthStore();
  
  // 清除 Token
  accessStore.setAccessToken(null);
  
  // 根据配置选择处理方式
  if (
    preferences.app.loginExpiredMode === 'modal' &&
    accessStore.isAccessChecked
  ) {
    // 显示登录过期弹窗
    accessStore.setLoginExpired(true);
  } else {
    // 跳转到登录页
    await authStore.logout();
  }
}
```

**两种处理方式：**

1. **弹窗模式（modal）**: 在当前页面显示登录弹窗，用户重新登录后继续操作
2. **页面跳转模式（page）**: 跳转到登录页面，用户重新登录后跳回原页面

## 三、登出流程

### 3.1 主动登出

用户点击退出按钮时，触发 `logout` 函数：

```typescript
async function logout(redirect: boolean = true) {
  try {
    const accessToken = accessStore.accessToken as string;
    if (accessToken) {
      // 1. 调用后端登出接口
      await logoutApi(accessToken);
    }
  } catch {
    // 不做任何处理
  }
  
  // 2. 重置所有 Store
  resetAllStores();
  accessStore.setLoginExpired(false);

  // 3. 跳转到登录页
  await router.replace({
    path: LOGIN_PATH,
    query: redirect
      ? {
          redirect: encodeURIComponent(router.currentRoute.value.fullPath),
        }
      : {},
  });
}
```

**API 接口：**
```typescript
export async function logoutApi(accessToken: string) {
  return baseRequestClient.post(
    '/system/auth/logout',
    {},
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  );
}
```

### 3.2 被动登出

当 Token 过期且刷新失败时，系统自动触发登出：

**触发场景：**
1. Token 过期
2. Refresh Token 过期
3. 用户被管理员强制下线
4. Token 被后端撤销

**处理方式：**
- 清除所有用户数据
- 清除所有权限数据
- 清除动态路由
- 跳转到登录页

## 四、请求拦截器链

系统通过多层拦截器处理请求和响应：

### 4.1 请求拦截器

**执行顺序：**

1. **添加请求头**
   ```typescript
   - Authorization: Bearer {token}
   - tenant-id: {tenantId}
   - visit-tenant-id: {visitTenantId}
   - Accept-Language: {locale}
   ```

2. **请求加密**（可选）
   ```typescript
   if (config.headers.isEncrypt) {
     config.data = apiEncrypt.encryptRequest(config.data);
     config.headers[apiEncrypt.getEncryptHeader()] = 'true';
   }
   ```

### 4.2 响应拦截器

**执行顺序：**

1. **响应解密**（可选）
   ```typescript
   if (response.headers[encryptHeader] === 'true') {
     response.data = apiEncrypt.decryptResponse(response.data);
   }
   ```

2. **Blob 响应处理**
   ```typescript
   // 处理文件下载时的 JSON 错误响应
   if (blob.type.includes('application/json')) {
     const parsed = JSON.parse(await blob.text());
     if (parsed.code !== 0) {
       throw new Error(parsed.msg);
     }
   }
   ```

3. **数据格式处理**
   ```typescript
   // 提取响应数据中的 data 字段
   if (responseData.code === 0) {
     return responseData.data;
   }
   ```

4. **Token 刷新**（401 错误）
   ```typescript
   // 自动刷新 Token 并重试请求
   ```

5. **错误提示**
   ```typescript
   // 根据错误码显示不同的错误提示
   ElMessage.error(errorMessage);
   ```

### 4.3 拦截器链图示

```
请求 → 请求拦截器 → 发送到服务器
                            ↓
                        服务器处理
                            ↓
响应 ← 响应拦截器 ← 服务器响应

请求拦截器链：
  1. 添加 Authorization 头
  2. 添加租户头
  3. 请求加密（可选）

响应拦截器链：
  1. 响应解密（可选）
  2. Blob 处理
  3. 数据格式处理
  4. Token 刷新（401）
  5. 错误提示
```

## 五、安全机制

### 5.1 密码加密

登录时可以选择对密码进行加密：

```typescript
loginApi(data, {
  headers: {
    isEncrypt: true,  // 启用加密
  },
});
```

**加密方式：**
- 使用 RSA 公钥加密
- 后端使用私钥解密

### 5.2 验证码验证

支持多种验证码类型，防止暴力破解：

**验证码类型：**
- **滑块验证码**: 用户拖动滑块到指定位置
- **文字点选**: 用户按顺序点击指定文字

**验证流程：**
1. 用户点击登录
2. 弹出验证码
3. 用户完成验证
4. 获取验证结果 `captchaVerification`
5. 将验证结果随登录请求提交

### 5.3 Token 安全

**安全措施：**

1. **Token 过期时间**
   - Access Token: 较短（如 2 小时）
   - Refresh Token: 较长（如 7 天）

2. **Token 存储**
   - 默认存储在 localStorage
   - 可配置为 sessionStorage 或内存存储

3. **Token 传输**
   - 使用 HTTPS 加密传输
   - Token 放在 Header 中，不放在 URL 中

4. **Token 撤销**
   - 后端可以撤销 Token
   - 用户可以主动登出

### 5.4 租户隔离

系统支持多租户，通过租户编号实现数据隔离：

**租户管理：**
```typescript
// 设置当前租户
accessStore.setTenantId(tenantId);

// 设置访问租户（跨租户访问）
accessStore.setVisitTenantId(visitTenantId);
```

**请求头携带：**
```typescript
config.headers['tenant-id'] = accessStore.tenantId;
config.headers['visit-tenant-id'] = accessStore.visitTenantId;
```

## 六、登录状态管理

### 6.1 登录状态判断

系统通过以下方式判断用户是否已登录：

```typescript
// 检查 accessToken 是否存在
if (!accessStore.accessToken) {
  // 未登录
  return {
    path: LOGIN_PATH,
    query: { redirect: encodeURIComponent(to.fullPath) },
  };
}
```

### 6.2 登录状态持久化

**持久化配置：**
```typescript
persist: {
  pick: [
    'accessToken',
    'refreshToken',
    'tenantId',
    'visitTenantId',
  ],
}
```

**持久化作用：**
- 用户刷新页面后保持登录状态
- 用户关闭浏览器后重新打开仍保持登录状态（localStorage 模式）

### 6.3 登录状态过期

**过期处理：**

1. **Token 过期**: 自动刷新 Token
2. **Refresh Token 过期**: 跳转登录页
3. **用户被踢下线**: 跳转登录页

**过期标记：**
```typescript
// 标记登录过期
accessStore.setLoginExpired(true);

// 判断是否过期
if (accessStore.loginExpired) {
  // 显示登录过期提示
}
```

## 七、完整流程图

### 7.1 登录流程

```
用户访问登录页
    ↓
输入用户名、密码（租户、验证码）
    ↓
点击登录按钮
    ↓
验证码验证（如果启用）
    ↓
调用登录 API
    ├─ 成功 → 获取 accessToken 和 refreshToken
    │   ↓
    │   存储 Token 到 Store
    │   ↓
    │   调用 get-permission-info API
    │   ├─ 获取用户信息
    │   ├─ 获取角色列表
    │   ├─ 获取菜单列表
    │   └─ 获取权限列表
    │   ↓
    │   存储用户信息和权限
    │   ↓
    │   生成动态路由
    │   ↓
    │   跳转到首页
    │   ↓
    │   显示登录成功提示
    │
    └─ 失败 → 显示错误提示
```

### 7.2 Token 刷新流程

```
请求 API
    ↓
收到 401 错误
    ↓
检查是否启用 Refresh Token
    ├─ 未启用 → 跳转登录页
    └─ 已启用 → 继续
        ↓
    检查是否正在刷新
        ├─ 是 → 加入请求队列
        │       ↓
        │   等待刷新完成
        │       ↓
        │   使用新 Token 重试请求
        │
        └─ 否 → 开始刷新
            ↓
        调用 refresh-token API
            ├─ 成功 → 获取新 Token
            │   ↓
            │   存储新 Token
            │   ↓
            │   处理队列中的请求
            │   ↓
            │   重试当前请求
            │
            └─ 失败 → 清除队列
                    ↓
                跳转登录页
```

### 7.3 登出流程

```
用户点击退出
    ↓
调用登出 API
    ↓
重置所有 Store
    ├─ 清除 accessToken
    ├─ 清除 refreshToken
    ├─ 清除 userInfo
    ├─ 清除 accessMenus
    ├─ 清除 accessCodes
    └─ 清除 accessRoutes
    ↓
清除动态路由
    ↓
跳转到登录页
    ↓
携带 redirect 参数（可选）
```

## 八、最佳实践

### 8.1 Token 安全建议

1. **使用 HTTPS**: 确保 Token 在传输过程中加密
2. **设置合理的过期时间**: Access Token 较短，Refresh Token 较长
3. **Token 刷新时机**: 在 Token 快过期时主动刷新，而不是等到 401 错误
4. **敏感操作二次验证**: 重要操作要求重新输入密码或验证码

### 8.2 性能优化

1. **减少权限请求**: 用户信息和权限可以缓存，不必每次都请求
2. **并行请求**: 登录成功后，可以并行获取用户信息、菜单、权限
3. **请求去重**: 避免重复发送相同的请求

### 8.3 用户体验

1. **登录状态提示**: 清晰提示用户登录状态（已登录、已过期）
2. **自动跳转**: 登录成功后自动跳转到原页面或首页
3. **错误提示友好**: 登录失败时显示具体的错误原因
4. **记住登录状态**: 提供记住登录状态的选项

## 九、常见问题

### 9.1 Token 过期后请求失败

**问题**: Token 过期后，第一个请求会失败

**解决方案**: 
- 使用 Refresh Token 自动刷新
- 刷新后自动重试失败的请求

### 9.2 多标签页同步登出

**问题**: 一个标签页登出后，其他标签页仍然显示已登录

**解决方案**: 
- 监听 `storage` 事件，当 Token 被清除时，自动刷新页面
- 或使用 WebSocket 推送登出消息

### 9.3 Token 刷新竞态条件

**问题**: 多个请求同时收到 401，导致多次刷新 Token

**解决方案**: 
- 使用 `isRefreshing` 标记和请求队列
- 确保同一时间只有一个刷新操作

## 十、总结

系统的登录和认证流程包括以下关键步骤：

1. **多种登录方式**: 支持用户名密码、手机验证码、社交账号等多种登录方式
2. **Token 管理**: 使用 JWT Token，支持自动刷新和持久化存储
3. **权限获取**: 登录成功后获取用户信息、角色、菜单、权限
4. **请求拦截**: 自动添加 Token 到请求头，处理 401 错误
5. **Token 刷新**: Token 过期时自动刷新，支持并发请求处理
6. **安全机制**: 验证码、密码加密、租户隔离等多重安全保障

整个流程设计合理，安全可靠，支持多种业务场景，为系统提供了完善的认证保障。

---

**相关文件：**
- `apps/web-ele/src/views/_core/authentication/login.vue` - 登录页面
- `apps/web-ele/src/store/auth.ts` - 认证 Store
- `apps/web-ele/src/api/core/auth.ts` - 认证 API
- `apps/web-ele/src/api/request.ts` - 请求配置
- `packages/stores/src/modules/access.ts` - 权限 Store
- `packages/effects/request/src/request-client/preset-interceptors.ts` - 拦截器
