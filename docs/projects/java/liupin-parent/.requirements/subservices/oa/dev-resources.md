# OA 服务 resources 目录迁移执行报告

**执行日期**: 2026-09-08
**需求来源**: `.requirements/subservices/oa/dev.txt` - 开发需求1
**模块**: `liupin-service/liupin-oa-service/`

---

## 一、需求概述

1. 模块 resources 当前所在目录 `src/resources/`，需移动到标准 Maven 目录 `src/main/resources/`。
2. 评估是否会影响模块功能、是否需要调整代码。
3. 执行结果保存到本文件。

> 说明：`dev.txt` 中 "忽略以下所有需求描述" 之后的开发需求2（bizWelfareList 整改）不在本次执行范围内，已被显式忽略。

---

## 二、执行前现状分析

### 2.1 目录布局（非标准）

迁移前 oa-service 的源码目录为非标准 Maven 布局：

```
src/
├── main/java/          # Java 源码（标准）
├── resources/          # 资源目录（非标准，应为 src/main/resources）
│   ├── bootstrap.yaml
│   ├── bootstrap-dev.yaml
│   ├── bootstrap-pro.yaml
│   ├── mybatis-config.xml
│   ├── log4j2.xml
│   ├── mapper/         # 19 个 MyBatis Mapper XML
│   └── templates/      # Thymeleaf 模板
└── test/java/
```

`src/main/resources/` 目录**不存在**；兄弟模块（如 `liupin-custom-service`）使用的是标准 `src/main/resources/`。

### 2.2 构建配置排查

全层级 pom 均无自定义 `<resources>` 配置：

| pom 文件 | `<build>`/`<resources>` 情况 |
|----------|------------------------------|
| 根 `liupin-parent/pom.xml` | 有 `<build>`，仅含 compiler/source/surefire/publish 插件，**无 `<resources>`** |
| `liupin-service/pom.xml`（父） | **无 `<build>` 段** |
| `liupin-oa-service/pom.xml` | `<build>` 仅含 `spring-boot-maven-plugin`，**无 `<resources>`** |

结论：Maven 使用 super-POM 默认资源目录 `src/main/resources`。由于 oa-service 把资源放在了 `src/resources/`，**默认配置根本不会把它们拷贝到 classpath**。

### 2.3 迁移前 target/classes 验证

迁移前编译产物 `target/classes/` 中：
- `bootstrap*.yaml`、`mybatis-config.xml`、`log4j2.xml` —— **均不存在**
- `mapper/*.xml` —— **0 个**
- `templates/` —— **不存在**

即运行时所需的配置文件、Mapper XML、模板全部缺失于 classpath，模块按当前布局打包后无法正常运行。

---

## 三、影响评估

### 3.1 运行时引用全部为 classpath 相对路径

排查模块内所有配置文件与代码，对资源文件的引用均使用 `classpath:` 前缀，**不依赖源码物理路径**：

| 引用位置 | 配置项 | 值 |
|----------|--------|----|
| `bootstrap.yaml` | `mybatis.config-location` | `classpath:mybatis-config.xml` |
| `bootstrap.yaml` | `mybatis.mapper-locations` | `classpath:mapper/*.xml` |
| `bootstrap.yaml` | `spring.thymeleaf.prefix` | `classpath:/templates/` |
| `log4j2.xml` | 日志路径 | `/var/logs`（OS 绝对路径，与源码目录无关） |

### 3.2 无硬编码路径引用

对模块全量搜索字符串 `src/resources`，**代码与配置中均无任何引用**。

### 3.3 评估结论

- **是否影响功能**：不影响。迁移到 `src/main/resources/` 后，Maven 默认机制会把资源正确拷贝到 classpath，所有 `classpath:` 引用照常生效，反而**修复了原先资源未进 classpath 的问题**。
- **是否需要调整代码**：**不需要**。无需修改任何 Java 代码、YAML 配置或 Mapper XML 内容。
- **是否需要调整 pom**：**不需要**。无需新增 `<resources>` 配置，标准目录即可被默认识别。

---

## 四、执行步骤

### 4.1 目录迁移

使用 `git mv` 保留文件历史（非删除+新增），将 `src/resources/` 整体移动到 `src/main/resources/`：

```bash
cd liupin-service/liupin-oa-service
git mv src/resources src/main/resources
```

迁移后布局：

```
src/
├── main/
│   ├── java/
│   └── resources/      # 已迁移至此（标准位置）
│       ├── bootstrap.yaml
│       ├── bootstrap-dev.yaml
│       ├── bootstrap-pro.yaml
│       ├── mybatis-config.xml
│       ├── log4j2.xml
│       ├── mapper/
│       └── templates/
└── test/java/
```

### 4.2 Git 状态

共 32 个文件被识别为重命名（`R`），git 历史完整保留，例如：

```
R  .../src/resources/bootstrap.yaml -> .../src/main/resources/bootstrap.yaml
R  .../src/resources/mybatis-config.xml -> .../src/main/resources/mybatis-config.xml
R  .../src/resources/mapper/HrStaffEmolumentWelfareMapper.xml -> .../src/main/resources/mapper/HrStaffEmolumentWelfareMapper.xml
...
```

---

## 五、验证结果

### 5.1 编译验证

使用 JDK 8（Lombok 1.18.20 与高版本 JDK 不兼容，必须用 JDK 8）编译：

```bash
JAVA_HOME=<jdk8> mvn -o -pl liupin-service/liupin-oa-service -am compile
```

结果：**BUILD SUCCESS**（退出码 0）。

### 5.2 资源进 classpath 验证

迁移后 `target/classes/` 中资源文件全部就位：

| 资源 | 迁移前 | 迁移后 |
|------|--------|--------|
| `bootstrap.yaml` / `bootstrap-dev.yaml` / `bootstrap-pro.yaml` | 缺失 | ✅ 存在 |
| `mybatis-config.xml` | 缺失 | ✅ 存在 |
| `log4j2.xml` | 缺失 | ✅ 存在 |
| `mapper/*.xml` | 0 个 | ✅ 19 个 |
| `templates/`（含 common/dept/person/reviewMain/reviewMainConsuming/template 子目录） | 缺失 | ✅ 存在 |
| 非 `.class` 资源文件总数 | 0 | ✅ 32 |

---

## 六、文件变更清单

| 操作 | 路径 | 说明 |
|------|------|------|
| 重命名 | `src/resources/**` → `src/main/resources/**` | 32 个文件整体迁移，git 识别为 rename |
| 无 | Java 代码 / YAML / XML 内容 | 无任何内容修改 |
| 无 | pom.xml（本模块及父级） | 无任何配置修改 |

---

## 七、执行结论

| 需求项 | 状态 | 说明 |
|-------|------|------|
| resources 目录迁移到 `src/main/resources/` | ✅ 完成 | `git mv` 整体迁移，32 文件历史保留 |
| 功能影响评估 | ✅ 完成 | 无影响；反而修复了资源未进 classpath 的缺陷 |
| 是否需调整代码 | ✅ 完成 | 不需要，所有引用为 `classpath:` 相对路径 |
| 编译验证 | ✅ 完成 | JDK 8 编译通过，32 个资源文件正确进入 `target/classes` |

**执行状态**: ✅ 成功完成
**风险等级**: 🟢 低风险（纯目录标准化迁移，无代码/配置内容变更，编译与资源拷贝均已验证）
