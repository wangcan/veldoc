---
description: 编译并启动 yudao-server（默认 local profile），返回进程与日志信息。
argument-hint: "[local|dev|test]"
---

启动芋道服务端。参数（profile，默认 local）：$ARGUMENTS

步骤：
1. 确定 profile：若 $ARGUMENTS 为空用 `local`，否则用传入值。
2. 先编译依赖到本地仓库（避免 -api 未 install 导致找不到）：
   `mvn clean install -T 1C -DskipTests`
3. 后台启动：
   `mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles={profile}`
   用 `run_in_background` 运行，日志重定向到 `/tmp/yudao-server-{profile}.log`。
4. 等待启动：轮询日志出现 `Started YudaoServerApplication` 或监听 48080 端口（最多 ~90s）。
5. 报告：进程 PID、日志路径、访问地址（`http://localhost:48080`，Swagger `http://localhost:48080/swagger-ui`）。
6. 如需停止：`pkill -f "yudao-server"` 或 `pkill -f "spring-boot:run"`。

注意：
- 不做任何数据库操作；如启动失败因库未就绪，提示用户手动准备库（执行 sql/ 下脚本），不自动连库。
- local profile 默认连本地 MySQL，需用户自行确保环境。
