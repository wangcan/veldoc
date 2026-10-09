# `/api/v1/login/sixthProductLogin/wxLogin` 向 `sys_user_auth_login` 写入数据的条件分析

> 需求来源：`.requirements/subservices/usercenter/task.txt`（实际需求，忽略 task.txt 中“需求1/2/3”）。
> 分析基线：当前工作区代码（`LoginServiceImpl.java` 已含本地修改，见下文“⚠️ 调试硬编码”说明）。

## 1. 调用链

```
POST /api/v1/login/sixthProductLogin/wxLogin
  → LoginController.sixthProductLogin          (LoginController.java:195-204)
  → loginService.wxSixthProductLoginLogin      (LoginServiceImpl.java:525-631)
```

控制器仅做参数校验（`platId`、`terminal` 非空）和 `@LimitAccess(expire=2)` 限流，核心逻辑在 `wxSixthProductLoginLogin`。

## 2. `sys_user_auth_login` 的底层写入入口

所有对 `sys_user_auth_login` 的 INSERT 最终都来自：

```
SysUserAuthLoginServiceImpl.save(authLogin)
  → sysUserAuthLoginMapper.insertSelective(authLogin)      (SysUserAuthLoginMapper.xml:132)
  → insert into sys_user_auth_login (...)
```

`save(...)` 被 `converAndSave(...)` 调用（`SysUserAuthLoginServiceImpl.java:130`）。`converAndSave` 在本接口流程中出现在两处：

| 调用点 | 位置 | 触发场景 |
|---|---|---|
| `UserServiceImpl.initUserAndAuthInfo` | `UserServiceImpl.java:507` | 全新用户注册 |
| `SysUserAuthLoginServiceImpl.selectByAuthInfo` | `SysUserAuthLoginServiceImpl.java:93-100` | 按 unionid 查到记录、但没有一条满足「openid 相同 且 对应 sys_user 仍存在」时，作为查询的副作用写入 |

> 注意：`selectByAuthInfo` 方法名是查询语义，但**有写入副作用**——这是本接口“隐式写库”的主要来源。

以下方法为纯读，不写库：`getBindPhoneUserByAuthLogin`、`generateLoginInfo`、`selectByUnionId`、`selectByPhoneList`、`selectByUserId`。

## 3. `wxSixthProductLoginLogin` 各分支的写入情况

方法按是否传 `phone` 分两大分支。

### 分支 A：`phone` 为空（未传手机号）→ 不写入

- unionid 无记录 → 返回游客（`id=0`、`userName="游客"`），不写。
- unionid 有记录 → `getBindPhoneUserByAuthLogin` 取已绑定手机号的用户直接登录，不写；取不到最终也走游客，不写。

### 分支 B：`phone` 不为空（传了手机号）→ 才可能写入

> ⚠️ **调试硬编码**：当前工作区 `LoginServiceImpl.java` 处于已修改状态（`git status` 显示 M）。该方法内
> - `wechatUserInfo`（`LoginServiceImpl.java:528-538`）的 openid/unionid 被硬编码；
> - `phone`（`LoginServiceImpl.java:547`）被硬编码为 `"13811974106"`。
>
> 因此**实际每次请求都会走分支 B**。正常生产逻辑下 `phone` 来自 `params.getPhone()`、wechat 信息来自 `wechatService.getWechatUserInfo(...)`。下面按生产逻辑描述。

B 分支三个子流程会触发 INSERT：

#### B2-① 全新用户注册（主路径）
**条件**：手机号在 `sys_user` 中不存在，且当前 unionid/openid 在 auth_login 中查不到匹配（`selectByAuthInfo` 返回 null）。

**写入**：`getSysUserByAuthInfo` → `initUser` → `initUserAndAuthInfo` 新建 `sys_user` **并 `converAndSave` 写入 1 条 auth_login**（`UserServiceImpl.java:507`）。随后还会给该用户绑定手机号（`sysUserService.updatePhone`）。

#### B2-② unionid 已存在但 openid 不匹配 / 对应用户已删
**条件**：手机号不存在，但 unionid 在 auth_login 中已有记录。

**写入**：先在 `selectByAuthInfo`（`LoginServiceImpl.java:599`）里 `converAndSave` **写入 1 条**（userId 取已有 unionid 记录的 userId，openid 为当前 openid）；随后 `getSysUserByAuthInfo` 拿到这条 authLogin，若其 userId 在 `sys_user` 中已被删，则再走 `initUser` **再写 1 条**（本次调用共 2 条）。

#### B1-b 手机号被他人占用
**条件**：手机号已存在，但没有一个匹配用户的 auth_login unionid 与当前一致（`sameUnionidAndPhoneUserOptional` 为空，且 `filterUser` 非空）。

**写入**：`LoginServiceImpl.java:592` 调用 `selectByAuthInfo(params, wechatUserInfo)`（返回值未被使用，是死代码，但副作用仍执行）：若该 unionid 已存在且 openid 不匹配 → `converAndSave` **写入 1 条**；若 unionid 不存在则不写。最终返回 `filterUser.get(0)`（手机号用户）登录。

> ⚠️ **疑似 bug**：此处插入的 auth_login 指向 unionid 原属 userId，但实际登录返回的是手机号用户，造成 auth_login 与登录用户不一致。

**不写入的子流程**：手机号已存在且存在「手机号 + unionid 双匹配」的用户（B1-a）→ 直接登录，不写。

## 4. 一句话结论

该接口**只有传了手机号（分支 B）才可能写入 `sys_user_auth_login`**，共三种情形会 INSERT：

1. **手机号不存在 + unionid/openid 都查不到** → 注册新用户时写入 1 条（主路径）；
2. **手机号不存在 + unionid 已存在但 openid 不匹配（或对应用户已删）** → `selectByAuthInfo` 写入 1 条，用户已删时再追加 1 条；
3. **手机号被他人占用且无 unionid 匹配** → `selectByAuthInfo` 副作用写入 1 条（死代码，且 userId 与登录用户不一致，疑似 bug）。

不传手机号（游客 / 已有 unionid 用户直接登录）**不会**写入。

## 5. 涉及代码位置速查

| 文件 | 行 | 说明 |
|---|---|---|
| `LoginController.java` | 195-204 | 接口入口 |
| `LoginServiceImpl.java` | 525-631 | `wxSixthProductLoginLogin` 主逻辑 |
| `LoginServiceImpl.java` | 528-538, 547 | ⚠️ 调试硬编码（wechatUserInfo / phone） |
| `LoginServiceImpl.java` | 592, 599 | `selectByAuthInfo` 调用点（含写入副作用） |
| `LoginServiceImpl.java` | 1256-1270 | `getSysUserByAuthInfo`（null 时走注册） |
| `LoginServiceImpl.java` | 1284-1286 | `initUser` → `initUserAndAuthInfo` |
| `UserServiceImpl.java` | 490-512 | `initUserAndAuthInfo`（注册时 `converAndSave`） |
| `SysUserAuthLoginServiceImpl.java` | 73-114 | `selectByAuthInfo`（查询 + 隐式写入） |
| `SysUserAuthLoginServiceImpl.java` | 117-132 | `converAndSave` → `save` |
| `SysUserAuthLoginMapper.xml` | 132 | `insertSelective` = `insert into sys_user_auth_login` |
