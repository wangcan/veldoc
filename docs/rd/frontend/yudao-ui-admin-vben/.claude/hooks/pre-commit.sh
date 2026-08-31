#!/bin/bash

# Git pre-commit hook
# 在提交前自动运行代码检查

echo "🔍 Running pre-commit checks..."

# 1. 运行 ESLint 检查
echo "📝 Checking code style with ESLint..."
pnpm lint
if [ $? -ne 0 ]; then
  echo "❌ ESLint check failed. Please fix the issues before committing."
  exit 1
fi

# 2. 运行 TypeScript 类型检查
echo "🔷 Checking TypeScript types..."
pnpm check:type
if [ $? -ne 0 ]; then
  echo "❌ TypeScript type check failed. Please fix the type errors."
  exit 1
fi

# 3. 格式化代码
echo "✨ Formatting code with Prettier..."
pnpm format

# 4. 检查提交信息格式
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

# 5. 运行单元测试（可选）
# echo "🧪 Running unit tests..."
# pnpm test:unit
# if [ $? -ne 0 ]; then
#   echo "❌ Unit tests failed. Please fix the failing tests."
#   exit 1
# fi

echo "✅ All checks passed! Committing..."
exit 0
