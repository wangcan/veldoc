#!/bin/bash

# Git pre-commit hook
# 在提交前运行代码检查和格式化

set -e

echo "🔍 Running pre-commit checks..."

# 1. 运行 ESLint
echo "📝 Running ESLint..."
pnpm lint

# 2. 运行类型检查
echo "🔬 Running type check..."
pnpm check:type

# 3. 运行单元测试
echo "🧪 Running unit tests..."
pnpm test:unit

# 4. 检查是否有未格式化的文件
echo "✨ Checking code format..."
pnpm format

echo "✅ All checks passed!"
