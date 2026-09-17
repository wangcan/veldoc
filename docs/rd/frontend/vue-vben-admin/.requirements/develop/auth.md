# 需求1 执行结果：接入后台账号密码登录

> 需求来源：`.requirements/develop/task.txt` 中的「需求1」。
>
> `task.txt` 中间有明确指令「忽略以下所有需求描述」，因此「需求2」（ruoyi 权限模块移植）未执行，本文档仅记录需求1的结果。

## 一、需求描述

结合后台登录接口文档地址：http://showdoc.canliang.wang/web/#/668966074/297761730 ，
接入通过账号、密码登录后台的操作。

## 二、接口契约

依据接口文档，后台登录接口为：

```
POST {{host}}/api/v1/user-center/auth/login
Content-Type: application/json
```

- **请求体**

  | 字段       | 类型     | 必填 | 说明                                  |
  | ---------- | -------- | ---- | ------------------------------------- |
  | `login`    | string   | 是   | 账号名 / 邮箱 / 手机号                |
  | `password` | string   | 是   | 用户密码                              |

  ```json
  { "login": "superadmin", "password": "123456" }
  ```

- **成功响应**（HTTP 200，`code: 0`）

  ```json
  {
    "success": true,
    "code": 0,
    "data": {
      "access_token": "<JWT>",
      "token_type": "bearer",
      "expires_in": 2592000,
      "user": {
        "id": 1,
        "name": "superadmin",
        "email": "superadmin@example.com",
        "phone": "13811974106",
        "status": "active",
        "roles": ["super_admin"],
        "permissions": ["system:user:list", "system:role:list", "..."]
      }
    }
  }
  ```

- **失败响应**（HTTP 200，`code: 1`）

  ```json
  {
    "message": "Invalid credentials",
    "errors": { "credentials": ["Invalid credentials"] },
    "code": 1
  }
  ```

- **后台服务地址**：JWT iss 指向 `http://49.235.53.53:9001`，本机部署后为 `http://localhost:9001`，经探测服务运行正常。

- **关联接口（实测）**

  | 接口                                 | 方法 | 状态     | 用途                       |
  | ------------------------------------ | ---- | -------- | -------------------------- |
  | `/api/v1/user-center/auth/login`     | POST | 200 ✅   | 账号密码登录，返回 JWT+用户 |
  | `/api/v1/user-center/auth/me`        | GET  | 200 ✅   | 获取当前登录用户资料        |
  | `/api/v1/user-center/auth/refresh`   | POST | 200 ✅   | 刷新 accessToken           |
  | `/api/v1/user-center/auth/logout`    | POST | 200 ✅   | 退出登录                   |
  | `/api/v1/user-center/user/info`      | GET  | 404 ❌   | 后端不存在，已停用          |
  | `/api/v1/user-center/auth/codes`     | GET  | 404 ❌   | 后端不存在，已停用          |

## 三、改动文件清单（6 个）

| 文件 | 改动内容 |
| --- | --- |
| `apps/web-antd/vite.config.ts` | 开发代理目标由 mock（`localhost:5320/api`）改为真实后台（`localhost:9001/api`） |
| `apps/web-antd/src/api/core/auth.ts` | `loginApi` 改为 `POST /v1/user-center/auth/login`，表单字段 `username` 映射为后端 `login`；新增 `LoginUser`/`LoginResult`/`RefreshTokenData`/`RefreshTokenBody` 等类型以匹配后端 `access_token`+`user` 结构；`refresh`/`logout` 路径更新；移除后端不存在的 `getAccessCodesApi` |
| `apps/web-antd/src/api/core/user.ts` | `getUserInfoApi` 改为 `GET /v1/user-center/auth/me`（原 `/user/info` 后端 404），并将后端用户资料映射为前端 `UserInfo` |
| `apps/web-antd/src/store/auth.ts` | 登录成功后直接使用响应里的 `user`（含 `roles`、`permissions`），不再调用会 404 的 `/user/info`、`/auth/codes`；权限码取自 `user.permissions`；角色取自 `user.roles` |
| `apps/web-antd/src/api/request.ts` | 修正 `doRefreshToken`：从后端响应体 `data.data.access_token` 提取新 token（原写法仅适用 mock） |
| `apps/web-antd/src/views/_core/authentication/login.vue` | 示例账号改为后端真实账号 `superadmin`；保留 `username` 字段名（`AuthenticationLogin` 组件「记住我」功能依赖它），在 API 层映射为 `login` |

## 四、关键设计点

1. **响应拦截器无需改动**
   后端返回 `{ code:0, data:{...} }`，与现有 `defaultResponseInterceptor({ codeField:'code', dataField:'data', successCode:0 })` 完全匹配。`requestClient`（带拦截器）的 `loginApi`/`getUserInfoApi` 自动返回 `data` 字段内容。

2. **字段映射 `username` → `login`**
   后端用 `login` 接收账号 / 手机号 / 邮箱，而前端 `AuthenticationLogin` 组件的「记住我」功能硬编码依赖 `username` 字段名。为兼顾两者，表单仍使用 `username`，在 `loginApi` 内部映射为 `login` 发送给后端。

3. **登录失败处理**
   后端以 HTTP 200 + `code:1` + `message` 返回鉴权失败，现有 `errorMessageResponseInterceptor` 会自动读取 `responseData.message` 并通过 `message.error` 弹出提示（如 `Invalid credentials`）。

4. **刷新场景（页面刷新后恢复会话）**
   accessToken 持久化于 `accessStore`，刷新页面时 token 仍在。路由守卫 `setupAccessGuard` 检测到 `isAccessChecked === false` 会调用 `authStore.fetchUserInfo()` → `/auth/me` 恢复用户资料；`accessCodes`（权限码）也已持久化，路由访问不受影响。

5. **角色与权限码来源**
   登录接口响应已包含 `user.roles` 与 `user.permissions`，登录时一次性写入 `userStore` 与 `accessStore`。`/auth/me` 不返回角色信息，因此刷新页面后 `userInfo.roles` 为空数组——但前端访问模式为 `frontend`（静态路由未对路由配置 `roles` 元信息），路由生成不受影响；权限码 `accessCodes` 已持久化，按钮级权限指令 `v-access` 仍可正常工作。

6. **Token 刷新**
   默认 `enableRefreshToken: false`（见 `packages/@core/preferences/src/config.ts`），未开启刷新流程。但已修正 `doRefreshToken` 的 token 提取逻辑，开启后可正常工作：`baseRequestClient` 不经过响应拦截器，返回原始 `AxiosResponse`，需从 `resp.data.data.access_token` 提取。

## 五、验证结果

| 验证项 | 结果 |
| --- | --- |
| `pnpm -F @vben/web-antd run typecheck` | ✅ 通过，无类型错误 |
| `oxlint`（改动文件） | ✅ 无报错 |
| 真机接口联调-登录 | ✅ `code:0`，返回 `access_token` + 用户（角色 `super_admin`，19 个权限码） |
| 真机接口联调-`/auth/me` | ✅ `code:0`，返回用户资料（`name=superadmin`） |
| 真机接口联调-错误密码 | ✅ `code:1`，`message=Invalid credentials` |

## 六、使用方式

1. 确保后台服务 `localhost:9001` 运行中。
2. 执行 `pnpm dev:antd` 启动前端。
3. 登录页选择 `Super Admin`（自动填入 `superadmin` / `123456`），完成滑动验证后即可登录真实后台。

## 七、未执行项

- 「需求2」（基于 ruoyi-vue-pro 的角色权限模块移植）依据 `task.txt` 中的「忽略以下所有需求描述」指令，未执行。
