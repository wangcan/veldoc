-- ==========================================
-- 短信模板配置查询和诊断脚本
-- ==========================================

-- 1. 查询 user-delete 模板的完整配置
SELECT
    id AS '模板ID',
    name AS '模板名称',
    code AS '模板编码',
    nickname AS '模板简称',
    channel_id AS '渠道ID',
    channel_code AS '渠道编码',
    status AS '状态(0启用1禁用)',
    api_template_id AS '短信服务商模板ID',
    content AS '模板内容',
    create_time AS '创建时间',
    update_time AS '更新时间'
FROM system_sms_template
WHERE code = 'user-delete';

-- 2. 查询模板对应的渠道信息
SELECT
    t.id AS template_id,
    t.code AS template_code,
    t.channel_code AS template_channel_code,
    c.id AS channel_id,
    c.code AS channel_code,
    c.status AS channel_status,
    c.signature AS channel_signature,
    c.api_key AS channel_api_key
FROM system_sms_template t
LEFT JOIN system_sms_channel c ON t.channel_id = c.id
WHERE t.code = 'user-delete';

-- 3. 查询所有启用的短信渠道
SELECT
    id AS '渠道ID',
    code AS '渠道编码',
    status AS '状态(0启用1禁用)',
    signature AS '短信签名',
    api_key AS 'API密钥',
    remark AS '备注'
FROM system_sms_channel
WHERE status = 0
ORDER BY id;

-- 4. 查询最近的短信发送日志
SELECT
    id AS '日志ID',
    mobile AS '手机号',
    template_code AS '模板编码',
    template_content AS '模板内容',
    channel_id AS '渠道ID',
    channel_code AS '渠道编码',
    send_status AS '发送状态(0初始化10忽略20成功30失败)',
    send_time AS '发送时间',
    api_send_code AS 'API错误码',
    api_send_msg AS 'API错误信息',
    create_time AS '创建时间'
FROM system_sms_log
WHERE template_code = 'user-delete'
ORDER BY create_time DESC
LIMIT 10;

-- 5. 统计短信发送情况（按状态）
SELECT
    send_status AS '发送状态',
    CASE send_status
        WHEN 0 THEN '初始化'
        WHEN 10 THEN '忽略发送'
        WHEN 20 THEN '发送成功'
        WHEN 30 THEN '发送失败'
        ELSE '未知'
    END AS '状态说明',
    COUNT(*) AS '数量'
FROM system_sms_log
WHERE template_code = 'user-delete'
GROUP BY send_status;

-- 6. 检查是否存在 channel_code 不一致的问题
-- 比较模板中的 channel_code 和实际渠道的 code 是否一致
SELECT
    t.id AS template_id,
    t.code AS template_code,
    t.channel_id AS template_channel_id,
    t.channel_code AS template_channel_code,
    c.id AS actual_channel_id,
    c.code AS actual_channel_code,
    CASE
        WHEN t.channel_code = c.code THEN '一致'
        ELSE '不一致❌'
    END AS '一致性检查'
FROM system_sms_template t
LEFT JOIN system_sms_channel c ON t.channel_id = c.id
WHERE t.code = 'user-delete';

-- 7. 查询所有短信模板（检查是否有重复的 code）
SELECT
    code AS '模板编码',
    COUNT(*) AS '数量',
    GROUP_CONCAT(id) AS '模板ID列表'
FROM system_sms_template
GROUP BY code
HAVING COUNT(*) > 1;
