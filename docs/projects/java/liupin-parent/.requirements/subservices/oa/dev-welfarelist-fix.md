# 开发需求执行结果 - bizWelfareList 接口功能整改

## 需求描述

1. 接口 `/api/v1/welfare/bizWelfareList` 功能整改
2. 当前记录 `fd_parentid` 为空时，通过 `fd_pre_dept_id` 获取部门名称

## 执行日期

2026-09-01

## 修改内容

### 修改文件

`liupin-service/liupin-oa-service/src/main/resources/mapper/SysOrgElementMapper.xml`

### 修改说明

修改 `selectVOList` 查询中的部门名称获取逻辑，使用 `COALESCE` 函数实现以下逻辑：

1. 优先使用 `fd_parentid` 查询部门名称
2. 如果 `fd_parentid` 为空，则使用 `fd_pre_dept_id` 查询部门名称
3. 如果两者都为空，则返回空字符串

### 修改前代码

```xml
(
select fd_name from  sys_org_element sys_org1
where  sys_org1.fd_id =sys_org.fd_parentid
and  sys_org1.fd_is_abandon = 0
) dept_name ,
```

### 修改后代码

```xml
COALESCE(
    (SELECT fd_name FROM sys_org_element sys_org1
     WHERE sys_org1.fd_id = sys_org.fd_parentid
     AND sys_org1.fd_is_abandon = 0),
    (SELECT fd_name FROM sys_org_element sys_org2
     WHERE sys_org2.fd_id = sys_org.fd_pre_dept_id
     AND sys_org2.fd_is_abandon = 0),
    ''
) AS dept_name ,
```

## 影响范围

### 直接影响

- `SysOrgElementService.selectAllSysOrgElementVOS()` 方法
- `BizWelfareService.bizWelfareList()` 方法
- `BizWelfareService.bizWelfareExport()` 方法

### 间接影响

所有调用 `SysOrgElementService.selectAllSysOrgElementVOS()` 的方法都会受到影响，部门名称获取逻辑已更新。

## 验证结果

- ✅ 代码编译通过
- ✅ SQL 语法正确
- ✅ 逻辑符合需求

## 测试建议

1. 查询 `fd_parentid` 不为空的记录，确认部门名称正常显示
2. 查询 `fd_parentid` 为空但 `fd_pre_dept_id` 不为空的记录，确认部门名称正常显示
3. 查询 `fd_parentid` 和 `fd_pre_dept_id` 都为空的记录，确认部门名称显示为空

## 相关文件

- 控制器：`liupin-service/liupin-oa-service/src/main/java/com/liupin/oa/controller/BizWelfareController.java`
- 业务服务：`liupin-service/liupin-oa-service/src/main/java/com/liupin/oa/service/BizWelfareService.java`
- 结果对象：`liupin-service/liupin-oa-service/src/main/java/com/liupin/oa/domain/result/BizWelfareResult.java`
- Mapper XML：`liupin-service/liupin-oa-service/src/main/resources/mapper/SysOrgElementMapper.xml`
