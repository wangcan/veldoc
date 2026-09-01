# liupin-oa-service 模块功能介绍

## 1. 模块概述

`liupin-oa-service` 是一个基于 Spring Boot 和 Spring Cloud 的 OA（办公自动化）业务模块，提供了企业办公相关的核心功能服务。

## 2. 技术栈

### 2.1 核心框架
- **Spring Boot**: 应用主框架
- **Spring Cloud Alibaba Nacos**: 服务注册与发现
- **Spring Cloud OpenFeign**: 服务间调用
- **MyBatis**: 数据持久化框架

### 2.2 数据存储
- **MySQL**: 关系型数据库
- **Redis**: 缓存数据库
- **Druid**: 数据库连接池

### 2.3 其他组件
- **Log4j2 + Disruptor**: 高性能日志
- **Spring Boot Actuator**: 应用监控
- **Spring Boot Admin Client**: 监控管理
- **Lombok**: 简化代码
- **Thymeleaf**: 模板引擎
- **Apache POI**: Excel 处理
- **Hutool**: Java 工具库
- **FastJSON**: JSON 处理

## 3. 模块功能

### 3.1 个人职责管理 (BizPersionDutyController)
- **路径**: `/api/v1/personDuty`
- **功能**:
  - 查询个人职责分页数据
  - 保存个人职责信息

### 3.2 员工入职管理 (BizStaffEntryController)
- **路径**: `/api/v1/staffEntry`
- **功能**:
  - 待入职员工信息提交
  - 根据手机号查询待入职员工信息
- **说明**: 支持从 OA 系统移动端页面提交待入职员工数据

### 3.3 薪酬福利管理 (BizWelfareController)
- **路径**: `/api/v1/welfare`
- **功能**:
  - 分页查询薪酬福利列表
  - 更新员工薪酬福利信息
  - 导出薪酬福利数据
  - 员工薪资同步更新

### 3.4 OKR 管理 (OkrController)
- **路径**: `/api/v1/okr`
- **功能**:
  - 查询个人 OKR 数据
  - 按月份拉取 OKR 数据
- **说明**: 集成 Tita OKR 系统

### 3.5 审批流程管理 (ReviewMainController)
- **路径**: `/api/v1/reviewMain`
- **功能**:
  - 获取审批模板分类
  - 分页查询审批流程列表
- **说明**: 支持按用户、搜索文本、关联用户、日期范围等条件查询

### 3.6 审批流程效率统计 (ReviewMainConsumingController)
- **路径**: `/api/v1/reviewMainConsuming`
- **功能**:
  - 审批流程效率统计列表查询
  - 审批效率统计导出
  - 审批详情统计列表查询
  - 审批详情统计导出
- **说明**: 支持按日期范围、用户、部门、审批模板等维度统计

### 3.7 组织架构管理 (SysOrgElementController)
- **路径**: `/api/v1/sysOrgElement`
- **功能**:
  - 授权认证
  - 个人职责用户列表查询
  - 员工信息列表查询
  - 部门树查询
  - 岗位列表查询

### 3.8 页面视图控制器 (ViewPageController)
- **路径**: `/api/view`
- **功能**:
  - 审批流程分页视图
  - 审批流程效率统计视图
  - 审批流程效率详情视图
  - 人员查询视图
  - 部门树视图
  - 审批模板树视图
- **说明**: 使用 Thymeleaf 模板引擎渲染页面

## 4. 数据模型

### 4.1 核心实体类
- **BizPersionDuty**: 个人职责
- **BizPersionDutyType**: 职责类型
- **BizPersionDutyTypeDetail**: 职责类型详情
- **BizPersionWorkHabit**: 工作习惯
- **BizSalaryUpdate**: 薪资更新
- **BizUserEntrySubmit**: 用户入职提交
- **SysOrgElement**: 组织架构元素
- **SysOrgPerson**: 组织人员
- **HrOrgElement**: HR 组织元素
- **HrStaffPersonInfo**: 员工个人信息
- **HrStaffEmolumentWelfare**: 员工薪酬福利

### 4.2 业务参数类
- **PersionDutyResultParam**: 个人职责结果参数
- **PendingEmploymentInsertParam**: 待入职员工参数
- **BizWelfareUpdateParam**: 薪酬福利更新参数
- **BizSalaryParam**: 薪资参数
- **SysOrgElementParam**: 组织架构查询参数

### 4.3 业务结果类
- **BizWelfareResult**: 薪酬福利结果
- **ReviewMainListResult**: 审批流程列表结果
- **SysOrgElementVO**: 组织架构视图对象

## 5. 服务层

### 5.1 核心服务
- **BizPersionDutyService**: 个人职责服务
- **BizStaffEntryService**: 员工入职服务
- **BizWelfareService**: 薪酬福利服务
- **OkrService**: OKR 服务
- **ReviewMainService**: 审批流程服务
- **ReviewMainConsumingService**: 审批效率统计服务
- **SysOrgElementService**: 组织架构服务

### 5.2 支持服务
- **BizAuthorizationUrlResourceService**: 授权资源服务
- **BizKmReviewPreviousStepTimeConsumingService**: 审批耗时服务
- **HrOrgElementService**: HR 组织服务
- **HrStaffPersonInfoService**: 员工个人信息服务
- **HrStaffEmolumentWelfareService**: 员工薪酬福利服务

## 6. 数据访问层 (Mapper)

模块使用 MyBatis 进行数据持久化，所有 Mapper 接口位于 `com.liupin.oa.mapper` 包下，对应的 XML 映射文件位于 `resources/mapper` 目录。

核心 Mapper 包括：
- **BizPersionDutyMapper**: 个人职责数据访问
- **BizStaffEntryMapper**: 员工入职数据访问
- **ReviewMainMapper**: 审批流程数据访问
- **SysOrgElementMapper**: 组织架构数据访问
- **HrStaffPersonInfoMapper**: 员工信息数据访问
- **HrStaffEmolumentWelfareMapper**: 薪酬福利数据访问

## 7. 配置说明

### 7.1 应用配置
- **应用名称**: liupin-oa-service
- **默认端口**: 10011
- **服务注册**: Nacos (127.0.0.1:8848)

### 7.2 数据源配置
- **数据库**: MySQL
- **连接池**: Druid
- **缓存**: Redis

### 7.3 MyBatis 配置
- **配置文件**: classpath:mybatis-config.xml
- **映射文件**: classpath:mapper/*.xml

### 7.4 文件上传配置
- **最大文件大小**: 20MB
- **最大请求大小**: 200MB

## 8. 接口访问控制

部分接口使用了 `@LimitAccess` 注解进行访问频率限制，例如：
- `@LimitAccess(expire = 2)`: 2 秒内限制重复访问

## 9. 安全认证

`SysOrgElementController` 的 `/auth` 接口使用了签名验证机制：
- 使用 `secret` 和 `sign` 进行身份验证
- 通过 `SimpleVerifyUtil` 验证签名有效性

## 10. 模块特点

1. **微服务架构**: 使用 Spring Cloud Alibaba 技术栈，支持服务注册发现和远程调用
2. **分层清晰**: Controller -> Service -> Mapper 三层架构
3. **日志完善**: 使用 Log4j2 + Disruptor 实现高性能异步日志
4. **监控集成**: 集成 Spring Boot Actuator 和 Admin Client
5. **热部署支持**: 引入 spring-boot-devtools 支持开发时热部署
6. **多视图支持**: 使用 Thymeleaf 支持 Web 页面渲染
7. **访问控制**: 使用注解实现接口访问频率限制
