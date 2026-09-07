# 路由请求的完整运行周期

本文档详细说明了一次路由请求在系统中的完整运行周期，从用户发起请求到页面渲染完成的整个流程。

## 概述

系统采用 **Vue Router** 作为路由管理工具，结合 **后端控制路由模式**（RBAC），实现了动态路由加载、权限验证、页面缓存等功能。路由周期包括：路由初始化、导航守卫、权限验证、路由生成、页面加载等阶段。

## 一、路由初始化阶段

### 1.1 创建路由实例

路由实例在应用启动时创建，位于 `apps/web-ele/src/router/index.ts`:

```typescript
const router = createRouter({
  history: createWebHistory(import.meta.env.VITE_BASE),
  routes,  // 初始路由列表
  scrollBehavior: (to, _from, savedPosition) => {
    if (savedPosition) {
      return savedPosition;
    }
    return to.hash ? { behavior: 'smooth', el: to.hash } : { left: 0, top: 0 };
  },
});
```

**关键点：**
- 使用 HTML5 History 模式（或 Hash 模式）
- 初始路由只包含核心路由（登录、错误页等）
- 动态路由会在用户登录后动态添加

### 1.2 初始路由配置

初始路由分为两类（`apps/web-ele/src/router/routes/index.ts`）：

#### 核心路由（coreRoutes）
- **登录页、注册页、找回密码等**：无需权限验证
- **根路由**：作为所有页面的父级容器
- **404 页面**：兜底路由

```typescript
const coreRoutes: RouteRecordRaw[] = [
  {
    component: BasicLayout,
    name: 'Root',
    path: '/',
    redirect: preferences.app.defaultHomePath,
    children: [],
  },
  {
    component: AuthPageLayout,
    name: 'Authentication',
    path: '/auth',
    children: [
      { name: 'Login', path: 'login', component: () => import('#/views/_core/authentication/login.vue') },
      // ... 其他认证页面
    ],
  },
];
```

#### 动态路由（accessRoutes）
- **业务模块路由**：系统管理、订单管理、用户管理等
- **需要权限验证**：根据用户角色动态加载
- **通过模块化组织**：每个业务模块一个文件

```typescript
// 动态路由通过 import.meta.glob 自动导入
const dynamicRouteFiles = import.meta.glob('./modules/**/*.ts', { eager: true });
const dynamicRoutes: RouteRecordRaw[] = mergeRouteModules(dynamicRouteFiles);
```

### 1.3 创建路由守卫

路由实例创建后，立即创建路由守卫：

```typescript
createRouterGuard(router);
```

## 二、导航守卫阶段

导航守卫是路由周期的核心，分为两个主要守卫：

### 2.1 通用守卫（setupCommonGuard）

**职责：** 处理页面加载状态、进度条显示

```typescript
function setupCommonGuard(router: Router) {
  const loadedPaths = new Set<string>();

  router.beforeEach((to) => {
    to.meta.loaded = loadedPaths.has(to.path);

    // 页面加载进度条
    if (!to.meta.loaded && preferences.transition.progress) {
      startProgress();
    }
    return true;
  });

  router.afterEach((to) => {
    loadedPaths.add(to.path);

    // 关闭页面加载进度条
    if (preferences.transition.progress) {
      stopProgress();
    }
  });
}
```

**流程：**
1. **beforeEach**: 检查页面是否已加载，显示进度条
2. **afterEach**: 记录已加载页面，关闭进度条

### 2.2 权限访问守卫（setupAccessGuard）

**职责：** 处理登录验证、权限检查、动态路由生成

```typescript
function setupAccessGuard(router: Router) {
  router.beforeEach(async (to, from) => {
    // 详细流程见下文
  });
}
```

## 三、权限验证详细流程

### 3.1 核心路由检查

首先检查目标路由是否为核心路由（登录、注册等）：

```typescript
if (coreRouteNames.includes(to.name as string)) {
  // 如果已登录且访问登录页，重定向到首页
  if (to.path === LOGIN_PATH && accessStore.accessToken) {
    return userStore.userInfo?.homePath || preferences.app.defaultHomePath;
  }
  return true;  // 核心路由直接放行
}
```

**逻辑：**
- 核心路由不需要权限验证
- 已登录用户访问登录页时，自动重定向到首页

### 3.2 Token 验证

检查用户是否已登录：

```typescript
if (!accessStore.accessToken) {
  // 未登录情况
  if (to.meta.ignoreAccess) {
    return true;  // 忽略权限的页面直接放行
  }

  // 重定向到登录页，携带当前路径作为重定向参数
  return {
    path: LOGIN_PATH,
    query: { redirect: encodeURIComponent(to.fullPath) },
    replace: true,
  };
}
```

**逻辑：**
- 未登录用户访问受保护页面时，重定向到登录页
- 保存当前路径，登录后自动跳回

### 3.3 动态路由生成检查

检查是否已生成过动态路由：

```typescript
if (accessStore.isAccessChecked) {
  return true;  // 已生成，直接放行
}
```

**说明：**
- `isAccessChecked` 标记是否已完成权限验证和路由生成
- 避免重复生成路由

### 3.4 获取用户信息和权限

首次访问时，获取用户信息和权限：

```typescript
// 加载字典数据（异步，不阻塞）
dictStore.setDictCacheByApi(getSimpleDictDataList);

// 获取用户信息和权限
let userInfo = userStore.userInfo;
if (!userInfo) {
  const authPermissionInfo = await authStore.fetchUserInfo();
  userInfo = authPermissionInfo.user;
}

const userRoles = userStore.userRoles ?? [];
```

**说明：**
- `fetchUserInfo()` 会调用后端 API 获取用户信息、角色、菜单、权限
- 字典数据异步加载，不阻塞路由跳转

### 3.5 生成菜单和路由

根据用户角色和权限生成可访问的菜单和路由：

```typescript
const { accessibleMenus, accessibleRoutes } = await generateAccess({
  roles: userRoles,
  router,
  routes: accessRoutes,  // 前端定义的所有动态路由
});

// 保存到 store
accessStore.setAccessMenus(accessibleMenus);
accessStore.setAccessRoutes(accessibleRoutes);
accessStore.setIsAccessChecked(true);
```

**详细流程见下文「动态路由生成」**

### 3.6 重定向到目标页面

路由生成完成后，重定向到目标页面：

```typescript
const redirectPath = (from.query.redirect ?? to.fullPath) as string;

return {
  ...router.resolve(decodeURIComponent(redirectPath)),
  replace: true,
};
```

## 四、动态路由生成

### 4.1 路由生成模式

系统支持两种路由生成模式：

1. **前端模式（frontend）**: 根据前端定义的路由和用户角色过滤
2. **后端模式（backend）**: 根据后端返回的菜单数据动态生成路由 ⭐（项目默认使用）

### 4.2 后端模式路由生成流程

`apps/web-ele/src/router/access.ts` 中的 `generateAccess` 函数：

```typescript
async function generateAccess(options: GenerateMenuAndRoutesOptions) {
  const pageMap: ComponentRecordType = import.meta.glob('../views/**/*.vue');
  const layoutMap: ComponentRecordType = {
    BasicLayout,
    IFrameView,
  };

  return await generateAccessible(preferences.app.accessMode, {
    ...options,
    fetchMenuListAsync: async () => {
      const accessMenus = accessStore.accessMenus as AppRouteRecordRaw[];
      return convertServerMenuToRouteRecordStringComponent(accessMenus);
    },
    forbiddenComponent,
    layoutMap,
    pageMap,
  });
}
```

**关键步骤：**

#### 步骤 1: 获取后端菜单数据

后端菜单数据已在 `fetchUserInfo()` 时获取并存储在 `accessStore.accessMenus`:

```typescript
// apps/web-ele/src/store/auth.ts
async function fetchUserInfo() {
  const authPermissionInfo = await getAuthPermissionInfoApi();
  userStore.setUserInfo(authPermissionInfo.user);
  userStore.setUserRoles(authPermissionInfo.roles);
  accessStore.setAccessMenus(authPermissionInfo.menus);  // 存储菜单
  accessStore.setAccessCodes(authPermissionInfo.permissions);
  return authPermissionInfo;
}
```

**后端 API 接口：**
- **路径**: `/system/auth/get-permission-info`
- **返回数据**:
  ```typescript
  {
    user: UserInfo,          // 用户信息
    roles: string[],         // 角色列表
    menus: Menu[],           // 菜单列表
    permissions: string[],   // 权限列表
  }
  ```

#### 步骤 2: 转换菜单数据为路由格式

`packages/utils/src/helpers/generate-routes-backend.ts` 中的 `generateRoutesByBackend` 函数：

```typescript
async function generateRoutesByBackend(options: GenerateMenuAndRoutesOptions) {
  const menuRoutes = await fetchMenuListAsync?.();

  // 规范化页面组件路径映射
  const normalizePageMap: ComponentRecordType = {};
  for (const [key, value] of Object.entries(pageMap)) {
    normalizePageMap[normalizeViewPath(key)] = value;
  }

  // 转换路由
  let routes = convertRoutes(menuRoutes, layoutMap, normalizePageMap);

  // 处理 menuVisibleWithForbidden 标记的路由
  if (forbiddenComponent) {
    routes = mapTree(routes, (route) => {
      if (menuHasVisibleWithForbidden(route)) {
        route.component = forbiddenComponent;  // 替换为 403 组件
      }
      return route;
    });
  }

  // 合并静态路由和动态路由
  return [...options.routes, ...routes];
}
```

#### 步骤 3: 组件映射转换

`convertRoutes` 函数将字符串组件名映射为实际的 Vue 组件：

```typescript
function convertRoutes(
  routes: RouteRecordStringComponent[],
  layoutMap: ComponentRecordType,
  pageMap: ComponentRecordType,
): RouteRecordRaw[] {
  return mapTree(routes, (node) => {
    const route = node as unknown as RouteRecordRaw;
    const { component, name } = node;

    // Layout 组件转换
    if (component && layoutMap[component]) {
      route.component = layoutMap[component];
    }
    // 页面组件转换
    else if (component) {
      const normalizePath = normalizeViewPath(component);
      const pageKey = normalizePath.endsWith('.vue')
        ? normalizePath
        : `${normalizePath}.vue`;
      if (pageMap[pageKey]) {
        route.component = pageMap[pageKey];
      } else {
        // 组件不存在时，使用 404 页面
        route.component = pageMap['/_core/fallback/not-found.vue'];
      }
    }

    return route;
  });
}
```

**组件映射关系：**
- `BasicLayout` → 基础布局组件
- `IFrameView` → IFrame 嵌入组件
- `views/xxx.vue` → 实际页面组件

### 4.3 路由注册

生成的路由通过 Vue Router 的 `addRoute` 方法动态注册：

```typescript
// 在 generateAccessible 函数中（packages/effects/access/src/accessible.ts）
for (const route of accessibleRoutes) {
  router.addRoute(route);
}
```

## 五、页面加载阶段

### 5.1 组件懒加载

所有页面组件都采用懒加载方式：

```typescript
component: () => import('#/views/system/user/index.vue')
```

**优点：**
- 按需加载，减少首屏加载时间
- 代码分割，优化性能

### 5.2 页面缓存

系统支持页面缓存，通过 `keep-alive` 实现：

**缓存条件：**
1. 路由 `meta.keepAlive` 为 `true`
2. 页面已加载过（`loadedPaths.has(to.path)`）

### 5.3 页面过渡动画

页面切换时可以显示过渡动画：

```typescript
// apps/web-ele/src/layouts/basic.vue
<RouterView v-slot="{ Component, route }">
  <Transition name="fade" mode="out-in">
    <KeepAlive :include="cachedTabs">
      <component :is="Component" :key="route.path" />
    </KeepAlive>
  </Transition>
</RouterView>
```

## 六、完整流程图

```
用户访问页面
    ↓
路由初始化（应用启动）
    ├─ 创建 Router 实例
    ├─ 注册核心路由
    └─ 创建路由守卫
    ↓
触发导航守卫（beforeEach）
    ├─ 通用守卫
    │   ├─ 检查页面是否已加载
    │   └─ 显示进度条
    ├─ 权限访问守卫
    │   ├─ 检查是否核心路由 → 是 → 放行
    │   ├─ 检查 Token
    │   │   ├─ 无 Token → 重定向到登录页
    │   │   └─ 有 Token → 继续
    │   ├─ 检查是否已生成路由
    │   │   ├─ 已生成 → 放行
    │   │   └─ 未生成 → 生成路由
    │   │       ├─ 获取用户信息和权限
    │   │       ├─ 获取后端菜单数据
    │   │       ├─ 转换菜单为路由
    │   │       ├─ 注册动态路由
    │   │       └─ 标记已完成权限验证
    │   └─ 重定向到目标页面
    ↓
路由匹配
    ├─ 查找匹配的路由
    └─ 解析路由参数
    ↓
组件加载
    ├─ 懒加载组件
    ├─ 执行组件生命周期
    └─ 渲染页面
    ↓
触发导航守卫（afterEach）
    ├─ 记录已加载页面
    ├─ 关闭进度条
    └─ 更新页面标题
    ↓
页面加载完成
```

## 七、关键技术点

### 7.1 后端控制路由（RBAC）

**优势：**
- 权限控制更灵活，可以在后端动态调整
- 前端代码无需维护权限逻辑
- 支持跨应用的统一权限管理

**实现要点：**
1. 后端返回菜单树结构
2. 前端将菜单转换为路由
3. 组件路径映射使用懒加载

### 7.2 路由懒加载

**实现方式：**
```typescript
// 使用 Vite 的 import.meta.glob
const pageMap: ComponentRecordType = import.meta.glob('../views/**/*.vue');

// 动态导入
component: () => import('#/views/system/user/index.vue')
```

**优点：**
- 减少首屏加载时间
- 代码自动分割
- 支持热更新

### 7.3 路由缓存策略

**缓存机制：**
- 使用 `keep-alive` 缓存组件实例
- 通过 `include` 属性控制缓存列表
- 结合 `loadedPaths` 判断是否需要重新加载

**注意事项：**
- 缓存过多页面会占用内存
- 需要合理设置缓存条件

### 7.4 路由重置

系统提供了路由重置功能，用于清除动态添加的路由：

```typescript
const resetRoutes = () => resetStaticRoutes(router, routes);
```

**使用场景：**
- 用户退出登录时
- 切换租户时
- 权限变更时

## 八、最佳实践

### 8.1 路由命名规范

- **路由名称**：使用 PascalCase，如 `UserList`
- **路由路径**：使用 kebab-case，如 `/user-list`
- **组件命名**：与路由名称保持一致

### 8.2 路由配置建议

```typescript
{
  name: 'UserList',           // 路由名称
  path: '/system/user',       // 路由路径
  component: () => import('#/views/system/user/index.vue'),
  meta: {
    title: '用户管理',         // 页面标题
    icon: 'mdi-account',      // 菜单图标
    keepAlive: true,          // 是否缓存
    hideInMenu: false,        // 是否在菜单中隐藏
    ignoreAccess: false,      // 是否忽略权限
    activeMenu: '',           // 激活的菜单项
  },
}
```

### 8.3 性能优化建议

1. **合理使用缓存**：仅缓存常用页面
2. **懒加载**：所有页面组件都使用懒加载
3. **路由预加载**：可以预加载即将访问的路由
4. **减少守卫逻辑**：守卫中避免复杂的计算

## 九、常见问题

### 9.1 页面刷新后路由丢失

**原因：** 动态路由未持久化，刷新后会丢失

**解决方案：** 刷新时会重新执行导航守卫，重新生成路由

### 9.2 路由权限变更后不生效

**原因：** 路由已缓存，未重新生成

**解决方案：** 调用 `resetRoutes()` 清除路由，设置 `isAccessChecked = false`

### 9.3 组件找不到

**原因：** 后端返回的组件路径不正确

**解决方案：** 检查 `pageMap` 中是否存在对应的组件路径

## 十、总结

路由请求的完整运行周期包括以下关键步骤：

1. **路由初始化**：创建路由实例和守卫
2. **导航守卫**：权限验证和路由生成
3. **路由生成**：根据后端菜单动态生成路由
4. **组件加载**：懒加载和缓存
5. **页面渲染**：执行组件生命周期

整个流程采用了 **后端控制路由** 模式，实现了灵活的权限控制和动态路由加载，保证了系统的安全性和可维护性。

---

**相关文件：**
- `apps/web-ele/src/router/index.ts` - 路由入口
- `apps/web-ele/src/router/guard.ts` - 路由守卫
- `apps/web-ele/src/router/access.ts` - 权限控制
- `apps/web-ele/src/router/routes/` - 路由配置
- `apps/web-ele/src/store/auth.ts` - 认证 Store
- `packages/stores/src/modules/access.ts` - 权限 Store
- `packages/utils/src/helpers/generate-routes-backend.ts` - 后端路由生成
