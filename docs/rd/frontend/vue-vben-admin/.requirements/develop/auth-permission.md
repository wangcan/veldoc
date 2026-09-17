# 需求1 执行结果：用户认证、权限分配、菜单渲染、动态路由、刷新token、退出登录

> 需求来源：`.requirements/develop/task.txt` 中的「需求1」。
>
> task.txt 中间有明确指令「忽略以下所有需求描述」，因此「需求2」未执行，本文档仅记录需求1的结果。
>
> 上一轮工作记录见 `.requirements/develop/auth.md`（已接入账号密码登录）。本轮在此基础上补齐「权限分配、菜单渲染、动态路由、刷新token、退出登录」。

## 一、需求描述

结合 5 个后台接口，完成用户登录认证、权限分配、菜单渲染、动态路由等操作；完成刷新 token 和退出登录操作。

| # | 接口 | 方法 | 路径（`{{host}} = http://49.235.53.53:9001`） |
| - | --- | --- | --- |
| 1 | 账号密码登录 | POST | `/api/v1/user-center/auth/login` |
| 2 | 当前登录用户信息 | GET | `/api/v1/user-center/auth/me` |
| 3 | 当前管理员树状权限信息 | GET | `/api/v1/user-center/auth/permission-info` |
| 4 | 刷新当前用户 token | POST | `/api/v1/user-center/auth/refresh` |
| 5 | 退出登录 | POST | `/api/v1/user-center/auth/logout` |

## 二、接口契约（已 curl 实测）

响应统一为 `{success, code:0成功, data, message?}`；token 过期/无效返回 **HTTP 401** `{message:"Unauthenticated.", code:1}`。

### 3. permission-info（本轮新接入，菜单/权限数据源）

```
GET /api/v1/user-center/auth/permission-info
Authorization: Bearer <access_token>
```

响应 `data`：

```jsonc
{
  "user": { "id": 1, "name": "superadmin", "nickname": null, "avatar": null },
  "roles": ["super_admin"],
  "permissions": ["*"],                 // 普通用户为具体权限码数组
  "menus": [
    {
      "id": 1, "name": "系统管理", "parentId": 0, "type": 1,        // 1=目录 2=菜单 3=按钮
      "sort": 10, "path": "/system", "icon": "ep:tools",
      "component": "", "componentName": null, "permission": "",
      "visible": true, "keepAlive": true, "alwaysShow": true,
      "children": [
        {
          "id": 100, "name": "用户管理", "type": 2, "path": "user",
          "icon": "ep:avatar", "component": "system/user/index",
          "componentName": "SystemUser", "permission": "system:user:list",
          "children": [
            { "id": 1001, "name": "用户查询", "type": 3, "permission": "system:user:query", "children": [] }
          ]
        }
      ]
    }
  ]
}
```

## 三、改动文件清单

| 文件 | 类型 | 改动 |
| --- | --- | --- |
| `apps/web-antd/vite.config.ts` | 修改 | dev 代理 target 由 `http://b.lpt.com/api`（IIS 404）改为 `http://49.235.53.53:9001/api` |
| `apps/web-antd/src/api/core/permission.ts` | 新建 | `getPermissionInfoApi` + 后端菜单树→`RouteRecordStringComponent[]` 转换 + `fetchMenuListWithAccessInfo`（回填 accessCodes/角色） |
| `apps/web-antd/src/api/core/index.ts` | 修改 | 导出 `./permission` |
| `apps/web-antd/src/router/access.ts` | 修改 | `fetchMenuListAsync` 由 mock 的 `getAllMenusApi()` 改为 `fetchMenuListWithAccessInfo()` |
| `apps/web-antd/src/api/request.ts` | 修改 | `formatToken` 提到模块作用域；给 `baseRequestClient` 加鉴权请求拦截器（refresh/logout 随请求携带 JWT） |
| `apps/web-antd/src/api/core/auth.ts` | 修改 | `refreshTokenApi`/`logoutApi` 去掉误传的 `{withCredentials:true}`（被当成请求体发了） |
| `apps/web-antd/src/preferences.ts` | 修改 | `accessMode:'mixed'`、`enableRefreshToken:true` |
| `packages/effects/access/src/use-access.ts` | 修改 | `hasAccessByCodes` 增加超级管理员通配权限码 `*` 放行逻辑 |
| `apps/web-antd/src/views/system/user/index.vue` | 新建 | 用户管理占位页 + `v-access:code` 按钮级权限演示 |
| `apps/web-antd/src/views/system/role/index.vue` | 新建 | 角色管理占位页 + `v-access:code` 演示 |
| `apps/web-antd/src/views/system/menu/index.vue` | 新建 | 菜单管理占位页 + `v-access:code` 演示 |

## 四、关键设计点

### 1. 访问模式：mixed（混合）

`preferences.app.accessMode = 'mixed'`。`generateAccessible`（`packages/effects/access/src/accessible.ts`）在 mixed 模式下并行执行：

- `generateRoutesByFrontend`：保留前端静态路由（`router/routes/modules/dashboard|demos|vben`），首页 `/analytics` 仍可用；
- `generateRoutesByBackend`：调用 `fetchMenuListAsync`（即 `fetchMenuListWithAccessInfo`）拉取后端菜单树生成动态路由；
- `mergeRoutesByName`：按 `name` 合并，后端「系统管理」与前端「Dashboard」等不冲突，侧边栏并存。

### 2. 后端菜单树 → 前端路由转换（`api/core/permission.ts`）

`transformBackendMenusToRoutes` 递归处理：

- **过滤 type===3（按钮）节点**：按钮是权限点（`system:user:create` 等），不参与路由生成；其权限码已由 `data.permissions` 提供，写入 `accessStore.accessCodes` 供 `v-access:code` 使用。
- **字段映射**：
  - `name` = `componentName` || 由 `path` 派生（`/system`→`System`，空路径→`Menu_{id}`）；
  - `path` 原样保留（顶级绝对 `/system`，子级相对 `user`，Vue Router 自动拼成 `/system/user`）；
  - `component` 原样保留：目录 `""`（`generateAccessible` 在有 children 时删除 component）；菜单 `"system/user/index"` 经 `normalizeViewPath`（`packages/utils/src/helpers/generate-routes-backend.ts`）映射到 `import.meta.glob('../views/**/*.vue')` 中的 `system/user/index.vue`；
  - `meta` = `{title: name, icon, order: sort, hideInMenu: !visible, keepAlive}`。

转换结果（实测）：

```
- System        path='/system'  component=''(目录,component 被删除)
  - SystemUser  path='user'     component='system/user/index' -> views/system/user/index.vue
  - SystemRole  path='role'     component='system/role/index' -> views/system/role/index.vue
  - SystemMenu  path='menu'     component='system/menu/index' -> views/system/menu/index.vue
```

### 3. 权限分配（accessCodes + roles）

`fetchMenuListWithAccessInfo` 一次调用完成：

1. `accessStore.setAccessCodes(info.permissions)` —— 按钮级权限码（`v-access:code` 依据）；
2. 增量更新 `userStore.userInfo`：`roles`、`avatar`、`realName`、`username`、`userId`（`/auth/me` 不返回 roles，此处由 permission-info 补齐）；
3. 返回转换后的菜单路由树。

登录时 `loginApi` 响应已含 `user.roles`/`user.permissions`（`store/auth.ts` 写入）；页面刷新时由 `/auth/me`（资料）+ `/auth/permission-info`（角色/权限/菜单）重建。`accessCodes` 持久化于 `accessStore`（`packages/stores/src/modules/access.ts` 的 `persist.pick`）。

### 4. 超级管理员通配权限 `*`

后端对 superadmin 返回 `permissions: ["*"]`，但 `hasAccessByCodes`（`packages/effects/access/src/use-access.ts`）原为严格集合匹配，会导致 superadmin 的 `v-access:code` 按钮被误隐藏。已增加放行逻辑：

```ts
if (userCodesSet.has('*')) return true;
```

### 5. 刷新 token（enableRefreshToken: true）

- 后端 token 过期返回 HTTP 401 → `authenticateResponseInterceptor`（`packages/effects/request/src/request-client/preset-interceptors.ts`）触发 `doRefreshToken`。
- `doRefreshToken` → `refreshTokenApi`（`baseRequestClient.post('/auth/refresh')`）→ 后端黑名单旧 token、签发新 token → `accessStore.setAccessToken(newToken)` → 重试原请求（请求拦截器从 store 重读新 token）。
- **关键修复**：`baseRequestClient` 原本没有请求拦截器，`refreshTokenApi`/`logoutApi` 发请求时**不带 Authorization 头**（refresh 会 401、logout 实际未注销 token）。已给 `baseRequestClient` 加鉴权请求拦截器，并去掉误传的 `{withCredentials:true}` 请求体。
- 并发 401 请求由 `client.isRefreshing` + `refreshTokenQueue` 串行化，避免重复刷新。

### 6. 退出登录

`store/auth.ts` 的 `logout` 调用 `logoutApi`（`baseRequestClient` 已携带 token）→ 后端 200 黑名单当前 token → `resetAllStores()` 清空本地态 → 跳转登录页（带 redirect）。此前因 baseRequestClient 未带头，后端 token 实际未被注销，现已修复。

## 五、验证结果

| 验证项 | 结果 |
| --- | --- |
| `pnpm -F @vben/web-antd run typecheck` | ✅ 通过，无类型错误 |
| `oxlint`（全部改动文件） | ✅ 无报错 |
| 后端联调-login（经 Vite 代理 `localhost:5666/api`） | ✅ code:0，返回 access_token + 用户（roles=super_admin，19 权限码） |
| 后端联调-permission-info（经代理） | ✅ code:0，返回 1 顶级菜单「系统管理」+ 3 子菜单 |
| 后端联调-/auth/me（经代理） | ✅ code:0，name=superadmin |
| 后端联调-refresh（经代理） | ✅ HTTP 200，返回新 access_token |
| 后端联调-logout（经代理，有效 token） | ✅ HTTP 200，`Successfully logged out` |
| 菜单转换模拟（真实数据） | ✅ type=3 按钮已过滤；目录/菜单 component 正确映射到 views |
| 动态路由组件编译 | ✅ `src/views/system/*/index.vue` 经 Vite 编译返回 HTTP 200 |
| dev 启动 | ✅ VITE v8.0.13 ready，无编译错误 |

## 六、使用方式

1. 确保后端服务 `http://49.235.53.53:9001` 可达（dev 代理已配置）。
2. **清空浏览器 localStorage**（偏好/accessStore 持久化缓存了旧 accessMode/enableRefreshToken，不清缓存新配置不生效）。
3. `pnpm dev:antd` 启动前端。
4. 登录页选择 `Super Admin`（自动填入 `superadmin` / `123456`），完成滑动验证 → 跳转 `/analytics`。
5. 侧边栏可见后端动态渲染的「系统管理」→ 用户/角色/菜单管理；点击进入对应动态路由占位页。
6. 占位页内「新增/编辑/删除」按钮由 `v-access:code` 守卫，superadmin（`*`）全部可见。
7. 刷新页面 → 会话由 `/auth/me` + `/auth/permission-info` 重建。
8. 退出登录 → 后端注销 token，回登录页。

## 七、未执行项

- 「需求2」（基于 ruoyi-vue-pro 的角色权限模块移植）依据 task.txt「忽略以下所有需求描述」指令，未执行。
- `apps/web-antd/src/api/core/menu.ts` 的 `getAllMenusApi`（原 mock `/menu/all`）已不再被 `access.ts` 使用，保留未删以免影响其他引用；后端菜单统一由 `permission.ts` 的 `fetchMenuListWithAccessInfo` 提供。
- system/user|role|menu 为占位页（演示菜单渲染+动态路由+按钮权限），真实 CRUD 业务不在需求1范围内。
