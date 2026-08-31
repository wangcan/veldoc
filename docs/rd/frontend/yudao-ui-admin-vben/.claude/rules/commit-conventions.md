# Git 提交规范

本文档定义了项目中 Git 提交的规范和最佳实践。

## Commit Message 格式

### 基本格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**: 提交类型（必需）
- **scope**: 影响范围（可选）
- **subject**: 简短描述（必需）
- **body**: 详细描述（可选）
- **footer**: 备注、破坏性变更、关闭 issue（可选）

### Type 类型

| Type | 说明 | 示例 |
|------|------|------|
| feat | 新功能 | feat(user): 添加用户登录功能 |
| fix | 修复 Bug | fix(order): 修复订单计算错误 |
| docs | 文档更新 | docs: 更新 README |
| style | 代码格式（不影响功能） | style: 格式化代码 |
| refactor | 重构（不是新功能也不是 Bug） | refactor(user): 重构用户模块 |
| perf | 性能优化 | perf(list): 优化列表渲染性能 |
| test | 添加测试 | test(user): 添加用户模块单元测试 |
| build | 构建系统或依赖 | build: 升级依赖版本 |
| ci | CI 配置更改 | ci: 更新 GitHub Actions |
| chore | 其他杂项 | chore: 更新 .gitignore |
| revert | 回退提交 | revert: 回退用户登录功能 |

### Scope 范围

常见的 scope 包括：

- **业务模块**: user, order, product, payment, etc.
- **技术模块**: api, store, router, component, etc.
- **应用**: web-antd, web-ele, web-naive, etc.
- **配置**: config, build, deploy, etc.

### Subject 规则

1. **使用祈使句**: 使用动词原形，首字母小写
2. **不超过 50 字符**: 保持简洁
3. **不以句号结尾**: 不使用句号、感叹号等
4. **使用中文**: 项目统一使用中文描述

```bash
# ✅ 推荐
feat(user): 添加用户登录功能
fix(order): 修复订单计算错误
docs: 更新 API 文档

# ❌ 不推荐
feat(user): Added user login feature.  # 使用了过去时，加了句号
fix(order): 修复了订单计算错误。  # 加了句号
docs: 更新API文档！！！  # 加了感叹号
```

### Body 规则

1. **使用祈使句**: 与 subject 保持一致
2. **详细说明**: 解释 why，而不是 what
3. **分点描述**: 多个要点分行描述

```bash
# ✅ 推荐
feat(user): 添加用户登录功能

实现基于 JWT 的用户登录功能，包括：
- 登录表单验证
- JWT token 存储
- 自动刷新 token
- 登录状态持久化

关闭 #123

# ❌ 不推荐
feat(user): 添加用户登录功能
增加了登录功能。
```

### Footer 规则

#### 关闭 Issue

```
关闭 #123
关闭 #456, #789
```

#### 破坏性变更

```
BREAKING CHANGE: 重构用户 API

旧 API:
- POST /api/user/login

新 API:
- POST /api/auth/login
- POST /api/auth/register
```

## 提交示例

### 新功能

```bash
feat(user): 添加用户注册功能

实现用户注册功能，包括：
- 注册表单验证
- 邮箱验证
- 发送验证码
- 密码加密存储

关闭 #234
```

### Bug 修复

```bash
fix(order): 修复订单总价计算错误

修复订单总价计算时未考虑优惠券的问题。
现已在计算时正确扣除优惠券金额。

修复 #567
```

### 文档更新

```bash
docs: 更新项目启动文档

- 添加环境要求说明
- 更新依赖安装步骤
- 添加常见问题解答
```

### 代码重构

```bash
refactor(api): 重构 API 请求模块

将 axios 实例配置提取到独立文件，
统一管理请求拦截器和响应拦截器。
```

### 性能优化

```bash
perf(list): 优化大列表渲染性能

使用虚拟滚动技术优化大列表渲染，
将 10000 条数据的渲染时间从 3s 降低到 200ms。
```

## 分支命名规范

### 分支类型

| 分支类型 | 命名规则 | 说明 |
|---------|---------|------|
| master | master | 主分支，生产环境 |
| develop | develop | 开发分支 |
| feature | feature/xxx | 新功能分支 |
| bugfix | bugfix/xxx | Bug 修复分支 |
| hotfix | hotfix/xxx | 紧急修复分支 |
| release | release/x.x.x | 发布分支 |

### 命名示例

```bash
# ✅ 推荐
feature/user-login
feature/order-export
bugfix/order-calculation
hotfix/security-patch
release/1.2.0

# ❌ 不推荐
feature/userLogin  # 应使用连字符
bugfix/fix-bug     # 应具体说明
hotfix             # 应包含具体内容
```

## Pull Request 规范

### PR 标题

PR 标题遵循 commit message 格式：

```bash
feat(user): 添加用户登录功能
fix(order): 修复订单计算错误
```

### PR 描述模板

```markdown
## 变更类型

- [ ] 新功能 (feature)
- [ ] Bug 修复 (fix)
- [ ] 文档更新 (docs)
- [ ] 代码重构 (refactor)
- [ ] 性能优化 (perf)
- [ ] 其他

## 变更说明

简要描述本次变更的内容和原因。

## 影响范围

- 用户模块
- 订单模块

## 测试情况

- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 手动测试通过

## 相关 Issue

关闭 #123
关闭 #456

## 检查清单

- [ ] 代码符合项目规范
- [ ] 已添加必要的注释
- [ ] 已更新相关文档
- [ ] 已添加单元测试
- [ ] 无明显性能问题
```

## 最佳实践

### 提交频率

- **小步提交**: 一次提交只做一件事
- **及时提交**: 完成一个小功能就提交
- **逻辑完整**: 每次提交应保持逻辑完整性

```bash
# ✅ 推荐 - 小步提交
git commit -m "feat(user): 添加登录表单"
git commit -m "feat(user): 实现登录逻辑"
git commit -m "feat(user): 添加登录状态持久化"

# ❌ 不推荐 - 大提交
git commit -m "feat(user): 完成整个登录模块"
```

### 提交信息

- **清晰明确**: 让其他开发者能快速理解
- **关联 Issue**: 在提交中关联相关 issue
- **避免敏感信息**: 不要在提交信息中包含密码、密钥等

### 代码审查

- **提交前自审**: 提交前自己 review 代码
- **请求审查**: 重要变更请求他人 review
- **及时响应**: 及时响应 review 意见

### 提交前检查

使用 Git hooks 自动检查：

```bash
# lefthook 配置
pre-commit:
  commands:
    lint:
      run: pnpm lint
    typecheck:
      run: pnpm check:type
    test:
      run: pnpm test:unit

commit-msg:
  commands:
    commitlint:
      run: npx commitlint --edit {1}
```

## 常见错误

### 错误示例

```bash
# ❌ 提交信息不清晰
git commit -m "fix bug"
git commit -m "update"
git commit -m "修改"

# ❌ 提交内容过多
git add .
git commit -m "many changes"

# ❌ 包含不应提交的文件
git add dist/
git add node_modules/
git add .env
```

### 正确做法

```bash
# ✅ 清晰的提交信息
git commit -m "fix(user): 修复登录验证失败问题"

# ✅ 分步提交
git add src/views/user/login.vue
git commit -m "feat(user): 添加登录表单"

# ✅ 检查要提交的文件
git status
git add src/

# ✅ 使用 .gitignore 排除文件
# .gitignore
dist/
node_modules/
.env
```

## 工具支持

### Commitlint

项目使用 commitlint 检查提交信息：

```javascript
// .commitlintrc.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert'],
    ],
    'subject-case': [2, 'always', 'lower-case'],
  },
};
```

### Commitizen

使用 commitizen 辅助提交：

```bash
# 安装
pnpm add -D commitizen cz-git

# 使用
pnpm commit
# 或
git cz
```

---

遵循这些规范，可以确保 Git 提交历史的清晰性、可读性和可追溯性。
