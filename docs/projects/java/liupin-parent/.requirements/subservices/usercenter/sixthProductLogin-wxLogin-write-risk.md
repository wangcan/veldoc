# 风险评估：`wxSixthProductLoginLogin` 在「手机号被他人占用」分支写入 `sys_user_auth_login`

> 需求：`.requirements/subservices/usercenter/task.txt` 需求项 3。
> 改动位置：`LoginServiceImpl.java:575-581`（原 575-579 注释取消，并在 return 前增加 `converAndSave` 写入）。

## 改动回顾

```java
// 原：手机号已存在但无 unionid 匹配时，else 分支为空，掉到下方 586 行注册流程
// 改后：取 filterUser.get(0) → converAndSave(其 userId, wechatUserInfo, params) → 登录返回
if (CollectionUtil.isNotEmpty(filterUser)) {
    SysUser sysUser = filterUser.get(0);
    sysUserAuthLoginService.converAndSave(sysUser.getId(), wechatUserInfo, params);
    asyncTaskExecutor.loginNotify(platFormHandler, sysUser);
    return generateLoginInfo(sysUser);
}
```

`converAndSave` 等价于 `insert into sys_user_auth_login(user_id=sysUser.id, union_id=wechatUserInfo.unionid, open_id=wechatUserInfo.openid, plat_id=params.platId, terminal=params.terminal, ...)`（`SysUserAuthLoginServiceImpl.java:117-132`）。

## 风险评估

### 风险 1（高）：账号绑定语义——把当前微信身份绑到「他人的手机号账户」上

本分支进入条件：手机号已存在 + 该手机号用户的 auth_login **没有**当前 unionid（`sameUnionidAndPhoneUserOptional` 为空，`LoginServiceImpl.java:564-573`）。

即 `filterUser.get(0)` 是「手机号已被其占用、但微信身份不是当前这个人」的用户。`converAndSave` 把**当前微信 unionid/openid 绑定到这个用户的 userId**。

- 后果：此后当前微信用户凭 unionid 即可登录到该手机号账户。
- 若手机号是误填/共用/被恶意使用，等于把他人账户的微信登录权交给了当前微信用户 → **账号接管风险**。
- 这与该分支日志「手机号已存在被他人使用」的语义冲突：被他人使用本应拒绝或走重新注册，而非绑定。

### 风险 2（中）：unionid 一对多绑定，后续登录行为不确定

当前 unionid 可能已绑定到另一个用户 Y（无手机号或不同手机号），现在又绑到 `filterUser.get(0)`（用户 X）。一条 unionid → 多条 auth_login、多个 userId。

- `selectByUnionId` 返回多条，`getBindPhoneUserByAuthLogin`（`LoginServiceImpl.java:736-777`）按 `miniProgramsCode` 优先级（sixth-product → tablet_mini_program → platId=1）挑一条返回。
- 同一微信用户在不同入口可能登录到不同账户，行为不确定且难复现。

### 风险 3（中）：可能触发唯一约束冲突 → 登录失败

仓库内未找到 `sys_user_auth_login` 的 DDL，**无法确认是否存在唯一索引**（如 `(union_id, plat_id)` 或 `(open_id, plat_id, terminal)`）。

- 若存在，且当前 unionid/openid 已有记录，`converAndSave` 直接 INSERT 会抛 `DuplicateKeyException`。
- 方法标注 `@Transactional`，异常会导致整个登录事务回滚 → **登录失败**。
- 建议：DBA 确认 `sys_user_auth_login` 索引情况；若存在唯一索引，应在写入前查重（参考 `converAndSaveForZheMeiMoBao` 的先查后写模式，`SysUserAuthLoginServiceImpl.java:152-171`）。

### 风险 4（中）：行为语义变更——由「重新注册」改为「绑定已有账户登录」

原代码该 else 分支为空，会继续走到 `LoginServiceImpl.java:586` 的注册流程（`selectByAuthInfo` + `getSysUserByAuthInfo`，无手机号则注册新用户并绑定手机号）。改动后直接 return，**不再走注册**。

- 改善点：避免了原 586 行 `selectByAuthInfo` 可能的双重写入。
- 风险点：语义从「重新注册新账户」变成「复用现有手机号账户并绑定微信」。需确认符合产品预期（与日志「使用 unionid 登录或者重新注册」的「重新注册」描述不一致）。

### 风险 5（低）：`filterUser.get(0)` 的不确定性

`sysUserService.selectByPhoneList` 可能返回多个同手机号用户，`.get(0)` 取第一个，顺序依赖数据库返回。绑定到「不确定是哪一个」的手机号用户，可能并非预期。

### 风险 6（低）：调试硬编码仍在

当前工作区 `LoginServiceImpl.java:528-538, 547` 的 `wechatUserInfo`（openid/unionid）与 `phone="13811974106"` 仍为硬编码调试值。改动本身不依赖这些硬编码，但合并/测试前必须恢复，否则所有请求都走分支 B 且写入的 unionid/openid 固定，会污染线上 auth_login 数据。

## 综合结论

**有风险，且风险 1 属业务安全级。** 改动把「他人手机号账户」与「当前微信身份」做了硬绑定，可能导致账号接管与 unionid 一对多紊乱。建议：

1. 先确认产品语义：该分支应「拒绝登录」「重新注册新账户」还是「绑定到该手机号账户」？若非第三种，不应执行此 `converAndSave`。
2. DBA 确认 `sys_user_auth_login` 唯一索引；若存在，写入前查重或改用 `converAndSaveForZheMeiMoBao` 模式。
3. 合并前清理 `LoginServiceImpl.java:528-538, 547` 的调试硬编码。
4. 若确实要绑定，建议加日志记录「unionid 由 user Y 改绑到 user X」并人工审核，或改为异步/队列处理。
