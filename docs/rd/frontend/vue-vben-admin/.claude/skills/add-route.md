---
name: add-route
description: 快速添加页面路由配置
triggers:
  - "添加路由"
  - "新建路由"
  - "add route"
---

# 快速添加页面路由

这个技能帮助你快速添加标准化的页面路由配置，包括路由定义、权限配置和菜单配置。

## 使用方法

```
/add-route <路由名称> [选项]
```

### 参数

- `路由名称`: 路由的名称（如 user-management）
- `选项`:
  - `--path=/custom-path`: 自定义路由路径
  - `--auth`: 需要认证
  - `--title=页面标题`: 页面标题
  - `--icon=icon-name`: 菜单图标
  - `--parent=parent-route`: 父路由

### 示例

```bash
# 添加用户管理路由
/add-route user-management --title="用户管理" --icon=users

# 添加需要认证的路由
/add-route profile --auth --title="个人中心"

# 添加子路由
/add-route user-list --parent=user-management --title="用户列表"
```

## 生成的文件

### 路由配置文件 (routes/modules/user-management.ts)

```typescript
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/user-management',
    name: 'UserManagement',
    component: () => import('@/views/user-management/index.vue'),
    meta: {
      title: '用户管理',
      icon: 'users',
      auth: true,
      order: 1,
    },
    children: [
      {
        path: 'list',
        name: 'UserList',
        component: () => import('@/views/user-management/list/index.vue'),
        meta: {
          title: '用户列表',
          icon: 'list',
          auth: true,
        },
      },
      {
        path: 'create',
        name: 'UserCreate',
        component: () => import('@/views/user-management/create/index.vue'),
        meta: {
          title: '创建用户',
          icon: 'plus',
          auth: true,
          hideInMenu: true,
        },
      },
      {
        path: ':id/edit',
        name: 'UserEdit',
        component: () => import('@/views/user-management/edit/index.vue'),
        meta: {
          title: '编辑用户',
          icon: 'edit',
          auth: true,
          hideInMenu: true,
        },
      },
    ],
  },
];

export default routes;
```

### 页面组件 (views/user-management/index.vue)

```vue
<template>
  <div class="user-management-page">
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';

defineOptions({
  name: 'UserManagementPage',
});

onMounted(() => {
  console.log('User Management Page mounted');
});
</script>

<style scoped>
.user-management-page {
  height: 100%;
}
</style>
```

### 国际化文件 (locales/zh-CN/user-management.json)

```json
{
  "userManagement": {
    "title": "用户管理",
    "list": {
      "title": "用户列表",
      "search": "搜索用户",
      "create": "创建用户",
      "edit": "编辑用户",
      "delete": "删除用户"
    },
    "form": {
      "name": "用户名",
      "email": "邮箱",
      "password": "密码",
      "status": "状态",
      "avatar": "头像"
    },
    "messages": {
      "createSuccess": "创建成功",
      "updateSuccess": "更新成功",
      "deleteSuccess": "删除成功",
      "deleteConfirm": "确定要删除该用户吗？"
    }
  }
}
```

## 路由配置说明

### 路由元信息 (meta)

```typescript
interface RouteMeta {
  // 页面标题
  title: string;
  
  // 菜单图标
  icon?: string;
  
  // 是否需要认证
  auth?: boolean;
  
  // 是否在菜单中隐藏
  hideInMenu?: boolean;
  
  // 是否缓存页面
  keepAlive?: boolean;
  
  // 菜单排序
  order?: number;
  
  // 外链
  link?: string;
  
  // 权限标识
  permissions?: string[];
  
  // 角色标识
  roles?: string[];
}
```

### 路由类型

#### 基础路由

```typescript
{
  path: '/about',
  name: 'About',
  component: () => import('@/views/about/index.vue'),
  meta: {
    title: '关于我们',
  },
}
```

#### 嵌套路由

```typescript
{
  path: '/system',
  name: 'System',
  component: () => import('@/views/system/index.vue'),
  meta: {
    title: '系统管理',
  },
  children: [
    {
      path: 'users',
      name: 'SystemUsers',
      component: () => import('@/views/system/users/index.vue'),
      meta: {
        title: '用户管理',
      },
    },
  ],
}
```

#### 动态路由

```typescript
{
  path: '/user/:id',
  name: 'UserDetail',
  component: () => import('@/views/user/detail.vue'),
  meta: {
    title: '用户详情',
  },
}
```

#### 重定向路由

```typescript
{
  path: '/old-path',
  redirect: '/new-path',
}
```

## 权限配置

### 角色权限

```typescript
meta: {
  title: '管理员页面',
  roles: ['admin'],
}
```

### 权限标识

```typescript
meta: {
  title: '用户管理',
  permissions: ['user:view', 'user:create', 'user:edit', 'user:delete'],
}
```

## 菜单配置

### 显示在菜单

```typescript
meta: {
  title: '用户管理',
  icon: 'users',
  order: 1,
}
```

### 隐藏菜单项

```typescript
meta: {
  title: '编辑用户',
  hideInMenu: true,
}
```

### 外链菜单

```typescript
meta: {
  title: '文档',
  icon: 'document',
  link: 'https://example.com/docs',
}
```

## 最佳实践

1. **命名规范**: 使用 kebab-case 命名路由
2. **懒加载**: 使用动态导入优化性能
3. **权限控制**: 合理配置权限和角色
4. **页面缓存**: 使用 keepAlive 缓存页面
5. **国际化**: 为所有文本添加国际化支持
6. **嵌套路由**: 合理使用嵌套路由组织页面结构
