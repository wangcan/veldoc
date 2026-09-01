# 留品项目模块介绍

## 项目概述

留品项目(liupin-parent)是一个基于 Spring Boot 2.3.4.RELEASE 和 Spring Cloud Hoxton.SR8 构建的微服务架构项目。项目采用 Spring Cloud Alibaba 2.2.3.RELEASE 作为微服务解决方案，使用 Nacos 作为服务注册与配置中心，实现了服务网关、服务治理、监控管理等完整的微服务生态体系。

项目采用 Maven 多模块架构，按照**核心模块**、**通用模块**、**业务模块**三个层次进行组织，实现了清晰的架构分层和模块解耦。

---

## 一、核心模块

核心模块是系统运行的基础设施，提供了微服务架构的核心能力。

### 1.1 liupin-api-gateway (API网关)

**模块定位**: 系统统一入口，流量网关

**主要功能**:
- 作为整个微服务系统的统一入口，所有外部请求通过网关路由到后端服务
- 提供统一的认证鉴权、流量控制、熔断降级等能力
- 集成 Nacos 服务发现，实现动态路由
- 集成 Sentinel 实现流量控制和熔断
- 负载均衡策略支持

**技术栈**:
- Spring Cloud Gateway
- Spring Cloud LoadBalancer
- Spring Cloud Alibaba Nacos Discovery/Config
- Spring Cloud Circuit Breaker Sentinel
- Redis (缓存、限流)

**依赖关系**:
- 依赖 `liupin-common` 通用模块
- 依赖 Spring Cloud Gateway 核心组件

**启动类**: `com.liupin.gateway.GateWayApplication`

---

### 1.2 liupin-common (通用工具模块)

**模块定位**: 基础工具库，通用组件

**主要功能**:
- 提供全局统一的工具类和基础组件
- 统一异常处理机制
- 统一API响应格式
- 统一日志记录（基于log4j2）
- 统一注解支持（如日志、短信等）
- JWT Token 处理
- MyBatis 分页组件
- HTTP客户端工具
- 文件处理工具

**核心包结构**:
```
com.liupin.common
├── annotation      # 自定义注解（如@EnableAccessLog, @EnableSms）
├── api             # 统一API响应模型
├── aspect          # AOP切面（日志、限流等）
├── component       # 通用组件
├── configuration   # 自动配置类
├── constant        # 常量定义
├── exception       # 异常定义与处理
├── factory         # 工厂类
├── function        # 函数式接口
├── model           # 数据模型
├── properties      # 配置属性类
└── utils           # 工具类
```

**技术栈**:
- Lombok (简化代码)
- Fastjson (JSON处理)
- PageHelper (MyBatis分页)
- HttpClient (HTTP请求)
- Commons-Lang3 / Commons-IO (通用工具)
- Hutool (工具集)
- JWT (Token处理)
- XXL-Job (分布式调度)

**依赖关系**:
- 被所有业务模块依赖
- 无业务依赖，保持纯净

---

### 1.3 liupin-module-dependency (模块依赖管理)

**模块定位**: 业务模块依赖聚合，API契约层

**主要功能**:
- 定义业务模块对外暴露的接口契约（DTO、VO、Feign接口）
- 管理跨服务调用的依赖关系
- 降低服务间耦合度

**子模块**:
- **liupin-usercenter-module**: 用户中心模块接口契约
- **liupin-data-collector-module**: 数据收集器模块接口契约
- **liupin-evaluation-module**: 评测模块接口契约
- **liupin-smartpen-module**: 智能笔模块接口契约

**依赖关系**:
- 被各业务服务依赖，提供跨服务调用的接口定义
- 通过 Feign 实现服务间调用

---

## 二、通用模块

通用模块提供了可复用的技术能力组件，支持业务模块快速集成特定功能。

### 2.1 liupin-spring-boot-starters (Spring Boot Starter集合)

**模块定位**: 自定义Spring Boot Starter，第三方集成封装

**主要功能**:
- 封装第三方服务集成，简化业务模块集成难度
- 提供开箱即用的自动配置能力
- 统一管理第三方SDK依赖版本

**子模块列表**:

| Starter名称 | 功能说明 |
|------------|---------|
| **tencent-spring-boot-starter** | 腾讯云服务集成（COS对象存储、STS临时密钥） |
| **dingtalk-spring-boot-starter** | 钉钉集成（消息推送、用户同步等） |
| **xxl-job-spring-boot-starter** | XXL-Job分布式任务调度集成 |
| **liupin-websocket-spring-boot-starter** | WebSocket支持 |
| **liupin-pay-spring-boot-starter** | 支付功能集成 |
| **baidu-spring-boot-starter** | 百度服务集成 |
| **wechat-spring-boot-starter** | 微信服务集成（小程序、公众号） |
| **liupin-umeng-spring-boot-starter** | 友盟推送集成 |
| **gray-govern-spring-boot-starter** | 灰度发布治理 |

**技术特点**:
- 遵循 Spring Boot Starter 规范
- 提供自动配置类
- 支持 properties 配置

---

### 2.2 liupin-spring-boot-admin (Spring Boot监控管理)

**模块定位**: 应用监控管理平台

**主要功能**:
- 提供可视化的应用监控界面
- 查看各微服务的健康状态、JVM信息、配置信息等
- 实时监控应用运行状态
- 支持多环境配置（dev、test、pro）

**技术栈**:
- Spring Boot Admin Server
- Spring Boot Actuator

**启动类**: `com.liupin.springboot.admin.SpringBootAdminApp`

**访问端口**: 9999

**配置环境**:
- dev: 开发环境
- test: 测试环境
- uat: UAT环境
- pro: 生产环境

---

### 2.3 liupin-publish-plugin (发布插件)

**模块定位**: 自定义Maven插件，自动化部署工具

**主要功能**:
- 基于 Maven 插件机制，实现一键部署能力
- 支持 SSH 远程部署到服务器
- 自动化构建、上传、启动服务
- 支持多服务器并发部署
- 支持多环境部署（dev、test、uat、pro）

**核心类**:
- `PublishProjectMojo`: 发布项目主逻辑
- `SSHUtil` / `SSHCommandExecutor`: SSH远程命令执行
- `Server`: 服务器配置模型

**使用方式**:
```bash
mvn liupin-publish:publishProjectMojo -Doptions=项目路径,服务名
```

**部署流程**:
1. 检查 pom.xml 打包配置
2. 读取 application.yaml 中的发布配置
3. 根据环境获取目标服务器列表
4. 通过 SSH 上传 JAR 包到服务器
5. 执行远程启动脚本 `/run-server.sh remote_start`

**部署路径**: `/usr/local/liupin/liupin-service/`

---

### 2.4 liupin-msg-route-service (消息路由服务)

**模块定位**: 消息中间件路由服务

**主要功能**:
- 基于 RocketMQ 的消息路由服务
- 实现异步消息处理
- 支持服务间的异步通信
- 消息转发与分发

**技术栈**:
- Apache RocketMQ
- Spring Cloud OpenFeign
- Nacos 服务发现

**启动类**: `com.liupin.msgroute.MsgRouteApp`

---

## 三、业务模块

业务模块实现了具体的业务功能，根据业务领域划分为多个独立的微服务。

### 3.1 liupin-service (业务服务集合)

**模块定位**: 核心业务服务集合

#### 3.1.1 用户中心服务 (liupin-usercenter-service)

**业务域**: 用户管理、认证授权

**主要功能**:
- 用户注册、登录、认证
- 用户信息管理
- 权限管理
- 第三方登录集成

**启动类**: `com.liupin.usercenter.UserCenterApp`

**技术特点**:
- @EnableDiscoveryClient 服务注册发现
- @EnableFeignClients 服务调用
- @EnableAsync 异步处理
- @EnableSms 短信功能
- @EnableAccessLog 访问日志

---

#### 3.1.2 文件服务 (liupin-file-service)

**业务域**: 文件上传、存储、处理

**主要功能**:
- 文件上传下载
- 文件存储管理（对接腾讯云COS）
- 图片处理
- 文件访问控制

**启动类**: `com.liupin.file.FileApplication`

---

#### 3.1.3 搜索服务 (liupin-search-service)

**业务域**: 搜索引擎、全文检索

**主要功能**:
- 基于Elasticsearch的全文检索
- 商品搜索、内容搜索
- 搜索推荐
- 搜索统计分析

**启动类**: `com.liupin.search.SearchApplication`

---

#### 3.1.4 评测服务 (liupin-evaluation-service)

**业务域**: 书法评测、智能评测

**主要功能**:
- 书法作品评测
- 评分算法
- 评测报告生成

**启动类**: `com.liupin.evaluation.EvaluationApp`

---

#### 3.1.5 字帖服务 (liupin-copybook-service)

**业务域**: 字帖管理、字帖生成

**主要功能**:
- 字帖模板管理
- 字帖生成
- 字帖练习记录

**启动类**: `com.liupin.copybook.CopybookApp`

---

#### 3.1.6 社区服务 (liupin-community-service)

**业务域**: 社区功能、用户互动

**主要功能**:
- 社区帖子管理
- 用户互动
- 社区内容审核

**启动类**: `com.liupin.community.LptCommunityApp`

---

#### 3.1.7 消息服务 (liupin-message-service)

**业务域**: 消息推送、通知

**主要功能**:
- 站内消息
- 推送通知
- 消息模板管理

**启动类**: `com.liupin.message.MessageApp`

---

#### 3.1.8 商城服务 (liupin-mall-service)

**业务域**: 电商、订单

**主要功能**:
- 商品管理
- 订单管理
- 购物车
- 支付集成

**启动类**: `com.liupin.mall.MallApp`

---

#### 3.1.9 营销服务 (liupin-marketing-service)

**业务域**: 营销活动、优惠券

**主要功能**:
- 营销活动管理
- 优惠券管理
- 活动效果分析

**启动类**: `com.liupin.marketing.MarketingApp`

---

#### 3.1.10 智能笔服务 (liupin-smartpen-service)

**业务域**: 智能硬件、智能笔

**主要功能**:
- 智能笔数据接收
- 笔迹处理
- 实时书写

**启动类**: `com.liupin.smartpen.SmartpenServiceApplication`

---

#### 3.1.11 笔画服务 (liupin-stroke-service)

**业务域**: 笔画分析、笔画教学

**主要功能**:
- 笔画识别
- 笔画教学
- 笔画分析

**启动类**: `com.liupin.stroke.StrokeServiceApplication`

---

#### 3.1.12 评论服务 (liupin-comment-service)

**业务域**: 评论、评价

**主要功能**:
- 评论管理
- 点赞功能
- 评论审核

**启动类**: `com.liupin.comment.CommentApplication`

---

#### 3.1.13 定制服务 (liupin-custom-service)

**业务域**: 个性化定制

**主要功能**:
- 用户定制需求
- 定制方案管理

**启动类**: `com.liupin.custom.CustomApp`

---

#### 3.1.14 OpenCV服务 (liupin-opencv-service)

**业务域**: 图像处理、计算机视觉

**主要功能**:
- 图像识别
- 图像处理
- 计算机视觉算法

**启动类**: `com.liupin.opencv.OpencvApp`

---

#### 3.1.15 APP服务 (liupin-app-service)

**业务域**: 移动端API聚合

**主要功能**:
- APP端API接口
- 数据聚合
- 移动端适配

**启动类**: `com.liupin.lptapp.LptApp`

---

#### 3.1.16 OA服务 (liupin-oa-service)

**业务域**: 办公自动化

**主要功能**:
- 办公流程
- 审批管理
- 内部协作

**启动类**: `com.liupin.oa.OaApp`

---

### 3.2 liupin-sidecar (Sidecar代理服务)

**模块定位**: 异构语言服务代理

**主要功能**:
- 为PHP、Python等异构语言服务提供Spring Cloud集成能力
- 实现异构服务的服务注册与发现
- 提供健康检查、负载均衡等能力

**子模块列表**:

| Sidecar名称 | 说明 |
|------------|------|
| **tablet-php-sidecar** | 平板PHP服务代理 |
| **lamp-php-sidecar** | 灯PHP服务代理 |
| **training-php-sidecar** | 培训PHP服务代理 |
| **calligraphy-php-sidecar** | 书法PHP服务代理 |
| **edu-online-sidecar** | 在线教育服务代理 |
| **liupin-shop-sidecar** | 商店服务代理 |
| **comment-center-sidecar** | 评论中心代理 |
| **sms-php-sidecar** | 短信PHP服务代理 |
| **python-cut-photo-sidecar** | Python切图服务代理 |
| **python-evaluate-sidecar** | Python评测服务代理 |
| **python-identify-word-sidecar** | Python文字识别服务代理 |
| **python-fill-grid-sidecar** | Python填格服务代理 |
| **children-custompad-sidecar** | 儿童定制PAD服务代理 |
| **tablet-association-sidecar** | 平板社区服务代理 |
| **classprogram-php-sidecar** | 课程计划PHP服务代理 |
| **zb-php-sidecar** | 直播PHP服务代理 |

**技术原理**:
- 基于 Spring Cloud Sidecar 模式
- 代理异构语言的HTTP服务
- 实现服务的注册与发现
- 提供健康检查端点

---

### 3.3 liupin-data-collector (数据收集器)

**模块定位**: 数据采集、数据分析

**主要功能**:
- 业务数据采集
- 数据清洗与处理
- 数据存储到Elasticsearch
- 数据分析统计

**技术栈**:
- Elasticsearch 7.6.2
- Spring Boot Actuator
- Spring Boot Admin Client

**依赖模块**: `liupin-data-collector-module`

**启动类**: `com.liupin.collector.DataCollectorApp`

---

## 四、技术架构总览

### 4.1 技术栈

| 技术组件 | 版本 | 说明 |
|---------|------|------|
| Spring Boot | 2.3.4.RELEASE | 基础框架 |
| Spring Cloud | Hoxton.SR8 | 微服务框架 |
| Spring Cloud Alibaba | 2.2.3.RELEASE | 微服务组件 |
| Nacos | 2.2.3.RELEASE | 服务注册与配置中心 |
| Sentinel | 2.2.3.RELEASE | 流量控制、熔断降级 |
| Gateway | Hoxton.SR8 | API网关 |
| OpenFeign | Hoxton.SR8 | 服务调用 |
| RocketMQ | 4.7.1 | 消息队列 |
| Elasticsearch | 7.6.2 | 搜索引擎 |
| MySQL | - | 关系数据库 |
| Redis | - | 缓存 |
| MyBatis | 1.3.2 | ORM框架 |
| Druid | 1.1.20 | 数据库连接池 |
| XXL-Job | 2.2.0 | 分布式任务调度 |
| Log4j2 | 2.17.1 | 日志框架 |
| Lombok | 1.18.20 | 代码简化 |

### 4.2 模块依赖关系图

```
liupin-parent (父工程)
├── liupin-common (核心基础)
│   └── 被所有业务模块依赖
├── liupin-module-dependency (模块依赖)
│   ├── liupin-usercenter-module
│   ├── liupin-data-collector-module
│   ├── liupin-evaluation-module
│   └── liupin-smartpen-module
├── liupin-spring-boot-starters (Starter集合)
│   ├── tencent-spring-boot-starter
│   ├── dingtalk-spring-boot-starter
│   ├── xxl-job-spring-boot-starter
│   └── ... (其他starter)
├── liupin-api-gateway (API网关)
│   └── 依赖 liupin-common
├── liupin-service (业务服务)
│   ├── liupin-usercenter-service
│   ├── liupin-file-service
│   └── ... (其他业务服务)
├── liupin-sidecar (Sidecar代理)
│   └── 多个sidecar子模块
├── liupin-data-collector (数据收集)
├── liupin-msg-route-service (消息路由)
├── liupin-spring-boot-admin (监控管理)
└── liupin-publish-plugin (发布插件)
```

### 4.3 服务治理架构

```
                     ┌─────────────┐
                     │   客户端    │
                     └──────┬──────┘
                            │
                     ┌──────▼──────┐
                     │ API Gateway │ ← 流量入口、路由、鉴权
                     └──────┬──────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
       ┌──────▼──────┐ ┌───▼────┐ ┌──────▼──────┐
       │ 用户服务    │ │文件服务│ │ 其他服务... │
       └──────┬──────┘ └───┬────┘ └──────┬──────┘
              │             │             │
              └─────────────┼─────────────┘
                            │
                     ┌──────▼──────┐
                     │    Nacos    │ ← 服务注册、配置中心
                     └─────────────┘
                            │
              ┌─────────────┼─────────────┐
       ┌──────▼──────┐ ┌───▼────┐ ┌──────▼──────┐
       │   MySQL     │ │ Redis  │ │ RocketMQ    │
       └─────────────┘ └────────┘ └─────────────┘
```

---

## 五、环境配置说明

项目支持多环境配置，通过 `spring.profiles.active` 指定环境：

| 环境标识 | 环境名称 | 说明 |
|---------|---------|------|
| dev | 开发环境 | 本地开发调试 |
| test | 测试环境 | 功能测试 |
| uat | UAT环境 | 用户验收测试 |
| pro | 生产环境 | 生产部署 |

配置文件命名规范：
- `application.yaml`: 主配置文件
- `application-{env}.yaml`: 环境配置文件
- `bootstrap.yaml`: 启动配置（如Nacos配置）

---

## 六、模块开发规范

### 6.1 模块命名规范

- **业务服务**: `liupin-{业务域}-service`
- **Sidecar**: `{业务}-php-sidecar` / `{业务}-python-sidecar`
- **Starter**: `{技术/厂商}-spring-boot-starter`
- **模块依赖**: `liupin-{业务域}-module`

### 6.2 代码结构规范

```
com.liupin.{模块名}
├── controller    # 控制器
├── service       # 服务层
├── mapper        # 数据访问层
├── domain        # 领域模型
├── config        # 配置类
├── constant      # 常量
├── enums         # 枚举
├── utils         # 工具类
└── {Module}App   # 启动类
```

### 6.3 依赖管理规范

- 所有业务模块必须依赖 `liupin-common`
- 跨服务调用通过 `liupin-module-dependency` 定义的接口
- 第三方集成使用统一的 `starter`
- 避免循环依赖

---

## 七、总结

留品项目采用清晰的模块化架构，将功能划分为：

- **核心模块** (3个): 提供基础设施能力
- **通用模块** (4个): 提供可复用的技术组件
- **业务模块** (3大类，30+子模块): 实现具体业务功能

这种架构设计具有以下优势：

1. **职责清晰**: 核心层、通用层、业务层各司其职
2. **易于扩展**: 新增业务模块只需遵循规范即可
3. **降低耦合**: 通过模块依赖管理实现服务解耦
4. **技术统一**: 统一的技术栈和组件封装
5. **运维友好**: 统一的监控、部署工具支持

---

**文档版本**: v1.0
**更新时间**: 2026-08-31
**维护团队**: 留品技术团队
