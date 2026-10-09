# 规则：业务模块结构与分层

> 适用于 `yudao-module-*` 所有业务模块。详见 `CLAUDE.md` 第 4 节。

## 1. 子模块拆分
每个业务模块 `yudao-module-{name}` 拆为两个 Maven 子模块：
- `yudao-module-{name}-api`：对外 API（接口 + DTO），供其它模块依赖。**只放接口与 DTO，不放 DO/Service 实现**。
- `yudao-module-{name}-biz`：业务实现，依赖本模块 `-api` 及所需 `yudao-spring-boot-starter-*`。

## 2. -biz 包结构（强约束）
包根 `cn.iocoder.yudao.module.{name}`：
```
controller/admin/{feature}/   后台管理端 Controller
controller/app/{feature}/      用户 App 端 Controller
service/{feature}/             Service 接口 + Impl
dal/dataobject/{feature}/      DO
dal/mysql/{feature}/           Mapper（extends BaseMapperX）
dal/redis/{feature}/           Redis DAO（可选）
convert/{feature}/             MapStruct Convert（可选，新代码可用 BeanUtils）
framework/                     模块内 Spring 配置
job/{feature}/                 定时任务
mq/{consumer,message,producer}/ RocketMQ
enums/                         ErrorCodeConstants 等
```

## 3. -api 包结构
包根 `cn.iocoder.yudao.module.{name}.api`：
```
api/{feature}/{X}Api.java        接口
api/{feature}/{X}ApiImpl.java    实现（放在 -biz 模块）
api/{feature}/dto/               跨模块 DTO
```

## 4. 模块注册
- 新模块必须在根 `pom.xml` 的 `<modules>` 中加 `<module>yudao-module-{name}</module>`。
- `yudao-server/pom.xml` 需引入新模块的 `-biz`。
- 默认 `crm`/`report`/`example` 在根 pom 中被注释；启用时取消注释。

## 5. 命名
- 模块目录、`<module>`、包根 `module.{name}`、表前缀 `{name}_`（如 `system_dept`）保持一致。
- 功能名 `{feature}` 在各层同名（如 `dept`）。

## 关联
- 脚手架代理：`.claude/agents/module-scaffolder.md`。
- 技能：`.claude/skills/yudao-new-module/SKILL.md`。
