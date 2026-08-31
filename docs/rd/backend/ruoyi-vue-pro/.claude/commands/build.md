# 构建项目命令

## 使用方式

```
/build [选项]
```

选项：
- `--skip-tests`: 跳过测试
- `--clean`: 清理后构建
- `--offline`: 离线模式

## 构建命令

### 编译

```bash
mvn compile
```

### 打包

```bash
# 打包并跳过测试
mvn clean package -DskipTests

# 打包并运行测试
mvn clean package
```

### 安装到本地仓库

```bash
mvn clean install -DskipTests
```

### 指定模块构建

```bash
# 只构建 system 模块
mvn clean package -pl yudao-module-system -am
```

## 构建产物

- `yudao-server/target/yudao-server.jar` - 可执行 JAR

## 构建优化

### 并行构建

```bash
mvn clean package -DskipTests -T 4
```

### 离线构建

```bash
mvn clean package -DskipTests -o
```

### 只构建修改的模块

```bash
mvn clean package -DskipTests -pl yudao-module-system
```
