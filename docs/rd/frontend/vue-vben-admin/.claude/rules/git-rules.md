# Git 提交规范

## 提交消息格式

### Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型 (type)

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整（不影响功能）
- `refactor`: 重构（不是新功能也不是 Bug 修复）
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具变动
- `ci`: CI 配置变动
- `build`: 构建系统或外部依赖变动
- `revert`: 回退提交

### 范围 (scope)

可选，表示影响范围：

- `core`: 核心功能
- `ui`: UI 相关
- `api`: API 相关
- `auth`: 认证相关
- `user`: 用户模块
- `order`: 订单模块
- `component`: 组件相关
- `style`: 样式相关
- `test`: 测试相关
- `config`: 配置相关

### 主题 (subject)

简短描述，不超过 50 个字符：

- 使用祈使句（如 "add" 而非 "added"）
- 首字母小写
- 结尾不加句号

### 正文 (body)

详细描述本次提交：

- 说明修改原因
- 前后对比
- 使用列表格式

### 页脚 (footer)

- **Breaking changes**: 不兼容变动
- **Closes**: 关闭 Issue
- **Refs**: 引用相关 Issue

## 提交示例

### 新功能

```
feat(user): 添加用户头像上传功能

- 支持拖拽上传
- 支持裁剪功能
- 添加文件大小限制（最大 2MB）
- 支持格式：jpg、png、gif

Closes #123
```

### Bug 修复

```
fix(auth): 修复登录 Token 过期未刷新问题

问题：
- Token 过期后未自动刷新
- 导致用户需要重新登录

修复：
- 添加 Token 刷新逻辑
- 使用 Refresh Token 自动续期
- 刷新失败后跳转登录页

Fixes #456
```

### 文档更新

```
docs(readme): 更新项目安装说明

- 添加 pnpm 安装方法
- 更新 Node.js 版本要求
- 添加常见问题解答
```

### 代码格式化

```
style: 格式化代码

- 统一使用单引号
- 添加分号
- 调整缩进为 2 空格
```

### 重构

```
refactor(user): 重构用户服务

变更：
- 提取用户服务为独立模块
- 优化代码结构
- 提高可测试性

影响：
- 无功能变更
- 提高代码可维护性
```

### 性能优化

```
perf(list): 优化大列表渲染性能

优化：
- 使用虚拟滚动
- 实现懒加载
- 减少不必要的重渲染

效果：
- 1000 条数据渲染时间从 2s 降至 200ms
- 内存占用减少 50%
```

### 测试

```
test(user): 添加用户服务单元测试

新增测试用例：
- 用户创建测试
- 用户更新测试
- 用户删除测试
- 异常情况测试

测试覆盖率：从 60% 提升至 85%
```

### 构建配置

```
chore(build): 优化构建配置

优化：
- 启用代码压缩
- 配置代码分割
- 添加构建分析工具

效果：
- 构建体积减少 30%
- 构建时间缩短 20%
```

### Breaking Changes

```
feat(api)!: 重构 API 接口

Breaking Changes:
- 所有 API 接口路径从 /api/v1 更改为 /api/v2
- 响应格式统一调整
- 请求参数命名改为 camelCase

迁移指南：
- 更新 API 调用路径
- 调整响应处理逻辑
- 修改请求参数命名

Refs #789
```

## 提交规范检查

### 提交前检查

1. **代码质量**
   - [ ] 通过 ESLint 检查
   - [ ] 通过类型检查
   - [ ] 通过单元测试

2. **提交信息**
   - [ ] 遵循 Conventional Commits
   - [ ] 描述清晰明确
   - [ ] 关联相关 Issue

3. **文件检查**
   - [ ] 不提交无关文件
   - [ ] 不提交敏感信息
   - [ ] 不提交调试代码

### 提交模板

```bash
# .git/commit-template

# <type>(<scope>): <subject>
# |<----  Using a maximum of 50 characters  ---->|


# Explain why this change is being made
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|


# Provide links or ids to any relevant tickets, articles or other resources
# Example: Fixes #123, Refs #456


# --- COMMIT END ---
# Type can be:
#   feat     (new feature)
#   fix      (bug fix)
#   docs     (documentation)
#   style    (formatting)
#   refactor (refactoring)
#   perf     (performance)
#   test     (testing)
#   chore    (maintenance)
#   revert   (revert commit)
#   build    (build system)
#   ci       (CI config)
#
# Remember to:
#   - Capitalize the subject line
#   - Use the imperative mood in the subject line
#   - Do not end the subject line with a period
#   - Separate subject from body with a blank line
#   - Use the body to explain what and why vs. how
#   - Can use multiple lines with "-" for bullet points in body
#   - Make footer to reference issues or breaking changes
# ------------------
```

## 分支命名规范

### 分支类型

- `main`: 主分支（生产环境）
- `develop`: 开发分支
- `feature/*`: 功能分支
- `bugfix/*`: Bug 修复分支
- `release/*`: 发布分支
- `hotfix/*`: 紧急修复分支

### 命名格式

```
<type>/<issue-id>-<short-description>
```

### 示例

```
feature/123-user-avatar-upload
bugfix/456-token-refresh-issue
release/v1.2.0
hotfix/789-critical-security-fix
```

## 提交最佳实践

### 原子提交

```
✅ 推荐：一个提交解决一个问题
git commit -m "feat(user): 添加用户头像上传功能"
git commit -m "test(user): 添加头像上传测试用例"

❌ 不推荐：一个提交解决多个问题
git commit -m "feat(user): 添加头像上传功能，修复登录 Bug，更新文档"
```

### 提交粒度

- **太小**: 一个提交只改了一行注释
- **合适**: 一个提交完成一个完整功能
- **太大**: 一个提交包含多个功能

### 提交时机

```bash
# ✅ 推荐：功能完成并测试通过后提交
pnpm test:unit  # 运行测试
pnpm lint       # 代码检查
git add .
git commit -m "feat(user): 添加用户头像上传功能"

# ❌ 不推荐：未测试直接提交
git add .
git commit -m "feat(user): 添加用户头像上传功能"
```

### 避免提交的内容

```
# .gitignore

# 依赖
node_modules/
dist/

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# 日志
*.log
npm-debug.log*

# 环境变量
.env
.env.local
.env.*.local

# 缓存
.cache/
*.tsbuildinfo

# 测试
coverage/
.nyc_output/
```

## Git Hooks

### pre-commit

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# 运行 lint
pnpm lint

# 运行测试
pnpm test:unit
```

### commit-msg

```bash
#!/bin/sh

# 验证提交消息格式
commit_msg=$(cat "$1")
pattern="^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\(.+\))?: .{1,50}"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
  echo "Invalid commit message format!"
  echo "Format: <type>(<scope>): <subject>"
  echo "Example: feat(user): add user avatar upload"
  exit 1
fi
```

## 工具配置

### Commitlint

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', 'ci', 'build', 'revert'],
    ],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-max-length': [2, 'always', 50],
  },
};
```

### Lefthook

```yaml
# lefthook.yml
pre-commit:
  commands:
    lint:
      run: pnpm lint
    test:
      run: pnpm test:unit

commit-msg:
  commands:
    commitlint:
      run: pnpm commitlint --edit {1}
```

## 最佳实践

1. **遵循 Conventional Commits**: 统一提交格式
2. **原子提交**: 一个提交解决一个问题
3. **清晰描述**: 说明做了什么、为什么做
4. **关联 Issue**: 关闭或引用相关 Issue
5. **提交前检查**: 运行 lint 和测试
6. **避免提交无关文件**: 使用 .gitignore
7. **定期推送**: 避免本地积累过多提交
8. **及时同步**: 经常 pull 远程更新
