# /test - 快速创建测试用例

## 描述

快速创建标准化的测试用例，包括单元测试和 E2E 测试。

## 用法

```
/test <目标名称> [选项]
```

## 参数

### 目标名称
- 格式：要测试的文件或功能名称
- 必须：是

### 选项

- `--type=<类型>`: 测试类型
  - `unit`: 单元测试（默认）
  - `e2e`: E2E 测试
  - `all`: 同时创建两种测试

- `--framework=<框架>`: 测试框架
  - `vitest`: Vitest（单元测试默认）
  - `playwright`: Playwright（E2E 测试默认）

- `--coverage`: 生成覆盖率报告
  - 默认：`false`

- `--watch`: 监听模式
  - 默认：`false`

- `--update`: 更新快照
  - 默认：`false`

## 示例

### 创建组件单元测试

```bash
/test UserProfile --type=unit
```

生成文件：
- `tests/unit/UserProfile.test.ts`

### 创建 API 单元测试

```bash
/test UserService --type=unit
```

生成文件：
- `tests/unit/UserService.test.ts`

### 创建 E2E 测试

```bash
/test UserManagement --type=e2e
```

生成文件：
- `tests/e2e/user-management.spec.ts`

### 创建完整测试套件

```bash
/test UserForm --type=all
```

生成文件：
- `tests/unit/UserForm.test.ts`
- `tests/e2e/user-form.spec.ts`

### 运行测试并生成覆盖率

```bash
/test UserProfile --coverage
```

## 生成的文件

### 单元测试 - 组件 (tests/unit/ComponentName.test.ts)

```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { mount, VueWrapper } from '@vue/test-utils';
import ComponentName from '@/components/ComponentName.vue';

describe('ComponentName', () => {
  let wrapper: VueWrapper<any>;

  beforeEach(() => {
    wrapper = mount(ComponentName, {
      props: {
        // Props
      },
    });
  });

  afterEach(() => {
    wrapper?.unmount();
  });

  describe('渲染测试', () => {
    it('应该正确渲染', () => {
      expect(wrapper.exists()).toBe(true);
    });
  });

  describe('交互测试', () => {
    it('应该触发事件', async () => {
      // 测试逻辑
    });
  });

  describe('状态测试', () => {
    it('应该正确处理状态', async () => {
      // 测试逻辑
    });
  });
});
```

### 单元测试 - 工具函数 (tests/unit/functionName.test.ts)

```typescript
import { describe, it, expect } from 'vitest';
import { functionName } from '@/utils';

describe('functionName', () => {
  it('应该正确处理正常输入', () => {
    expect(functionName('input')).toBe('expected');
  });

  it('应该正确处理边界情况', () => {
    expect(functionName('')).toBe('');
  });

  it('应该正确处理异常输入', () => {
    expect(() => functionName(null)).toThrow();
  });
});
```

### E2E 测试 (tests/e2e/feature.spec.ts)

```typescript
import { test, expect, Page } from '@playwright/test';

test.describe('功能名称', () => {
  let page: Page;

  test.beforeEach(async ({ browser }) => {
    page = await browser.newPage();
    // 登录等前置操作
  });

  test.afterEach(async () => {
    await page.close();
  });

  test('应该显示列表', async () => {
    await page.goto('/list');
    await expect(page.locator('.list-container')).toBeVisible();
  });

  test('应该能创建新项', async () => {
    await page.goto('/create');
    await page.fill('[name="name"]', 'Test Name');
    await page.click('button[type="submit"]');
    await expect(page.locator('.success-message')).toBeVisible();
  });
});
```

## 测试类型

### 单元测试

测试范围：
- 组件渲染
- 函数逻辑
- 工具方法
- Store 状态

工具：
- Vitest
- Vue Test Utils
- Happy DOM

### E2E 测试

测试范围：
- 用户流程
- 页面交互
- 表单提交
- 权限控制

工具：
- Playwright
- Chromium/Firefox/WebKit

## 测试规范

### AAA 模式

```typescript
it('测试描述', () => {
  // Arrange (准备)
  const input = 'test';
  
  // Act (执行)
  const result = functionName(input);
  
  // Assert (断言)
  expect(result).toBe('expected');
});
```

### 测试分组

```typescript
describe('功能模块', () => {
  describe('子功能1', () => {
    it('测试用例1', () => {});
    it('测试用例2', () => {});
  });

  describe('子功能2', () => {
    it('测试用例1', () => {});
  });
});
```

### 测试命名

```typescript
// ✅ 推荐：描述性命名
it('应该在用户名为空时显示错误提示', () => {});

// ❌ 不推荐：模糊命名
it('测试1', () => {});
```

## 常用断言

### 相等性

```typescript
expect(value).toBe(expected);          // 严格相等
expect(value).toEqual(expected);       // 深度相等
expect(value).toStrictEqual(expected); // 严格深度相等
```

### 真值

```typescript
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();
```

### 数字

```typescript
expect(value).toBeGreaterThan(10);
expect(value).toBeLessThan(20);
expect(value).toBeGreaterThanOrEqual(10);
expect(value).toBeLessThanOrEqual(20);
expect(value).toBeCloseTo(10.5, 2);
```

### 字符串

```typescript
expect(value).toMatch(/pattern/);
expect(value).toContain('substring');
expect(value).toHaveLength(5);
```

### 数组

```typescript
expect(array).toContain(item);
expect(array).toHaveLength(5);
expect(array).toContainEqual({ id: 1 });
```

### 对象

```typescript
expect(object).toHaveProperty('key');
expect(object).toHaveProperty('key', value);
expect(object).toMatchObject({ key: value });
```

### 异常

```typescript
expect(() => function()).toThrow();
expect(() => function()).toThrow(Error);
expect(() => function()).toThrow('error message');
```

### 异步

```typescript
// Promise
await expect(promise).resolves.toBe(value);
await expect(promise).rejects.toThrow();

// 响应
expect(response.status).toBe(200);
expect(response.data).toEqual(expectedData);
```

## Mock 使用

### 函数 Mock

```typescript
// 创建 Mock 函数
const mockFn = vi.fn();

// 设置返回值
mockFn.mockReturnValue('value');
mockFn.mockReturnValueOnce('once');

// 设置实现
mockFn.mockImplementation(() => 'value');

// 验证调用
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith(arg1, arg2);
expect(mockFn).toHaveBeenCalledTimes(2);
```

### 模块 Mock

```typescript
// Mock 整个模块
vi.mock('@/api/user', () => ({
  getUser: vi.fn().mockResolvedValue({ id: '1', name: 'Test' }),
}));

// Mock 部分导出
vi.mock('@/api/user', async (importOriginal) => {
  const original = await importOriginal();
  return {
    ...original,
    getUser: vi.fn().mockResolvedValue({ id: '1' }),
  };
});
```

### 时间 Mock

```typescript
// 使用假时间
vi.useFakeTimers();

// 前进时间
vi.advanceTimersByTime(1000);

// 恢复真实时间
vi.useRealTimers();
```

## 测试命令

```bash
# 运行所有测试
pnpm test:unit

# 运行特定测试
pnpm test:unit UserProfile

# 监听模式
pnpm test:unit --watch

# 生成覆盖率
pnpm test:unit --coverage

# 更新快照
pnpm test:unit --update

# 运行 E2E 测试
pnpm test:e2e

# 运行特定 E2E 测试
pnpm test:e2e user-management
```

## 工作流程

1. **分析测试目标**: 确定测试范围和类型
2. **生成测试文件**: 创建测试文件和基本结构
3. **编写测试用例**: 添加测试用例
4. **运行测试**: 执行测试验证
5. **优化测试**: 完善测试覆盖

## 注意事项

1. 测试文件应靠近被测试文件
2. 测试应独立、可重复
3. 避免测试实现细节
4. 保持测试简单清晰
5. 及时更新测试

## 相关命令

- `/component`: 创建组件
- `/api`: 创建 API
- `/page`: 创建页面
