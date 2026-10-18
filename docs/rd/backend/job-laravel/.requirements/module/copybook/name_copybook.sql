INSERT INTO `name_copybook_layouts` (
    `version_code`, `name`, `content_page_count`, `font`, `has_stroke_order`,
    `two_char_config_code`, `three_char_config_code`, `four_char_config_code`,
    `male_product_code`, `female_product_code`, `status`, `sort`, `remark`, `created_at`, `updated_at`
) VALUES (
    'ncv_1', '36页手写体', '36', 'handwritten', '1',
    'two_p14', 'three_p14', 'four_p14',
    'lztycl519', 'lztycl520', '1', '1', '程序32页+4页其他', NOW(), NOW()
), (
    'ncv_1', '36页楷体', '36', 'standard', '1',
    'two_p14', 'three_p14', 'four_p14',
    'lztycl519', 'lztycl520', '1', '2', '程序32页+4页其他', NOW(), NOW()
), (
    'ncv_1', '52页手写体', '52', 'handwritten', '1',
    'two_p14', 'three_p14', 'four_p14',
    'lztycl541', 'lztycl542', '1', '3', '程序38页+14页其他', NOW(), NOW()
), (
    'ncv_1', '36页楷体', '36', 'standard', '1',
    'two_p14', 'three_p14', 'four_p14',
    'lztycl541', 'lztycl542', '1', '4', '程序38页+14页其他', NOW(), NOW()
);


