---
name: yudao-run-server
description: 编译依赖并后台启动 yudao-server（默认 local profile，端口 48080），轮询日志确认启动成功，返回 PID/日志路径/访问地址。当用户要求「启动服务」「跑起来」「启动 yudao」「本地启动」时触发。
---

# 技能：启动 yudao-server

## 触发场景
- 「启动服务」「把项目跑起来」
- 「启动 yudao，用 local/dev/test profile」
- 「本地启动一下看效果」

## 输入
- profile（可选，默认 `local`）

## 执行步骤
1. 确定 profile：参数为空则 `local`。
2. **编译安装依赖**（避免 -api 未 install）：
   `mvn clean install -T 1C -DskipTests`（后台，日志 `/tmp/yudao-build.log`）。
3. **启动服务**（后台运行）：
   `mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles={profile}`，日志重定向 `/tmp/yudao-server-{profile}.log`。
4. **等待就绪**：每 ~10s 读取日志尾部，直到出现 `Started YudaoServerApplication` 或 48080 端口监听；最多等 ~120s。
5. **报告**：
   - 进程 PID
   - 日志路径 `/tmp/yudao-server-{profile}.log`
   - 访问地址：`http://localhost:48080`，Swagger：`http://localhost:48080/swagger-ui`，Knife4j：`http://localhost:48080/doc.html`
6. **停止方式**：`pkill -f "yudao-server"` 或 `pkill -f "spring-boot:run"`。

## 失败处理
- 若启动失败提示数据库连接错误：**不自动连库/不自动建表**，提示用户手动准备本地 MySQL 与执行 `sql/` 下脚本（如 `sql/mysql/quartz.sql`、各模块建表脚本），以及 `application-local.yaml` 的数据源配置。
- 端口占用：提示并执行 `pkill -f yudao-server` 后重试。

## 约束
- 红线：不做任何数据库操作；启动所需库由用户自行准备。
- 不编辑 `target/`、`*.class`、`generated-sources/`。

## 关联
- 命令：`/yudao-run`。
- 规则：`no-db-ops.md`。
