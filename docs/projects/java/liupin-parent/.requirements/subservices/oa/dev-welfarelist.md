# OA bizWelfareList 接口整改执行报告

**执行日期**: 2026-09-08
**需求来源**: `.requirements/subservices/oa/dev.txt` - 开发需求2
**模块**: `liupin-service/liupin-oa-service/`
**接口**: `GET /api/v1/welfare/bizWelfareList`、`GET /api/v1/welfare/bizWelfareExport`

---

## 一、需求与实现对照

| # | 需求 | 实现方式 |
|---|------|----------|
| 1 | 接口 bizWelfareList 功能整改 | 见下文各点 |
| 2 | 新增返回值部门ID | `BizWelfareResult` 新增 `fdParentid`，`setDeptName` 从 `SysOrgElementVO.getFdParentid()` 回填 |
| 3 | fd_parentid 为空时通过 fd_pre_dept_id 获取部门名称 | SQL 层：`SysOrgElementMapper.xml` 的 `selectVOList` 中 `dept_name` 改为 `COALESCE(fd_parentid 子查询, fd_pre_dept_id 子查询, '')` |
| 4 | 新增连接数据库 oapi 的数据库连接 | 新增 `PrimaryDataSourceConfiguration` + `OapiDataSourceConfiguration` + `bootstrap-dev/pro/local.yaml` 的 `spring.datasource.oapi` |
| 5 | 基于返回值部门名称查 oapi 库 department_oa 表（oa_name = 部门名称） | 新增 `DepartmentOaMapper.selectByOaName/selectByOaNames`、`DepartmentOaService` |
| 6 | 返回值新增 department_oa 的 id（金蝶ID）、oa_code、jd_number | `BizWelfareResult` 新增 `jdDeptId`/`oaCode`/`jdNumber`，`setDepartmentOaInfo` 批量查询回填 |
| 7 | 新增返回值一并加入导出功能 | `bizWelfareExport` 新增 4 列 |

---

## 二、文件变更清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `src/main/java/com/liupin/oa/config/PrimaryDataSourceConfiguration.java` | 主数据源配置（`@Primary`，`@MapperScan("com.liupin.oa.mapper")`，绑 `classpath:mapper/*.xml`） |
| `src/main/java/com/liupin/oa/config/OapiDataSourceConfiguration.java` | oapi 数据源配置（`@MapperScan("com.liupin.oa.oapi.mapper")`，绑 `classpath:mapper/oapi/*.xml`） |
| `src/main/java/com/liupin/oa/domain/DepartmentOa.java` | department_oa 实体（id/oaName/oaCode/jdNumber） |
| `src/main/java/com/liupin/oa/oapi/mapper/DepartmentOaMapper.java` | oapi Mapper 接口（selectByOaName + selectByOaNames 批量） |
| `src/main/resources/mapper/oapi/DepartmentOaMapper.xml` | oapi Mapper XML |
| `src/main/java/com/liupin/oa/service/DepartmentOaService.java` | department_oa 服务 |

### 修改文件

| 文件 | 变更 |
|------|------|
| `src/main/java/com/liupin/oa/OaApp.java` | 移除 `@MapperScan("com.liupin.oa.mapper")`，交给两个数据源配置类 |
| `src/main/java/com/liupin/oa/domain/result/BizWelfareResult.java` | 新增字段 `fdParentid`、`jdDeptId`、`oaCode`、`jdNumber` |
| `src/main/java/com/liupin/oa/service/BizWelfareService.java` | 注入 `DepartmentOaService`；`setDeptName` 回填 fdParentid 并调用 `setDepartmentOaInfo` 批量查 department_oa 回填；`bizWelfareExport` 新增 4 列 |
| `src/main/resources/mapper/SysOrgElementMapper.xml` | `selectVOList` 的 `dept_name` 改为 `COALESCE(fd_parentid, fd_pre_dept_id, '')` 回退 |
| `src/main/resources/bootstrap-dev.yaml` | 新增 `spring.datasource.oapi` 配置 |
| `src/main/resources/bootstrap-pro.yaml` | 新增 `spring.datasource.oapi` 配置 |

> `bootstrap-local.yaml` 已含 oapi 配置（`sh-cdb-jgubck6c.sql.tencentcdb.com:63998/oapi`，账号 oatest），未改动。

---

## 三、多数据源实现要点（关键）

### 3.1 为何需要 PrimaryDataSourceConfiguration

oa-service 原为单数据源，靠 `mybatis-spring-boot-starter` 1.3.2 自动配置（`@ConditionalOnMissingBean(SqlSessionFactory)`）。引入 `OapiDataSourceConfiguration` 后会注册 `oapiSqlSessionFactory` Bean，触发自动配置退让，导致主 mapper 无 SqlSessionFactory 绑定 XML（`BindingException: Invalid bound statement (not found)`）。

故必须显式声明主数据源的 `PrimaryDataSourceConfiguration`（`@Primary`），用 `@MapperScan("com.liupin.oa.mapper")` 绑定顶层 19 个 mapper 到 `primarySqlSessionFactory`，mapper XML 路径 `classpath:mapper/*.xml`。

### 3.2 oapi mapper 包独立放置

oapi mapper 放在 `com.liupin.oa.oapi.mapper`（**非** `com.liupin.oa.mapper.oapi` 子包），避免被主 `@MapperScan("com.liupin.oa.mapper")` 递归扫描到引发重复注册。oapi mapper XML 路径 `classpath:mapper/oapi/*.xml`。

### 3.3 OaApp 移除 @MapperScan

原 `OaApp` 上的 `@MapperScan("com.liupin.oa.mapper")` 移除，由 `PrimaryDataSourceConfiguration` 接管，避免 App 顶层扫描与配置类冲突。

### 3.4 部门名称 COALESCE 回退（SQL 层）

`SysOrgElementMapper.xml` 的 `selectVOList` 原 `dept_name`（仅 fd_parentid）改为：

```sql
COALESCE(
  (select fd_name from sys_org_element sys_org1
   where sys_org1.fd_id = sys_org.fd_parentid and sys_org1.fd_is_abandon = 0),
  (select fd_name from sys_org_element sys_org2
   where sys_org2.fd_id = sys_org.fd_pre_dept_id and sys_org2.fd_is_abandon = 0),
  ''
) dept_name
```

### 3.5 department_oa 批量查询（避免 N+1）

`setDepartmentOaInfo`：收集去重部门名称 → 一次 `listByOaNames`（`oa_name IN (...)`）→ 建 Map 回填 `jdDeptId/oaCode/jdNumber`。

---

## 四、oapi 数据源连接信息

| 环境 | url | 账号 | 来源 |
|------|-----|------|------|
| local | `jdbc:mysql://sh-cdb-jgubck6c.sql.tencentcdb.com:63998/oapi` | oatest | 已有配置 |
| dev | `jdbc:mysql://sh-cdb-jgubck6c.sql.tencentcdb.com:63998/oapi` | myd | 复用 dev 主库地址，库名 oapi |
| pro | `jdbc:mysql://172.17.16.50:3306/oapi` | oatwo | 复用 pro 主库地址，库名 oapi |

> ⚠️ dev/pro 的 oapi 连接信息按"复用各环境主库地址"推断。部署前需确认对应主机上的 `oapi` 库存在且账号有访问权限；不符则修改对应 `bootstrap-*.yaml` 的 `spring.datasource.oapi` 块。

---

## 五、接口返回值新增字段

| 字段名 | 类型 | 说明 | 来源 |
|--------|------|------|------|
| fdParentid | String | 部门ID | sys_org_element.fd_parentid |
| jdDeptId | String | 金蝶部门ID | department_oa.id |
| oaCode | String | OA部门编码 | department_oa.oa_code |
| jdNumber | String | 金蝶部门编码 | department_oa.jd_number |

## 六、导出功能新增列

1. 部门ID → `fdParentid`
2. 金蝶部门ID → `jdDeptId`
3. OA部门编码 → `oaCode`
4. 金蝶部门编码 → `jdNumber`

---

## 七、验证

1. **编译**：JDK 8 下 `mvn -o -pl liupin-service/liupin-oa-service -am compile` → **BUILD SUCCESS**。
2. **运行**：`mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=local"` → **Started OaApp in 3.833 seconds**，Tomcat 端口 10011。
3. **BindingException 检查**：日志中 `BindingException` / `Invalid bound statement` 计数 = **0**（上次的多数据源绑定失效问题已解决）。
4. **oapi 数据源**：无连接/初始化错误。
5. 唯一 ERROR 为 local 环境 oatest 账号对主库 `biz_user_okr_id` 表无 INSERT 权限（定时任务触发），属既有数据库权限问题，与本次改动无关。

---

## 八、数据库要求

确保 oapi 数据库中存在 `department_oa` 表，字段：`id`（主键/金蝶ID）、`oa_name`（匹配键）、`oa_code`、`jd_number`。

---

## 九、执行结论

| 需求项 | 状态 |
|-------|------|
| 新增返回值部门ID | ✅ 完成 |
| fd_parentid 为空时用 fd_pre_dept_id 取部门名称 | ✅ 完成（SQL 层 COALESCE 回退） |
| 新增 oapi 数据库连接 | ✅ 完成（local/dev/pro 三环境，多数据源配置类） |
| 查询 department_oa 表 | ✅ 完成（按 oa_name 匹配，批量查询） |
| 返回值新增金蝶部门ID/OA部门编码/金蝶部门编码 | ✅ 完成 |
| 导出功能新增字段 | ✅ 完成（4 列） |
| 编译验证 | ✅ 通过 |
| 运行验证（无 BindingException） | ✅ 通过 |

**执行状态**: ✅ 成功完成
**风险等级**: 🟡 中风险（dev/pro 的 oapi 库连接信息为推断值，部署前需核实）
