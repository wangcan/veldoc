# 芋道 ruoyi-vue-pro 项目模块介绍

## 模块总览

芋道 ruoyi-vue-pro 项目采用多模块架构设计，遵循"高内聚、低耦合"的原则，将系统按功能职责划分为核心模块、通用模块和业务模块三大类。

```
ruoyi-vue-pro/
├── yudao-dependencies/       # 【核心】BOM 依赖管理
├── yudao-framework/          # 【核心】框架层
├── yudao-server/             # 【核心】启动模块
│
├── yudao-module-system/      # 【通用】系统模块
├── yudao-module-infra/       # 【通用】基础设施模块
├── yudao-module-member/      # 【通用】会员模块
├── yudao-module-bpm/         # 【通用】工作流模块
├── yudao-module-pay/         # 【通用】支付模块
├── yudao-module-report/      # 【通用】数据报表模块
├── yudao-module-mp/          # 【通用】微信公众号模块
│
├── yudao-module-mall/        # 【业务】商城模块
├── yudao-module-crm/         # 【业务】CRM 模块
├── yudao-module-erp/         # 【业务】ERP 模块
├── yudao-module-wms/         # 【业务】WMS 模块
├── yudao-module-mes/         # 【业务】MES 模块
├── yudao-module-hrm/         # 【业务】HRM 模块
├── yudao-module-fms/         # 【业务】FMS 模块
├── yudao-module-ai/          # 【业务】AI 大模型模块
├── yudao-module-iot/         # 【业务】IoT 物联网模块
└── yudao-module-im/          # 【业务】IM 即时通讯模块
```

---

## 一、核心模块

核心模块是系统的基础支撑，提供依赖管理、框架能力和启动入口。

### 1.1 yudao-dependencies（依赖管理）

**模块定位**：BOM（Bill of Materials）依赖管理

**核心职责**：
- 统一管理整个项目的依赖版本
- 确保各模块依赖版本一致性
- 简化依赖配置，避免版本冲突

**主要依赖版本**：
| 依赖 | 版本 |
|------|------|
| Spring Boot | 4.1.0 |
| MyBatis Plus | 3.5.16 |
| Redisson | 4.6.1 |
| Flowable | 8.0.0 |
| Knife4j | 4.5.0 |
| Hutool | 5.8.46 / 6.0.0-M22 |
| Lombok | 1.18.46 |
| MapStruct | 1.6.3 |

### 1.2 yudao-framework（框架层）

**模块定位**：技术框架层，提供基础设施能力

**核心职责**：
- 封装通用技术组件
- 提供开箱即用的 Spring Boot Starter
- 统一技术实现标准

**子模块列表**：

| 子模块 | 功能说明 |
|--------|---------|
| **yudao-common** | 通用工具类、枚举、异常、常量定义 |
| **yudao-spring-boot-starter-web** | Web 相关配置，全局异常处理、跨域、序列化 |
| **yudao-spring-boot-starter-security** | 安全认证，基于 Spring Security + Token |
| **yudao-spring-boot-starter-mybatis** | MyBatis Plus 配置、数据权限、多租户 |
| **yudao-spring-boot-starter-redis** | Redis 配置、Redisson 分布式锁、缓存 |
| **yudao-spring-boot-starter-excel** | Excel 导入导出，基于 EasyExcel |
| **yudao-spring-boot-starter-job** | 定时任务，支持 Quartz、XXL-Job |
| **yudao-spring-boot-starter-mq** | 消息队列，支持 Redis/RabbitMQ/Kafka/RocketMQ |
| **yudao-spring-boot-starter-websocket** | WebSocket 实时通信 |
| **yudao-spring-boot-starter-monitor** | 监控配置，Actuator、SkyWalking |
| **yudao-spring-boot-starter-protection** | 保护机制，限流、熔断 |
| **yudao-spring-boot-starter-test** | 测试工具，单元测试支持 |
| **yudao-spring-boot-starter-biz-tenant** | 多租户支持 |
| **yudao-spring-boot-starter-biz-data-permission** | 数据权限 |
| **yudao-spring-boot-starter-biz-ip** | IP 地址解析 |

**模块依赖原则**：
- ✅ 框架模块之间可以相互依赖
- ❌ 框架模块不可依赖业务模块

### 1.3 yudao-server（启动模块）

**模块定位**：应用启动入口

**核心职责**：
- 整合所有业务模块
- 提供 RESTful API 入口
- 管理应用配置和启动

**特点**：
- 本质上是一个空壳容器
- 通过 Maven 依赖引入需要的业务模块
- 支持按需引入，实现模块化部署

**默认启用的模块**：
- yudao-module-system（系统模块）
- yudao-module-infra（基础设施模块）

**可选启用的模块**（需取消注释）：
- yudao-module-member（会员模块）
- yudao-module-bpm（工作流模块）
- yudao-module-pay（支付模块）
- yudao-module-mall（商城模块）
- yudao-module-crm（CRM 模块）
- yudao-module-erp（ERP 模块）
- yudao-module-ai（AI 模块）
- yudao-module-iot（IoT 模块）
- 等等...

---

## 二、通用模块

通用模块提供跨业务领域的通用能力，支撑上层业务系统。

### 2.1 yudao-module-system（系统模块）

**模块定位**：系统基础功能，支撑核心业务

**核心职责**：
- 用户管理、角色管理、权限管理
- 部门管理、岗位管理
- 菜单管理、字典管理
- 租户管理（SaaS 多租户）
- 操作日志、登录日志
- 短信管理、邮件管理
- 站内信、通知公告

**主要功能**：

| 功能 | 描述 |
|------|------|
| 用户管理 | 用户增删改查、分配角色、重置密码 |
| 角色管理 | 角色权限分配、数据范围设置 |
| 菜单管理 | 菜单配置、按钮权限、操作权限 |
| 部门管理 | 组织架构树形结构、数据权限 |
| 租户管理 | SaaS 多租户、租户套餐 |
| 短信管理 | 短信渠道、模板、日志 |
| 邮件管理 | 邮箱账号、模板、发送日志 |
| 操作日志 | 操作记录、查询审计 |
| 登录日志 | 登录记录、异常登录监控 |

**技术特点**：
- 基于 Spring Security 实现权限控制
- 使用 `@PreAuthorize` 注解控制接口权限
- 使用 `@DataPermission` 注解控制数据权限
- 支持多租户，自动注入租户条件

### 2.2 yudao-module-infra（基础设施模块）

**模块定位**：基础设施运维与管理

**核心职责**：
- 代码生成器
- 文件管理（本地、OSS、S3）
- 配置管理
- 定时任务管理
- API 接口文档
- 服务器监控

**主要功能**：

| 功能 | 描述 |
|------|------|
| 代码生成 | 一键生成 Java、Vue、SQL 代码 |
| 文件管理 | 文件上传、下载、预览 |
| 配置管理 | 系统配置、动态配置 |
| 定时任务 | 任务管理、任务日志、执行监控 |
| 数据库文档 | 数据库表结构文档生成 |
| 服务器监控 | 服务器状态、JVM 监控 |

### 2.3 yudao-module-member（会员模块）

**模块定位**：会员中心，C 端用户管理

**核心职责**：
- 会员注册、登录、认证
- 会员信息管理
- 会员等级、积分
- 会员地址管理

**主要功能**：

| 功能 | 描述 |
|------|------|
| 会员管理 | 会员注册、信息维护 |
| 会员等级 | 等级配置、升级规则 |
| 积分管理 | 积分获取、消耗、查询 |
| 收货地址 | 地址管理、默认地址 |

### 2.4 yudao-module-bpm（工作流模块）

**模块定位**：业务流程管理（BPM）

**核心职责**：
- 流程定义、流程设计
- 表单配置
- 流程实例管理
- 任务中心（待办、已办、我的申请）

**技术栈**：
- 基于 Flowable 8.0.0 实现
- 支持双设计器：BPMN 设计器 + 仿钉钉/飞书设计器

**主要功能**：

| 功能 | 描述 |
|------|------|
| 流程设计 | 可视化流程设计、表单配置 |
| 流程实例 | 流程发起、查询、管理 |
| 任务中心 | 待办任务、已办任务、我的申请 |
| 流程操作 | 会签、或签、驳回、转办、委派、加签 |
| 流程监控 | 流程图查看、任务跟踪 |

**特色功能**：
- ✅ 会签、或签、依次审批
- ✅ 驳回、转办、委派、加签、减签
- ✅ 超时审批、自动提醒
- ✅ 父子流程、条件分支、并行分支
- ✅ 表单权限配置

### 2.5 yudao-module-pay（支付模块）

**模块定位**：支付能力，统一支付接入

**核心职责**：
- 支付渠道管理
- 支付订单管理
- 退款订单管理
- 回调通知管理

**支持的支付渠道**：
- 支付宝支付
- 微信支付
- 其他第三方支付

**主要功能**：

| 功能 | 描述 |
|------|------|
| 应用管理 | 配置支付应用、渠道配置 |
| 支付订单 | 创建支付、查询支付、支付回调 |
| 退款订单 | 创建退款、查询退款、退款回调 |
| 回调通知 | 支付/退款回调通知记录 |

### 2.6 yudao-module-report（数据报表模块）

**模块定位**：数据可视化报表

**核心职责**：
- 报表设计器
- 大屏设计器
- 图形设计器
- 打印设计器

**技术栈**：
- 基于积木报表实现

**主要功能**：

| 功能 | 描述 |
|------|------|
| 报表设计 | 拖拽式报表设计 |
| 大屏设计 | 数据大屏可视化 |
| 图形设计 | 图表可视化 |
| 打印设计 | 打印模板设计 |

### 2.7 yudao-module-mp（微信公众号模块）

**模块定位**：微信公众号管理

**核心职责**：
- 公众号账号管理
- 菜单管理
- 粉丝管理
- 消息管理
- 自动回复
- 素材管理
- 模板消息

**主要功能**：

| 功能 | 描述 |
|------|------|
| 账号管理 | 公众号接入、配置 |
| 菜单管理 | 自定义菜单 |
| 粉丝管理 | 粉丝列表、标签管理 |
| 消息管理 | 消息接收、回复 |
| 自动回复 | 关键词自动回复 |
| 素材管理 | 图文素材、图片素材 |
| 模板消息 | 模板消息发送 |

---

## 三、业务模块

业务模块提供垂直领域的业务系统，可根据需求按需引入。

### 3.1 yudao-module-mall（商城模块）

**模块定位**：电子商城系统

**模块组成**：
- product（商品模块）
- promotion（营销模块）
- trade（交易模块）
- statistics（统计模块）

**主要功能**：

| 功能 | 描述 |
|------|------|
| 商品管理 | 商品分类、商品信息、规格属性 |
| 营销管理 | 优惠券、秒杀、拼团、砍价 |
| 交易管理 | 订单管理、购物车、售后 |
| 统计分析 | 销售统计、商品统计、流量统计 |

### 3.2 yudao-module-crm（CRM 模块）

**模块定位**：客户关系管理系统

**核心职责**：
- 客户管理
- 联系人管理
- 商机管理
- 合同管理
- 回款管理

**主要功能**：

| 功能 | 描述 |
|------|------|
| 客户管理 | 客户信息、客户跟进、客户公海 |
| 联系人管理 | 联系人信息、联系人跟进 |
| 商机管理 | 商机创建、商机推进、商机分析 |
| 合同管理 | 合同创建、合同审批、合同归档 |
| 回款管理 | 回款计划、回款记录 |

### 3.3 yudao-module-erp（ERP 模块）

**模块定位**：企业资源计划系统

**核心职责**：
- 采购管理
- 销售管理
- 库存管理
- 财务管理
- 产品管理

**主要功能**：

| 功能 | 描述 |
|------|------|
| 采购管理 | 采购订单、采购入库、采购退货 |
| 销售管理 | 销售订单、销售出库、销售退货 |
| 库存管理 | 库存查询、库存调拨、库存盘点 |
| 财务管理 | 应收应付、费用管理 |
| 产品管理 | 产品信息、产品分类 |

### 3.4 yudao-module-wms（WMS 模块）

**模块定位**：仓库管理系统

**核心职责**：
- 仓库管理
- 物料管理
- 库存管理
- 入库管理
- 出库管理
- 移库管理
- 盘库管理

**主要功能**：

| 功能 | 描述 |
|------|------|
| 仓库管理 | 仓库配置、库位管理 |
| 物料管理 | 物料信息、物料分类 |
| 库存管理 | 库存查询、库存预警 |
| 入库管理 | 采购入库、生产入库、其他入库 |
| 出库管理 | 销售出库、生产出库、其他出库 |
| 移库管理 | 库位调拨 |
| 盘库管理 | 盘点任务、盘点差异处理 |

### 3.5 yudao-module-mes（MES 模块）

**模块定位**：制造执行系统

**核心职责**：
- 基础数据管理
- 排班日历
- 设备管理
- 工具管理
- 生产管理
- 质量管理
- 仓库管理

**主要功能**：

| 功能 | 描述 |
|------|------|
| 基础数据 | 工厂、车间、产线、工位 |
| 排班日历 | 班次配置、排班计划 |
| 设备管理 | 设备信息、设备维护 |
| 工具管理 | 工具信息、工具使用 |
| 生产管理 | 生产订单、生产排程、生产执行 |
| 质量管理 | 质检方案、质检记录 |

### 3.6 yudao-module-hrm（HRM 模块）

**模块定位**：人力资源管理系统

**核心职责**：
- 员工管理
- 招聘管理
- 考勤管理
- 薪资管理
- 社保管理
- 绩效管理

**主要功能**：

| 功能 | 描述 |
|------|------|
| 员工管理 | 员工档案、员工入职、员工离职 |
| 招聘管理 | 招聘需求、招聘计划、面试管理 |
| 考勤管理 | 考勤记录、请假审批、加班审批 |
| 薪资管理 | 薪资结构、薪资核算、薪资发放 |
| 社保管理 | 社保方案、社保缴纳 |
| 绩效管理 | 绩效方案、绩效考核 |

### 3.7 yudao-module-fms（FMS 模块）

**模块定位**：财务管理系统

**核心职责**：
- 凭证管理
- 账簿管理
- 报表管理
- 结账管理

**主要功能**：

| 功能 | 描述 |
|------|------|
| 凭证管理 | 凭证录入、凭证审核、凭证查询 |
| 账簿管理 | 总账、明细账、余额表 |
| 报表管理 | 资产负债表、利润表、现金流量表 |
| 结账管理 | 期末结账、反结账 |

### 3.8 yudao-module-ai（AI 大模型模块）

**模块定位**：AI 大模型集成平台

**核心职责**：
- AI 聊天对话
- AI 绘图
- AI 音乐生成
- AI 写作
- 思维导图生成

**已接入的模型**：
- OpenAI（GPT 系列）
- 阿里云通义千问
- 百度文心一言
- 讯飞星火
- 智谱 AI
- DeepSeek
- Ollama 本地模型
- 其他主流大模型

**主要功能**：

| 功能 | 描述 |
|------|------|
| AI 聊天 | 多模型对话、对话历史、对话角色 |
| AI 绘图 | 文生图、图生图 |
| AI 音乐 | 音乐生成、音乐编辑 |
| AI 写作 | 文章生成、内容优化 |
| 思维导图 | 自动生成思维导图 |

### 3.9 yudao-module-iot（IoT 物联网模块）

**模块定位**：物联网平台

**核心职责**：
- 设备管理
- 设备接入
- 数据采集
- 设备监控

**主要功能**：

| 功能 | 描述 |
|------|------|
| 设备管理 | 设备注册、设备配置、设备状态 |
| 设备接入 | MQTT 协议、设备认证 |
| 数据采集 | 设备数据上报、数据存储 |
| 设备监控 | 设备在线状态、设备异常告警 |

### 3.10 yudao-module-im（IM 即时通讯模块）

**模块定位**：即时通讯系统

**核心职责**：
- 单聊、群聊
- 消息收发
- 消息撤回
- 消息已读

**主要功能**：

| 功能 | 描述 |
|------|------|
| 单聊 | 一对一聊天、消息发送 |
| 群聊 | 群组管理、群消息 |
| 消息管理 | 消息发送、消息撤回、消息已读 |
| 在线状态 | 用户在线状态显示 |

---

## 四、模块依赖关系

### 4.1 依赖原则

```
业务模块 → 框架模块 → 基础模块
    ↓           ↓
  不可相互依赖  可以相互依赖
```

**原则说明**：
1. 业务模块（yudao-module-*）依赖框架模块（yudao-framework）
2. 业务模块之间**不可**相互依赖
3. 框架模块之间可以相互依赖
4. 所有模块依赖 yudao-dependencies 进行版本管理

### 4.2 典型依赖关系

```xml
<!-- 业务模块依赖示例 -->
<dependencies>
    <!-- 依赖框架模块 -->
    <dependency>
        <groupId>cn.iocoder.boot</groupId>
        <artifactId>yudao-spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>cn.iocoder.boot</groupId>
        <artifactId>yudao-spring-boot-starter-mybatis</artifactId>
    </dependency>
    <dependency>
        <groupId>cn.iocoder.boot</groupId>
        <artifactId>yudao-spring-boot-starter-redis</artifactId>
    </dependency>
</dependencies>
```

---

## 五、模块启用指南

### 5.1 按需启用模块

在 `yudao-server/pom.xml` 中，取消注释即可启用对应模块：

```xml
<!-- 启用会员模块 -->
<dependency>
    <groupId>cn.iocoder.boot</groupId>
    <artifactId>yudao-module-member</artifactId>
    <version>${revision}</version>
</dependency>

<!-- 启用工作流模块 -->
<dependency>
    <groupId>cn.iocoder.boot</groupId>
    <artifactId>yudao-module-bpm</artifactId>
    <version>${revision}</version>
</dependency>
```

### 5.2 模块启用注意事项

1. **数据库初始化**：启用新模块后，需要执行对应的 SQL 脚本
2. **Redis 缓存**：部分模块需要 Redis 支持
3. **第三方服务**：部分模块需要配置第三方服务（如 AI 模块需要配置 API Key）
4. **资源消耗**：每启用一个模块，会增加应用启动时间和内存消耗

---

## 六、模块扩展开发

### 6.1 新建业务模块

推荐使用项目内置的代码生成器快速创建模块：

1. 访问：系统工具 → 代码生成
2. 配置数据库表
3. 生成代码：Entity、Mapper、Service、Controller、VO
4. 将生成的代码复制到新模块中

### 6.2 模块命名规范

```
yudao-module-{业务领域}
├── yudao-module-{业务领域}-api      # API 接口定义
└── yudao-module-{业务领域}-biz      # 业务实现
```

**示例**：
```
yudao-module-crm/
├── yudao-module-crm-api/     # CRM 接口定义
└── yudao-module-crm-biz/     # CRM 业务实现
```

---

## 七、相关文档

- [项目打包部署指南](./intro-deploy.md)
- [官方文档](https://doc.iocoder.cn)
- [快速启动](https://doc.iocoder.cn/quick-start)
- [模块迁移文档](https://doc.iocoder.cn/migrate-module)
