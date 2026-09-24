-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2026-09-18 08:58:52
-- 服务器版本： 8.0.37
-- PHP 版本： 8.3.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `online_knowledge`
--

-- --------------------------------------------------------

--
-- 表的结构 `wp_affair`
--

CREATE TABLE `wp_affair` (
  `id` int NOT NULL COMMENT 'ID',
  `affair_type` varchar(30) NOT NULL DEFAULT '' COMMENT '类型',
  `accurate` varchar(60) NOT NULL DEFAULT '' COMMENT '精准度',
  `year` smallint NOT NULL DEFAULT '0' COMMENT '年',
  `month` tinyint(1) NOT NULL DEFAULT '0' COMMENT '月',
  `day` tinyint(1) NOT NULL DEFAULT '0' COMMENT '日',
  `title` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '名称',
  `country_code` varchar(100) NOT NULL DEFAULT '' COMMENT '国家',
  `brief` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '简述',
  `description` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '描述',
  `baidu_url` varchar(300) NOT NULL DEFAULT '' COMMENT '百度百科URL',
  `path_point` varchar(200) NOT NULL DEFAULT '' COMMENT '特定路径',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- 表的结构 `wp_century`
--

CREATE TABLE `wp_century` (
  `id` int NOT NULL COMMENT 'ID',
  `code` varchar(80) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '代码',
  `name` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `brief` varchar(2000) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简介',
  `chronology_url` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '百度年表URL',
  `baidu_url` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '百度百科URL',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='世纪';

-- --------------------------------------------------------

--
-- 表的结构 `wp_chronology`
--

CREATE TABLE `wp_chronology` (
  `id` int NOT NULL COMMENT 'ID',
  `code` varchar(80) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '代码',
  `century_code` varchar(80) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '世纪代码',
  `name` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `brief` varchar(2000) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简介',
  `baidu_url` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '百度百科URL',
  `period_brief` varchar(2000) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '纪年简介',
  `period_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '几年标记',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='年表';

-- --------------------------------------------------------

--
-- 表的结构 `wp_country`
--

CREATE TABLE `wp_country` (
  `id` int NOT NULL COMMENT 'ID',
  `code` varchar(80) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '代码',
  `sort` varchar(60) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '类别',
  `name` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `name_english` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '英文名',
  `name_short` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简称',
  `name_full` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称全称',
  `begin_end` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '起止时间',
  `region` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '所在区域',
  `capital` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '首都',
  `first_emperor` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '开国皇帝',
  `area` decimal(20,2) NOT NULL DEFAULT '0.00' COMMENT '面积',
  `population` decimal(20,2) NOT NULL DEFAULT '0.00' COMMENT '人口',
  `duration` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '年数',
  `brief` varchar(2000) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简介',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `baidu_url` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '百度百科URL',
  `knowledge_path` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '	知识路径	',
  `path_old` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '知识路径',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `is_important` tinyint(1) NOT NULL DEFAULT '0' COMMENT '重要'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='国家';

-- --------------------------------------------------------

--
-- 表的结构 `wp_country_catalog`
--

CREATE TABLE `wp_country_catalog` (
  `id` int NOT NULL COMMENT 'ID',
  `bigsort` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '一级分类',
  `parent_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '分类',
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '代码',
  `name` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `name_english` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '英文名',
  `description` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '描述',
  `baidu_url` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '百度百科URL',
  `path_point` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识路径',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='丛书';

-- --------------------------------------------------------

--
-- 表的结构 `wp_country_listing`
--

CREATE TABLE `wp_country_listing` (
  `id` int NOT NULL COMMENT 'ID',
  `bigsort` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '一级分类',
  `catalog_code` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '分类代码',
  `country_code` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '国家/王朝代码',
  `title` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名号',
  `description` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '描述',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='名号';

-- --------------------------------------------------------

--
-- 表的结构 `wp_period`
--

CREATE TABLE `wp_period` (
  `id` int NOT NULL COMMENT 'ID',
  `period_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '类型',
  `type_ext` varchar(60) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '补充',
  `country_code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '国家代码',
  `figure_code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '君主',
  `eraname` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '年号',
  `term` smallint NOT NULL DEFAULT '0' COMMENT '任数',
  `term_num` tinyint(1) NOT NULL DEFAULT '0' COMMENT '本人任数',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '标题',
  `brief` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '描述',
  `baidu_url` varchar(200) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '百度百科',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `start_accurate` varchar(30) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '精准度',
  `start_year` smallint NOT NULL DEFAULT '0' COMMENT '起始年',
  `end_accurate` varchar(30) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '结束日期精准度',
  `end_year` smallint NOT NULL DEFAULT '0' COMMENT '结束年',
  `start_end_detail` varchar(200) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '起止时间字符串',
  `show_type_base` tinyint(1) NOT NULL DEFAULT '0' COMMENT '展示类型',
  `deal_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '处理状态',
  `extfield` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '附加字段'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='历史时期';

-- --------------------------------------------------------

--
-- 表的结构 `wp_period_year`
--

CREATE TABLE `wp_period_year` (
  `id` int NOT NULL COMMENT 'ID',
  `period_id` int NOT NULL DEFAULT '0' COMMENT '时期ID',
  `year` smallint NOT NULL DEFAULT '0' COMMENT '年',
  `period_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类型',
  `country_code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '国家代码',
  `figure_code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '君主',
  `eraname` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '年号',
  `title` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `show_type_base` tinyint(1) NOT NULL DEFAULT '0' COMMENT '基础展示类型',
  `show_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '展示类型'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='纪年信息';

--
-- 转储表的索引
--

--
-- 表的索引 `wp_affair`
--
ALTER TABLE `wp_affair`
  ADD UNIQUE KEY `id` (`id`) USING BTREE;

--
-- 表的索引 `wp_century`
--
ALTER TABLE `wp_century`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_chronology`
--
ALTER TABLE `wp_chronology`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_country`
--
ALTER TABLE `wp_country`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_country_catalog`
--
ALTER TABLE `wp_country_catalog`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_country_listing`
--
ALTER TABLE `wp_country_listing`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_period`
--
ALTER TABLE `wp_period`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_period_year`
--
ALTER TABLE `wp_period_year`
  ADD PRIMARY KEY (`id`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `wp_affair`
--
ALTER TABLE `wp_affair`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_century`
--
ALTER TABLE `wp_century`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_chronology`
--
ALTER TABLE `wp_chronology`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_country`
--
ALTER TABLE `wp_country`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_country_catalog`
--
ALTER TABLE `wp_country_catalog`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_country_listing`
--
ALTER TABLE `wp_country_listing`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_period`
--
ALTER TABLE `wp_period`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_period_year`
--
ALTER TABLE `wp_period_year`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
