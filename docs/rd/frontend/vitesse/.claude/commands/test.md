---
name: test
description: 运行测试
---

# 运行测试

## 单元测试

使用 Vitest 运行单元测试。

```bash
# 运行测试
pnpm test

# 监听模式
pnpm test:unit
```

## E2E 测试

使用 Cypress 运行端到端测试。

```bash
# 打开 Cypress 测试界面
pnpm test:e2e
```

## 测试文件位置

- 单元测试: `test/**/*.test.ts`
- E2E 测试: `cypress/**/*.cy.ts`

## 编写测试

```typescript
// 单元测试示例
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import MyComponent from './MyComponent.vue'

describe('MyComponent', () => {
  it('renders correctly', () => {
    const wrapper = mount(MyComponent)
    expect(wrapper.text()).toContain('Hello')
  })
})
```
