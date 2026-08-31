#!/bin/bash
# 推送前测试脚本

echo "=== 开始推送前测试 ==="

# 1. 运行 Maven 编译
echo "编译项目..."
mvn compile -q
if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi
echo "✅ 编译成功"

# 2. 运行单元测试（可选）
# echo "运行单元测试..."
# mvn test -q
# if [ $? -ne 0 ]; then
#     echo "❌ 测试失败"
#     exit 1
# fi
# echo "✅ 测试通过"

# 3. 检查代码风格（如果有配置）
# echo "检查代码风格..."
# mvn checkstyle:check -q
# if [ $? -ne 0 ]; then
#     echo "❌ 代码风格检查失败"
#     exit 1
# fi
# echo "✅ 代码风格检查通过"

echo "=== 推送前测试完成 ==="
exit 0
