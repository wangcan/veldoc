# lpt-sidecar 项目文档

## 1. 项目概述

**项目名称**: lpt-sidecar

**项目描述**: 字帖生成服务系统，主要用于姓名字帖和DIY字帖的生成、管理和分发。该系统支持多种字帖版式，集成了淘宝、抖音等第三方订单处理，实现了自动化的字帖生成流程。

**技术栈**:
- Java 1.8
- Spring Boot 2.7.11
- Gradle 构建工具
- MySQL 数据库
- Redis 缓存
- MyBatis Plus ORM框架
- Sa-Token 权限认证
- 腾讯云 COS 对象存储
- 微信小程序集成

---

## 2. 项目结构

### 2.1 目录结构

```
lpt-sidecar/
├── build.gradle              # Gradle构建配置
├── settings.gradle           # Gradle设置
├── gradlew                   # Gradle包装脚本(Unix)
├── gradlew.bat               # Gradle包装脚本(Windows)
├── .env                      # 环境变量配置(本地)
├── .env.example              # 环境变量配置示例
├── run-server.sh             # 服务启动脚本
├── generate.sh               # 字帖生成脚本
├── auto_delete.sh            # 自动清理脚本
├── src/
│   ├── main/
│   │   ├── java/com/liupin/utils/
│   │   │   ├── bean/         # 数据传输对象
│   │   │   ├── common/       # 公共类(上下文等)
│   │   │   ├── configuration/# 配置类
│   │   │   ├── constant/     # 常量定义
│   │   │   ├── entity/       # 实体类
│   │   │   ├── exception/    # 异常类
│   │   │   ├── mapper/       # MyBatis Mapper接口
│   │   │   ├── paint/        # 绘图相关
│   │   │   ├── properties/   # 配置属性类
│   │   │   ├── rest/         # 控制器层
│   │   │   │   └── admin/    # 管理后台控制器
│   │   │   ├── service/      # 服务层
│   │   │   │   ├── admin/    # 管理后台服务
│   │   │   │   └── PDFHandler/ # PDF处理
│   │   │   ├── util/         # 工具类
│   │   │   │   └── picture/  # 图片处理工具
│   │   │   └── wx/           # 微信相关
│   │   └── resources/
│   │       ├── application.yml        # 主配置
│   │       ├── application-dev.yml    # 开发环境配置
│   │       ├── application-test.yml   # 测试环境配置
│   │       ├── application-pro.yml    # 生产环境配置
│   │       ├── log4j2.xml            # 日志配置
│   │       └── mapper/               # MyBatis XML映射文件
│   └── test/                  # 测试代码
├── lib/                       # 本地依赖JAR包
└── workspace/                 # 工作目录
```

### 2.2 核心包说明

| 包名 | 说明 |
|------|------|
| bean | 存放DTO、VO等数据传输对象 |
| common | 公共组件，如用户上下文、请求上下文 |
| configuration | Spring配置类，包括CORS、Redis、Sa-Token等 |
| constant | 常量定义，如字帖类型、版式类型等 |
| entity | 数据库实体类 |
| exception | 自定义业务异常 |
| mapper | MyBatis Mapper接口 |
| rest | RESTful API控制器 |
| service | 业务逻辑层 |
| util | 工具类集合 |
| wx | 微信小程序相关服务 |

---

## 3. 核心功能模块

### 3.1 字帖生成服务 (ImageService)

**核心类**: `com.liupin.utils.service.ImageService`

**功能描述**:
- 字帖生成任务调度（定时轮询）
- PDF文件生成与合并
- Node.js调用执行字帖生成
- 多节点分布式处理支持

**关键方法**:
- `generate()` - 定时轮询生成字帖
- `insertCommodity()` - 插入商品记录并分配节点
- `createPDF()` - 创建PDF文件

### 3.2 字帖类型

系统支持多种字帖类型，定义在 `CommodityType` 常量类：

| 类型值 | 说明 |
|--------|------|
| 1 | 姓名字帖1.0 |
| 3 | DIY字帖 |
| 4 | 姓名字帖2.0 |

### 3.3 版式类型

系统支持丰富的字帖版式，定义在 `AllFormatType` 常量类，包括：
- 多种页面布局
- 不同字体样式
- 自定义版式

### 3.4 控制器层 API

#### 主要控制器列表

| 控制器 | 功能 |
|--------|------|
| ImageController | 图片和字帖生成核心接口 |
| CommodityController | 商品管理接口 |
| CopyBookController | 字帖管理接口 |
| DiyController | DIY字帖接口 |
| FileController | 文件上传下载 |
| LoginController | 登录认证 |
| StatisticsController | 统计数据接口 |
| TaoBaoOrderController | 淘宝订单处理 |
| ChildrenSignetController | 儿童印章相关 |
| CommodityDownloadController | 商品下载管理 |

---

## 4. 数据模型

### 4.1 核心实体

#### Commodity (商品/字帖订单)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键ID |
| orderNum | String | 订单号 |
| taobaoOrderNum | String | 淘宝订单号 |
| fileName | String | 文件名 |
| fileUrl | String | 文件URL |
| status | Integer | 状态(-1:待处理, 0:失败, 1:成功, -2:生成中) |
| type | Integer | 字帖类型 |
| format | Integer | 版式 |
| node | Integer | 处理节点编号 |
| gender | Integer | 性别 |
| uid | Integer | 用户ID |
| createTime | Date | 创建时间 |
| updateTime | Date | 更新时间 |

#### 其他实体

- **CommodityDiy** - DIY字帖详情
- **CommodityThirdParty** - 第三方商品信息
- **CommodityDownloadInfo** - 下载记录
- **TabletOrder** - 字帖订单
- **User** - 用户信息
- **FileInfo** - 文件信息
- **QrCode** - 二维码
- **ChildrenSignetInfo** - 儿童印章信息
- **WordSvg** - 字帖SVG数据

---

## 5. 技术架构

### 5.1 技术栈详情

| 技术 | 版本 | 用途 |
|------|------|------|
| Spring Boot | 2.7.11 | 应用框架 |
| MyBatis Plus | 3.5.2 | ORM框架 |
| Sa-Token | 1.30.0 | 权限认证 |
| Redisson | 3.17.7 | Redis客户端 |
| Hutool | 5.8.2 | Java工具库 |
| FastJSON2 | 2.0.6 | JSON处理 |
| Apache POI | 5.2.2 | Excel处理 |
| PDFBox | 2.0.27 | PDF处理 |
| iText | 5.5.13.2 | PDF生成 |
| 腾讯云COS SDK | 5.6.23 | 对象存储 |
| 微信小程序SDK | 4.3.9.B | 微信集成 |

### 5.2 关键配置类

| 配置类 | 功能 |
|--------|------|
| CorsConfiguration | 跨域配置 |
| CosConfiguration | 腾讯云COS配置 |
| RedissonConfig | Redis配置 |
| SaTokenConfiguration | Sa-Token权限配置 |
| MybatisPlusConfiguration | MyBatis Plus配置 |
| NodeConfig | 节点配置(分布式) |
| TaskSchedulerConfig | 定时任务配置 |
| WebMvcConfiguration | Web MVC配置 |
| GlobalExceptionHandler | 全局异常处理 |

---

## 6. 第三方集成

### 6.1 腾讯云 COS

用于存储生成的字帖PDF、图片等文件。

**配置位置**: `application.yml` -> `cos` 节点

### 6.2 微信小程序

集成微信小程序登录和二维码生成功能。

**配置位置**: `application.yml` -> `wx.miniapp` 节点

### 6.3 淘宝/聚水潭

处理淘宝订单，对接聚水潭ERP系统。

**相关配置**: `application-{profile}.yml` -> `jushuitan` 节点

### 6.4 抖音

抖音订单处理接口。

**相关配置**: `application-{profile}.yml` -> `tiktok-service` 节点

---

## 7. 分布式架构

### 7.1 多节点部署

系统支持多节点分布式部署，通过 `node` 字段实现任务分配。

**配置参数**:
- `NODE_NUM` - 当前节点编号
- `NODE_COUNT` - 节点总数

**任务分配策略**:
- 单节点：固定 `NODE_NUM=1`
- 多节点：通过 `RandomUtil.alternateReturn()` 轮询分配

### 7.2 负载均衡

通过 Nginx 实现负载均衡，配置位置：
```
/usr/local/liupin/newtool/webserver/nginx/conf/nginx.conf
```

---

## 8. 文件存储

### 8.1 字帖数据目录

| 目录 | 说明 |
|------|------|
| /usr/local/liupin/name-copybook | 字帖输入输出目录 |
| /usr/local/liupin/name-copybook{n}/copybook | PDF输出目录 |
| /usr/local/liupin/name-copybook{n}/dist | 前端资源 |
| /usr/local/liupin/name-copybook{n}/node | Node.js服务 |

### 8.2 新增版式步骤

1. 创建目录 `/usr/local/liupin/name-copybook{新序号}`
2. 创建子目录 `/copybook` (PDF输出)
3. 创建子目录 `/dist` (设置权限: `chmod -R 777 dist`)
4. 创建子目录 `/node` (Node.js服务)
5. 配置 Nginx 端口

---

## 9. 安全与权限

### 9.1 Sa-Token 配置

- Token有效期: 30天
- 支持并发登录
- Token风格: UUID
- 不使用Cookie存储

### 9.2 接口权限

通过 `SaTokenConfiguration` 配置接口访问权限。

---

## 10. 日志与监控

### 10.1 日志配置

使用 Log4j2 作为日志框架，配置文件: `log4j2.xml`

### 10.2 日志级别

通过环境变量 `LOG_LEVEL` 控制日志级别。

---

## 11. 环境配置

### 11.1 环境变量

通过 `.env` 文件配置环境变量：

```properties
APP_PORT=7777                 # 应用端口
DB_URL=jdbc:mysql://...       # 数据库连接
DB_USERNAME=root              # 数据库用户名
DB_PASSWORD=pwd               # 数据库密码
LOG_LEVEL=DEBUG               # 日志级别
NODE_NUM=1                    # 节点编号
NODE_COUNT=1                  # 节点总数
REDIS_HOST=...                # Redis主机
REDIS_PORT=...                # Redis端口
REDIS_PWD=...                 # Redis密码
REDIS_DATABASE=2              # Redis数据库
```

### 11.2 环境Profile

- `dev` - 开发环境
- `test` - 测试环境
- `pro` - 生产环境

---

## 12. 依赖说明

### 12.1 关键依赖

| 依赖 | 用途 |
|------|------|
| spring-boot-starter-web | Web应用 |
| spring-boot-devtools | 热部署 |
| mysql-connector-j | MySQL驱动 |
| mybatis-plus-boot-starter | ORM |
| sa-token-spring-boot-starter | 权限认证 |
| redisson | Redis客户端 |
| hutool-all | 工具集 |
| fastjson2 | JSON处理 |
| poi-ooxml | Excel处理 |
| pdfbox | PDF操作 |
| itextpdf | PDF生成 |
| cos_api | 腾讯云COS |
| wx-java-miniapp-spring-boot-starter | 微信小程序 |

### 12.2 本地依赖

`lib/` 目录存放本地JAR包依赖。

---

## 13. 开发规范

### 13.1 代码规范

- 使用Lombok简化实体类
- 统一异常处理 `GlobalExceptionHandler`
- RESTful API设计
- 异步处理使用 `@Async`
- 定时任务使用 `@Scheduled`

### 13.2 数据库规范

- 使用MyBatis Plus进行数据库操作
- 主键策略: 自增 (`IdType.AUTO`)
- 逻辑删除支持

---

## 14. 项目特点

1. **分布式字帖生成**: 支持多节点协同处理，提高生成效率
2. **多渠道订单支持**: 集成淘宝、抖音等电商平台订单处理
3. **丰富的版式支持**: 支持多种字帖版式和自定义DIY
4. **自动化流程**: 定时任务自动处理字帖生成队列
5. **云端存储**: 生成的PDF自动上传至腾讯云COS
6. **Node.js集成**: 调用Node.js服务进行字帖渲染

---

## 15. 维护说明

### 15.1 服务发布

- 单台服务: `NODE_NUM = 1`
- 两台服务: 对应设置不同的 `NODE_NUM`，分别打包部署

### 15.2 机器扩容

1. 修改 `ImageService.insertCommodity` 方法的节点配置
2. 启动 Nginx 服务
3. 重启项目

### 15.3 清理脚本

`auto_delete.sh` - 自动清理临时文件

---

## 16. 参考链接

- Spring Boot文档: https://spring.io/projects/spring-boot
- MyBatis Plus文档: https://baomidou.com/
- Sa-Token文档: https://sa-token.cc/
- 腾讯云COS文档: https://cloud.tencent.com/document/product/436
