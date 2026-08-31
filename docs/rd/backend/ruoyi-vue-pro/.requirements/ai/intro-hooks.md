# .claude/hooks/ 目录文件分析

## 目录概述

`.claude/hooks/` 目录存放自动化钩子（Hooks）脚本。钩子在特定事件触发时自动执行，用于代码质量检查、安全审计、自动化测试等场景。

## 文件列表

```
.claude/hooks/
├── post-edit.sh     # 文件编辑后处理脚本
├── pre-commit.sh    # Git 提交前检查脚本
└── pre-push.sh      # 推送前测试脚本
```

---

## 1. post-edit.sh - 文件编辑后处理脚本

### 基本信息

| 属性 | 值 |
|------|-----|
| 触发时机 | 文件编辑完成后 |
| 触发条件 | Claude Code 编辑文件后 |
| 参数 | `$FILE_PATH` - 被编辑的文件路径 |

### 功能职责

#### Java 文件处理

```bash
# 1. 检查文件头注释
if ! head -1 "$FILE_PATH" | grep -q "/\*"; then
    echo "⚠️  建议为 $FILENAME 添加类注释"
fi

# 2. 检查导入语句
if grep -q "import java.util.*;" "$FILE_PATH"; then
    echo "⚠️  $FILE_PATH 中存在通配符导入，建议使用具体导入"
fi

# 3. 检查代码格式
if grep -q $'\t' "$FILE_PATH"; then
    echo "⚠️  $FILE_PATH 中存在 Tab 字符，建议使用 4 个空格"
fi
```

#### XML 文件处理

```bash
# 检查 XML 格式
if ! xmllint --noout "$FILE_PATH" 2>/dev/null; then
    echo "❌ $FILE_PATH XML 格式错误"
fi
```

### 检查项

| 文件类型 | 检查项 | 级别 |
|---------|--------|------|
| Java | 缺少类注释 | 警告 |
| Java | 通配符导入 | 警告 |
| Java | Tab 字符 | 警告 |
| XML | 格式错误 | 错误 |

### 使用场景

- 编辑 Java 文件后检查代码风格
- 编辑 XML 文件后验证格式
- 提醒开发者添加注释

---

## 2. pre-commit.sh - Git 提交前检查脚本

### 基本信息

| 属性 | 值 |
|------|-----|
| 触发时机 | `git commit` 前执行 |
| 触发条件 | 文件已 `git add` 并准备提交 |
| 失败处理 | 检查失败则阻止提交 |

### 功能职责

#### 1. Java 代码检查

```bash
# 检查 System.out.println
if grep -r "System\.out\.println" $files; then
    echo "❌ 发现 System.out.println，请使用日志输出"
    exit 1
fi

# 检查 @Autowired 字段注入
if grep -r "@Autowired" $files | grep "private"; then
    echo "⚠️  发现 @Autowired 字段注入，建议使用构造器注入"
fi
```

#### 2. SQL 文件检查

```bash
# 检查危险的 DROP 语句
if grep -ri "DROP\s\(TABLE\|DATABASE\)" $sql_files; then
    echo "❌ 发现危险的 DROP 语句"
    exit 1
fi
```

#### 3. 配置文件检查

```bash
# 检查明文密码
if grep -ri "password.*=.*[a-zA-Z0-9]" $config_files | grep -v "your_password"; then
    echo "⚠️  配置文件中可能存在明文密码，请使用环境变量"
fi
```

### 检查项

| 检查类型 | 检查项 | 级别 | 失败行为 |
|---------|--------|------|---------|
| Java | System.out.println | 错误 | 阻止提交 |
| Java | @Autowired 字段注入 | 警告 | 允许提交 |
| SQL | DROP TABLE/DATABASE | 错误 | 阻止提交 |
| 配置 | 明文密码 | 警告 | 允许提交 |

### 使用场景

- 提交前检查代码质量
- 阻止不合规代码提交
- 安全审计

### 执行流程

```
git commit
    ↓
pre-commit.sh 触发
    ↓
检查暂存区文件
    ↓
┌─────────────┐
│ 检查通过？  │
└─────────────┘
    ↓           ↓
   是          否
    ↓           ↓
允许提交    阻止提交
```

---

## 3. pre-push.sh - 推送前测试脚本

### 基本信息

| 属性 | 值 |
|------|-----|
| 触发时机 | `git push` 前执行 |
| 触发条件 | 准备推送代码到远程仓库 |
| 失败处理 | 测试失败则阻止推送 |

### 功能职责

#### 1. Maven 编译

```bash
echo "编译项目..."
mvn compile -q
if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi
echo "✅ 编译成功"
```

#### 2. 单元测试（可选，已注释）

```bash
# echo "运行单元测试..."
# mvn test -q
# if [ $? -ne 0 ]; then
#     echo "❌ 测试失败"
#     exit 1
# fi
# echo "✅ 测试通过"
```

#### 3. 代码风格检查（可选，已注释）

```bash
# echo "检查代码风格..."
# mvn checkstyle:check -q
# if [ $? -ne 0 ]; then
#     echo "❌ 代码风格检查失败"
#     exit 1
# fi
# echo "✅ 代码风格检查通过"
```

### 执行流程

```
git push
    ↓
pre-push.sh 触发
    ↓
执行 Maven 编译
    ↓
┌─────────────┐
│ 编译成功？  │
└─────────────┘
    ↓           ↓
   是          否
    ↓           ↓
允许推送    阻止推送
```

### 使用场景

- 推送前验证代码可编译
- 确保代码质量
- 阻止问题代码推送

### 可配置项

可以通过取消注释启用：
- 单元测试检查
- 代码风格检查

---

## 钩子设计模式

### 1. 生命周期钩子

| 钩子 | 触发时机 | 用途 |
|------|---------|------|
| post-edit | 文件编辑后 | 即时检查 |
| pre-commit | Git 提交前 | 提交验证 |
| pre-push | Git 推送前 | 推送验证 |

### 2. 级别划分

| 级别 | 图标 | 行为 |
|------|------|------|
| 错误 | ❌ | 阻止操作 |
| 警告 | ⚠️ | 提示但不阻止 |
| 成功 | ✅ | 继续执行 |

### 3. 渐进式验证

```
编辑文件
    ↓ post-edit（即时反馈）
暂存文件
    ↓
git commit
    ↓ pre-commit（提交验证）
本地提交完成
    ↓
git push
    ↓ pre-push（推送验证）
推送到远程
```

---

## 文件格式规范

### 脚本头部

```bash
#!/bin/bash
# 脚本描述

# 获取参数
FILE_PATH=$1

# 检查参数
if [ -z "$FILE_PATH" ]; then
    exit 0
fi
```

### 检查逻辑

```bash
# 文件类型过滤
if [[ "$FILE_PATH" == *.java ]]; then
    # Java 检查逻辑
fi

# 执行检查
if grep -q "pattern" "$FILE_PATH"; then
    echo "❌ 发现问题"
    exit 1  # 阻止操作
fi
```

### 退出码

| 退出码 | 含义 |
|-------|------|
| 0 | 成功，继续操作 |
| 1 | 失败，阻止操作 |

---

## 配置方式

### 在 settings.json 中配置

```json
{
  "hooks": {
    "post-edit": ".claude/hooks/post-edit.sh",
    "pre-commit": ".claude/hooks/pre-commit.sh",
    "pre-push": ".claude/hooks/pre-push.sh"
  }
}
```

### Git Hooks 配置

需要将脚本链接到 Git hooks 目录：

```bash
# 设置 pre-commit hook
ln -s ../../.claude/hooks/pre-commit.sh .git/hooks/pre-commit

# 设置 pre-push hook
ln -s ../../.claude/hooks/pre-push.sh .git/hooks/pre-push
```

---

## 扩展建议

可以根据项目需要添加更多钩子：

| 建议钩子 | 触发时机 | 用途 |
|---------|---------|------|
| post-merge | 合并后 | 自动安装依赖 |
| post-checkout | 切换分支后 | 提醒配置差异 |
| pre-rebase | 变基前 | 检查未提交修改 |

---

## 最佳实践

### 1. 快速反馈

钩子应该快速执行：
- 只检查必要的问题
- 避免耗时操作
- 使用增量检查

### 2. 清晰提示

错误信息应该清晰：
- 说明问题所在
- 提供解决方案
- 使用图标区分级别

### 3. 可配置性

提供配置选项：
- 可以跳过某些检查
- 可以调整检查级别
- 可以启用/禁用钩子

---

## 总结

`.claude/hooks/` 目录定义了三个自动化钩子：

1. **post-edit.sh** - 文件编辑后即时检查，提示代码风格问题
2. **pre-commit.sh** - 提交前检查，阻止不合规代码提交
3. **pre-push.sh** - 推送前编译验证，确保代码可编译

这些钩子实现了渐进式的代码质量保障：
- 编辑时即时反馈
- 提交时质量检查
- 推送时编译验证

通过自动化检查，提高了代码质量，减少了代码审查的工作量。
