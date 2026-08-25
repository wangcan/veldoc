#!/bin/bash

# Git commit-msg hook
# 验证提交消息是否符合 Conventional Commits 规范

set -e

# 获取提交消息文件路径
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# 定义提交消息格式
# 格式: <type>(<scope>): <subject>
# 例如: feat(user): 添加用户头像上传功能

# 允许的类型
TYPES="feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert"

# 提交消息正则表达式
PATTERN="^($TYPES)(\([a-z0-9-]+\))?:\s.{1,50}"

# 验证提交消息格式
if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo "❌ Invalid commit message format!"
    echo ""
    echo "Commit message format: <type>(<scope>): <subject>"
    echo ""
    echo "Types:"
    echo "  feat     - 新功能"
    echo "  fix      - Bug 修复"
    echo "  docs     - 文档更新"
    echo "  style    - 代码格式调整"
    echo "  refactor - 重构"
    echo "  perf     - 性能优化"
    echo "  test     - 测试相关"
    echo "  chore    - 构建/工具变动"
    echo "  ci       - CI 配置变动"
    echo "  build    - 构建系统变动"
    echo "  revert   - 回退提交"
    echo ""
    echo "Examples:"
    echo "  feat(user): 添加用户头像上传功能"
    echo "  fix(auth): 修复登录 Token 过期问题"
    echo "  docs(readme): 更新安装说明"
    echo ""
    exit 1
fi

echo "✅ Commit message format is valid!"
