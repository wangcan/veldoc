# CLAUDE.md 文件分析

## 文件概述

`CLAUDE.md` 是项目级 Claude Code 指令文件，作为 AI 助手理解项目的核心入口点。该文件定义了项目的开发规范、技术栈、架构原则和常用命令。

## 文件内容

### 1. 项目概述

包含项目基础信息：
- 项目名称：芋道 ruoyi-vue-pro
- 源项目：https://github.com/YunaiV/ruoyi-vue-pro
- 分支：master-jdk25

### 2. 技术栈定义

| 类别 | 技术/版本 |
|------|----------|
| Java | JDK 25 |
| Spring Boot | 4.1.0 |
| 数据库 | MySQL + MyBatis Plus 3.5.16 |
| 缓存 | Redis + Redisson 4.6.1 |
| 消息队列 | Event/Redis/RabbitMQ/Kafka/RocketMQ |
| 工作流 | Flowable 8.0.0 |
| 安全认证 | Spring Security + Token + Redis |
| 接口文档 | Knife4j 4.5.0 + SpringDoc 3.0.3 |
| 工具类 | Hutool 5.8.46/6.0.0-M22, Guava, FastJson2 |
| 构建工具 | Maven |
| 代码增强 | Lombok 1.18.46, MapStruct 1.6.3 |

### 3. 项目结构

定义了清晰的模块化结构：
- **yudao-dependencies**: BOM 依赖管理
- **yudao-framework**: 框架核心模块
- **yudao-server**: 主启动模块
- **yudao-module-xxx**: 各业务模块（system/infra/member/bpm/pay/mall/crm/erp/ai/iot 等）

### 4. 开发规范

#### 代码规范
- 遵循《阿里巴巴 Java 开发手册》
- 类、方法必须有中文注释
- 使用 Slf4j 日志框架
- 使用统一异常处理

#### 分层架构
```
Controller层 → Service层 → Dal层
```

#### 模块依赖原则
- 业务模块依赖 framework 模块
- framework 模块之间可相互依赖
- 业务模块之间不可相互依赖

### 5. 常用命令

提供常用开发命令：
- 构建命令：`mvn clean package -DskipTests`
- 启动命令：`mvn spring-boot:run -pl yudao-server`
- 数据库初始化：`mysql -u root -p < sql/mysql/ruoyi-vue-pro.sql`

### 6. 访问地址

- Swagger UI: http://localhost:48080/swagger-ui
- Knife4j: http://localhost:48080/doc.html

### 7. 注意事项

- 数据库版本：MySQL 8.0+
- Redis 版本：6.0+
- 多租户支持注意事项
- 数据权限控制
- 事务管理

## 文件作用

### 1. 项目认知入口

作为 AI 助手（Claude Code）的首要参考文件，帮助 AI 理解：
- 项目的技术栈和版本
- 项目的目录结构
- 开发规范和约定
- 常用操作命令

### 2. 上下文注入

Claude Code 会在每次会话开始时自动读取此文件，将其内容注入到系统提示中，确保 AI：
- 遵循项目规范编写代码
- 使用正确的技术栈版本
- 遵循项目架构原则
- 生成符合项目风格的代码

### 3. 规范约束

通过显式定义规范，约束 AI 的行为：
- 代码风格统一
- 命名规范一致
- 分层架构清晰
- 注释要求明确

### 4. 开发效率提升

提供常用命令和访问地址，使开发者能够：
- 快速执行常见操作
- 知道在哪里查看接口文档
- 了解默认账号密码

## 文件设计特点

### 1. 结构清晰

使用 Markdown 格式，层次分明：
- 一级标题：主章节
- 二级标题：子章节
- 表格：技术栈、命令列表
- 代码块：命令示例

### 2. 内容全面

覆盖项目开发的各个方面：
- 技术选型
- 目录结构
- 开发规范
- 常用命令
- 注意事项

### 3. 针对性强

专门为 AI 助手设计：
- 明确的规则定义
- 清晰的约束条件
- 具体的示例代码

## 与其他配置文件的关系

```
CLAUDE.md (项目核心指令)
    ├── 引用 .claude/rules/ (详细规则)
    ├── 被 .claude/settings.json 引用
    └── 指导 agents/skills/commands 的行为
```

## 最佳实践建议

1. **保持更新**：技术栈升级时同步更新版本信息
2. **精简内容**：避免冗余，保持核心信息
3. **提供示例**：重要规范提供代码示例
4. **版本控制**：与代码一起提交到 Git 仓库

## 总结

CLAUDE.md 是 Claude Code 的核心配置文件，扮演着"项目说明书"的角色。它帮助 AI 助手理解项目、遵循规范、生成高质量代码，是项目 AI 辅助开发的基础设施。
