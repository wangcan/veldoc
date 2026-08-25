# hooks 目录分析

## 目录概述

`.claude/hooks/` 目录包含自动化钩子脚本，这些脚本在特定事件触发时自动执行，实现代码质量保障和开发流程自动化。

## 目录位置

```
/data/project/backend/ai-laravel/.claude/hooks/
```

## 目录结构

```
.claude/hooks/
├── README.md            # 钩子说明文档
├── pint-format.sh       # Pint 代码格式化钩子
├── test-related.sh      # 相关测试运行钩子
└── migration-check.sh   # 迁移检查钩子
```

## 钩子类型

Claude Code 支持以下钩子类型：

| 钩子类型 | 触发时机 | 典型用途 |
|---------|---------|---------|
| `PreToolUse` | 工具执行前 | 验证、预处理 |
| `PostToolUse` | 工具执行后 | 格式化、验证、清理 |
| `Notification` | 特定事件 | 通知、日志 |
| `Stop` | 会话结束 | 清理、报告 |

---

## 钩子详细分析

### 1. README.md

**文件**: `README.md`

#### 文件内容概要

README 文档提供了钩子的完整说明，包括：

1. **可用钩子列表**
   - `pint-format.sh` - PHP 代码格式化
   - `test-related.sh` - 运行相关测试
   - `migration-check.sh` - 检查待执行迁移

2. **钩子类型说明**
   - PreToolUse
   - PostToolUse
   - Notification
   - Stop

3. **配置方法**
   - 在 `settings.json` 中配置
   - 使用 matcher 匹配工具

4. **创建新钩子的指南**
   - 创建 bash 脚本
   - 设置可执行权限
   - 添加配置

5. **最佳实践**
   - 保持钩子快速
   - 优雅处理错误
   - 记录有用信息

#### 关键配置示例

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "toolName": "Edit|Write"
        },
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/hook.sh"
          }
        ]
      }
    ]
  }
}
```

---

### 2. pint-format.sh

**文件**: `pint-format.sh`

#### 基本信息

- **触发时机**: 编辑或写入 PHP 文件后
- **触发条件**: `Edit|Write` 工具
- **功能**: 使用 Laravel Pint 自动格式化 PHP 代码

#### 脚本内容

```bash
#!/usr/bin/env bash
# Format PHP files with Pint after editing
# This hook runs after Edit or Write tools modify PHP files

# Get the list of modified PHP files
PHP_FILES=$(git diff --name-only --cached --diff-filter=ACM "*.php" 2>/dev/null | head -20)

if [ -n "$PHP_FILES" ]; then
    echo "🎨 Formatting PHP files with Pint..."
    vendor/bin/pint --dirty --format agent 2>/dev/null || true
fi
```

#### 工作流程

```
1. 用户编辑/创建 PHP 文件
   ↓
2. PostToolUse 钩子触发
   ↓
3. pint-format.sh 执行
   ↓
4. 检查是否有修改的 PHP 文件
   ↓
5. 如果有，运行 Pint 格式化
   ↓
6. 代码风格保持一致
```

#### 关键命令解析

**获取修改的文件**:
```bash
git diff --name-only --cached --diff-filter=ACM "*.php"
```
- `--name-only`: 只显示文件名
- `--cached`: 检查暂存区的修改
- `--diff-filter=ACM`: 只检查添加(A)、复制(C)、修改(M)的文件
- `"*.php"`: 只检查 PHP 文件

**运行 Pint**:
```bash
vendor/bin/pint --dirty --format agent
```
- `--dirty`: 只格式化有修改的文件
- `--format agent`: 输出格式适合 AI 读取
- `2>/dev/null`: 隐藏错误输出
- `|| true`: 即使失败也继续执行

#### 配置方式

在 `settings.json` 中：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "php vendor/bin/pint --dirty --format agent"
          }
        ]
      }
    ]
  }
}
```

#### 实际效果

**场景1：创建新控制器**

```
用户：创建一个 UserController

AI 创建文件：
app/Http/Controllers/UserController.php

钩子自动执行：
🎨 Formatting PHP files with Pint...
Formatted: app/Http/Controllers/UserController.php

结果：
✅ 文件已创建并格式化
```

**场景2：编辑现有模型**

```
用户：在 User 模型中添加一个 scope

AI 编辑文件：
app/Models/User.php

钩子自动执行：
🎨 Formatting PHP files with Pint...
Formatted: app/Models/User.php

结果：
✅ 文件已编辑并格式化
```

#### 为什么使用此钩子

- ✅ **自动格式化**: 无需手动运行 Pint
- ✅ **保持一致**: 确保所有 PHP 文件风格一致
- ✅ **节省时间**: 减少重复性工作
- ✅ **减少错误**: 避免忘记格式化

---

### 3. test-related.sh

**文件**: `test-related.sh`

#### 基本信息

- **触发时机**: 文件修改后（可选）
- **触发条件**: 环境变量 `RUN_TESTS=true`
- **功能**: 运行相关的 PHPUnit 测试

#### 脚本内容

```bash
#!/usr/bin/env bash
# Run related tests after file changes
# This hook can be triggered manually or configured for specific file types

# Check if we should run tests
SHOULD_RUN=${RUN_TESTS:-false}
TEST_FILTER=${TEST_FILTER:-""}

if [ "$SHOULD_RUN" = "true" ]; then
    if [ -n "$TEST_FILTER" ]; then
        echo "🧪 Running tests with filter: $TEST_FILTER"
        php artisan test --compact --filter="$TEST_FILTER" 2>/dev/null || true
    else
        echo "🧪 Running all tests..."
        php artisan test --compact 2>/dev/null || true
    fi
fi
```

#### 工作流程

```
1. 设置环境变量
   export RUN_TESTS=true
   export TEST_FILTER=UserTest
   ↓
2. 文件修改触发钩子
   ↓
3. 检查 RUN_TESTS 环境变量
   ↓
4. 如果为 true，运行测试
   ↓
5. 根据 TEST_FILTER 过滤测试
   ↓
6. 显示测试结果
```

#### 环境变量说明

| 变量 | 默认值 | 说明 |
|-----|--------|------|
| `RUN_TESTS` | `false` | 是否运行测试 |
| `TEST_FILTER` | `""` | 测试过滤器 |

#### 使用方式

**手动触发**:
```bash
# 运行所有测试
RUN_TESTS=true /path/to/test-related.sh

# 运行特定测试
RUN_TESTS=true TEST_FILTER=UserTest /path/to/test-related.sh
```

**配置为钩子**（可选）:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "RUN_TESTS=true TEST_FILTER=RelatedTest /path/to/test-related.sh"
          }
        ]
      }
    ]
  }
}
```

#### 实际效果

```
用户：修改 User 模型
AI 编辑文件：app/Models/User.php

手动运行：
RUN_TESTS=true TEST_FILTER=UserTest /path/to/test-related.sh

输出：
🧪 Running tests with filter: UserTest
  PASS  Tests\Feature\UserTest
  ✓ user can register
  ✓ user can login
  ✓ user can logout
  Tests:  3 passed
```

#### 为什么使用此钩子

- ✅ **快速验证**: 修改后立即测试
- ✅ **灵活控制**: 通过环境变量控制
- ✅ **精准测试**: 支持测试过滤
- ✅ **减少错误**: 及早发现问题

#### 适用场景

- 开发过程中快速验证
- CI/CD 流程中自动化测试
- 代码审查前的验证

---

### 4. migration-check.sh

**文件**: `migration-check.sh`

#### 基本信息

- **触发时机**: 数据库相关文件修改后
- **功能**: 检查是否有待执行的迁移

#### 脚本内容

```bash
#!/usr/bin/env bash
# Check for pending migrations after database-related changes

# List of patterns that suggest migration-related changes
MIGRATION_PATTERNS=("database/migrations" "app/Models" "Schema::create" "Schema::table")

# Check if any migration files were created or modified
PENDING_MIGRATIONS=$(php artisan migrate:status 2>/dev/null | grep -c "Pending" || echo "0")

if [ "$PENDING_MIGRATIONS" -gt 0 ]; then
    echo "⚠️  Found $PENDING_MIGRATIONS pending migration(s)"
    echo "Run 'php artisan migrate' to apply them."
fi
```

#### 工作流程

```
1. 创建或修改迁移文件
   ↓
2. 钩子执行
   ↓
3. 检查待执行迁移数量
   ↓
4. 如果有待执行迁移，提醒用户
   ↓
5. 用户运行 php artisan migrate
```

#### 关键命令解析

**检查迁移状态**:
```bash
php artisan migrate:status
```
输出示例：
```
+------+------------------------------------------------+-------+
| Ran? | Migration                                      | Batch |
+------+------------------------------------------------+-------+
| Yes  | 2014_10_12_000000_create_users_table           | 1     |
| Yes  | 2014_10_12_100000_create_password_reset_tokens | 1     |
| No   | 2026_08_25_123456_create_products_table        | Pending |
+------+------------------------------------------------+-------+
```

**统计待执行迁移**:
```bash
grep -c "Pending"
```
- 统计包含 "Pending" 的行数

#### 使用方式

**手动运行**:
```bash
/path/to/migration-check.sh
```

**配置为钩子**（推荐）:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/migration-check.sh"
          }
        ]
      }
    ]
  }
}
```

#### 实际效果

**场景1：创建新迁移**

```
用户：创建 products 表迁移

AI 创建文件：
database/migrations/2026_08_25_123456_create_products_table.php

钩子执行：
⚠️  Found 1 pending migration(s)
Run 'php artisan migrate' to apply them.

用户响应：
php artisan migrate
```

**场景2：没有待执行迁移**

```
用户：修改 User 模型

AI 编辑文件：
app/Models/User.php

钩子执行：
（无输出 - 没有待执行迁移）
```

#### 为什么使用此钩子

- ✅ **及时提醒**: 创建迁移后立即提醒
- ✅ **避免遗忘**: 防止忘记运行迁移
- ✅ **提高可见性**: 清楚知道数据库状态
- ✅ **减少错误**: 避免因迁移未执行导致的问题

---

## 钩子配置详解

### 配置结构

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/hook.sh"
          }
        ]
      }
    ]
  }
}
```

### 配置字段

| 字段 | 类型 | 说明 |
|-----|------|------|
| `matcher` | string | 匹配工具名称的正则表达式 |
| `hooks` | array | 钩子列表 |
| `type` | string | 钩子类型（command） |
| `command` | string | 要执行的命令 |

### Matcher 示例

```json
// 匹配 Edit 和 Write 工具
"matcher": "Edit|Write"

// 匹配所有 Bash 命令
"matcher": "Bash.*"

// 匹配特定的 MCP 工具
"matcher": "mcp__laravel-boost__database-schema"

// 匹配所有工具
"matcher": ".*"
```

---

## 钩子执行顺序

当多个钩子匹配同一工具时，按数组顺序执行：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {"type": "command", "command": "hook1.sh"},  // 先执行
          {"type": "command", "command": "hook2.sh"}   // 后执行
        ]
      }
    ]
  }
}
```

---

## 钩子最佳实践

### 1. 保持快速

钩子应该快速执行，避免长时间等待：

```bash
# 好：限制文件数量
head -20

# 差：处理所有文件
cat *.php
```

### 2. 优雅处理错误

使用 `|| true` 避免错误中断：

```bash
# 好：即使失败也继续
vendor/bin/pint --dirty 2>/dev/null || true

# 差：失败会中断流程
vendor/bin/pint --dirty
```

### 3. 条件执行

只在必要时执行：

```bash
# 好：检查条件
if [ -n "$PHP_FILES" ]; then
    vendor/bin/pint --dirty
fi

# 差：总是执行
vendor/bin/pint --dirty
```

### 4. 友好输出

使用图标和清晰的提示：

```bash
echo "🎨 Formatting PHP files..."
echo "✅ Formatted successfully"
echo "⚠️  Warning: pending migrations"
```

---

## 创建自定义钩子

### 步骤1：创建脚本

```bash
#!/usr/bin/env bash
# My custom hook
# Description: What this hook does

# Your logic here
echo "🔧 Running custom hook..."

# Example: Check something
if [ condition ]; then
    echo "✅ Check passed"
else
    echo "⚠️  Check failed"
fi
```

### 步骤2：设置可执行权限

```bash
chmod +x .claude/hooks/my-hook.sh
```

### 步骤3：添加配置

在 `settings.json` 中添加：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/my-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### 步骤4：测试钩子

```bash
# 手动测试
./.claude/hooks/my-hook.sh

# 在项目中测试
# 创建或编辑文件，观察钩子是否执行
```

---

## 钩子使用场景

### 场景1：自动代码格式化

```
需求：所有 PHP 文件自动格式化

解决方案：
1. 使用 pint-format.sh 钩子
2. 配置在 PostToolUse 中
3. 匹配 Edit|Write 工具

效果：
每次编辑或创建 PHP 文件后自动格式化
```

### 场景2：迁移提醒

```
需求：创建迁移后提醒执行

解决方案：
1. 使用 migration-check.sh 钩子
2. 配置在 PostToolUse 中
3. 匹配 Write 工具（创建迁移文件）

效果：
创建迁移文件后自动检查并提醒
```

### 场景3：测试验证

```
需求：修改代码后自动运行相关测试

解决方案：
1. 使用 test-related.sh 钩子
2. 设置环境变量 RUN_TESTS=true
3. 配置测试过滤器

效果：
修改代码后自动运行相关测试
```

---

## 钩子对比表

| 钩子 | 触发时机 | 主要功能 | 自动化程度 |
|-----|---------|---------|----------|
| `pint-format.sh` | 文件编辑后 | 代码格式化 | 完全自动 |
| `test-related.sh` | 文件编辑后（可选）| 运行测试 | 环境变量控制 |
| `migration-check.sh` | 创建迁移后 | 迁移提醒 | 自动检查 |

---

## 总结

`.claude/hooks/` 目录包含三个自动化钩子脚本：

1. **`pint-format.sh`** - PHP 代码自动格式化
2. **`test-related.sh`** - 相关测试运行（可选）
3. **`migration-check.sh`** - 待执行迁移检查

这些钩子：
- 提高代码质量
- 自动化重复性工作
- 减少人为错误
- 提升开发效率

通过合理配置钩子，可以实现：
- 自动代码格式化
- 及时的迁移提醒
- 灵活的测试验证
- 持续的质量保障

钩子是 Claude Code 自动化能力的核心组件，它们在后台默默工作，确保代码质量和开发流程的一致性。
