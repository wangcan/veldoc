#!/bin/bash
# Git 提交前检查脚本

echo "=== 开始代码检查 ==="

# 1. 检查 Java 代码格式
echo "检查 Java 代码格式..."
files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.java$')
if [ -n "$files" ]; then
    # 检查是否有 System.out.println
    if grep -r "System\.out\.println" $files; then
        echo "❌ 发现 System.out.println，请使用日志输出"
        exit 1
    fi

    # 检查是否有 @Autowired 字段注入
    if grep -r "@Autowired" $files | grep "private"; then
        echo "⚠️  发现 @Autowired 字段注入，建议使用构造器注入"
    fi

    echo "✅ Java 代码格式检查通过"
fi

# 2. 检查 SQL 文件
echo "检查 SQL 文件..."
sql_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sql$')
if [ -n "$sql_files" ]; then
    # 检查是否有 DROP 语句
    if grep -ri "DROP\s\(TABLE\|DATABASE\)" $sql_files; then
        echo "❌ 发现危险的 DROP 语句"
        exit 1
    fi

    echo "✅ SQL 文件检查通过"
fi

# 3. 检查配置文件
echo "检查配置文件..."
config_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '(application.*\.ya?ml|application.*\.properties)$')
if [ -n "$config_files" ]; then
    # 检查是否有明文密码
    if grep -ri "password.*=.*[a-zA-Z0-9]" $config_files | grep -v "your_password"; then
        echo "⚠️  配置文件中可能存在明文密码，请使用环境变量"
    fi

    echo "✅ 配置文件检查通过"
fi

echo "=== 代码检查完成 ==="
