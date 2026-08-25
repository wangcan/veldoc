# /page - 快速创建页面

## 描述

快速创建标准化的页面组件，包含路由配置、国际化、布局等完整配置。

## 用法

```
/page <页面名称> [选项]
```

## 参数

### 页面名称
- 格式：kebab-case（如 `user-list`）
- 必须：是

### 选项

- `--title=<标题>`: 页面标题
  - 默认：页面名称转换后的中文

- `--path=<路径>`: 路由路径
  - 默认：`/页面名称`

- `--icon=<图标>`: 菜单图标
  - 默认：`file`

- `--auth`: 需要认证
  - 默认：`true`

- `--no-auth`: 不需要认证

- `--parent=<父路由>`: 父路由名称
  - 用于创建嵌套路由

- `--layout=<布局>`: 布局类型
  - `default`: 默认布局
  - `blank`: 空白布局
  - `fullscreen`: 全屏布局
  - 默认：`default`

- `--api`: 创建关联的 API 文件
  - 默认：`false`

## 示例

### 创建简单页面

```bash
/page user-list --title="用户列表" --icon=users
```

生成文件：
- `src/views/user-list/index.vue`
- `src/router/routes/modules/user-list.ts`
- `src/locales/zh-CN/user-list.json`

### 创建嵌套页面

```bash
/page user-create --parent=user --title="创建用户"
```

生成文件：
- `src/views/user/create/index.vue`
- 更新路由配置

### 创建带 API 的页面

```bash
/page user-management --api --title="用户管理"
```

生成文件：
- `src/views/user-management/index.vue`
- `src/api/user-management.ts`
- `src/router/routes/modules/user-management.ts`
- `src/locales/zh-CN/user-management.json`

### 创建全屏页面

```bash
/page dashboard --layout=fullscreen --title="仪表盘"
```

## 生成的文件

### 页面组件 (views/page-name/index.vue)

```vue
<template>
  <div class="page-name">
    <!-- 页面内容 -->
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';

defineOptions({
  name: 'PageName',
});

onMounted(() => {
  // 页面初始化逻辑
});
</script>

<style scoped>
.page-name {
  /* 样式 */
}
</style>
```

### 路由配置 (router/routes/modules/page-name.ts)

```typescript
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/page-name',
    name: 'PageName',
    component: () => import('@/views/page-name/index.vue'),
    meta: {
      title: '页面标题',
      icon: 'file',
      auth: true,
    },
  },
];

export default routes;
```

### 国际化文件 (locales/zh-CN/page-name.json)

```json
{
  "pageName": {
    "title": "页面标题",
    "description": "页面描述"
  }
}
```

### API 文件 (api/page-name.ts)

```typescript
import { request } from '@/utils/request';

export interface PageNameItem {
  id: string;
  name: string;
}

export function getPageNameList() {
  return request.get<PageNameItem[]>('/api/page-name');
}
```

## 页面类型

### 列表页面

特点：
- 包含表格、搜索、分页
- 支持 CRUD 操作
- 批量操作功能

示例：
- 用户列表
- 订单列表
- 产品列表

### 详情页面

特点：
- 展示详细信息
- 关联数据展示
- 操作按钮

示例：
- 用户详情
- 订单详情
- 产品详情

### 表单页面

特点：
- 表单输入
- 数据验证
- 提交处理

示例：
- 创建用户
- 编辑订单
- 设置页面

### 仪表盘页面

特点：
- 数据可视化
- 图表展示
- 关键指标

示例：
- 数据概览
- 运营报表
- 监控面板

## 页面结构

### 列表页面结构

```
views/user-list/
├── index.vue              # 主页面
├── components/            # 子组件
│   ├── UserSearch.vue     # 搜索表单
│   ├── UserTable.vue      # 表格组件
│   └── UserForm.vue       # 表单组件
├── composables/           # 组合式函数
│   ├── useSearch.ts       # 搜索逻辑
│   └── useTable.ts        # 表格逻辑
└── types.ts               # 类型定义
```

### 工作流程

1. **解析参数**: 获取页面名称和选项
2. **创建目录**: 创建页面目录结构
3. **生成文件**: 创建页面、路由、国际化文件
4. **更新配置**: 更新路由和国际化配置

## 注意事项

1. 页面名称必须是 kebab-case
2. 父路由必须已存在
3. 国际化文件会自动合并到配置
4. 路由配置会自动注册

## 相关命令

- `/component`: 创建组件
- `/api`: 创建 API
- `/route`: 添加路由
- `/i18n`: 添加国际化
