# .claude/agents/ 目录文件分析

## 目录概述

`.claude/agents/` 目录存放自定义代理（Agent）定义文件。每个代理是一个专业化的子助手，专注于特定类型的任务。代理可以拥有独立的模型配置、工具权限和提示词。

## 文件列表

```
.claude/agents/
├── code-reviewer.md    # 代码审查专家
├── java-developer.md   # Java 后端开发专家
└── sql-developer.md    # 数据库开发专家
```

---

## 1. code-reviewer.md - 代码审查专家

### 基本信息

| 属性 | 值 |
|------|-----|
| 名称 | `code-reviewer` |
| 描述 | 代码审查专家，专注于代码质量、安全性和性能优化 |
| 模型 | `sonnet` |
| 工具 | `Read, Glob, Grep`（只读工具） |

### 功能职责

专注于代码审查的四个维度：

1. **代码质量**
   - 可读性检查
   - 可维护性评估
   - 可扩展性分析
   - 代码复用检查

2. **安全性**
   - SQL 注入防护检查
   - XSS 攻击防护检查
   - 权限控制验证
   - 敏感数据加密检查

3. **性能优化**
   - N+1 查询检测
   - 索引使用分析
   - 缓存策略检查
   - 分页查询验证

4. **Spring Boot 最佳实践**
   - 依赖注入方式
   - 事务管理正确性
   - 异常处理规范
   - 配置管理方式

### 审查清单

提供了针对各层的审查标准：

| 层级 | 检查项 |
|------|--------|
| Controller | 权限注解、参数校验、返回类型统一 |
| Service | 事务注解、日志记录、异常处理 |
| Mapper | SQL 注入风险、索引使用、批量操作 |

### 输出格式

以 Markdown 表格形式输出审查结果：

```markdown
| 行号 | 问题类型 | 问题描述 | 建议修复 |
|------|---------|---------|---------|
| 45 | 安全 | 缺少权限注解 | 添加 @PreAuthorize |
```

### 使用场景

- 代码提交前的自动审查
- Pull Request 代码评审
- 代码质量改进建议

---

## 2. java-developer.md - Java 后端开发专家

### 基本信息

| 属性 | 值 |
|------|-----|
| 名称 | `java-developer` |
| 描述 | Java 后端开发专家，精通 Spring Boot、MyBatis Plus、Redis 等技术栈 |
| 模型 | `sonnet` |
| 工具 | `Read, Edit, Write, Bash, Glob, Grep`（完整工具集） |

### 技术专长

- **Java 25** - 虚拟线程、模式匹配、记录类
- **Spring Boot 4.1.0** - 自动配置、条件装配、Actuator
- **MyBatis Plus 3.5.16** - ORM、代码生成、分页
- **Redis + Redisson** - 缓存、分布式锁、消息队列
- **Spring Security** - 认证授权、JWT、OAuth2
- **Flowable 8.0.0** - 工作流引擎、BPMN

### 开发规范

定义了详细的开发规范：

1. **代码风格**
   - 遵循阿里巴巴 Java 开发手册
   - 使用 Lombok 简化 POJO
   - 使用 MapStruct 进行对象映射
   - 所有 public 方法必须有中文注释

2. **分层架构**
   ```
   Controller → Service → Dal
   ```

3. **命名约定**

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| Controller | XxxController | UserController |
| Service 接口 | XxxService | UserService |
| Service 实现 | XxxServiceImpl | UserServiceImpl |
| Mapper | XxxMapper | UserMapper |
| DO | XxxDO | UserDO |
| VO | XxxVO/XxxPageReqVO | UserVO |

### 代码模板

提供标准 CRUD 代码模板，包括：
- Controller 创建接口
- Service 接口和实现
- Mapper 分页查询

### 使用场景

- 创建新的业务模块
- 实现标准 CRUD 功能
- 编写 Spring Boot 业务代码
- 调试和优化代码

---

## 3. sql-developer.md - 数据库开发专家

### 基本信息

| 属性 | 值 |
|------|-----|
| 名称 | `sql-developer` |
| 描述 | 数据库开发专家，精通 MySQL、MyBatis Plus、数据建模 |
| 模型 | `sonnet` |
| 工具 | `Read, Edit, Write, Bash` |

### 技术栈

- **MySQL 8.0+** - 主数据库
- **MyBatis Plus 3.5.16** - ORM 框架
- **Druid 1.2.28** - 数据库连接池
- **多数据源** - MySQL、Oracle、PostgreSQL、达梦等

### 数据库设计规范

1. **表命名规范**

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 业务表 | 模块_业务名 | system_user |
| 关联表 | 模块_业务1_业务2 | system_user_role |
| 字典表 | 模块_dict_type | system_dict_data |

2. **字段设计模板**
   - 主键设计
   - 业务字段设计
   - 通用字段（creator, create_time, updater, update_time, deleted）

3. **索引设计原则**
   - 唯一索引
   - 普通索引
   - 联合索引（最左前缀原则）

### MyBatis Plus 使用

提供 DO 实体类和 Mapper 接口的标准模板：
- 使用 `BaseMapperX` 扩展
- 使用 `LambdaQueryWrapperX` 条件构造
- 支持数据权限和多租户

### 性能优化建议

1. 避免 SELECT *
2. 使用批量操作
3. 合理使用索引
4. 正确分页查询
5. 配置连接池监控

### 使用场景

- 设计数据库表结构
- 编写 SQL 迁移脚本
- 创建 Mapper 接口
- 优化数据库性能
- 处理多租户数据

---

## 代理设计模式

### 1. 专业化分工

每个代理专注于特定领域：
- `java-developer` - 业务逻辑开发
- `sql-developer` - 数据库开发
- `code-reviewer` - 代码审查（只读）

### 2. 工具权限控制

| 代理 | 工具权限 | 原因 |
|------|---------|------|
| java-developer | 完整 | 需要创建/修改文件 |
| sql-developer | 读写 | 需要创建 SQL 文件 |
| code-reviewer | 只读 | 只审查不修改 |

### 3. 模型配置

所有代理使用 `sonnet` 模型：
- 平衡性能和成本
- 满足专业任务需求

### 4. 提示词结构

每个代理文件包含：
1. **Front Matter** - 元数据配置
2. **角色定义** - 明确代理定位
3. **专业领域** - 列出技术栈
4. **规范标准** - 定义代码规范
5. **模板示例** - 提供标准模板
6. **最佳实践** - 给出建议

---

## 文件格式规范

### Front Matter

每个代理文件必须包含 YAML 格式的 front matter：

```yaml
---
name: agent-name           # 代理名称（唯一标识）
description: 代理描述       # 功能描述
model: sonnet              # 使用的模型
tools: [Read, Edit, ...]   # 工具列表
---
```

### 正文结构

```markdown
# 代理标题

## 技术专长 / 功能职责

## 开发规范 / 审查维度

## 代码模板 / 审查清单

## 使用场景 / 常见问题
```

---

## 使用方式

### 1. 命令行调用

```bash
# Claude Code 自动根据任务类型选择代理
# 或显式指定代理
/agent java-developer 创建用户管理模块
```

### 2. 自动触发

Claude Code 根据任务描述自动选择合适的代理：
- 包含"创建"、"实现"关键词 → `java-developer`
- 包含"审查"、"检查"关键词 → `code-reviewer`
- 包含"数据库"、"表"、"SQL"关键词 → `sql-developer`

---

## 扩展建议

可以根据项目需要添加更多代理：

| 建议代理 | 职责 |
|---------|------|
| `frontend-developer` | Vue 前端开发 |
| `api-designer` | API 设计和文档 |
| `test-engineer` | 测试用例编写 |
| `security-auditor` | 安全审计 |

---

## 总结

`.claude/agents/` 目录定义了三个专业化代理：

1. **java-developer** - 全功能 Java 开发代理，负责业务代码编写
2. **sql-developer** - 数据库专家，负责数据库设计和 SQL 编写
3. **code-reviewer** - 只读审查代理，负责代码质量检查

这些代理通过专业化分工、工具权限控制和规范化的提示词，实现了高效、规范的 AI 辅助开发。
