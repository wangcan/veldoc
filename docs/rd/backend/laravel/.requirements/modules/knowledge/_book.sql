-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2026-09-17 19:57:21
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
-- 表的结构 `wp_book`
--

CREATE TABLE `wp_book` (
  `id` int NOT NULL COMMENT 'ID',
  `code` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '书籍代码',
  `category` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '主分类',
  `name` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `book_path` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '图书路径',
  `path_label` varchar(60) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '路径标签',
  `path_point` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '特定路径',
  `path_old` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '知识路径',
  `position` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '推荐位',
  `nationality` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '国籍',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `description` varchar(2000) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '描述',
  `baidu_url` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '百度百科',
  `douban_url` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '豆瓣URL',
  `author` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '作者',
  `is_ancientread` tinyint(1) NOT NULL DEFAULT '0' COMMENT '古籍阅读',
  `is_onlineread` tinyint(1) NOT NULL DEFAULT '0' COMMENT '在线阅读',
  `is_otherread` tinyint(1) NOT NULL DEFAULT '0' COMMENT '文档',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `deal_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '处理状态',
  `publish_at` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '发布时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `extfield` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '附件字段'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `wp_book_catalog`
--

CREATE TABLE `wp_book_catalog` (
  `id` int NOT NULL COMMENT 'ID',
  `bigsort` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '一级分类',
  `sort` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '分类',
  `code` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '代码',
  `name` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `title` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '标题',
  `brief` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简介',
  `book_num` smallint NOT NULL DEFAULT '0' COMMENT '图书数',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='丛书';

-- --------------------------------------------------------

--
-- 表的结构 `wp_book_listing`
--

CREATE TABLE `wp_book_listing` (
  `id` int NOT NULL COMMENT 'ID',
  `book_code` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '书籍代码',
  `catalog_code` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '丛书代码',
  `catalog_volume_id` int NOT NULL DEFAULT '0' COMMENT '分类',
  `serial` smallint NOT NULL DEFAULT '0' COMMENT '序号',
  `name` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `brief` varchar(2000) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简介',
  `author` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '作者',
  `author_alias` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '作者别名',
  `translator` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '译者',
  `figure` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '作者信息',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `extfield` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '附加字段'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `wp_book_volume`
--

CREATE TABLE `wp_book_volume` (
  `id` int NOT NULL COMMENT 'ID',
  `catalog_code` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '丛书代码',
  `name` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `brief` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简介',
  `book_num` smallint NOT NULL DEFAULT '0' COMMENT '图书数量',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `knowledge_path` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '知识路径',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `extfield` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '代码'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='丛书卷别';

-- --------------------------------------------------------

--
-- 表的结构 `wp_chapter`
--

CREATE TABLE `wp_chapter` (
  `id` int NOT NULL COMMENT 'ID',
  `code` varchar(300) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '代码',
  `chapter_type` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '章节类型',
  `serial` int NOT NULL DEFAULT '0' COMMENT '序号',
  `book_code` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '书籍代码',
  `name` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名称',
  `title` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '标题',
  `author` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '作者',
  `description` varchar(2000) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '描述',
  `brief` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '简介',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `knowledge_path` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '知识路径',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `extfield` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '附加字段'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `wp_figure_listing`
--

CREATE TABLE `wp_figure_listing` (
  `id` int NOT NULL COMMENT 'ID',
  `type` varchar(30) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '类型',
  `figure_code` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '人物代码',
  `country_code` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '国家/王朝代码',
  `orderlist` int NOT NULL DEFAULT '0' COMMENT '排序',
  `book_code` varchar(200) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '书籍代码',
  `chapter_code` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '章节代码',
  `muwiki_code` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '词条代码',
  `title` varchar(100) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '名号',
  `description` varchar(500) CHARACTER SET utf8mb3 NOT NULL DEFAULT '' COMMENT '描述',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='名号';

--
-- 转储表的索引
--

--
-- 表的索引 `wp_book`
--
ALTER TABLE `wp_book`
  ADD PRIMARY KEY (`code`),
  ADD UNIQUE KEY `id` (`id`) USING BTREE;

--
-- 表的索引 `wp_book_catalog`
--
ALTER TABLE `wp_book_catalog`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_book_listing`
--
ALTER TABLE `wp_book_listing`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_book_volume`
--
ALTER TABLE `wp_book_volume`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_chapter`
--
ALTER TABLE `wp_chapter`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `wp_figure_listing`
--
ALTER TABLE `wp_figure_listing`
  ADD PRIMARY KEY (`id`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `wp_book`
--
ALTER TABLE `wp_book`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_book_catalog`
--
ALTER TABLE `wp_book_catalog`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_book_listing`
--
ALTER TABLE `wp_book_listing`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_book_volume`
--
ALTER TABLE `wp_book_volume`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_chapter`
--
ALTER TABLE `wp_chapter`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- 使用表AUTO_INCREMENT `wp_figure_listing`
--
ALTER TABLE `wp_figure_listing`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
