#!/bin/bash

# Git pre-auto-gc hook
# 在自动垃圾回收前运行

set -e

echo "🧹 Preparing for garbage collection..."

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes"
    echo "It's recommended to commit or stash them before garbage collection"
    exit 1
fi

# 检查是否有正在运行的进程
if pgrep -f "pnpm dev" > /dev/null; then
    echo "⚠️  Warning: Development server is running"
    echo "Please stop the dev server before garbage collection"
    exit 1
fi

echo "✅ Ready for garbage collection"
