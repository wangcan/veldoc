执行说明（极简版角色权限管理）：
- 新增表 roles（角色id、角色名称 name 唯一索引、描述、权限信息 permissions JSON、软删除 deleted_at）及对应模型（SoftDeletes）、工厂；
- 管理员表 admins 新增头像 avatar、昵称 nickname、角色 role_id（单一角色，取角色表ID，外键约束角色表）字段；
- 权限选项初始化数组保存到 Modules/Copybook/config/permissions.php，接口 GET api/v1/role-permissions 返回该数组；
- 角色的 permissions 保存所选权限标识集合（JSON 数组），校验必须是权限选项中的键且去重、至少一项；
- 角色接口：GET/POST/PUT/DELETE api/v1/roles、GET api/v1/roles/{id}（完整 CRUD）；删除为软删除，已分配给管理员的角色拒绝删除（409）；
- 角色名称唯一索引包含软删除记录（软删除的角色名称不能被新角色复用）；
- 管理员接口（新增/更新）支持 avatar、nickname、role_id 字段；role_id 校验角色存在且未删除，传 null 可清除角色分配；管理员列表支持昵称模糊、角色ID筛选，列表/详情响应含角色信息；admin/me 返回头像、昵称、角色（含权限信息）；
- 权限仅用于前端菜单展示控制，后端接口暂未按权限拦截（极简版）。

执行说明（需求2）：
- 生成 Swagger（OpenAPI 3.0.3）接口文档 .requirements/modules/copybook/api.json，覆盖 Copybook 模块全部 32 条路由（36 个操作，PUT/PATCH 分别计一个）：认证（登录/当前管理员/退出/刷新令牌）、管理员管理、角色权限管理、字库管理、姓名字帖版本/版式/记录、姓名单字字数配置；
- 文档与代码实际行为一致：请求体取自各 FormRequest 校验规则（必填/可选/长度/枚举），响应结构取自 API Resource 字段；分页列表为 data+meta（不含 success），详情/新增/更新为 success+data(+message)，删除为 204（Symfony 对 204 清空响应体，按无响应体描述）；PATCH 操作通过 $ref 引用同路径 put 操作，避免重复定义；
- 记录各接口错误响应：401 未认证、422 校验失败（message+errors）、404 模型不存在、角色删除 409（已分配管理员）、字库与姓名单字字数配置的自定义 404 文案、登录失败 401 文案；
- 枚举取值来自代码：性别 male/female、字体 standard/handwritten、姓名字帖状态 pending/processing/completed/name_abnormal/font_abnormal/other_abnormal（含中文标签说明）、权限标识 index/namecopybook/childrenstamp/nametag/fontmanage/system；
- 认证方式文档化为 JWT Bearer（Authorization: Bearer {token}），除 POST admin/login 外全部接口要求认证；
- 已校验：JSON 语法有效、145 个 $ref 全部可解析、文档操作与 php artisan route:list 实际注册路由一一对应（无遗漏、无多余）。


执行说明（需求1+需求2）：
- 新增 Modules/Copybook/app/Http/Middleware/NormalizeApiResponse：所有 api/* JSON 响应统一在 body 头部补充 http_code（原始HTTP状态码）与 status（原始状态码为200时为0，其他为1）；HTTP状态码按上述规则映射（5xx 调整为 500 时 http_code 保留原值）；非 api/* 请求与非 JSON 响应不受影响；对已含 http_code 的响应幂等跳过；
- 中间件挂载于模块 api 路由组最外层（RouteServiceProvider::mapApiRoutes 改为 [NormalizeApiResponse::class, 'api']），覆盖控制器正常响应与路由管线内异常渲染响应（422/404/409/500 等）；bootstrap/app.php 的 withExceptions->respond 覆盖路由匹配失败（404/405）等内核层异常响应，两层通过 http_code 幂等判断协同、不会重复处理；
- 需求2：bootstrap/app.php withMiddleware 新增 redirectGuestsTo(fn () => null)，覆盖框架默认的 route('login') 跳转回调（该路由不存在导致 RouteNotFoundException 500）；认证失败统一返回 401 JSON（含 http_code/status），不带 Accept: application/json 的请求同样返回 401（此前为 500）；
- 行为变化：201/204/405/409/422 等接口的 HTTP 状态码统一变为 200，原状态码见 http_code 字段；status 依据原始状态码判定（201/204 等成功但非 200 的响应 status 为 1）；204 删除接口因 Symfony prepare 阶段清空内容，调整为 200 后响应体仅含 http_code/status；
- 控制器代码零改动（response()->json 原样返回，由统一层转换）；更新全部受影响测试断言（assertCreated/assertUnprocessable/assertNoContent/409/405 → assertOk + http_code 校验，共 5 个测试文件 44 处）；新增 ApiResponseRulesTest（24 个测试）：各状态码映射表（含 5xx→500、幂等性、非 api 请求跳过）、201/204/422/404/409/405 信封校验、登录失败与未认证 401 信封、无 Accept 头的 401 认证失败回归测试；全模块 122 个测试通过；api.json 接口文档需按新返回规则另行更新（未在本需求范围内）。

执行说明（补充）：
- 统一返回规则升级为应用级：新增 App/Http/Middleware/NormalizeApiResponse（模块级 Modules/Copybook/app/Http/Middleware/NormalizeApiResponse 已删除），通过 bootstrap/app.php 的 $middleware->prepend 挂在全局中间件栈最外层，按请求路径生效（api/* 或 /），覆盖所有模块的 api 接口，各模块无需单独挂载；模块 RouteServiceProvider 恢复为原始的 api 路由组定义；
- 生效范围共用一个判定 shouldNormalize（api/* 或 /）：全局中间件按它决定是否包装响应，withExceptions 的 shouldRenderJsonWhen 与 respond 也复用同一判定（路由匹配失败 404/405 等内核层异常响应同样按统一规则处理），两层以 http_code 幂等判断协同、不会重复处理；
- 路由 /（routes/web.php）改为返回 response()->json([])，经全局中间件包装后仅返回基本字段 {"http_code":200,"status":0}，不含其他业务字段；非 api/* 且非 / 的请求（如 /up）不受影响；
- 认证失败返回 401 的修复（redirectGuestsTo(fn () => null)）保持不变，仍对全部模块生效；
- 测试更新：ApiResponseRulesTest 的中间件引用改为 App 级类、新增路由 / 基本字段断言、非 api 请求跳过用例改用 /up 路径；全量测试 125 个通过（原 tests/Feature/ExampleTest 因 / 路由改为 JSON 响应而恢复通过）；已实测验证：GET / 返回 {"http_code":200,"status":0}，GET /api/v1/admin/me 不带 Accept 头返回 401 信封，未知 api 路由返回 404 信封。
