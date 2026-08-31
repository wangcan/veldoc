#!/bin/bash
# 文件编辑后处理脚本

# 获取编辑的文件路径
FILE_PATH=$1

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# 只处理 Java 文件
if [[ "$FILE_PATH" == *.java ]]; then
    echo "处理 Java 文件: $FILE_PATH"

    # 1. 添加文件头注释（如果没有）
    if ! head -1 "$FILE_PATH" | grep -q "/\*"; then
        # 获取文件名
        FILENAME=$(basename "$FILE_PATH")

        # 在文件开头添加注释
        # 注意：这里只是示例，实际使用需要更复杂的处理
        echo "⚠️  建议为 $FILENAME 添加类注释"
    fi

    # 2. 检查导入语句
    if grep -q "import java.util.\*;" "$FILE_PATH"; then
        echo "⚠️  $FILE_PATH 中存在通配符导入，建议使用具体导入"
    fi

    # 3. 检查代码格式
    if grep -q $'\t' "$FILE_PATH"; then
        echo "⚠️  $FILE_PATH 中存在 Tab 字符，建议使用 4 个空格"
    fi
fi

# 处理 XML 文件
if [[ "$FILE_PATH" == *.xml ]]; then
    # 检查 XML 格式
    if ! xmllint --noout "$FILE_PATH" 2>/dev/null; then
        echo "❌ $FILE_PATH XML 格式错误"
    fi
fi

exit 0
