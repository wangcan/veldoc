# 数据库初始化命令

## 使用方式

```
/db-init [database]
```

参数：
- `database`: 数据库名，默认 `ruoyi-vue-pro`

## 初始化步骤

### 1. 创建数据库

```sql
CREATE DATABASE IF NOT EXISTS `ruoyi-vue-pro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. 执行 SQL 脚本

```bash
# Linux/Mac
mysql -u root -p ruoyi-vue-pro < sql/mysql/ruoyi-vue-pro.sql

# Windows
mysql -u root -p ruoyi-vue-pro < sql\mysql\ruoyi-vue-pro.sql
```

### 3. 验证初始化

```sql
-- 查看表数量
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'ruoyi-vue-pro';

-- 查看用户表
SELECT * FROM system_user WHERE id = 1;
```

## SQL 脚本位置

- 主脚本: `sql/mysql/ruoyi-vue-pro.sql`
- 升级脚本: `sql/mysql/upgrade/`

## 默认账号

| 用户名 | 密码 | 角色 |
|-------|------|------|
| admin | admin123 | 超级管理员 |
| user | user123 | 普通用户 |

## 注意事项

1. 确保数据库服务已启动
2. 确保有创建数据库的权限
3. 生产环境请修改默认密码
