# 项目安装的包

这是一个 **Laravel 13** 项目，运行在 **PHP 8.4** 上，使用 **SQLite** 数据库。

## 核心 Laravel 包

| 包名 | 版本 | 说明 |
|------|------|------|
| `laravel/framework` | 13.26.1 | Laravel 框架核心 |
| `laravel/tinker` | 3.0.2 | REPL 交互式调试工具 |
| `laravel/pint` | 1.30.5 | 代码格式化工具 |
| `laravel/pail` | 1.2.7 | 日志查看工具 |
| `laravel/pao` | 1.1.4 | 进程管理工具 |
| `laravel/boost` | 2.5.5 | Laravel Boost MCP 服务 |
| `laravel/mcp` | 0.9.4 | MCP 协议支持 |
| `laravel/agent-detector` | 2.0.2 | User-Agent 检测 |
| `laravel/prompts` | 0.3.23 | CLI 交互提示组件 |
| `laravel/serializable-closure` | 2.0.15 | 可序列化闭包 |
| `laravel/roster` | 1.0.0 | Laravel Roster |

## 开发与测试包

| 包名 | 版本 | 说明 |
|------|------|------|
| `phpunit/phpunit` | 12.5.33 | 单元测试框架 |
| `fakerphp/faker` | 1.24.1 | 假数据生成器 |
| `mockery/mockery` | 1.6.15 | Mock 框架 |
| `filp/whoops` | 2.18.4 | 错误页面处理 |
| `nunomaduro/collision` | 8.9.5 | CLI 错误处理 |
| `nunomaduro/termwind` | 2.4.0 | 终端样式工具 |

## HTTP 与网络

| 包名 | 版本 | 说明 |
|------|------|------|
| `guzzlehttp/guzzle` | 8.1.0 | HTTP 客户端 |
| `guzzlehttp/psr7` | 3.1.0 | PSR-7 实现 |
| `guzzlehttp/promises` | 3.0.2 | Promise 库 |
| `guzzlehttp/uri-template` | 2.0.0 | URI 模板 |
| `symfony/http-foundation` | 8.1.5 | HTTP 基础组件 |
| `symfony/http-kernel` | 8.1.5 | HTTP 内核组件 |
| `symfony/mailer` | 8.1.5 | 邮件组件 |
| `symfony/mime` | 8.1.5 | MIME 组件 |

## 文件系统与存储

| 包名 | 版本 | 说明 |
|------|------|------|
| `league/flysystem` | 3.35.3 | 文件系统抽象层 |
| `league/flysystem-local` | 3.35.3 | 本地文件系统适配器 |
| `league/mime-type-detection` | 1.17.0 | MIME 类型检测 |

## 日期与时间

| 包名 | 版本 | 说明 |
|------|------|------|
| `nesbot/carbon` | 3.13.2 | 日期时间处理库 |
| `carbonphp/carbon-doctrine-types` | 3.2.0 | Carbon Doctrine 类型 |

## 数据处理与验证

| 包名 | 版本 | 说明 |
|------|------|------|
| `brick/math` | 0.18.0 | 高精度数学库 |
| `ramsey/uuid` | 4.9.3 | UUID 生成库 |
| `ramsey/collection` | 2.1.1 | 集合库 |
| `egulias/email-validator` | 4.0.4 | 邮箱验证器 |
| `dragonmantank/cron-expression` | 3.6.0 | Cron 表达式解析 |
| `league/uri` | 7.8.1 | URI 处理库 |
| `league/commonmark` | 2.10.0 | Markdown 解析器 |

## Symfony 组件

| 包名 | 版本 | 说明 |
|------|------|------|
| `symfony/console` | 8.1.5 | 命令行组件 |
| `symfony/finder` | 8.1.5 | 文件查找组件 |
| `symfony/routing` | 8.1.5 | 路由组件 |
| `symfony/process` | 8.1.5 | 进程组件 |
| `symfony/string` | 8.1.2 | 字符串处理 |
| `symfony/var-dumper` | 8.1.5 | 变量转储 |
| `symfony/yaml` | 8.1.5 | YAML 解析 |
| `symfony/clock` | 8.1.0 | 时钟组件 |
| `symfony/css-selector` | 8.1.5 | CSS 选择器 |
| `symfony/error-handler` | 8.1.5 | 错误处理 |
| `symfony/event-dispatcher` | 8.1.5 | 事件分发器 |
| `symfony/translation` | 8.1.5 | 翻译组件 |
| `symfony/uid` | 8.1.5 | UID 组件 |

## PSR 标准接口

| 包名 | 版本 | 说明 |
|------|------|------|
| `psr/container` | 2.0.2 | 容器接口 |
| `psr/log` | 3.0.2 | 日志接口 |
| `psr/http-message` | 2.0 | HTTP 消息接口 |
| `psr/http-client` | 1.0.3 | HTTP 客户端接口 |
| `psr/http-factory` | 1.1.0 | HTTP 工厂接口 |
| `psr/event-dispatcher` | 1.0.0 | 事件分发器接口 |
| `psr/simple-cache` | 3.0.0 | 简单缓存接口 |
| `psr/clock` | 1.0.0 | 时钟接口 |

## 其他 PHP 包

| 包名 | 版本 | 说明 |
|------|------|------|
| `monolog/monolog` | 3.10.0 | 日志库 |
| `vlucas/phpdotenv` | 5.6.4 | 环境变量加载 |
| `nikic/php-parser` | 5.8.0 | PHP 解析器 |
| `psy/psysh` | 0.12.24 | PHP REPL |
| `doctrine/inflector` | 2.1.0 | 单词变形 |
| `league/config` | 1.2.0 | 配置库 |
| `nette/utils` | 4.1.5 | 工具集 |
| `fruitcake/php-cors` | 1.4.0 | CORS 支持 |
| `composer/semver` | 3.4.4 | 版本约束解析 |

## PHPUnit 相关包

| 包名 | 版本 | 说明 |
|------|------|------|
| `phpunit/php-code-coverage` | 12.5.7 | 代码覆盖率 |
| `phpunit/php-file-iterator` | 6.0.1 | 文件迭代器 |
| `phpunit/php-timer` | 8.0.0 | 计时器 |
| `sebastian/comparator` | 7.1.8 | 比较器 |
| `sebastian/diff` | 7.0.0 | 差异对比 |
| `sebastian/environment` | 8.1.2 | 环境检测 |
| `sebastian/version` | 6.0.0 | 版本信息 |

---

## 前端包 (npm)

| 包名 | 版本 | 说明 |
|------|------|------|
| `vite` | 8.0.0 | 构建工具 |
| `tailwindcss` | 4.0.0 | CSS 框架 |
| `@tailwindcss/vite` | 4.0.0 | Tailwind Vite 插件 |
| `laravel-vite-plugin` | 3.1 | Laravel Vite 插件 |
| `@laravel/multiplex` | 0.4.1 | Laravel Multiplex |
| `concurrently` | 10.0.3 | 并发运行工具 |

---

**总计**: 107 个 PHP 包，6 个 npm 包
