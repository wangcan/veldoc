# LTP Gateway 项目介绍

## 项目概述

这是一个基于 **Spring Cloud Gateway** 的微服务 API 网关项目，为六品堂在线教育平台提供统一的入口，负责请求路由、身份认证、熔断保护等核心功能。

## 技术栈

| 技术组件 | 版本 | 用途 |
|---------|------|------|
| Spring Boot | 2.6.6 | 基础框架 |
| Spring Cloud Gateway | 3.1.1 | API 网关核心 |
| Nacos | 2021.0.1.0 | 服务注册与发现、配置中心 |
| Redisson | 3.17.0 | Redis 客户端 |
| JWT (jjwt) | 0.9.1 | Token 认证 |
| Resilience4j | 2.1.1 | 熔断器 |
| Log4j2 | - | 日志框架 |
| Fastjson | 2.0.4.graal | JSON 处理 |

## 项目结构

```
com.liupin.gateway/
├── GatewayApplication.java          # 主入口类
├── circuitBreaker/                  # 熔断器配置
│   ├── CircuitBreakerStatePrinter.java
│   ├── CircuitBreakerStatePrinterFactory.java
│   └── DefaultCustomizer.java       # 熔断器默认配置
├── component/                       # 核心组件
│   ├── ApiResponse.java             # 统一响应封装
│   ├── LoginInfo.java               # 登录信息实体
│   ├── ResponseInfo.java            # 响应信息枚举
│   ├── SystemPlatEnum.java          # 系统平台枚举
│   ├── TerminalExclusiveConstant.java # 终端互斥常量
│   └── TokenConstant.java           # Token 常量
├── config/                          # 配置类
│   ├── CustomerErrorWebExceptionConfiguration.java
│   ├── CustomerRedisAutoConfiguration.java
│   ├── GlobalExceptionHandler.java  # 全局异常处理
│   ├── JsonErrorWebExceptionHandler.java
│   ├── PrometheusConfiguration.java
│   └── RedissonConfig.java          # Redis 配置
├── constant/                        # 常量定义
├── controller/                      # 控制器
│   └── HeartbeatController.java     # 心跳检测
├── exception/                       # 异常定义
│   ├── BizException.java
│   └── JwtTokenAuthException.java
├── filter/                          # 过滤器
│   ├── CustomizedGatewayFilterFactory.java
│   ├── JwtTokenGatewayFilter.java   # JWT 认证过滤器
│   └── RequestTimeLoggerFilter.java # 请求日志过滤器
├── properties/                      # 属性配置
│   └── SkipPathProperties.java      # 免登录路径配置
├── route/                           # 路由配置
│   ├── DynamicRouteEntity.java      # 动态路由实体
│   └── DynamicRouteListener.java    # 动态路由监听器
└── tool/                            # 工具类
    ├── IpUtil.java
    ├── SpringUtils.java
    └── SystemClock.java
```

## 核心功能模块

### 1. JWT Token 认证 (`JwtTokenGatewayFilter`)

#### 工作流程
1. **请求拦截**：所有请求首先经过 JWT Token 过滤器
2. **白名单检查**：检查请求路径是否在免登录列表中
3. **Token 提取**：从请求头 `Authorization` 中提取 Bearer Token
4. **系统标识获取**：从请求头 `System` 获取当前系统标识
5. **Token 解析**：根据系统标识获取对应的密钥，解析 JWT Token
6. **用户信息提取**：从 Token 中提取用户登录信息（LoginInfo）
7. **终端互斥检查**：验证用户是否在其他设备登录（同端互斥）
8. **请求转发**：认证通过后将请求转发到后端服务

#### 多系统平台支持
网关支持多个业务系统，每个系统有独立的密钥和平台ID：

| 系统 | 系统标识 | 平台ID | 说明 |
|------|---------|--------|------|
| 碑帖 | tablet | 1 | 碑帖应用 |
| 教培 | training | 2 | 教培后台 |
| 乐写字 | smartPen | 3 | 智能笔应用 |
| 在线教育 | eduOnline | 4 | 在线教育平台 |
| AI测评 | aiScore | 5 | 六六写字测评 |
| 点评中台 | commentMiddle | 6 | 点评中台 |
| 施强平台 | sqPlat | 8 | 施强平台 |
| 六品智学 | art | 11 | 六品智学 |
| 六品堂练字 | lpt_write | 12 | 六品堂练字 |
| 定制字帖 | copybook | 13 | 自定义字帖小程序 |
| 浙美墨宝 | zhemeimobao | 14 | 浙美墨宝小程序 |
| 毛笔定制 | maobiCustom | 15 | 毛笔定制 |

### 2. 动态路由管理 (`DynamicRouteListener`)

#### 核心机制
- **配置源**：从 Nacos 配置中心读取路由配置（dataId: `gateway-routes`）
- **动态监听**：监听 Nacos 配置变化，实现路由动态更新
- **路由结构**：每个路由包含 ID、URI、断言（Predicates）、过滤器（Filters）

#### 路由配置示例
```json
[
  {
    "id": "training-manager",
    "uri": "lb://training-manager",
    "predicates": [
      "Path=/trainingAdmin/**"
    ],
    "filters": [
      "StripPrefix=1",
      "CustomizedFilterBean=jwtTokenGatewayFilter"
    ],
    "metadata": {
      "response-timeout": 15000
    }
  }
]
```

#### 工作流程
1. 应用启动时，监听 Nacos 配置变化
2. 从 Nacos 加载初始路由配置
3. 解析 JSON 配置为 RouteDefinition
4. 通过 RouteDefinitionWriter 更新路由表
5. 发布 RefreshRoutesEvent 事件刷新路由缓存
6. 当配置变化时，自动重新加载并更新路由

### 3. 熔断器保护 (`DefaultCustomizer`)

#### 熔断器配置
- **滑动窗口类型**：基于时间的滑动窗口
- **窗口大小**：10 秒
- **最小调用次数**：5 次（达到此数量才开始统计）
- **失败率阈值**：50%（失败率达到此值触发熔断）
- **熔断等待时间**：5 秒（熔断后等待多久转为半开状态）
- **半开状态允许调用次数**：5 次
- **异常处理**：所有异常都视为失败

#### 熔断器状态
1. **关闭（CLOSED）**：正常状态，请求正常转发
2. **打开（OPEN）**：熔断状态，拒绝请求，快速失败
3. **半开（HALF_OPEN）**：允许部分请求通过，测试服务是否恢复

### 4. 请求日志记录 (`RequestTimeLoggerFilter`)

#### 功能特性
- 记录每个请求的处理时间
- 记录请求的路由 ID、HTTP 方法和路径
- 作为全局过滤器，优先级最低（最后执行）

#### 日志示例
```
[training-manager] POST /trainingAdmin/api/login Time: 23ms
```

### 5. 终端互斥登录

#### 实现机制
- 使用 Redis 存储用户的登录 Token
- Key 格式：`user:terminal:exclusive:{userId}:{terminalType}`
- 用户登录时，将 Token 的 hashCode 存入 Redis 列表
- 每次请求验证当前 Token 是否在 Redis 列表中
- 不在列表中则表示用户已在其他设备登录，拒绝请求

#### 白名单机制
- 部分平台（platId）不参与终端互斥检查
- 部分用户（白名单用户）不受终端互斥限制

### 6. 统一响应格式 (`ApiResponse`)

```java
{
  "status": 0,          // 0=成功，其他=失败
  "msg": "success",     // 响应消息
  "data": {},           // 响应数据
  "totalNum": 100,      // 总数（分页）
  "pageIndex": 1,       // 当前页（分页）
  "pageSize": 10,       // 每页大小（分页）
  "totalPage": 10       // 总页数（分页）
}
```

## 工作原理详解

### 请求处理流程

```
客户端请求
    ↓
[RequestTimeLoggerFilter] 记录开始时间
    ↓
[JwtTokenGatewayFilter] JWT 认证
    ├→ 检查是否免登录路径 → 是 → 跳过认证
    ├→ 提取 Token 和系统标识
    ├→ 解析 Token 获取用户信息
    ├→ 检查终端互斥
    └→ 认证失败 → 抛出异常
    ↓
[路由匹配] 根据 Predicates 匹配路由
    ↓
[过滤器链] 执行路由特定的过滤器
    ├→ StripPrefix：去除路径前缀
    ├→ AddRequestHeader：添加请求头
    └→ 其他自定义过滤器
    ↓
[负载均衡] 通过 Nacos 发现服务实例
    ↓
[转发请求] 将请求转发到后端服务
    ↓
[熔断器保护] 如果后端服务异常，触发熔断
    ↓
[返回响应] 将响应返回给客户端
    ↓
[RequestTimeLoggerFilter] 记录请求耗时
```

### Nacos 配置中心集成

#### 配置加载流程
1. 应用启动时连接 Nacos Server
2. 加载 `bootstrap.yml` 中配置的 Nacos 地址
3. 根据 `spring.profiles.active` 加载对应环境配置
4. 监听动态路由配置 `gateway-routes`
5. 监听免登录路径配置 `skipPathConfig.yaml`

#### 配置文件结构
```
bootstrap.yml           # 主配置文件
bootstrap-dev.yml       # 开发环境配置
bootstrap-test.yml      # 测试环境配置
bootstrap-pro.yml       # 生产环境配置
bootstrap-k8s.yml       # K8s 环境配置
```

### 服务发现与负载均衡

- 使用 Nacos 作为服务注册中心
- 使用 Spring Cloud LoadBalancer 进行负载均衡
- 路由 URI 格式：`lb://service-name`（表示从 Nacos 查找服务）

## 核心配置说明

### 网关配置 (`bootstrap.yml`)

```yaml
server:
  port: 8888                    # 网关端口

spring:
  application:
    name: liupin-api-gateway    # 服务名称
  cloud:
    gateway:
      httpclient:
        connect-timeout: 3000   # 连接超时 3 秒
        response-timeout: 10s   # 响应超时 10 秒
      globalcors:               # 全局 CORS 配置
        cors-configurations:
          '[/**]':
            allow-credentials: true
            allowed-origin-patterns: "*"
            allowed-headers: "*"
            allowed-methods: "*"
            max-age: 3600

dynamic.routes:
  data-id: gateway-routes       # 动态路由配置 dataId
  group: DEFAULT_GROUP          # Nacos 配置分组
```

### Redis 配置 (`RedissonConfig`)

根据不同环境配置 Redis 连接：
- **开发环境**：127.0.0.1:6379
- **测试环境**：192.168.203.1:6379
- **生产环境**：172.17.0.8:6380

连接池配置：
- 连接池大小：16
- 最小空闲连接数：8
- 超时时间：5000ms

## 部署架构

### 部署方式
- 支持 Docker 容器化部署
- 支持 Kubernetes 集群部署
- 支持传统虚拟机部署

### 高可用架构
```
                    Nginx/SLB
                        ↓
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
   Gateway-1       Gateway-2       Gateway-3
        ↓               ↓               ↓
        └───────────────┼───────────────┘
                        ↓
                   Nacos Cluster
                        ↓
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
   Service-A        Service-B        Service-C
```

### 环境支持
- **dev**：开发环境
- **test**：测试环境
- **pro**：生产环境
- **k8s**：Kubernetes 环境

## 安全机制

### 1. JWT Token 认证
- 使用 HMAC-SHA256 签名算法
- 每个系统使用独立的密钥
- Token 包含用户 ID、登录信息等
- Token 过期后需重新登录

### 2. 同端互斥登录
- 同一用户在同一终端类型只能保持一个登录状态
- 新登录会踢掉旧的登录状态
- Redis 存储登录状态，支持分布式部署

### 3. CORS 跨域配置
- 允许所有来源（allowed-origin-patterns: "*"）
- 允许携带凭证（allow-credentials: true）
- 允许所有请求头和请求方法
- 预检请求缓存 3600 秒

### 4. 白名单机制
- 支持配置免登录路径
- 支持按系统配置不同的白名单
- 路径匹配支持 Ant 风格通配符

## 监控与日志

### 日志配置
- 使用 Log4j2 作为日志框架
- 支持异步日志（Disruptor）
- 记录请求耗时、路由信息

### 健康检查
- 提供 `/` 心跳接口
- 用于负载均衡器健康检查

### 监控集成
- 支持 Prometheus 指标采集（已注释）
- 支持 Spring Boot Admin 监控

## 性能优化

### 1. 异步非阻塞
- 基于 WebFlux 响应式编程
- 使用 Netty 作为服务器
- 非阻塞 I/O，高并发性能

### 2. 连接池优化
- HTTP 客户端连接池
- Redis 连接池配置
- 合理的超时设置

### 3. 熔断降级
- 保护后端服务
- 快速失败，避免雪崩
- 自动恢复机制

## 扩展性设计

### 1. 自定义过滤器
- 实现 `GatewayFilter` 接口
- 通过 `CustomizedGatewayFilterFactory` 注册
- 支持在路由配置中使用

### 2. 动态路由
- 无需重启即可更新路由
- 支持路由优先级排序
- 支持丰富的断言和过滤器

### 3. 多系统支持
- 通过 System 标识区分不同系统
- 每个系统独立的密钥配置
- 统一的用户认证流程

## 常见问题

### Q1: Token 认证失败怎么办？
**A**: 检查以下几点：
1. Token 是否过期
2. 请求头是否包含正确的 `Authorization` 和 `System`
3. Token 格式是否正确（Bearer Token）
4. 系统标识是否正确

### Q2: 如何添加新的免登录路径？
**A**: 在 Nacos 配置中心的 `skipPathConfig.yaml` 中添加路径配置。

### Q3: 如何添加新的路由？
**A**: 在 Nacos 配置中心的 `gateway-routes` 配置中添加新的路由定义，网关会自动更新。

### Q4: 熔断器触发后如何恢复？
**A**: 熔断器会在 5 秒后自动转为半开状态，允许部分请求通过。如果这些请求成功，熔断器会关闭；如果失败率仍然很高，熔断器会继续保持打开状态。

## 总结

LTP Gateway 是一个功能完善的微服务 API 网关，具有以下特点：

1. **统一入口**：所有微服务请求通过网关统一接入
2. **安全认证**：JWT Token 认证 + 同端互斥登录
3. **动态路由**：基于 Nacos 的动态路由配置
4. **熔断保护**：Resilience4j 熔断器保护后端服务
5. **多系统支持**：支持多个业务系统，每个系统独立配置
6. **高可用性**：支持集群部署，无单点故障
7. **易扩展**：支持自定义过滤器、动态路由更新

该项目为六品堂在线教育平台的微服务架构提供了坚实的网关基础设施。
