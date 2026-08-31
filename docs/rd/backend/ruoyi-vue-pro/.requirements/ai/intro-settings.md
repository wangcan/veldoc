# settings.json 文件分析

## 文件概述

`.claude/settings.json` 是 Claude Code 的项目级配置文件，定义了项目的基本信息、构建命令、以及引用的规则、代理和技能文件。此文件会被提交到 Git 仓库，作为团队共享的配置。

## 文件内容

### 完整配置结构

```json
{
  "project": {
    "name": "ruoyi-vue-pro",
    "description": "芋道 ruoyi-vue-pro 企业级快速开发平台",
    "javaVersion": "25",
    "springBootVersion": "4.1.0"
  },
  "build": {
    "command": "mvn clean package -DskipTests",
    "testCommand": "mvn test",
    "startCommand": "mvn spring-boot:run -pl yudao-server"
  },
  "rules": [
    ".claude/rules/java-code-style.md",
    ".claude/rules/spring-boot-patterns.md",
    ".claude/rules/mybatis-plus-patterns.md",
    ".claude/rules/security-patterns.md"
  ],
  "agents": [
    ".claude/agents/java-developer.md",
    ".claude/agents/code-reviewer.md",
    ".claude/agents/sql-developer.md"
  ],
  "skills": [
    ".claude/skills/create-module.md",
    ".claude/skills/create-crud.md",
    ".claude/skills/run-tests.md"
  ]
}
```

### 配置项说明

#### 1. project 配置块

| 字段 | 说明 | 值 |
|------|------|-----|
| `name` | 项目名称 | `ruoyi-vue-pro` |
| `description` | 项目描述 | 芋道 ruoyi-vue-pro 企业级快速开发平台 |
| `javaVersion` | Java 版本 | `25` |
| `springBootVersion` | Spring Boot 版本 | `4.1.0` |

**作用**：提供项目基础信息，帮助 AI 理解项目背景和版本约束。

#### 2. build 配置块

| 字段 | 说明 | 命令 |
|------|------|------|
| `command` | 构建命令 | `mvn clean package -DskipTests` |
| `testCommand` | 测试命令 | `mvn test` |
| `startCommand` | 启动命令 | `mvn spring-boot:run -pl yudao-server` |

**作用**：定义常用构建操作，使 Claude Code 能够自动执行构建、测试、启动等任务。

#### 3. rules 配置块

引用的规则文件列表：

| 文件 | 说明 |
|------|------|
| `java-code-style.md` | Java 代码风格规范 |
| `spring-boot-patterns.md` | Spring Boot 最佳实践 |
| `mybatis-plus-patterns.md` | MyBatis Plus 使用规范 |
| `security-patterns.md` | 安全规范 |

**作用**：定义代码规范和最佳实践，指导 AI 生成符合项目标准的代码。

#### 4. agents 配置块

引用的代理文件列表：

| 文件 | 说明 |
|------|------|
| `java-developer.md` | Java 后端开发专家 |
| `code-reviewer.md` | 代码审查专家 |
| `sql-developer.md` | 数据库开发专家 |

**作用**：定义专业化的子代理，处理特定类型的任务。

#### 5. skills 配置块

引用的技能文件列表：

| 文件 | 说明 |
|------|------|
| `create-module.md` | 创建新业务模块 |
| `create-crud.md` | 创建标准 CRUD 功能 |
| `run-tests.md` | 运行项目测试 |

**作用**：定义可复用的操作技能，快速执行常见开发任务。

## 文件作用

### 1. 项目元数据管理

存储项目的基本信息：
- 项目名称和描述
- 技术栈版本
- 这些信息帮助 AI 理解项目背景

### 2. 命令集中管理

统一管理常用命令：
- 构建命令
- 测试命令
- 启动命令
- 使 Claude Code 能自动执行这些操作

### 3. 资源引用管理

集中管理 Claude Code 的资源配置：
- 规则文件（rules）
- 代理定义（agents）
- 技能定义（skills）
- 实现配置的模块化管理

### 4. 团队协作支持

作为团队共享配置：
- 提交到 Git 仓库
- 团队成员使用相同配置
- 确保 AI 行为一致性

## 配置层次结构

```
settings.json (项目共享配置)
    ↓ 覆盖
settings.local.json (本地个人配置，Git 忽略)
```

### settings.local.json 示例

```json
{
  "permissions": {
    "allow": [
      "Bash(mvn:*)",
      "Bash(mysql:*)",
      "Read(**)"
    ]
  }
}
```

**作用**：本地配置可以覆盖共享配置，定义个人偏好设置。

## 与其他文件的关系

```
settings.json
    ├── 引用 rules/*.md (代码规范)
    ├── 引用 agents/*.md (代理定义)
    ├── 引用 skills/*.md (技能定义)
    └── 被 CLAUDE.md 说明
```

## 配置最佳实践

### 1. 版本控制

- `settings.json` 提交到 Git
- `settings.local.json` 添加到 `.gitignore`

### 2. 命令定义

- 使用项目通用的标准命令
- 避免平台特定的命令（如 Windows 特有命令）
- 提供完整命令，包括必要参数

### 3. 引用路径

- 使用相对路径引用其他配置文件
- 保持配置文件的相对位置稳定

### 4. 配置更新

- 新增规则/代理/技能时更新引用
- 版本升级时更新版本信息
- 定期审查配置的有效性

## JSON Schema

虽然没有强制 schema，但推荐的配置结构：

```json
{
  "project": {
    "name": "string",
    "description": "string",
    "javaVersion": "string",
    "springBootVersion": "string"
  },
  "build": {
    "command": "string",
    "testCommand": "string",
    "startCommand": "string"
  },
  "rules": ["string"],
  "agents": ["string"],
  "skills": ["string"]
}
```

## 总结

`settings.json` 是 Claude Code 项目配置的核心文件，负责：
1. 定义项目元数据
2. 管理构建命令
3. 引用规则、代理、技能文件
4. 支持团队协作

它是项目 Claude Code 功能的"配置中心"，确保 AI 助手能够正确理解项目并执行正确的操作。
