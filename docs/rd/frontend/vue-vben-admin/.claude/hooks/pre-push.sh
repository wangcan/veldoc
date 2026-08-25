#!/bin/bash

# Git pre-push hook
# 在推送前运行完整测试套件

set -e

echo "🚀 Running pre-push checks..."

# 1. 运行完整测试套件
echo "🧪 Running all tests..."
pnpm test:unit

# 2. 运行 E2E 测试（可选）
# echo "🎭 Running E2E tests..."
# pnpm test:e2e

# 3. 检查构建
echo "📦 Checking build..."
pnpm build

# 4. 代码质量检查
echo "✨ Running code quality checks..."
pnpm lint
pnpm check:type

echo "✅ All pre-push checks passed!"
