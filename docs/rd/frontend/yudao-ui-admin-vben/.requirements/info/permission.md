# 菜单、角色、权限处理机制

本文档详细介绍系统如何配合后端接口完成菜单、角色、权限的处理，包括权限获取、菜单渲染、权限验证、角色管理等功能。

## 概述

系统采用 **RBAC (Role-Based Access Control)** 权限模型，通过「用户-角色-权限」三层结构实现细粒度的权限控制。支持三种权限控制模式：

1. **前端模式（frontend）**: 前端定义路由和权限，后端只返回角色
2. **后端模式（backend）**: 后端返回菜单和权限，前端动态生成路由 ⭐（项目默认使用）
3. **混合模式（mixed）**: 前后端路由合并

权限控制包括：
- **菜单级别**: 控制菜单是否显示
- **路由级别**: 控制路由是否可访问
- **按钮级别**: 控制按钮是否显示或可用
- **组件级别**: 控制组件内容的显示

## 一、权限数据获取

### 1.1 权限数据结构

用户登录成功后，系统会调用 `/system/auth/get-permission-info` 接口获取权限信息：

**API 接口：**
```typescript
export async function getAuthPermissionInfoApi() {
  return requestClient.get<AuthPermissionInfo>(
    '/system/auth/get-permission-info',
  );
}
```

**响应数据结构：**
```typescript
interface AuthPermissionInfo {
  user: UserInfo;           // 用户信息
  roles: string[];          // 角色列表，如 ['admin', 'user']
  menus: Menu[];            // 菜单列表
  permissions: string[];    // 权限列表，如 ['system:user:create', 'system:user:update']
}
```

**菜单数据结构：**
```typescript
interface Menu {
  id: number;               // 菜单ID
  parentId: number;         // 父菜单ID
  name: string;             // 菜单名称
  path: string;             // 路由路径
  component: string;        // 组件路径
  componentName?: string;   // 组件名称
  icon: string;             // 菜单图标
  sort: number;             // 排序号
  visible: boolean;         // 是否可见
  keepAlive: boolean;       // 是否缓存
  children?: Menu[];        // 子菜单
}
```

### 1.2 权限数据存储

权限数据获取后，会分别存储在不同的 Store 中：

**存储逻辑：**
```typescript
async function fetchUserInfo() {
  const authPermissionInfo = await getAuthPermissionInfoApi();
  
  // 用户信息存储
  userStore.setUserInfo(authPermissionInfo.user);
  userStore.setUserRoles(authPermissionInfo.roles);
  
  // 权限信息存储
  accessStore.setAccessMenus(authPermissionInfo.menus);
  accessStore.setAccessCodes(authPermissionInfo.permissions);
  
  return authPermissionInfo;
}
```

**Store 结构：**

#### UserStore（用户信息）
```typescript
interface AccessState {
  userInfo: BasicUserInfo | null;  // 用户信息
  userRoles: string[];             // 用户角色
}

export const useUserStore = defineStore('core-user', {
  state: (): AccessState => ({
    userInfo: null,
    userRoles: [],
  }),
});
```

#### AccessStore（权限信息）
```typescript
interface AccessState {
  accessCodes: string[];           // 权限码列表
  accessMenus: MenuRecordRaw[];    // 可访问的菜单列表
  accessRoutes: RouteRecordRaw[];  // 可访问的路由列表
  accessToken: null | string;      // 访问令牌
  isAccessChecked: boolean;        // 是否已检查权限
}

export const useAccessStore = defineStore('core-access', {
  state: (): AccessState => ({
    accessCodes: [],
    accessMenus: [],
    accessRoutes: [],
    accessToken: null,
    isAccessChecked: false,
  }),
});
```

## 二、菜单处理机制

### 2.1 菜单生成流程

菜单生成分为以下几个步骤：

#### 步骤 1: 获取后端菜单数据

登录成功后，从 `/system/auth/get-permission-info` 接口获取菜单数据：

```typescript
const authPermissionInfo = await getAuthPermissionInfoApi();
accessStore.setAccessMenus(authPermissionInfo.menus);
```

#### 步骤 2: 转换菜单为路由格式

将后端菜单数据转换为前端路由格式：

**转换函数：** `packages/utils/src/helpers/generate-menus.ts`

```typescript
function convertServerMenuToRouteRecordStringComponent(
  menuList: AppRouteRecordRaw[],
  parent = '',
  nameSet: Set<string> = new Set(),
): RouteRecordStringComponent[] {
  const menus: RouteRecordStringComponent[] = [];
  
  menuList.forEach((menu) => {
    // 1. 处理外链菜单
    if (isHttpUrl(menu.path)) {
      const url = new URL(menu.path);
      let link: string | undefined;
      let iframeSrc: string | undefined;
      
      if (url.searchParams.has('_iframe')) {
        url.searchParams.delete('_iframe');
        iframeSrc = url.toString();
      } else {
        link = menu.path;
      }

      menus.push({
        component: 'IFrameView',
        meta: {
          hideInMenu: !menu.visible,
          icon: menu.icon,
          iframeSrc,
          link,
          order: menu.sort,
          title: menu.name,
        },
        name: menu.name,
        path: `${menu.id}`,
      });
      return;
    }
    
    // 2. 处理 Layout 组件
    if (menu.children && menu.parentId === 0) {
      menu.component = 'BasicLayout';
    }
    if (menu.component === 'Layout') {
      menu.component = 'BasicLayout';
    }
    
    // 3. 处理子菜单
    if (menu.children && menu.parentId !== 0) {
      menu.component = '';
    }

    // 4. 处理路径
    if (parent) {
      menu.path = `${parent}/${menu.path}`;
    }
    if (!menu.path.startsWith('/')) {
      menu.path = `/${menu.path}`;
    }

    // 5. 防止 name 重复
    let finalName = menu.componentName || menu.name;
    if (nameSet.has(finalName)) {
      finalName = menu.name + menu.id;
      console.error(`menu name duplicate: ${menu.name}, id: ${menu.id}`);
    }
    nameSet.add(finalName);

    // 6. 处理 query 参数
    let query: Record<string, string> | undefined;
    const queryIndex = menu.component.indexOf('?');
    if (queryIndex !== -1) {
      const queryString = menu.component.slice(queryIndex + 1);
      query = Object.fromEntries(new URLSearchParams(queryString).entries());
      menu.component = menu.component.slice(0, queryIndex);
    }

    // 7. 构建路由对象
    const buildMenu: RouteRecordStringComponent = {
      component: menu.component,
      meta: {
        hideInMenu: !menu.visible,
        icon: menu.icon,
        keepAlive: menu.keepAlive,
        order: menu.sort,
        title: menu.name,
        ...(query && { query }),
      },
      name: finalName,
      path: menu.path,
    };

    // 8. 递归处理子菜单
    if (menu.children && menu.children.length > 0) {
      buildMenu.children = convertServerMenuToRouteRecordStringComponent(
        menu.children,
        menu.path,
        nameSet,
      );
    }

    menus.push(buildMenu);
  });
  
  return menus;
}
```

**关键处理逻辑：**

1. **外链菜单处理**: 
   - 带 `?_iframe` 参数的作为内嵌页面处理
   - 不带参数的作为外链处理

2. **Layout 组件处理**:
   - 顶级菜单（parentId === 0）使用 `BasicLayout`
   - 将后端的 `Layout` 统一转换为 `BasicLayout`

3. **路径处理**:
   - 确保路径以 `/` 开头
   - 子菜单路径拼接父级路径

4. **name 唯一性**:
   - 使用 Set 检测重复的 name
   - 重复时自动添加 ID 后缀

5. **query 参数**:
   - 支持在 component 中定义 query 参数
   - 自动提取并存储到 meta.query 中

#### 步骤 3: 组件映射

将字符串组件名映射为实际的 Vue 组件：

```typescript
const pageMap: ComponentRecordType = import.meta.glob('../views/**/*.vue');
const layoutMap: ComponentRecordType = {
  BasicLayout,
  IFrameView,
};

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

**组件映射规则：**

| 组件字符串 | 映射结果 |
|----------|---------|
| `BasicLayout` | 基础布局组件 |
| `IFrameView` | IFrame 嵌入组件 |
| `system/user/index` | `../views/system/user/index.vue` |
| 其他 | 根据路径查找对应的 Vue 组件 |

#### 步骤 4: 注册路由

将生成的路由动态注册到 Vue Router：

```typescript
const root = router.getRoutes().find((item) => item.path === '/');
const names = root?.children?.map((item) => item.name) ?? [];

accessibleRoutes.forEach((route) => {
  if (root && !route.meta?.noBasicLayout) {
    // 如果路由已存在，则更新
    if (names?.includes(route.name)) {
      const index = root.children?.findIndex((item) => item.name === route.name);
      if (index !== undefined && index !== -1 && root.children) {
        root.children[index] = route;
      }
    } else {
      // 否则添加新路由
      root.children?.push(route);
    }
  } else {
    router.addRoute(route);
  }
});

// 重新注册根路由
if (root) {
  if (root.name) {
    router.removeRoute(root.name);
  }
  router.addRoute(root);
}
```

### 2.2 菜单渲染

#### 菜单数据生成

从路由生成菜单数据：

```typescript
function generateMenus(
  routes: RouteRecordRaw[],
  router: Router,
): MenuRecordRaw[] {
  // 将路由列表转换为以 name 为键的对象映射
  const finalRoutesMap = Object.fromEntries(
    router.getRoutes().map(({ name, path }) => [name, path]),
  );

  let menus = mapTree<ExRouteRecordRaw, MenuRecordRaw>(routes, (route) => {
    const path = finalRoutesMap[route.name as string] ?? route.path ?? '';
    const { meta = {} as RouteMeta, name: routeName, redirect, children = [] } = route;
    const {
      activeIcon,
      badge,
      badgeType,
      badgeVariants,
      hideChildrenInMenu = false,
      icon,
      link,
      order,
      title = '',
      query,
    } = meta;

    const name = (title || routeName || '') as string;
    const resultChildren = hideChildrenInMenu ? [] : ((children as MenuRecordRaw[]) ?? []);

    // 设置子菜单的父子关系
    if (resultChildren.length > 0) {
      resultChildren.forEach((child) => {
        child.parents = [...(route.parents ?? []), path];
        child.parent = path;
      });
    }

    const resultPath = hideChildrenInMenu ? redirect || path : link || path;

    return {
      activeIcon,
      badge,
      badgeType,
      badgeVariants,
      icon,
      name,
      query,
      order,
      parent: route.parent,
      parents: route.parents,
      path: resultPath,
      show: !meta.hideInMenu,
      children: resultChildren,
    };
  });

  // 排序并过滤
  menus = sortTree(menus, (a, b) => (a?.order ?? 999) - (b?.order ?? 999));
  return filterTree(menus, (menu) => !!menu.show);
}
```

#### 菜单组件渲染

**菜单组件：** `packages/@core/ui-kit/menu-ui/src/menu.vue`

菜单组件根据 `accessMenus` 数据渲染菜单列表：

```vue
<template>
  <div class="menu-container">
    <template v-for="menu in menus" :key="menu.path">
      <!-- 有子菜单 -->
      <SubMenu v-if="menu.children && menu.children.length > 0" :menu="menu">
        <!-- 递归渲染子菜单 -->
      </SubMenu>
      <!-- 无子菜单 -->
      <MenuItem v-else :menu="menu" />
    </template>
  </div>
</template>

<script setup lang="ts">
import { useAccessStore } from '@vben/stores';

const accessStore = useAccessStore();
const menus = computed(() => accessStore.accessMenus);
</script>
```

**菜单项元信息：**
```typescript
interface MenuRecordRaw {
  name: string;              // 菜单名称
  path: string;              // 菜单路径
  icon?: string;             // 图标
  activeIcon?: string;       // 激活状态图标
  order?: number;            // 排序号
  show?: boolean;            // 是否显示
  disabled?: boolean;        // 是否禁用
  badge?: string;            // 徽标
  badgeType?: 'dot' | 'normal';  // 徽标类型
  badgeVariants?: string;    // 徽标颜色
  children?: MenuRecordRaw[];    // 子菜单
  parent?: string;           // 父级路径
  parents?: string[];        // 所有父级路径
  query?: Record<string, any>;  // 查询参数
}
```

### 2.3 菜单权限控制

菜单级别的权限控制体现在两个方面：

#### 1. 后端控制

后端返回的菜单数据中，只包含用户有权访问的菜单：

```typescript
// 后端接口只返回有权限的菜单
const menus = await getAuthPermissionInfoApi();
accessStore.setAccessMenus(menus);
```

**优点：**
- 安全性高，前端无法绕过
- 减少前端判断逻辑

#### 2. 前端过滤

前端会根据 `meta.hideInMenu` 过滤隐藏的菜单：

```typescript
// 过滤掉隐藏的菜单项
return filterTree(menus, (menu) => !!menu.show);
```

**使用场景：**
- 某些页面需要在菜单中隐藏，但仍可通过路由访问
- 某些页面仅在特定条件下显示

## 三、权限验证机制

### 3.1 权限验证方式

系统支持两种权限验证方式：

#### 1. 基于角色的权限验证（Role-Based）

```typescript
function hasAccessByRoles(roles: string[]) {
  const userRoleSet = new Set(userStore.userRoles);
  const intersection = roles.filter((item) => userRoleSet.has(item));
  return intersection.length > 0;
}

// 使用示例
if (hasAccessByRoles(['admin', 'manager'])) {
  // 有权限
}
```

#### 2. 基于权限码的验证（Code-Based）⭐ 推荐

```typescript
function hasAccessByCodes(codes: string[]) {
  const userCodesSet = new Set(accessStore.accessCodes);
  const intersection = codes.filter((item) => userCodesSet.has(item));
  return intersection.length > 0;
}

// 使用示例
if (hasAccessByCodes(['system:user:create'])) {
  // 有权限
}
```

**推荐使用权限码的原因：**
- 权限粒度更细
- 更灵活，可以精确控制每个操作
- 不受角色名称变化的影响

### 3.2 权限验证实现

#### 方式 1: 组件级别控制

使用 `<AccessControl>` 组件包裹需要权限控制的内容：

```vue
<template>
  <AccessControl :codes="['system:user:create']" type="code">
    <button>创建用户</button>
  </AccessControl>
  
  <AccessControl :codes="['admin']" type="role">
    <button>管理员操作</button>
  </AccessControl>
</template>

<script setup lang="ts">
import { AccessControl } from '@vben/access';
</script>
```

**组件实现：**
```vue
<script lang="ts" setup>
import { computed } from 'vue';
import { useAccess } from './use-access';

interface Props {
  codes?: string[];
  type?: 'code' | 'role';
}

const props = withDefaults(defineProps<Props>(), {
  codes: () => [],
  type: 'role',
});

const { hasAccessByCodes, hasAccessByRoles } = useAccess();

const hasAuth = computed(() => {
  const { codes, type } = props;
  return type === 'role' ? hasAccessByRoles(codes) : hasAccessByCodes(codes);
});
</script>

<template>
  <slot v-if="!codes"></slot>
  <slot v-else-if="hasAuth"></slot>
</template>
```

#### 方式 2: 指令级别控制

使用 `v-access` 指令控制元素显示：

```vue
<template>
  <!-- 基于角色 -->
  <button v-access:role="'admin'">管理员操作</button>
  <button v-access:role="['admin', 'manager']">管理员或经理操作</button>
  
  <!-- 基于权限码 -->
  <button v-access:code="'system:user:create'">创建用户</button>
  <button v-access:code="['system:user:create', 'system:user:update']">创建或更新用户</button>
</template>

<script setup lang="ts">
import { registerAccessDirective } from '@vben/access';

// 在应用初始化时注册指令
registerAccessDirective(app);
</script>
```

**指令实现：**
```typescript
function isAccessible(
  el: Element,
  binding: DirectiveBinding<string | string[]>,
) {
  const { accessMode, hasAccessByCodes, hasAccessByRoles } = useAccess();

  const value = binding.value;
  if (!value) return;

  // 根据参数选择验证方法
  const authMethod =
    accessMode.value === 'frontend' && binding.arg === 'role'
      ? hasAccessByRoles
      : hasAccessByCodes;

  const values = Array.isArray(value) ? value : [value];

  // 无权限则移除元素
  if (!authMethod(values)) {
    el?.remove();
  }
}

const authDirective: Directive = {
  mounted: isAccessible,
};

export function registerAccessDirective(app: App) {
  app.directive('access', authDirective);
}
```

#### 方式 3: 按钮级别控制（表格操作）

在表格操作按钮中使用 `auth` 属性控制：

```vue
<template>
  <Grid table-title="用户列表">
    <template #toolbar-tools>
      <TableAction
        :actions="[
          {
            label: '创建用户',
            type: 'primary',
            icon: ACTION_ICON.ADD,
            auth: ['system:user:create'],  // 权限控制
            onClick: handleCreate,
          },
          {
            label: '导出',
            type: 'primary',
            icon: ACTION_ICON.DOWNLOAD,
            auth: ['system:user:export'],  // 权限控制
            onClick: handleExport,
          },
        ]"
      />
    </template>
    
    <template #actions="{ row }">
      <TableAction
        :actions="[
          {
            label: '编辑',
            type: 'primary',
            link: true,
            icon: ACTION_ICON.EDIT,
            auth: ['system:user:update'],  // 权限控制
            onClick: handleEdit.bind(null, row),
          },
          {
            label: '删除',
            type: 'danger',
            link: true,
            icon: ACTION_ICON.DELETE,
            auth: ['system:user:delete'],  // 权限控制
            popConfirm: {
              title: `确认删除 ${row.username} 吗？`,
              confirm: handleDelete.bind(null, row),
            },
          },
        ]"
      />
    </template>
  </Grid>
</template>
```

**实现原理：**
```typescript
// TableAction 组件内部会检查 auth 权限
function filterActionsByAuth(actions: ActionItem[]) {
  return actions.filter((action) => {
    if (!action.auth) return true;
    return hasAccessByCodes(action.auth);
  });
}
```

#### 方式 4: 编程式验证

在代码中直接调用验证函数：

```typescript
import { useAccess } from '@vben/access';

const { hasAccessByCodes, hasAccessByRoles } = useAccess();

// 检查权限
if (hasAccessByCodes(['system:user:create'])) {
  // 有权限，执行操作
} else {
  // 无权限，提示用户
  ElMessage.warning('您没有创建用户的权限');
}
```

### 3.3 路由级别权限控制

路由级别的权限控制通过路由守卫实现：

**守卫逻辑：**
```typescript
function setupAccessGuard(router: Router) {
  router.beforeEach(async (to, from) => {
    const accessStore = useAccessStore();
    
    // 1. 核心路由（登录、错误页等）不需要权限验证
    if (coreRouteNames.includes(to.name as string)) {
      return true;
    }

    // 2. 检查 Token
    if (!accessStore.accessToken) {
      // 未登录，跳转登录页
      return {
        path: LOGIN_PATH,
        query: { redirect: encodeURIComponent(to.fullPath) },
      };
    }

    // 3. 检查是否已生成动态路由
    if (accessStore.isAccessChecked) {
      return true;
    }

    // 4. 生成动态路由
    const { accessibleRoutes } = await generateAccess({
      roles: userRoles,
      router,
      routes: accessRoutes,
    });

    // 5. 保存路由信息
    accessStore.setAccessRoutes(accessibleRoutes);
    accessStore.setIsAccessChecked(true);

    // 6. 重定向到目标页面
    return { ...router.resolve(to.fullPath), replace: true };
  });
}
```

**路由 meta 权限配置：**
```typescript
interface RouteMeta {
  title?: string;                // 页面标题
  icon?: string;                 // 菜单图标
  keepAlive?: boolean;           // 是否缓存
  hideInMenu?: boolean;          // 是否在菜单中隐藏
  ignoreAccess?: boolean;        // 是否忽略权限验证
  menuVisibleWithForbidden?: boolean;  // 菜单可见但无权限访问时显示 403
  activeMenu?: string;           // 激活的菜单项
  authority?: string[];          // 需要的权限码或角色
}
```

### 3.4 403 无权限处理

当用户访问无权限的路由时，系统会显示 403 页面：

**实现方式：**

1. **菜单可见但无权限访问**：
   ```typescript
   meta: {
     menuVisibleWithForbidden: true,  // 菜单可见但访问显示 403
   }
   ```

2. **组件替换**：
   ```typescript
   if (menuHasVisibleWithForbidden(route)) {
     route.component = forbiddenComponent;  // 替换为 403 组件
   }
   ```

## 四、角色管理

### 4.1 角色数据结构

```typescript
interface Role {
  id: number;               // 角色ID
  name: string;             // 角色名称
  code: string;             // 角色编码
  status: number;           // 状态
  sort: number;             // 排序
  remark?: string;          // 备注
  permissions?: string[];   // 权限列表
  dataScope?: number;       // 数据范围
  dataScopeDeptIds?: number[];  // 数据范围部门ID
}
```

### 4.2 角色分配

系统支持为用户分配多个角色：

**用户角色分配页面：** `apps/web-ele/src/views/system/user/modules/assign-role-form.vue`

```vue
<template>
  <VbenModal title="分配角色">
    <el-transfer
      v-model="selectedRoles"
      :data="allRoles"
      :titles="['可选角色', '已选角色']"
    />
  </VbenModal>
</template>

<script setup lang="ts">
import { assignUserRole } from '#/api/system/permission';

async function handleSubmit() {
  await assignUserRole({
    userId: props.userId,
    roleIds: selectedRoles.value,
  });
}
</script>
```

### 4.3 角色权限分配

为角色分配菜单和权限：

**角色菜单分配：**

```typescript
interface RoleMenuAssignParams {
  roleId: number;
  menuIds: number[];
}

export async function assignRoleMenu(data: RoleMenuAssignParams) {
  return requestClient.post('/system/permission/assign-role-menu', data);
}
```

**角色数据权限分配：**

```typescript
interface RoleDataScopeAssignParams {
  roleId: number;
  dataScope: number;        // 数据范围类型
  dataScopeDeptIds: number[];  // 自定义部门范围
}

export async function assignRoleDataScope(data: RoleDataScopeAssignParams) {
  return requestClient.post('/system/permission/assign-role-data-scope', data);
}
```

**数据范围类型：**
```typescript
enum DataScope {
  ALL = 1,              // 全部数据权限
  CUSTOM = 2,           // 自定义数据权限
  DEPT = 3,             // 本部门数据权限
  DEPT_AND_CHILD = 4,   // 本部门及以下数据权限
  SELF = 5,             // 仅本人数据权限
}
```

## 五、权限控制模式

### 5.1 前端模式（frontend）

**特点：**
- 前端定义所有路由和权限
- 后端只返回用户角色
- 根据角色过滤路由

**适用场景：**
- 权限相对固定的系统
- 不需要动态调整菜单的系统

**实现：**
```typescript
// 前端定义路由
const routes = [
  {
    path: '/system/user',
    name: 'UserList',
    component: () => import('#/views/system/user/index.vue'),
    meta: {
      title: '用户管理',
      icon: 'mdi-account',
      authority: ['admin', 'system:user:view'],  // 需要的角色或权限
    },
  },
];

// 根据角色过滤路由
function generateRoutesByFrontend(
  routes: RouteRecordRaw[],
  roles: string[],
  forbiddenComponent?: Component,
): RouteRecordRaw[] {
  return filterTree(routes, (route) => {
    const { authority } = route.meta || {};
    if (!authority) return true;
    
    // 检查角色或权限
    const hasRole = roles.some(role => authority.includes(role));
    const hasCode = accessStore.accessCodes.some(code => authority.includes(code));
    
    if (!hasRole && !hasCode) {
      if (route.meta?.menuVisibleWithForbidden) {
        route.component = forbiddenComponent;
        return true;
      }
      return false;
    }
    return true;
  });
}
```

### 5.2 后端模式（backend）⭐ 推荐

**特点：**
- 后端返回菜单和权限
- 前端动态生成路由
- 权限控制更灵活

**适用场景：**
- 需要动态调整菜单的系统
- 需要细粒度权限控制的系统
- 多租户系统

**实现：**
```typescript
async function generateRoutesByBackend(
  options: GenerateMenuAndRoutesOptions,
): Promise<RouteRecordRaw[]> {
  const { fetchMenuListAsync, layoutMap, pageMap, forbiddenComponent } = options;

  // 1. 获取后端菜单
  const menuRoutes = await fetchMenuListAsync?.();
  if (!menuRoutes) {
    return [];
  }

  // 2. 转换菜单为路由
  let routes = convertRoutes(menuRoutes, layoutMap, pageMap);

  // 3. 处理无权限的路由
  if (forbiddenComponent) {
    routes = mapTree(routes, (route) => {
      if (menuHasVisibleWithForbidden(route)) {
        route.component = forbiddenComponent;
      }
      return route;
    });
  }

  // 4. 合并静态路由和动态路由
  return [...options.routes, ...routes];
}
```

**优点：**
- 权限控制更安全，前端无法绕过
- 支持动态调整菜单，无需重新部署前端
- 适合多租户系统

### 5.3 混合模式（mixed）

**特点：**
- 前后端路由合并
- 前端定义部分路由，后端补充其他路由

**适用场景：**
- 部分路由需要前端固定，部分需要后端动态配置

**实现：**
```typescript
const [frontendRoutes, backendRoutes] = await Promise.all([
  generateRoutesByFrontend(routes, roles, forbiddenComponent),
  generateRoutesByBackend(options),
]);

// 合并路由
const resultRoutes = mergeRoutesByName(backendRoutes, frontendRoutes);
```

## 六、完整流程图

### 6.1 权限获取流程

```
用户登录成功
    ↓
调用 get-permission-info API
    ├─ 获取用户信息
    ├─ 获取角色列表
    ├─ 获取菜单列表
    └─ 获取权限列表
    ↓
存储到 Store
    ├─ userStore.setUserInfo()
    ├─ userStore.setUserRoles()
    ├─ accessStore.setAccessMenus()
    └─ accessStore.setAccessCodes()
    ↓
生成动态路由
    ↓
注册路由
    ↓
渲染菜单
```

### 6.2 权限验证流程

```
访问页面或操作
    ↓
检查权限
    ├─ 组件级别：AccessControl 组件
    ├─ 指令级别：v-access 指令
    ├─ 按钮级别：auth 属性
    └─ 编程式：hasAccessByCodes/hasAccessByRoles
    ↓
有权限？
    ├─ 是 → 显示/执行
    └─ 否 → 隐藏/提示
```

### 6.3 菜单渲染流程

```
登录成功
    ↓
获取菜单数据
    ↓
转换为路由格式
    ├─ 处理外链菜单
    ├─ 处理 Layout 组件
    ├─ 处理路径
    ├─ 防止 name 重复
    └─ 处理 query 参数
    ↓
组件映射
    ├─ BasicLayout
    ├─ IFrameView
    └─ 页面组件
    ↓
注册路由
    ↓
生成菜单数据
    ├─ 排序
    └─ 过滤隐藏菜单
    ↓
渲染菜单组件
```

## 七、最佳实践

### 7.1 权限设计原则

1. **最小权限原则**: 用户只拥有完成工作所需的最小权限
2. **职责分离**: 不同角色的权限尽量不重叠
3. **权限粒度**: 权限设计要细粒度，便于灵活组合
4. **命名规范**: 权限码采用 `模块:资源:操作` 格式

**权限码命名示例：**
```typescript
// 模块:资源:操作
'system:user:create'     // 创建用户
'system:user:update'     // 更新用户
'system:user:delete'     // 删除用户
'system:user:export'     // 导出用户
'system:user:import'     // 导入用户
'system:role:view'       // 查看角色
'system:role:create'     // 创建角色
```

### 7.2 权限控制建议

1. **后端验证**: 所有权限验证必须由后端再次验证，前端验证仅作为用户体验优化
2. **菜单隐藏**: 不应该显示用户无权访问的菜单（除非业务需要）
3. **按钮隐藏**: 无权限的按钮应该隐藏，而不是禁用
4. **友好提示**: 当用户尝试访问无权限的资源时，给出友好的提示

### 7.3 性能优化

1. **权限缓存**: 用户权限可以缓存到本地，减少请求
2. **菜单缓存**: 菜单数据可以缓存，仅在权限变更时更新
3. **按需加载**: 路由组件采用懒加载，减少首屏加载时间

## 八、常见问题

### 8.1 权限变更后如何生效？

**问题**: 管理员修改用户权限后，用户需要刷新页面才能生效

**解决方案**: 
- 使用 WebSocket 推送权限变更通知
- 或轮询检查权限版本号
- 收到通知后重新获取权限并刷新路由

### 8.2 如何处理跨模块权限？

**问题**: 某些操作需要多个模块的权限

**解决方案**: 
```typescript
// 方式 1: 定义组合权限
'system:user:manage' = ['system:user:create', 'system:user:update', 'system:user:delete']

// 方式 2: 在验证时检查多个权限
if (hasAccessByCodes(['system:user:create']) && hasAccessByCodes(['system:user:update'])) {
  // 需要 create 和 update 权限
}

// 方式 3: 使用 AccessControl 组件包裹多个
<AccessControl :codes="['system:user:create']">
  <AccessControl :codes="['system:user:update']">
    <button>操作</button>
  </AccessControl>
</AccessControl>
```

### 8.3 如何处理数据权限？

**问题**: 不同用户只能看到不同范围的数据

**解决方案**: 
- 后端根据用户的数据权限范围过滤数据
- 前端传递 `dataScope` 和 `dataScopeDeptIds` 给后端
- 后端在 SQL 查询时动态添加数据权限过滤条件

## 九、总结

系统的菜单、角色、权限处理机制包括以下关键点：

1. **权限获取**: 登录后获取用户信息、角色、菜单、权限
2. **菜单生成**: 后端菜单数据转换为前端路由，支持外链、内嵌、动态路由
3. **权限验证**: 支持组件、指令、按钮、编程式多种权限验证方式
4. **角色管理**: 支持多角色、角色权限分配、数据权限控制
5. **权限模式**: 支持前端、后端、混合三种权限控制模式

整个权限体系设计合理，安全可靠，支持细粒度的权限控制，为企业级应用提供了完善的权限管理解决方案。

---

**相关文件：**
- `packages/stores/src/modules/access.ts` - 权限 Store
- `packages/stores/src/modules/user.ts` - 用户 Store
- `packages/effects/access/src/use-access.ts` - 权限验证 Hook
- `packages/effects/access/src/access-control.vue` - 权限控制组件
- `packages/effects/access/src/directive.ts` - 权限指令
- `packages/effects/access/src/accessible.ts` - 权限生成
- `packages/utils/src/helpers/generate-menus.ts` - 菜单生成
- `packages/utils/src/helpers/generate-routes-backend.ts` - 后端路由生成
- `apps/web-ele/src/api/core/auth.ts` - 认证 API
