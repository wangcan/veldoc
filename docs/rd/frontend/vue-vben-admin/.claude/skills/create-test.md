---
name: create-test
description: 快速创建单元测试和 E2E 测试用例
triggers:
  - "创建测试"
  - "新建测试"
  - "add test"
---

# 快速创建测试用例

这个技能帮助你快速创建标准化的测试用例，包括单元测试和 E2E 测试。

## 使用方法

```
/create-test <目标名称> [选项]
```

### 参数

- `目标名称`: 要测试的文件或功能名称
- `选项`:
  - `--type=unit`: 创建单元测试
  - `--type=e2e`: 创建 E2E 测试
  - `--framework=vitest`: 使用 Vitest（默认）
  - `--framework=playwright`: 使用 Playwright

### 示例

```bash
# 创建组件单元测试
/create-test UserProfile --type=unit

# 创建 API 单元测试
/create-test UserService --type=unit

# 创建 E2E 测试
/create-test UserManagement --type=e2e
```

## 生成的文件

### 单元测试 - 组件 (ComponentName.test.ts)

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { mount, VueWrapper } from '@vue/test-utils';
import UserProfile from '@/components/UserProfile.vue';

describe('UserProfile', () => {
  let wrapper: VueWrapper<any>;

  const mockUser = {
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    avatar: 'https://example.com/avatar.jpg',
  };

  beforeEach(() => {
    wrapper = mount(UserProfile, {
      props: {
        user: mockUser,
      },
    });
  });

  afterEach(() => {
    wrapper?.unmount();
  });

  describe('渲染测试', () => {
    it('应该正确渲染用户信息', () => {
      expect(wrapper.find('.user-name').text()).toBe(mockUser.name);
      expect(wrapper.find('.user-email').text()).toBe(mockUser.email);
    });

    it('应该显示用户头像', () => {
      const avatar = wrapper.find('.user-avatar');
      expect(avatar.attributes('src')).toBe(mockUser.avatar);
    });

    it('应该有默认头像', () => {
      const wrapper = mount(UserProfile, {
        props: {
          user: { ...mockUser, avatar: undefined },
        },
      });
      expect(wrapper.find('.default-avatar').exists()).toBe(true);
    });
  });

  describe('交互测试', () => {
    it('应该触发编辑事件', async () => {
      await wrapper.find('.edit-button').trigger('click');
      expect(wrapper.emitted('edit')).toBeTruthy();
      expect(wrapper.emitted('edit')![0]).toEqual([mockUser.id]);
    });

    it('应该触发删除事件', async () => {
      vi.spyOn(window, 'confirm').mockReturnValue(true);
      await wrapper.find('.delete-button').trigger('click');
      expect(wrapper.emitted('delete')).toBeTruthy();
    });

    it('删除时应该确认', async () => {
      vi.spyOn(window, 'confirm').mockReturnValue(false);
      await wrapper.find('.delete-button').trigger('click');
      expect(wrapper.emitted('delete')).toBeFalsy();
    });
  });

  describe('状态测试', () => {
    it('应该显示加载状态', async () => {
      const wrapper = mount(UserProfile, {
        props: { loading: true },
      });
      expect(wrapper.find('.loading-spinner').exists()).toBe(true);
    });

    it('应该显示错误状态', async () => {
      const wrapper = mount(UserProfile, {
        props: { error: '加载失败' },
      });
      expect(wrapper.find('.error-message').text()).toBe('加载失败');
    });
  });
});
```

### 单元测试 - 工具函数 (functionName.test.ts)

```typescript
import { describe, it, expect } from 'vitest';
import { formatDate, debounce, deepClone } from '@/utils';

describe('formatDate', () => {
  it('应该正确格式化日期', () => {
    const date = new Date('2025-08-25');
    expect(formatDate(date, 'YYYY-MM-DD')).toBe('2025-08-25');
  });

  it('应该处理无效日期', () => {
    expect(formatDate(null)).toBe('');
    expect(formatDate(undefined)).toBe('');
  });

  it('应该支持不同格式', () => {
    const date = new Date('2025-08-25 14:30:00');
    expect(formatDate(date, 'YYYY/MM/DD')).toBe('2025/08/25');
    expect(formatDate(date, 'HH:mm:ss')).toBe('14:30:00');
  });
});

describe('debounce', () => {
  it('应该延迟执行', async () => {
    let counter = 0;
    const increment = debounce(() => counter++, 100);
    
    increment();
    increment();
    increment();
    
    expect(counter).toBe(0);
    
    await new Promise(resolve => setTimeout(resolve, 150));
    expect(counter).toBe(1);
  });
});
```

### E2E 测试 (feature.spec.ts)

```typescript
import { test, expect, Page } from '@playwright/test';

test.describe('用户管理', () => {
  let page: Page;

  test.beforeEach(async ({ browser }) => {
    page = await browser.newPage();
    
    // 登录
    await page.goto('/login');
    await page.fill('[name="username"]', 'admin');
    await page.fill('[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await page.waitForURL('/dashboard');
  });

  test.afterEach(async () => {
    await page.close();
  });

  test('应该显示用户列表', async () => {
    await page.goto('/users');
    
    // 等待表格加载
    await expect(page.locator('.user-table')).toBeVisible();
    
    // 验证数据
    const rows = await page.locator('.user-row').count();
    expect(rows).toBeGreaterThan(0);
  });

  test('应该能搜索用户', async () => {
    await page.goto('/users');
    
    // 输入搜索关键词
    await page.fill('[placeholder="搜索用户"]', 'admin');
    await page.press('[placeholder="搜索用户"]', 'Enter');
    
    // 等待结果
    await page.waitForSelector('.user-row');
    
    // 验证搜索结果
    const firstRow = await page.locator('.user-row').first();
    await expect(firstRow).toContainText('admin');
  });

  test('应该能创建新用户', async () => {
    await page.goto('/users/create');
    
    // 填写表单
    await page.fill('[name="name"]', 'Test User');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'Password123!');
    
    // 提交表单
    await page.click('button[type="submit"]');
    
    // 验证成功消息
    await expect(page.locator('.success-message')).toBeVisible();
    
    // 验证跳转到列表页
    await page.waitForURL('/users');
  });

  test('应该能编辑用户', async () => {
    await page.goto('/users');
    
    // 点击第一个编辑按钮
    await page.locator('.edit-button').first().click();
    
    // 修改名称
    const nameInput = page.locator('[name="name"]');
    await nameInput.fill('Updated Name');
    
    // 保存
    await page.click('button[type="submit"]');
    
    // 验证成功消息
    await expect(page.locator('.success-message')).toBeVisible();
  });

  test('应该能删除用户', async () => {
    await page.goto('/users');
    
    // 监听确认对话框
    page.on('dialog', dialog => dialog.accept());
    
    // 点击删除按钮
    await page.locator('.delete-button').first().click();
    
    // 验证成功消息
    await expect(page.locator('.success-message')).toBeVisible();
  });
});
```

## 测试规范

### 命名约定

- **测试文件**: `*.test.ts` 或 `*.spec.ts`
- **测试套件**: 使用 describe 分组
- **测试用例**: 使用 "应该..." 格式

### AAA 模式

```typescript
it('应该正确计算总价', () => {
  // Arrange (准备)
  const items = [
    { price: 100, quantity: 2 },
    { price: 50, quantity: 3 },
  ];
  
  // Act (执行)
  const total = calculateTotal(items);
  
  // Assert (断言)
  expect(total).toBe(350);
});
```

### Mock 使用

```typescript
// Mock 函数
const mockCallback = vi.fn();
mockCallback.mockReturnValue('mocked');

// Mock 模块
vi.mock('@/api/user', () => ({
  getUser: vi.fn().mockResolvedValue({ id: '1', name: 'Test' }),
}));

// Mock 时间
vi.useFakeTimers();
vi.advanceTimersByTime(1000);
```

## 最佳实践

1. **测试覆盖**: 覆盖所有边界情况
2. **独立性**: 测试之间互不影响
3. **可读性**: 测试代码清晰易懂
4. **快速执行**: 避免不必要的延迟
5. **持续集成**: 自动化测试
