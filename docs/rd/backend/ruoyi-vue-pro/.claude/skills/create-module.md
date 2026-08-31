---
name: create-module
description: 创建新的业务模块，包含完整的目录结构和基础代码
triggers: ["创建模块", "新建模块", "create module"]
---

# 创建业务模块

## 使用方式

```
/create-module <模块名> <模块描述>
```

示例：
```
/create-module notification 通知模块
```

## 模块结构

创建的模块遵循以下目录结构：

```
yudao-module-xxx/
├── pom.xml                              # Maven 配置
├── yudao-module-xxx-api/                # API 层
│   ├── pom.xml
│   └── src/main/java/cn/iocoder/yudao/module/xxx/
│       ├── api/                         # API 接口定义
│       ├── enums/                       # 枚举类
│       ├── dto/                         # DTO 类
│       └── constants/                   # 常量类
└── yudao-module-xxx-biz/                # 业务层
    ├── pom.xml
    └── src/main/java/cn/iocoder/yudao/module/xxx/
        ├── controller/
        │   └── admin/                   # 管理后台接口
        │       └── vo/                  # VO 类
        ├── service/                     # Service 接口
        │   └── dal/
        │       ├── dataobject/          # DO 实体
        │       └── mysql/               # Mapper
        └── convert/                     # 对象转换
    └── src/main/resources/
        └── application.yaml             # 配置文件
```

## 执行步骤

1. 确认模块名称和描述
2. 创建目录结构
3. 生成 pom.xml 文件
4. 生成基础代码模板
5. 更新父 pom.xml 添加模块

## 注意事项

- 模块名使用小写字母和连字符，如 `user-profile`
- 需要在父 pom.xml 中添加新模块
- API 层用于定义接口和 DTO，供其他模块调用
- BIZ 层包含具体业务实现
