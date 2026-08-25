#!/bin/bash

# Git post-merge hook
# 在合并分支后自动安装依赖和更新配置

set -e

echo "🔄 Running post-merge tasks..."

# 1. 检查 package.json 是否有变更
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q "package.json\|pnpm-lock.yaml"; then
    echo "📦 Installing dependencies..."
    pnpm install
fi

# 2. 检查是否有新的 Git hooks
if [ -d ".git/hooks" ]; then
    echo "🪝 Setting up Git hooks..."
    pnpm exec lefthook install
fi

# 3. 检查是否有新的 TypeScript 配置
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q "tsconfig.json"; then
    echo "⚙️ TypeScript configuration changed"
fi

# 4. 检查是否有新的环境变量文件
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q ".env.example"; then
    echo "🔐 Environment variables example updated"
    echo "Please check and update your .env file if needed"
fi

echo "✅ Post-merge tasks completed!"
