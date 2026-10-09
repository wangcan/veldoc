# mcp.md — 项目 MCP 配置说明

> 本文件为需求 `.requirements/ai/ai.txt` 中**需求2**的处理结果。
> 需求1、需求3 及以下均按 ai.txt 第 6 行「忽略以下所有需求」忽略，未执行。
> 全程未做任何数据库操作（遵守 ai.txt 第 1 行红线）。

## 一、需求与依据

- **需求2**：结合项目当前的技术栈，为项目配置几个 MCP，介绍各个 MCP 的特点和作用，结果存到本文件。
- **MCP（Model Context Protocol）**：Anthropic 提出的开放协议，让 Claude 通过标准化接口连接外部工具/数据源。每个 MCP Server 暴露若干 tools/resources/prompts，Claude 按需调用，从而获得「读文件、查文档、操作仓库、结构化推理、持久记忆」等能力。
- **项目技术栈**（来自根 `pom.xml` / `yudao-dependencies`）：Java 8、Spring Boot 2.7.18、MyBatis-Plus、Druid+dynamic-datasource、Redisson+Lock4j、RocketMQ、Flowable、EasyExcel、MapStruct、Lombok、Hutool、Knife4j+SpringDoc、MinIO、微信 Java、阿里云/腾讯云 SMS、JustAuth、Spring Boot Admin、SkyWalking；Maven 多模块（11 个业务模块 + framework + server）；MySQL 主库（兼容达梦）。
- **包名校验**：下表所有 npm 包均经 `npm view <pkg> version` 验证存在（node v24.18.0 / npx 11.16.0 / uvx 0.12.6 可用）。

## 二、配置文件

MCP 配置已写入项目根 `.mcp.json`（项目级、可提交 Git，团队成员共享）。Claude Code 启动时自动加载并拉起其中声明的 MCP Server。

```
/data/java/ruoyi-vue-pro/.mcp.json   # 项目级 MCP 配置（新增）
```

启用 5 个 MCP Server：filesystem、context7、github、sequential-thinking、memory。
MySQL MCP 因与「不做任何数据库操作」红线冲突，**默认不启用**，仅在文末作为可选项说明（见第五节）。

## 三、各 MCP 特点与作用

### 1. filesystem — 文件系统访问
- **包**：`@modelcontextprotocol/server-filesystem`（官方参考实现，已校验存在）。
- **配置**：`npx -y @modelcontextprotocol/server-filesystem /data/java/ruoyi-vue-pro`，作用域锁定项目根目录。
- **特点**：提供 `read_file` / `write_file` / `list_directory` / `search_files` / `move_file` 等工具，对指定目录树进行结构化文件操作。
- **对本项目的作用**：
  - yudao 是 11 个业务模块 + framework 的大型多模块仓库，文件量大；filesystem MCP 提供统一的目录浏览与检索入口，快速定位 `yudao-module-{x}/yudao-module-{x}-biz/...` 下的 Controller/Service/DO/Mapper。
  - 与 Claude Code 内置 Read/Edit 互补：MCP 侧重「批量检索 + 目录视图」，内置工具侧重「精确编辑」。
- **注意**：作用域已限定在项目根，不会越权访问仓库外文件。

### 2. context7 — 依赖库实时文档
- **包**：`@upstash/context7-mcp`（已校验，v4.2.0）。
- **配置**：`npx -y @upstash/context7-mcp`，无需 token。
- **特点**：按库 + 版本拉取最新官方文档/API 参考，返回给 Claude 作为准确上下文，避免凭记忆给出过时或版本不符的 API。
- **对本项目的作用（关键）**：
  - 项目锁定在 **Spring Boot 2.7.18**（非当前主线 3.x），MyBatis-Plus、Flowable、Knife4j、Hutool、EasyExcel 等均有特定大版本，API 差异显著（如 SpringBoot 2.x 用 `javax.*`、3.x 用 `jakarta.*`）。
  - context7 让 Claude 在写代码时拉取「Spring Boot 2.7.x / MyBatis-Plus 3.5.x / Flowable 6.x」的准确用法，避免把 3.x 的 API 写进 Java8/2.7 项目导致编译失败。这是本项目收益最高的 MCP。

### 3. github — 仓库与协作
- **包**：`@modelcontextprotocol/server-github`（已校验）。
- **配置**：`npx -y @modelcontextprotocol/server-github`，需环境变量 `GITHUB_PERSONAL_ACCESS_TOKEN`（`.mcp.json` 中用 `${GITHUB_PERSONAL_ACCESS_TOKEN}` 占位，未设置时该 server 不生效，不影响其它 server）。
- **特点**：提供 issue/PR/仓库搜索、文件读取、分支/创建 PR 等工具。
- **对本项目的作用**：
  - 项目底层框架来源于上游 `YunaiV/ruoyi-vue-pro`；遇到不确定实现时，可用 github MCP 搜索上游 issue/PR 看官方解释与已知问题。
  - 本仓库自身的 PR/issue 协作（查、评论、创建 PR）可直接通过 MCP 完成，无需切到浏览器。

### 4. sequential-thinking — 结构化推理
- **包**：`@modelcontextprotocol/server-sequential-thinking`（已校验）。
- **配置**：`npx -y @modelcontextprotocol/server-sequential-thinking`，无依赖。
- **特点**：提供一个「可回退、可修正」的分步思考工具，每步可修订前序结论，适合长链路推理。
- **对本项目的作用**：
  - 跨 11 个模块的重构（如统一某约定、迁移某能力）、新模块脚手架设计、复杂工作流（Flowable）编排时，用分步推理降低遗漏。
  - 对「跨模块是否该走 -api」「权限码命名」「租户与数据权限叠加」等架构判断尤为有用。

### 5. memory — 持久化知识图谱
- **包**：`@modelcontextprotocol/server-memory`（已校验）。
- **配置**：`npx -y @modelcontextprotocol/server-memory`，无依赖。
- **特点**：基于实体/关系/观察的知识图谱，跨会话持久（默认存于进程内存，可配文件持久化）。
- **对本项目的作用**：
  - 记忆项目约定（命名铁律、分层结构）、模块地图、常见 ErrorCode 段位、已做决策（如「禁库」「新模块需注册根 pom」），新会话直接召回，减少重复勘察。
  - 与 Claude Code 自身的文件型 memory 互补：MCP memory 适合结构化三元组关系，文件 memory 适合长文事实。

## 四、配置汇总表

| MCP | 包 | 命令 | 是否需密钥 | 默认启用 | 主要收益 |
| --- | --- | --- | --- | --- | --- |
| filesystem | `@modelcontextprotocol/server-filesystem` | `npx -y … /data/java/ruoyi-vue-pro` | 否 | 是 | 多模块文件检索/读写 |
| context7 | `@upstash/context7-mcp` | `npx -y …` | 否 | 是 | SpringBoot2.7/MyBatis-Plus 等版本精确文档 |
| github | `@modelcontextprotocol/server-github` | `npx -y …` | 是（GITHUB_TOKEN） | 是（未设 token 则跳过） | 上游 issue/PR、本仓库协作 |
| sequential-thinking | `@modelcontextprotocol/server-sequential-thinking` | `npx -y …` | 否 | 是 | 跨模块重构/架构分步推理 |
| memory | `@modelcontextprotocol/server-memory` | `npx -y …` | 否 | 是 | 跨会话记忆项目约定/地图 |

## 五、可选项（默认不启用，与红线冲突）

### mysql — 数据库访问（谨慎，默认关闭）
- **包**：`@benborla29/mcp-server-mysql`（社区实现，已校验 v2.0.9）。
- **特点**：提供只读/读写 SQL 执行、表结构查询工具。
- **为何默认不启用**：本项目 ai.txt 第 1 行明确规定「**不做任何数据库操作**」，`.claude/rules/no-db-ops.md` 与 `settings.json` 的 `deny` 列表已硬禁 `mysql`/`psql`/`disql` 等客户端。启用 mysql MCP 会与该红线直接冲突。
- **如确需**（仅限只读 schema 检查，且在受控环境）：可手动加入 `.mcp.json`，并务必配置为 `--readonly` 模式、仅连只读副本、绝不执行 DDL/DML；团队须知晓此为例外。默认配置中**不含**此项。

如需启用，参考片段（**非默认**，需人工添加）：
```json
"mysql": {
  "command": "npx",
  "args": ["-y", "@benborla29/mcp-server-mysql"],
  "env": {
    "MYSQL_HOST": "127.0.0.1",
    "MYSQL_PORT": "3306",
    "MYSQL_USER": "${MYSQL_READONLY_USER}",
    "MYSQL_PASS": "${MYSQL_READONLY_PASS}",
    "MYSQL_DB": "yudao",
    "ALLOW_INSERT_OPERATION": "false",
    "ALLOW_UPDATE_OPERATION": "false",
    "ALLOW_DELETE_OPERATION": "false"
  }
}
```

## 六、启用与使用

1. **配置已就绪**：`.mcp.json` 已在项目根，下次启动 Claude Code 自动加载。
2. **github token**（可选）：如需 github MCP，在 shell 设置 `export GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxx`（或写入 `~/.bashrc`），Claude Code 会通过 `${...}` 占位读取。
3. **首次拉起**：各 server 首次用 `npx -y` 会下载包并缓存，之后启动很快；如遇 PATH 问题（npx 不在默认 PATH），改用绝对路径 `/root/.nvm/versions/node/v24.18.0/bin/npx` 或确保 nvm 已 source。
4. **验证**：启动后在 Claude Code 中执行 `/mcp` 可查看各 server 连接状态与暴露的工具列表。
5. **禁库红线不变**：即使启用 MCP，Claude 仍受 `no-db-ops.md` 与 `settings.json` deny 列表约束，不执行任何数据库操作；mysql MCP 默认不启用。

## 七、与已有 Claude 资产的协同

| MCP | 协同的已有资产 |
| --- | --- |
| context7 | `.claude/rules/java-conventions.md`（Java8/版本限制）、`agents/java-backend-dev.md` |
| filesystem | `.claude/skills/yudao-new-crud`、`yudao-conventions-check`（检索参照功能） |
| github | `CLAUDE.md` 第 1 节（上游来源）、Git 工作流 |
| sequential-thinking | `.claude/agents/module-scaffolder.md`、`skills/yudao-new-module` |
| memory | `CLAUDE.md` 资产索引、`.claude/rules/*`（可记忆约定） |

## 八、未执行说明

- 需求1（Claude 配置初始化）与需求3（分析 CLAUDE.md/settings/agents/commands/hooks/rules/skills）均在 ai.txt 第 6 行「忽略以下所有需求」之后，按规则忽略，未执行。需求1 的产物（CLAUDE.md、.claude/* 等）已在前序会话生成并保留。
- 本次仅完成需求2：配置 5 个 MCP（`.mcp.json`）+ 说明文件（本 `mcp.md`），未做任何数据库操作。
