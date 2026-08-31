# Hooks 目录分析报告

## 目录概述

`.claude/hooks/` 目录包含项目的 Git 钩子脚本。这些脚本在特定的 Git 操作前后自动执行，用于代码质量检查、测试运行和规范验证。

## 目录结构

```
.claude/hooks/
├── pre-commit.sh    # 提交前钩子
└── pre-push.sh      # 推送前钩子
```

## Hook 文件格式

### 1. 文件格式

- **文件类型**: Shell 脚本（.sh）
- **执行权限**: 需要可执行权限
- **退出状态**: 
  - `exit 0`: 允许操作继续
  - `exit 1`: 阻止操作

### 2. 脚本结构

```bash
#!/bin/bash

# Hook 描述
echo "🔍 Running hook checks..."

# 检查逻辑
command
if [ $? -ne 0 ]; then
  echo "❌ Check failed"
  exit 1
fi

# 成功退出
echo "✅ All checks passed"
exit 0
```

## Hook 详细分析

### 1. pre-commit.sh (提交前钩子)

#### 基本信息

- **触发时机**: 执行 `git commit` 命令之前
- **作用范围**: 当前提交的文件
- **主要功能**: 代码质量检查、格式化、提交信息验证

#### 脚本内容解析

##### 1. ESLint 检查

```bash
echo "📝 Checking code style with ESLint..."
pnpm lint
if [ $? -ne 0 ]; then
  echo "❌ ESLint check failed. Please fix the issues before committing."
  exit 1
fi
```

**作用**:
- 检查代码风格问题
- 发现代码错误
- 确保代码符合 ESLint 规则

**失败后果**: 阻止提交，需要修复问题

##### 2. TypeScript 类型检查

```bash
echo "🔷 Checking TypeScript types..."
pnpm check:type
if [ $? -ne 0 ]; then
  echo "❌ TypeScript type check failed. Please fix the type errors."
  exit 1
fi
```

**作用**:
- 检查 TypeScript 类型错误
- 确保类型安全
- 防止运行时类型错误

**失败后果**: 阻止提交，需要修复类型错误

##### 3. 代码格式化

```bash
echo "✨ Formatting code with Prettier..."
pnpm format
```

**作用**:
- 自动格式化代码
- 统一代码风格
- 提高代码可读性

**特点**: 不检查结果，直接格式化并继续

##### 4. 提交信息格式检查

```bash
echo "💬 Checking commit message format..."
commit_msg_file=$1
if [ -f "$commit_msg_file" ]; then
  commit_msg=$(cat "$commit_msg_file")
  if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,50}"; then
    echo "❌ Invalid commit message format."
    echo ""
    echo "Correct format:"
    echo "  type(scope): subject"
    echo ""
    echo "Example:"
    echo "  feat(user): add login feature"
    echo "  fix(order): fix calculation error"
    echo ""
    exit 1
  fi
fi
```

**作用**:
- 验证提交信息格式
- 确保符合 Git 规范
- 保持提交历史清晰

**格式要求**:
```
type(scope): subject
```

**类型**:
- feat: 新功能
- fix: Bug 修复
- docs: 文档更新
- style: 代码格式
- refactor: 重构
- perf: 性能优化
- test: 测试
- build: 构建
- ci: CI 配置
- chore: 杂项
- revert: 回退

**失败后果**: 阻止提交，提示正确的格式

##### 5. 单元测试（可选）

```bash
# echo "🧪 Running unit tests..."
# pnpm test:unit
# if [ $? -ne 0 ]; then
#   echo "❌ Unit tests failed. Please fix the failing tests."
#   exit 1
# fi
```

**作用**:
- 运行单元测试
- 确保测试通过
- 防止破坏现有功能

**特点**: 默认注释，可根据需要启用

#### 执行流程

```
git commit
    ↓
运行 pre-commit.sh
    ↓
ESLint 检查 ──失败──→ 阻止提交
    ↓ 成功
TypeScript 类型检查 ──失败──→ 阻止提交
    ↓ 成功
代码格式化
    ↓
提交信息格式检查 ──失败──→ 阻止提交
    ↓ 成功
允许提交
```

#### 特点

- **自动化**: 自动执行检查，无需手动操作
- **全面性**: 覆盖代码质量、类型安全、格式规范
- **可配置**: 可根据需要启用/禁用检查项
- **用户友好**: 提供清晰的错误提示

---

### 2. pre-push.sh (推送前钩子)

#### 基本信息

- **触发时机**: 执行 `git push` 命令之前
- **作用范围**: 当前分支的所有提交
- **主要功能**: 全面测试、构建检查、代码质量扫描

#### 脚本内容解析

##### 1. 分支识别

```bash
current_branch=$(git rev-parse --abbrev-ref HEAD)

protected_branches="master main develop"
if echo "$protected_branches" | grep -qw "$current_branch"; then
  # 受保护分支的完整检查
else
  # 功能分支的基本检查
fi
```

**作用**:
- 识别当前分支
- 区分受保护分支和功能分支
- 执行不同级别的检查

**受保护分支**: master、main、develop
**功能分支**: 其他分支

##### 2. 受保护分支的完整检查

###### a. 运行所有测试

```bash
echo "🧪 Running all tests..."
pnpm test:unit
if [ $? -ne 0 ]; then
  echo "❌ Unit tests failed. Please fix before pushing."
  exit 1
fi
```

**作用**: 确保所有测试通过

###### b. 构建检查

```bash
echo "🏗️ Running build check..."
pnpm build:ele
if [ $? -ne 0 ]; then
  echo "❌ Build failed. Please fix before pushing."
  exit 1
fi
```

**作用**: 确保项目可以正常构建

###### c. 代码质量扫描

```bash
echo "🔍 Running code quality scan..."
pnpm lint
if [ $? -ne 0 ]; then
  echo "❌ Code quality issues found. Please fix before pushing."
  exit 1
fi
```

**作用**: 再次检查代码质量

###### d. 依赖检查

```bash
echo "📦 Checking dependencies..."
pnpm check:dep
if [ $? -ne 0 ]; then
  echo "⚠️ Dependency issues found. Consider fixing."
  # 不阻止推送，只是警告
fi
```

**作用**: 检查依赖问题

**特点**: 仅警告，不阻止推送

##### 3. 功能分支的基本检查

```bash
echo "🌿 Pushing to feature branch: $current_branch"
echo "Running basic checks..."

pnpm lint
if [ $? -ne 0 ]; then
  echo "❌ Code style issues found. Please fix before pushing."
  exit 1
fi

pnpm check:type
if [ $? -ne 0 ]; then
  echo "❌ TypeScript errors found. Please fix before pushing."
  exit 1
fi
```

**作用**: 执行基本检查，不运行完整测试和构建

**原因**: 功能分支开发过程中，快速迭代更重要

##### 4. 显示推送的提交

```bash
echo ""
echo "📋 Commits to be pushed:"
git log --oneline origin/$current_branch..HEAD
echo ""
```

**作用**: 
- 显示即将推送的提交
- 让用户确认推送内容
- 提供最后审查的机会

#### 执行流程

```
git push
    ↓
运行 pre-push.sh
    ↓
识别分支类型
    ↓
┌─────────────┬─────────────┐
│ 受保护分支   │ 功能分支     │
├─────────────┼─────────────┤
│ 所有测试    │ Lint 检查   │
│ 构建检查    │ 类型检查    │
│ 质量扫描    │             │
│ 依赖检查    │             │
└─────────────┴─────────────┘
    ↓
显示推送的提交
    ↓
允许推送
```

#### 特点

- **分级检查**: 不同分支执行不同级别的检查
- **全面保护**: 受保护分支执行完整检查
- **灵活高效**: 功能分支执行快速检查
- **信息透明**: 显示推送内容，便于确认

---

## Hooks 工作原理

### Git Hook 机制

Git 提供了钩子机制，允许在特定事件发生时执行自定义脚本：

1. **客户端钩子**: 在客户端执行
   - pre-commit: 提交前
   - pre-push: 推送前
   - commit-msg: 提交信息验证

2. **服务端钩子**: 在服务器端执行
   - pre-receive: 接收推送前
   - post-receive: 接收推送后

### Claude Code 集成

Claude Code 将 hooks 集成到项目配置中：

1. **位置**: `.claude/hooks/`
2. **格式**: Shell 脚本
3. **权限**: 自动设置可执行权限
4. **触发**: Git 操作时自动执行

## Hooks 配置

### 1. 启用/禁用

可以在 `.claude/settings.json` 中配置：

```json
{
  "hooks": {
    "pre-commit": true,
    "pre-push": true
  }
}
```

### 2. 跳过 Hook

在特殊情况下可以跳过 hook：

```bash
# 跳过 pre-commit
git commit --no-verify

# 跳过 pre-push
git push --no-verify
```

**注意**: 不建议常规跳过，仅用于紧急情况

### 3. 自定义配置

可以根据项目需求自定义 hook：

```bash
#!/bin/bash

# 自定义检查
echo "Running custom checks..."

# 添加自定义逻辑
custom_check
if [ $? -ne 0 ]; then
  echo "Custom check failed"
  exit 1
fi

# 调用默认 hook
source .claude/hooks/pre-commit.sh
```

## Hooks 与其他配置的关系

### 1. 与 rules 的关系

hooks 根据 rules 中定义的规范执行检查：

- **vue-style-guide.md**: 代码风格检查
- **typescript-rules.md**: 类型检查
- **commit-conventions.md**: 提交信息格式检查

### 2. 与 commands 的关系

commands 可以触发 hooks 的执行：

- `/check-i18n`: 可以集成到 pre-commit
- `/create-module`: 生成的代码会经过 hooks 检查

### 3. 与 agents 的关系

agents 生成的代码会经过 hooks 检查：

- 生成的代码必须通过 lint 检查
- 类型定义必须通过类型检查
- 确保生成的代码符合规范

## 最佳实践

### 1. 提交前检查

建议在提交前运行所有检查：

```bash
# 手动运行检查
pnpm lint
pnpm check:type
pnpm test:unit

# 或使用 hook 自动检查
git commit
```

### 2. 定期更新

定期更新 hook 脚本：

- 添加新的检查项
- 更新检查规则
- 优化执行效率

### 3. 团队协作

作为团队共享的配置：

- 所有成员使用相同的 hooks
- 确保代码质量标准一致
- 减少代码审查工作量

### 4. 性能优化

优化 hook 执行速度：

- 仅检查修改的文件
- 使用增量检查
- 缓存检查结果

## 常见问题

### 1. Hook 执行失败怎么办？

**解决方案**:
1. 查看错误信息
2. 修复问题
3. 重新执行 git 操作

### 2. 如何临时跳过 hook？

**方法**:
```bash
git commit --no-verify
git push --no-verify
```

**注意**: 仅在紧急情况下使用

### 3. Hook 执行太慢怎么办？

**优化方案**:
1. 仅检查修改的文件
2. 简化检查逻辑
3. 使用缓存机制

### 4. 如何添加自定义检查？

**方法**:
```bash
#!/bin/bash

# 添加自定义检查
echo "Running custom check..."
custom_command
if [ $? -ne 0 ]; then
  echo "Custom check failed"
  exit 1
fi

# 继续执行默认检查
# ...
```

## 总结

`.claude/hooks/` 目录包含了两个 Git 钩子脚本，它们在 Git 操作的关键节点自动执行代码质量检查：

1. **pre-commit.sh**: 提交前执行
   - ESLint 检查
   - TypeScript 类型检查
   - 代码格式化
   - 提交信息格式验证

2. **pre-push.sh**: 推送前执行
   - 分支识别
   - 受保护分支完整检查（测试、构建、质量扫描）
   - 功能分支基本检查
   - 显示推送内容

这些 Hooks 具有以下优势：

- **自动化**: 无需手动执行检查
- **质量保证**: 确保代码符合规范
- **分级检查**: 不同分支不同策略
- **团队协作**: 统一代码质量标准
- **效率提升**: 快速发现问题

建议开发者在日常开发中充分利用这些 hooks，以保证代码质量和项目稳定性。同时，也可以根据项目需求添加新的自定义钩子。
