# Optimize Imports Skill

优化导入语句的技能。

## 触发条件

- 代码提交前
- 用户显式请求优化导入
- 文件保存时（可配置）

## 执行流程

### 1. 扫描导入语句

扫描文件中的所有导入语句：
- ES6 导入
- TypeScript 导入
- Vue 组件导入
- 样式导入

### 2. 检测未使用的导入

分析代码中实际使用的导入：
- 标记未使用的导入
- 标记部分使用的导入

### 3. 排序导入语句

按照规范排序导入语句：
1. Node.js 内置模块
2. 外部依赖
3. 内部模块（@vben/*）
4. 相对路径导入
5. 类型导入（type）

### 4. 合并重复导入

合并来自同一模块的多个导入：

```typescript
// 优化前
import { ref } from 'vue';
import { computed } from 'vue';
import { onMounted } from 'vue';

// 优化后
import { computed, onMounted, ref } from 'vue';
```

### 5. 格式化导入

统一导入格式：
- 单行导入 vs 多行导入
- 引号使用（单引号 vs 双引号）
- 分号使用

## 示例

### 优化前

```typescript
import { ref } from 'vue';
import { computed } from 'vue';
import { onMounted } from 'vue';
import { ElButton } from 'element-plus';
import { ElTable } from 'element-plus';
import { unused } from 'some-package';
import type { Ref } from 'vue';
import { UserApi } from '#/api/user';
import { $t } from '#/locales';
```

### 优化后

```typescript
import { computed, onMounted, ref, type Ref } from 'vue';

import { ElButton, ElTable } from 'element-plus';

import { $t } from '#/locales';
import { UserApi } from '#/api/user';
```

## 排序规则

1. **优先级排序**:
   - Vue 核心
   - UI 框架
   - 工具库
   - 项目内部模块
   - 类型导入

2. **字母排序**: 同优先级内按字母排序

3. **分组**: 不同优先级之间添加空行

## 配置选项

```json
{
  "organizeImports": {
    "enabled": true,
    "removeUnused": true,
    "sortImports": true,
    "mergeImports": true,
    "groupImports": true,
    "groups": [
      "vue",
      "element-plus",
      "@vben/*",
      "#/*",
      "type"
    ]
  }
}
```

## 注意事项

1. 保留副作用导入（如样式文件）
2. 不删除显式标记为 used 的导入
3. 注意 TypeScript 类型导入的区分
4. 测试文件中可能有特殊导入需求

---

使用此技能可自动优化导入语句，提升代码可读性和维护性。
