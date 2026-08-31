#!/bin/bash

# Git pre-push hook
# 在推送前自动运行测试和构建检查

echo "🚀 Running pre-push checks..."

# 获取当前分支名
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 只对特定分支运行完整检查
protected_branches="master main develop"
if echo "$protected_branches" | grep -qw "$current_branch"; then
  echo "🔒 Pushing to protected branch: $current_branch"
  echo "Running comprehensive checks..."

  # 1. 运行所有测试
  echo "🧪 Running all tests..."
  pnpm test:unit
  if [ $? -ne 0 ]; then
    echo "❌ Unit tests failed. Please fix before pushing."
    exit 1
  fi

  # 2. 运行 E2E 测试（可选，耗时较长）
  # echo "🎭 Running E2E tests..."
  # pnpm test:e2e
  # if [ $? -ne 0 ]; then
  #   echo "❌ E2E tests failed. Please fix before pushing."
  #   exit 1
  # fi

  # 3. 构建检查
  echo "🏗️ Running build check..."
  pnpm build:ele
  if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix before pushing."
    exit 1
  fi

  # 4. 代码质量扫描
  echo "🔍 Running code quality scan..."
  pnpm lint
  if [ $? -ne 0 ]; then
    echo "❌ Code quality issues found. Please fix before pushing."
    exit 1
  fi

  # 5. 依赖检查
  echo "📦 Checking dependencies..."
  pnpm check:dep
  if [ $? -ne 0 ]; then
    echo "⚠️ Dependency issues found. Consider fixing."
    # 不阻止推送，只是警告
  fi

else
  echo "🌿 Pushing to feature branch: $current_branch"
  echo "Running basic checks..."

  # 仅运行基本检查
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
fi

# 显示即将推送的提交
echo ""
echo "📋 Commits to be pushed:"
git log --oneline origin/$current_branch..HEAD
echo ""

echo "✅ All checks passed! Pushing..."
exit 0
