/*
 Navicat Premium Dump SQL

 Source Server         : mysqlconnection
 Source Server Type    : MySQL
 Source Server Version : 80041 (8.0.41)
 Source Host           : localhost:3306
 Source Schema         : videoapp

 Target Server Type    : MySQL
 Target Server Version : 80041 (8.0.41)
 File Encoding         : 65001

 Date: 23/07/2025 18:10:33
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `comment_id` bigint NOT NULL AUTO_INCREMENT,
  `video_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `video_id`(`video_id` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (1, 101, 1001, '你好', '2025-07-21 17:29:54', '2025-07-21 17:30:06');
INSERT INTO `comment` VALUES (5, 101, 1001, '1', '2025-07-21 09:49:28', '2025-07-21 09:49:28');
INSERT INTO `comment` VALUES (6, 101, 1002, 'very good', '2025-07-22 01:44:30', '2025-07-22 01:44:30');
INSERT INTO `comment` VALUES (7, 101, 1002, '很好', '2025-07-22 01:45:01', '2025-07-22 01:45:01');
INSERT INTO `comment` VALUES (8, 101, 1003, '11111', '2025-07-22 01:46:44', '2025-07-22 01:46:44');
INSERT INTO `comment` VALUES (9, 501, 1001, '切切切', '2025-07-22 02:22:13', '2025-07-22 02:22:13');
INSERT INTO `comment` VALUES (10, 501, 1002, '1111', '2025-07-22 02:24:47', '2025-07-22 02:24:47');
INSERT INTO `comment` VALUES (11, 501, 1003, '1', '2025-07-22 02:58:24', '2025-07-22 02:58:24');
INSERT INTO `comment` VALUES (12, 501, 1003, '1', '2025-07-22 02:58:40', '2025-07-22 02:58:40');
INSERT INTO `comment` VALUES (13, 501, 1003, '11', '2025-07-22 02:58:43', '2025-07-22 02:58:43');
INSERT INTO `comment` VALUES (14, 501, 1003, '1111', '2025-07-22 02:58:46', '2025-07-22 02:58:46');
INSERT INTO `comment` VALUES (15, 501, 1003, '11111', '2025-07-22 02:58:48', '2025-07-22 02:58:48');
INSERT INTO `comment` VALUES (16, 501, 1001, 'nihao', '2025-07-23 01:47:34', '2025-07-23 01:47:34');

-- ----------------------------
-- Table structure for danmaku
-- ----------------------------
DROP TABLE IF EXISTS `danmaku`;
CREATE TABLE `danmaku`  (
  `danmaku_id` bigint NOT NULL AUTO_INCREMENT,
  `video_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `time_offset` int NOT NULL,
  `color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `position` tinyint NOT NULL DEFAULT 0,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`danmaku_id`) USING BTREE,
  INDEX `video_id`(`video_id` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `danmaku_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `danmaku_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of danmaku
-- ----------------------------

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `favorite_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `category_id` bigint NOT NULL,
  `video_id` bigint NOT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`favorite_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `video_id`(`video_id` ASC) USING BTREE,
  CONSTRAINT `favorite_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `favorite_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES (1, 1001, 0, 101, '2025-07-23 03:49:41');
INSERT INTO `favorite` VALUES (2, 1002, 0, 101, '2025-07-23 04:07:47');

-- ----------------------------
-- Table structure for like
-- ----------------------------
DROP TABLE IF EXISTS `like`;
CREATE TABLE `like`  (
  `like_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `video_id` bigint NULL DEFAULT NULL,
  `comment_id` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`like_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `video_id`(`video_id` ASC) USING BTREE,
  INDEX `comment_id`(`comment_id` ASC) USING BTREE,
  CONSTRAINT `like_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `like_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `like_ibfk_3` FOREIGN KEY (`comment_id`) REFERENCES `comment` (`comment_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of like
-- ----------------------------

-- ----------------------------
-- Table structure for short_video_collect
-- ----------------------------
DROP TABLE IF EXISTS `short_video_collect`;
CREATE TABLE `short_video_collect`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '收藏记录ID',
  `user_id` bigint NOT NULL COMMENT '用户ID，关联user表',
  `video_id` bigint NOT NULL COMMENT '视频ID，关联video表 (category=4)',
  `collect_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_video_collect`(`user_id` ASC, `video_id` ASC) USING BTREE,
  INDEX `video_id`(`video_id` ASC) USING BTREE,
  CONSTRAINT `short_video_collect_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `short_video_collect_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户短视频收藏表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of short_video_collect
-- ----------------------------
INSERT INTO `short_video_collect` VALUES (4, 1001, 510, '2025-07-11 14:35:00');
INSERT INTO `short_video_collect` VALUES (5, 1002, 504, '2025-07-12 18:00:00');
INSERT INTO `short_video_collect` VALUES (6, 1002, 505, '2025-07-12 18:05:00');
INSERT INTO `short_video_collect` VALUES (7, 1002, 508, '2025-07-13 10:20:00');
INSERT INTO `short_video_collect` VALUES (8, 1001, 505, '2025-07-22 09:08:56');
INSERT INTO `short_video_collect` VALUES (10, 1003, 501, '2025-07-22 09:52:49');
INSERT INTO `short_video_collect` VALUES (14, 1001, 504, '2025-07-22 10:22:53');
INSERT INTO `short_video_collect` VALUES (34, 1001, 501, '2025-07-23 03:53:59');
INSERT INTO `short_video_collect` VALUES (36, 1002, 502, '2025-07-23 04:07:19');

-- ----------------------------
-- Table structure for short_video_history
-- ----------------------------
DROP TABLE IF EXISTS `short_video_history`;
CREATE TABLE `short_video_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '历史记录ID',
  `user_id` bigint NOT NULL COMMENT '用户ID，关联user表',
  `video_id` bigint NOT NULL COMMENT '视频ID，关联video表 (category=4)',
  `watch_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '观看时间',
  `last_watched_progress` int NULL DEFAULT 0 COMMENT '上次观看进度，单位秒 (可选)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_watch_time`(`user_id` ASC, `watch_time` DESC) USING BTREE,
  INDEX `idx_video_watch_time`(`video_id` ASC, `watch_time` DESC) USING BTREE,
  CONSTRAINT `short_video_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `short_video_history_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户短视频历史记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of short_video_history
-- ----------------------------
INSERT INTO `short_video_history` VALUES (1, 1001, 501, '2025-07-10 08:55:00', 120);
INSERT INTO `short_video_history` VALUES (2, 1001, 502, '2025-07-10 10:05:00', 30);
INSERT INTO `short_video_history` VALUES (3, 1001, 507, '2025-07-11 14:00:00', 0);
INSERT INTO `short_video_history` VALUES (4, 1001, 509, '2025-07-11 14:28:00', 60);
INSERT INTO `short_video_history` VALUES (6, 1002, 504, '2025-07-12 17:50:00', 90);
INSERT INTO `short_video_history` VALUES (7, 1002, 506, '2025-07-12 19:10:00', 45);
INSERT INTO `short_video_history` VALUES (8, 1002, 508, '2025-07-13 10:15:00', 150);

-- ----------------------------
-- Table structure for swipers
-- ----------------------------
DROP TABLE IF EXISTS `swipers`;
CREATE TABLE `swipers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '连接',
  `imgurl` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '轮播图像',
  `state` int NULL DEFAULT 0 COMMENT '状态',
  `order` int NULL DEFAULT 0 COMMENT '排序',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of swipers
-- ----------------------------
INSERT INTO `swipers` VALUES (1, '朝雪录', 'https://www.baidu.com', 'tv1.png', 0, 0, '2025-07-03 05:21:23', '2025-07-03 05:21:25');
INSERT INTO `swipers` VALUES (2, '正当防卫', 'https://www.baidu.com', 'tv2.png', 0, 0, '2025-07-03 05:21:55', '2025-07-03 05:21:57');
INSERT INTO `swipers` VALUES (3, '淬火年代', 'htts://www.baidu.com', 'tv3.png', 0, 0, '2025-07-03 05:22:27', '2025-07-03 05:22:30');
INSERT INTO `swipers` VALUES (4, '水饺皇后', 'http://drive.yyunxi6.info/ToysGames', 'movie1.png', 0, 114, '2009-09-13 12:49:48', '2006-09-24 13:35:40');
INSERT INTO `swipers` VALUES (5, '帕丁顿熊3', 'http://drive.shihan9.com/Others', 'movie2.png', 0, 852, '2017-06-18 23:46:28', '2020-12-08 06:15:55');
INSERT INTO `swipers` VALUES (6, '星际宝贝史迪奇', 'https://image.jialuy9.info/Baby', 'movie3.png', 0, 897, '2016-11-08 21:47:23', '2022-07-19 23:06:04');
INSERT INTO `swipers` VALUES (7, '仙宠', 'http://drive.otsuka1.us/Food', 'anime1.png', 0, 269, '2011-05-02 16:27:28', '2018-01-21 10:04:27');
INSERT INTO `swipers` VALUES (8, '奥美迦奥特曼', 'https://auth.zitao1944.co.jp/ClothingShoesandJewelry', 'anime2.png', 0, 698, '2010-02-27 18:08:00', '2024-12-11 20:31:27');
INSERT INTO `swipers` VALUES (9, '海贼王', 'https://image.ngsumwi.jp/Others', 'anime3.png', 0, 461, '2005-05-02 15:47:47', '2010-04-13 13:32:23');
INSERT INTO `swipers` VALUES (10, '舌尖上的中国', 'http://www.tsubasa628.net/AutomotivePartsAccessories', 'documentary1.png', 0, 110, '2024-02-08 22:37:43', '2020-02-11 01:01:09');
INSERT INTO `swipers` VALUES (11, '单挑荒野 第二季', 'http://auth.waisant326.co.jp/CenturionGardenOutdoor', 'documentary2.png', 0, 678, '2003-01-16 04:14:40', '2011-10-23 23:05:45');
INSERT INTO `swipers` VALUES (12, '航拍中国', 'https://www.fengshi20.org/AppsGames', 'documentary3.png', 0, 933, '2010-08-13 21:51:19', '2011-08-09 01:31:01');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '快去取一个昵称吧~',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `register_time` datetime NOT NULL,
  `status` tinyint NOT NULL DEFAULT 0,
  `user_level` int NOT NULL DEFAULT 1,
  `last_login_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1005 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1001, 'user1', 'e10adc3949ba59abbe56e057f20f883e', '测试用户', '1001.png', '13800138000', 'testuser@example.com', '2025-07-20 16:27:35', 1, 1, '2025-07-20 16:27:35');
INSERT INTO `user` VALUES (1002, 'user2', '123456', 'xx', '1002.png', '12345678912', 'user2@example.com', '2025-07-20 16:27:35', 1, 1, '2025-07-20 16:27:35');
INSERT INTO `user` VALUES (1003, 'user3', 'e10adc3949ba59abbe56e057f20f883e', '用户990520', '3.png', NULL, NULL, '2025-07-21 03:53:10', 0, 1, NULL);
INSERT INTO `user` VALUES (1004, '111', '96e79218965eb72c92a549dd5a330112', '用户530359', 'file-1753241142582-964228049.jpg', NULL, NULL, '2025-07-23 09:55:30', 0, 1, NULL);

-- ----------------------------
-- Table structure for user_profile
-- ----------------------------
DROP TABLE IF EXISTS `user_profile`;
CREATE TABLE `user_profile`  (
  `profile_id` bigint NOT NULL AUTO_INCREMENT,
  `gender` tinyint NULL DEFAULT 0,
  `birthday` datetime NULL DEFAULT NULL,
  `signature` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `update_time` datetime NOT NULL,
  `user_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`profile_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `user_profile_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_profile
-- ----------------------------
INSERT INTO `user_profile` VALUES (1, 1, '1990-01-01 00:00:00', '这是一个测试用户', '2025-07-20 16:27:35', 1001);
INSERT INTO `user_profile` VALUES (2, 1, '2021-10-20 00:00:00', '这是另一个测试用户', '2025-07-20 16:27:35', 1002);

-- ----------------------------
-- Table structure for video
-- ----------------------------
DROP TABLE IF EXISTS `video`;
CREATE TABLE `video`  (
  `video_id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `cover_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `video_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `duration` int NOT NULL,
  `status` tinyint NOT NULL DEFAULT 0,
  `view_count` bigint NOT NULL DEFAULT 0,
  `like_count` bigint NOT NULL DEFAULT 0,
  `publish_time` datetime NULL DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  `category` int NOT NULL,
  PRIMARY KEY (`video_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 511 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of video
-- ----------------------------
INSERT INTO `video` VALUES (101, '琅琊榜', '十二年前七万赤焰军被奸人所害导致全军覆没，冤死梅岭，只剩少帅林殊侥幸生还。十二年后林殊改头换面化身“麒麟才子”梅长苏（胡歌 饰），建立江左盟，以“琅琊榜”第一才子的身份重返帝都。梅长苏背负血海深仇，暗中帮助昔日挚友靖王（王凯 饰）周旋于太子（高鑫 饰）与誉 王（黄维德 饰）的斗争之中，同时又遇到了昔日未婚妻——云南王郡主穆霓凰（刘涛 饰）却不能相见。梅长苏以病弱之躯为昭雪冤案、为振兴河山，踏上了一条黑暗又惊心动魄的夺嫡之路。', 'langyabang.png', 'https://videos.example.com/langyabang.mp4', 45, 1, 1234567, 89012, '2024-01-15 10:00:00', '2024-01-10 08:30:00', '2025-07-10 15:45:00', 0);
INSERT INTO `video` VALUES (102, '老友记 第一季', '莫妮卡（柯特妮·考克斯 ）、钱德（马修·派瑞）、瑞秋（詹妮弗·安妮斯顿）、菲比（莉莎·库卓）、乔伊（马特·理勃兰）和罗斯（大卫·休谟）是彼此最好的朋友，一起走过十年岁月的点点滴滴。虽然老友们各有各的性格特点，也会有矛盾和争执，但对于彼此，他们永远be there for you.\r\n　　故事开始在Central Perk咖啡馆里，婚礼上落荒而逃的瑞秋闯进来寻找老同学莫妮卡。莫妮卡的哥哥刚刚离婚，而他从小暗恋的人正是这个落跑新娘瑞秋。瑞秋在莫妮卡家住了下来，决定不再做爸爸的女孩儿，真正的步入社会，于是在其他老友的帮助下，她上路了，从二十多岁初入社会，到三十多岁成家立业，他们一走就是十年。\r\n　　十年间风风雨雨，在嬉笑怒骂中，在离别团聚中，他们向我们讲述着友情、爱情还有生活。让我们和他们一起开怀大笑或是黯然神伤。', 'friends.png', 'https://videos.example.com/friends.mp4', 22, 1, 5678901, 34567, '2024-05-18 13:10:00', '2024-04-20 08:30:00', '2025-07-06 15:40:00', 0);
INSERT INTO `video` VALUES (103, '甄嬛传', '时为满清雍正元年，结束了血腥的夺位之争，新的君主（陈建斌 饰）继位，国泰民安，政治清明，但在一片祥和的表象之下，一股暗流蠢蠢欲动。尤其后宫，华妃（蒋欣 饰）与皇后（蔡少芬 饰）分庭抗礼，各方势力裹挟其中，凶险异常。在太后（刘雪华 饰）的主持下，一场盛大的选秀拉开帷幕。以 此为机缘，美丽善良的女孩——大理寺少卿甄远道长女甄嬛（孙俪 饰）意外得到雍正的赏识，从此步入皇宫。在皇后和华妃两方势力的夹击下，甄嬛小心周旋，忍辱负重，命悬一线。她不得不用自己的智慧保护自己，又一次次被卷入残酷的宫闱斗争之中……\r\n　　本片根据流潋紫的同名小说原著改编。', 'zhenhuanzhuan.png', 'https://videos.example.com/empresses-in-the-palace.mp4', 45, 1, 9012345, 78901, '2024-09-18 14:55:00', '2024-08-25 09:30:00', '2025-07-02 16:10:00', 0);
INSERT INTO `video` VALUES (104, '觉醒年代', '本剧以1915年《青年杂志》问世到1921年《新青年》成为中国共产党机关刊物为贯穿，展现了从新文化运动到中国共产党建立这段波澜壮阔的历史画卷，讲述觉醒年代的百态人生。该剧以李大钊、陈独秀、胡适从相识、相知到分手，走上不同人生道路的传奇故事为基本叙事线，以毛泽东、陈延年、陈乔年、邓中夏、赵世炎等革命青年追求真理的坎坷经历为辅助线，艺术地再现了一批名冠中华的文化大师和一群理想飞扬的热血青年演绎出的一段充满激情、燃烧理想的澎湃岁月。', 'juexingniandai.png', 'https://videos.example.com/age-of-awakening.mp4', 45, 1, 7167890, 56789, '2024-06-15 12:20:00', '2024-05-20 09:15:00', '2025-06-16 14:55:00', 0);
INSERT INTO `video` VALUES (105, '黑镜：潘达斯奈基', '菲恩·怀特海德、威尔·保尔特等主演的《黑镜》特别影片[黑镜：潘达斯奈基]首发剧照！影片将聚焦一位年轻的程序员，他将一部奇幻小说改编为游戏。然而很快现实和虚拟世界混合在一起，开始造成混乱。影片充满大量的暴力元素。该片将于12月28日登陆Netflix。', 'blackmirror.png', 'https://videos.example.com/black-mirror-bandersnatch.mp4', 150, 1, 2301234, 90123, '2024-10-25 14:00:00', '2024-09-30 09:45:00', '2025-06-12 14:45:00', 0);
INSERT INTO `video` VALUES (106, '西部世界', '故事设定在未来世界，在一个庞大的高科技成人主题乐园中，有着拟真人的机器“接待员”能让游客享尽情欲、暴力等欲望的放纵，主要叙述被称为“西部世界”的未来主题公园。它提供给游客杀戮与性欲的满足。\r\n　　但是在这世界下，各种暗流涌动。部分机器人出现自我觉醒，发现了自己只是作为故事角色的存在，并且想摆脱乐园对其的控制；乐园的管理层害怕乐园的创造者控制着乐园的一切而试图夺其控制权，而乐园创造者则不会善罢甘休并且探寻其伙伴创造者曾经留下的谜团；而买下乐园的一名高管试图重新发现当年的旅程留下的谜团。', 'westworld.png', 'https://videos.example.com/westworld-awakening.mp4', 60, 1, 6745678, 45678, '2025-02-25 18:40:00', '2025-01-30 09:30:00', '2025-06-08 14:55:00', 0);
INSERT INTO `video` VALUES (107, '权力的游戏 第八季', '　HBO剧集《权力的游戏》第八季将于2019年4月14日播出，本季共6集。\r\n　　故事发展至第八季，重返临冬城的琼恩·雪诺（基特·哈灵顿 Kit Harington 饰）在布兰·史塔克（伊萨克·亨普斯特德-怀特 Isaac Hempstead-Wright 饰）口中得知了自己身 世的秘密，让他与丹妮莉丝·塔格利安（艾米莉亚·克拉克 Emilia Clarke 饰）的关系蒙上了一层冰霜。\r\n　　狼家少年们终于迎来了久违的重逢。攸伦将黄金团带给众叛亲离的瑟后试图取得她的信任。临冬城大战一触即发，人类能否战胜夜王？', 'gameofthrones.png', 'https://videos.example.com/game-of-thrones-the-long-night.mp4', 60, 1, 9012345, 78901, '2025-07-05 18:35:00', '2025-06-10 09:30:00', '2025-05-27 14:35:00', 0);
INSERT INTO `video` VALUES (108, '绝命律师 第一季', '本剧为《绝命毒师》的前传，讲述律师Saul Goodman的故事。本剧采用非线性叙事。Saul Goodman初次登场时并不叫Saul Goodman，他的名字叫Jimmy McGill，当时只是一个小律师与调查员Mike在一起工作，过着养家糊口的日子。本剧将描述Jimmy转变为Saul Goodman的全过程。', 'bettercallsaul.png', 'https://videos.example.com/better-call-saul.mp4', 55, 1, 1234567, 89012, '2025-06-15 12:10:00', '2025-05-20 09:15:00', '2025-06-04 14:15:00', 0);
INSERT INTO `video` VALUES (109, '长安的荔枝', '故事讲述了主人公李善德（雷佳音 饰）在同僚的欺瞒之下从监事变身“荔枝使”，被迫接下一道为贺贵妃生辰、需从岭南运送新鲜荔枝到长安的“死亡”任务，荔枝“一日色变，两日香变，三日味变”，而岭南距长安五千余里，山水迢迢，这是个不可能完成的任务。为保女儿李袖儿余生安稳，李善德无奈启程前往岭南；与此同时，替左相寻找扳倒右相敛财罪证的郑平安（岳云鹏 饰）已先一步抵达岭南。各自身负重任的郎舅二人在他乡偶遇，意外结识胡商商会会长阿弥塔（那尔那茜 饰）、空浪坊坊主云清（安沺 饰）、胡商苏谅（吕凉 饰）、峒女阿僮（周美君 饰）等人，还遭遇岭南刺史何有光（冯嘉怡 饰）和掌书记赵辛民（公磊 饰）的重重阻拦。双线纠缠之下任务难度飙升，他们将如何打破死局、寻觅一线生机？', 'changandelizhi.png', 'https://videos.example.com/friends-reunion.mp4', 140, 1, 5678901, 34567, '2025-03-12 14:55:00', '2025-02-15 09:45:00', '2025-05-31 14:25:00', 0);
INSERT INTO `video` VALUES (110, '白鹿原', '20世纪初，渭河平原滋水县有一个白鹿原，生活着一群普通却不平凡的百姓。白鹿两家合而为村，相互依存又关系微妙。少东家白嘉轩（张嘉益 饰）与鹿子霖（何冰 饰）为了族长位置暗自较劲儿。嘉轩娶回逃难的仙草（秦海璐 饰），先后生下孝文、孝武和白灵三个孩子。鹿子霖爱走歪门邪道，一心 让两个儿子兆鹏和兆海光宗耀祖。生于乱世，城头变幻大王旗。但不管谁做官，总不免鱼肉底层的百姓。白嘉轩顶着各方的压力，成为白鹿原上响当当的一根硬骨头。可是孩子们长大后，却各有各的主意。拒绝包办婚姻的兆鹏（雷佳音 饰）加入共产党，自己的弟弟则成为国军军官。白灵紧随兆鹏入了党，孝文一心讨好父亲，却渐渐偏离了正道。半个世纪的画卷，展现了中国乱世下的众生相……\r\n　　本片根据已故作家陈忠实的同名小说改编。', 'bailuyuan.png', 'https://videos.example.com/black-mirror-christmas-special.mp4', 90, 1, 4567890, 23456, '2024-04-25 12:25:00', '2024-03-30 09:15:00', '2025-05-23 14:40:00', 0);
INSERT INTO `video` VALUES (201, '流浪地球2', '在并不遥远的未来，太阳急速衰老与膨胀，再过几百年整个太阳系将被它吞噬毁灭。为了应对这场史无前例的危机，地球各国放下芥蒂，成立联合政府，试图寻找人类存续的出路。通过摸索与考量，最终推着地球逃出太阳系的“移山计划”获得压倒性胜利。人们着手建造上万台巨大的行星发动机，带着地球踏上漫漫征程。满腔赤诚的刘培强（吴京 饰）和韩朵朵（王智 饰）历经层层考验成为航天员大队的一员，并由此相知相恋。但是漫漫征途的前方，仿佛有一股神秘的力量不断破坏者人类的自救计划。看似渺小的刘培强、量子科学家图恒宇（刘德华 饰）、联合政府中国代表周喆直（李雪健 饰）以及无数平凡的地球人，构成了这项伟大计划的重要一环……', 'liulangdiqiu2.png', 'https://videos.example.com/wanderingearth2.mp4', 173, 1, 2345678, 90123, '2023-01-22 00:00:00', '2023-01-15 00:00:00', '2025-07-10 12:00:00', 1);
INSERT INTO `video` VALUES (202, '满江红', '南宋绍兴年间，一代忠良岳鹏举物故，引无数良臣赤子扼腕叹息。四年后，奸相秦桧（雷佳音 饰）率兵与金国相约会谈。谁知会谈前夜，金国使者在秦桧驻地为人所害。事态紧急，亲兵营副统领孙均（易烊千玺 饰）得知不成器的老舅——小兵张大（沈腾 饰）了解线索，遂将其带到秦桧处。秦桧命二人一个时辰内找出真凶，否则一律处死。时间飞速流逝，舞姬瑶琴（王佳怡 饰）、更夫丁三旺（潘斌龙 饰）、马夫刘喜（余皑磊 饰）接连卷入其中，而宰相府总管何立（张译 饰）与副总管武义淳（岳云鹏 饰）相继入场，又将这场波谲云诡的调查涂满血腥。\r\n　　谁是真正凶手？他们行刺所为何事？奸相内心深处又藏着什么不可告人的秘密？', 'manjinghong.png', 'https://videos.example.com/manjianghong.mp4', 159, 1, 1987654, 85432, '2023-01-22 00:00:00', '2023-01-15 00:00:00', '2025-07-10 12:10:00', 1);
INSERT INTO `video` VALUES (203, '长安三万里', '安史之乱后数年，吐蕃大军压境，战况危机。剑南西川节度使高适奋力抵抗，然孤兵难支，只得退守云山城。夜幕降临，大雪如轮，朝廷却派来程公公持节监军。高适得知对方讯问的正是他“加害李白”的缘由，于是在昏黄的烛光下，缓缓道出了他和李白起于微末时的故事，以及盛唐文坛的一时盛况。遥想当年，父母双亡的高适决心去长安求取功名，途中遇到文采飞扬且乐观傲慢的李白。他们踌躇满志，却发现空有文采和抱负却报国无门。长安之后，李白南下扬州，高适则继续等待晋升的机会。在这一过程中，杜甫、王维、常建、李龟年、吴道子、张旭等群星璀璨，交替登场，共同谱写了大唐盛世最瑰丽的画卷。', 'changansanwanli.png', 'https://videos.example.com/changan.mp4', 168, 1, 1567890, 76543, '2023-07-08 00:00:00', '2023-07-01 00:00:00', '2025-07-10 12:20:00', 1);
INSERT INTO `video` VALUES (204, '封神 第一部', '天寒地冻，杀气逼人。大商二王子殷寿（费翔 饰）带领亲手调教的质子旅和殷商大军征讨叛乱的冀州侯苏护，却无意间解除了轩辕坟中妖狐的封印。妖狐附身苏护之女妲己（娜然 饰）的身上，被殷寿带回朝歌献给父王和王兄。夜宴之上，大王子智乱神迷，拔剑弑父。在此之后，殷寿继承王位，而天降灾异又迫使他做出自焚祭天的决定。与此同时，昆仑仙人姜子牙（黄渤 饰）携封神榜下山，寻找天下共主，以期救拔苍生。在朝歌期间，他觉察到殷寿的残暴，遂匆匆逃离。另一方面，曾视殷寿为明主的王子殷郊（陈牧驰 饰）以及西伯侯质子姬发（于适 饰）也发现了商王的私欲和妲己的诡异之处。', 'fengshen1.png', 'https://videos.example.com/fengshen.mp4', 148, 1, 1234567, 65432, '2023-07-20 00:00:00', '2023-07-13 00:00:00', '2025-07-10 12:30:00', 1);
INSERT INTO `video` VALUES (205, '流浪地球', '近未来，科学家们发现太阳急速衰老膨胀，短时间内包括地球在内的整个太阳系都将被太阳所吞没。为了自救，人类提出一个名为“流浪地球”的大胆计划，即倾全球之力在地球表面建造上万座发动机和转向发动机，推动地球离开太阳系，用2500年的时间奔往另外一个栖息之地。中国航天员刘培强（吴京 饰）在儿子刘启四岁那年前往国际空间站，和国际同侪肩负起领航者的重任。转眼刘启（屈楚萧 饰）长大，他带着妹妹朵朵（赵今麦 饰）偷偷跑到地表，偷开外公韩子昂（吴孟达 饰）的运输车，结果不仅遭到逮捕，还遭遇了全球发动机停摆的事件。为了修好发动机，阻止地球坠入木星，全球开始展开饱和式营救，连刘启他们的车也被强征加入。在与时间赛跑的过程中，无数的人前仆后继，奋不顾身，只为延续百代子孙生存的希望……', 'liulangdiqiu.png', 'https://videos.example.com/wanderingearth.mp4', 125, 1, 1876543, 89012, '2019-02-05 00:00:00', '2019-01-29 00:00:00', '2025-07-10 12:40:00', 1);
INSERT INTO `video` VALUES (206, '你好，李焕英', '一场意外，改变了一对母女的命运。病床上的母亲李焕英（刘佳 饰）昏迷不醒，女儿贾晓玲（贾玲 饰）涕泗横流，唯恐与母亲阴阳两隔。恍惚之中，晓玲突然穿越到久远以前的陌生时代，并在那里意外邂逅尚待字闺中的青年李焕英（张小斐 饰）。在此之后，晓玲以远亲相称，成为妈妈形影不离的好姐妹。许是见证了妈妈数十年来的劳苦辛酸，晓玲希望通过努力改变妈妈的命运，让她变成一个幸福快乐、富足无忧的女人。而一系列搞笑、感人的小故事，就围绕这对姐妹花母女展开……', 'nihaolihuanying.png', 'https://videos.example.com/lihuanying.mp4', 128, 1, 2109876, 98765, '2021-02-12 00:00:00', '2021-02-05 00:00:00', '2025-07-10 12:50:00', 1);
INSERT INTO `video` VALUES (207, '哪吒之魔童降世', '天地灵气孕育出一颗能量巨大的混元珠，元始天尊将混元珠提炼成灵珠和魔丸，灵珠投胎为人，助周伐纣时可堪大用；而魔丸则会诞出魔王，为祸人间。元始天尊启动了天劫咒语，3年后天雷将会降临，摧毁魔丸。太乙受命将灵珠托生于陈塘关李靖家的儿子哪吒身上。然而阴差阳错，灵珠和魔丸竟然被掉包。本应是灵珠英雄的哪吒却成了混世大魔王。调皮捣蛋顽劣不堪的哪吒却徒有一颗做英雄的心。然而面对众人对魔丸的误解和即将来临的天雷的降临，哪吒是否命中注定会立地成魔？他将何去何从？', 'nezhazhimotongjiangshi.png', 'https://videos.example.com/nezha.mp4', 110, 1, 2567890, 109876, '2019-07-26 00:00:00', '2019-07-19 00:00:00', '2025-07-10 13:00:00', 1);
INSERT INTO `video` VALUES (208, '长津湖', '电影以抗美援朝战争第二次战役中的长津湖战役为背景，讲述了一段波澜壮阔的历史：71年前，中国人民志愿军赴朝作战，在极寒严酷环境下，东线作战部队凭着钢铁意志和英勇无畏的战斗精神一路追击，奋勇杀敌，扭转了战场态势，打出了军威国威。', 'changjinghu.png', 'https://videos.example.com/changjinhu.mp4', 176, 1, 1765432, 87654, '2021-09-30 00:00:00', '2021-09-23 00:00:00', '2025-07-10 13:10:00', 1);
INSERT INTO `video` VALUES (209, '唐人街探案3', '为了争夺东京新唐人街的开发权，东南亚帮派与日本黑帮组织黑龙会纷争不断。为了避免冲突升级，合作共赢，东南亚商会会长苏察维邀请黑龙会头目渡边胜（三浦友和 饰）谈判。谈判地点设在四面环水的日式茶室，室内只有双方头目而已。谁知谈判开始没多久，室内就传来惨叫声。众人涌入后发现，苏察维被打碎的屏风玻璃杀害，而躺在一旁的渡边胜则满手鲜血。突发意外将双方敌意再度拉至顶点，为了证明清白，渡边通过侦探野田昊（妻木夫聪 饰）找来了秦风（刘昊然 饰）和唐仁（王宝强 饰），试图揭开密实杀人案的真相。', 'tangrenjietanan3.png', 'https://videos.example.com/tainrendao3.mp4', 136, 1, 1654321, 76543, '2021-02-12 00:00:00', '2021-02-05 00:00:00', '2025-07-10 13:20:00', 1);
INSERT INTO `video` VALUES (210, '战狼2', '由于一怒杀害了强拆牺牲战友房子的恶霸，屡立功勋的冷锋（吴京 饰）受到军事法庭的判决。在押期间，亲密爱人龙小云壮烈牺牲。出狱后，冷锋辗转来到非洲，他辗转各地，只为寻找杀害小云的凶手。在此期间，冷锋逗留的国家发生叛乱，叛徒红巾军大开杀戒，血流成河。中国派出海军执行撤侨任务，期间冷锋得知有一位陈博士被困在五十五公里外的医院，而叛军则试图抓住这位博士。而从另一位华侨（于谦 饰）口中得知，杀害小云的凶手正待在这个国家。\r\n　　在无法得到海军支援的情况下，冷锋只身闯入硝烟四起的战场。不屈不挠的战狼，与冷酷无情的敌人展开悬殊之战…… ', 'zhanlang2.png', 'https://videos.example.com/zhanlang2.mp4', 123, 1, 2876543, 119876, '2017-07-27 00:00:00', '2017-07-20 00:00:00', '2025-07-10 13:30:00', 1);
INSERT INTO `video` VALUES (301, '鬼灭之刃', '故事发生在日本大正时代。原本过着平凡无忧生活的灶门炭治郎（花江夏树 配音）和家人们，因为恶鬼的袭击而人生彻底发生转变。母亲和多个兄弟姐们遭到杀害，而幸存的妹妹祢豆子（鬼头明里 配音）受到鬼舞辻无惨（关俊彦 配音）之血的影响也化身恶鬼。为了给家人们报仇，并且解救妹妹，炭治郎拜入鳞泷左近次门下学习剑术，并最终通过严苛选拔成为一名鬼杀队剑士。在这一过程中，他结识了我妻善逸（下野纮 配音）、栗花落香奈乎（上田丽奈 配音）、嘴平伊之助（松冈祯丞 配音）等伙伴，也在试炼修行的过程中，注定要完成和鬼之始祖鬼舞辻无惨的宿命对决……\r\n　　本片根据日本漫画家吾峠呼世晴所著的少年漫画改编。', 'guimiezhiren.png', 'https://videos.example.com/demon-slayer.mp4', 24, 1, 3456789, 12345, '2019-04-06 00:00:00', '2019-03-20 00:00:00', '2025-07-15 14:00:00', 2);
INSERT INTO `video` VALUES (302, '海贼王', '传奇海盗哥尔•D•罗杰在临死前曾留下关于其毕生的财富“One Piece”的消息，由此引得群雄并起，众海盗们为了这笔传说中的巨额财富展开争夺，各种势力、政权不断交替，整个世界进入了动荡混乱的“大海贼时代”。\r\n　　生长在东海某小村庄的路飞受到海贼香克斯的精神指引，决定成为一名出色的海盗。为了达成这个目标，并找到万众瞩目的One Piece，路飞踏上艰苦的旅程。一路上他遇到了无数磨难，也结识了索隆、娜美、乌索普、香吉、罗宾等一众性格各异的好友。他们携手一同展开充满传奇色彩的大冒险……\r\n　　本片根据日本漫画家尾田荣一郎超人气漫画原作《One Piece》改编。', 'onepiece.png', 'https://videos.example.com/one-piece.mp4', 25, 1, 7890123, 56789, '1999-10-20 00:00:00', '1999-09-15 00:00:00', '2025-07-15 14:10:00', 2);
INSERT INTO `video` VALUES (303, '火影忍者', '十多年前一只拥有巨大威力的妖兽“九尾妖狐”袭击了木叶忍者村，当时的第四代火影拼尽全力，以自己的生命为代价将“九尾妖狐”封印在了刚出生的鸣人身上。木叶村终于恢复了平静，但村民们却把鸣人当成像“九尾妖狐”那样的怪物看待，所有人都疏远他。鸣人自小就孤苦无依，一晃十多年过去了，少年鸣人考入了木叶村的忍者学校，结识了好朋友佐助和小樱。佐助是宇智波家族的传人之一，当他还是小孩的时候他的哥哥——一个已经拥有高超忍术的忍者将他们家族的人都杀死了，然后投靠了一直想将木叶村毁灭的大蛇丸，佐助自小就发誓要超越哥哥，为家族报仇。鸣人他们在忍者学校得到了教官卡卡西的精心指点，在他的帮助下去迎接成长中的一次又一次挑战！ ', 'huoyingrenzhe.png', 'https://videos.example.com/naruto.mp4', 24, 1, 6789012, 45678, '2002-10-03 00:00:00', '2002-09-15 00:00:00', '2025-07-15 14:20:00', 2);
INSERT INTO `video` VALUES (304, '名侦探柯南', '工藤新一是全国著名的高中生侦探，在一次追查黑衣人犯罪团伙时不幸被团伙成员发现，击晕后喂了神奇的药水，工藤新一变回了小孩！新一找到了经常帮助他的阿笠博士，博士为他度身打造不少间谍武器。为了防止犯罪团伙对他进行报复，新一决定隐姓埋名，暗中追查他们，希望能得到解药。一日，新一 的女友毛利兰来到了阿笠博士的家寻找男友的下落，被小兰撞见的新一情急之下编造了自己名叫江户川柯南，随后柯南寄居在了小兰家。小兰的父亲毛利小五郎是一名私家侦探，新一可以籍着和他一起四出办案一起追查黑夜人的下落。柯南在小学认识步美等小学生，他们一起组织了一个少年侦探团，向罪犯宣战！', 'mingzhentankenan.png', 'https://videos.example.com/detective-conan.mp4', 24, 1, 5678901, 34567, '1996-01-08 00:00:00', '1995-12-20 00:00:00', '2025-07-15 14:30:00', 2);
INSERT INTO `video` VALUES (305, '哆啦A梦', '小学生静儿、大雄、强夫和胖子技安是四个最亲密的伙伴，说是亲密伙伴，是因为他们四个经常在一起玩，但强夫和胖子技安经常欺负大雄。而大雄天生就是被人欺负的对象，他胆小内向，经常被强夫和技安欺负得大哭着跑回家。不过，大雄家里住着来自未来的机器猫——哆啦A梦，哆啦A梦经常会看到大雄被欺负忍不住拿出一些未来世界的“法宝”帮助他，不过大雄大多数都会滥用这些“法宝”去作弄人，最后经常导致局面不可收拾，笑料百出……', 'duolaameng.png', 'https://videos.example.com/doraemon.mp4', 25, 1, 4567890, 23456, '1979-04-02 00:00:00', '1979-03-15 00:00:00', '2025-07-15 14:40:00', 2);
INSERT INTO `video` VALUES (306, '七龙珠', '很久很久以前，曾流传着这样一个传说：世界各地散落着七颗龙珠，只要集齐这些珠子，就可召唤出神龙，而神龙可以帮助你实现任何一个愿望。\r\n　　住在深山中的小悟空本领高强，偶然的机会他随时尚少女布尔玛走出大山，四处寻找传说中的龙珠。期间碰上好色的鬼仙人与乌龙、一碰女人就面红耳赤的乐平、自大的小和尚克林，经历了各种各样的艰险和奇遇，也惹出一连串爆笑的故事。当然还有许多邪恶的家伙为了满足私欲寻找龙珠，与小悟空他们展开了连番激斗……', 'qilongzhu.png', 'https://videos.example.com/dragon-ball.mp4', 25, 1, 3456789, 12345, '1986-02-26 00:00:00', '1986-01-20 00:00:00', '2025-07-15 14:50:00', 2);
INSERT INTO `video` VALUES (307, '进击的巨人 总集篇 最后的进击', '当艾伦释放出巨人的终极力量时，世界的命运岌岌可危。怀着消灭所有威胁艾尔迪亚的人的强烈决心，他率领一支不可阻挡的巨人大军向马莱进击。', 'jinjidejuren.png', 'https://videos.example.com/attack-on-titan.mp4', 24, 1, 2345678, 90123, '2013-04-07 00:00:00', '2013-03-20 00:00:00', '2025-07-15 15:00:00', 2);
INSERT INTO `video` VALUES (308, '千与千寻', '千寻和爸爸妈妈一同驱车前往新家，在郊外的小路上不慎进入了神秘的隧道——他们去到了另外一个诡异世界—一个中世纪的小镇。远处飘来食物的香味，爸爸妈妈大快朵颐，孰料之后变成了猪！这时小镇上渐渐来了许多样子古怪、半透明的人。\r\n　　千寻仓皇逃出，一个叫小白的人救了他，喂了她阻止身体消 失的药，并且告诉她怎样去找锅炉爷爷以及汤婆婆，而且必须获得一份工作才能不被魔法变成别的东西。\r\n　　千寻在小白的帮助下幸运地获得了一份在浴池打杂的工作。渐渐她不再被那些怪模怪样的人吓倒，并从小玲那儿知道了小白是凶恶的汤婆婆的弟子。\r\n　　一次，千寻发现小白被一群白色飞舞的纸人打伤，为了救受伤的小白，她用河神送给她的药丸驱出了小白身体内的封印以及守封印的小妖精，但小白还是没有醒过来。\r\n　　为了救小白，千寻又踏上了她的冒险之旅。', 'xianyuxianxun.png', 'https://videos.example.com/spirited-away.mp4', 125, 1, 1234567, 89012, '2001-07-20 00:00:00', '2001-06-25 00:00:00', '2025-07-15 15:10:00', 2);
INSERT INTO `video` VALUES (309, '龙猫', '小月的母亲生病住院了，父亲带着她与四岁的妹妹小梅到乡间的居住。她们对那里的环境都感到十分新奇，也发现了很多有趣的事情。她们遇到了很多小精灵，她们来到属于她们的环境中，看到了她们世界中很多的奇怪事物，更与一只大大胖胖的龙猫成为了朋友。龙猫与小精灵们利用他们的神奇力量，为小月与妹妹带来了很多神奇的景观，令她们大开眼界。\r\n　　妹妹小梅常常挂念生病中的母亲，嚷着要姐姐带着她去看母亲，但小月拒绝了。小梅竟然自己前往，不料途中迷路了，小月只好寻找她的龙猫及小精灵朋友们帮助。', 'longmao.png', 'https://videos.example.com/my-neighbor-totoro.mp4', 86, 1, 9012345, 78901, '1988-04-16 00:00:00', '1988-03-20 00:00:00', '2025-07-15 15:20:00', 2);
INSERT INTO `video` VALUES (310, '新世纪福音战士', '突袭世界的大灾难“第二次冲击”后，世界在废墟之上重建。14岁的少年碇真嗣被父亲碇元渡叫到第3新东京市。本以为能见到父亲迎接的他，却见到名为“ 使徒”的巨大生物与军队交火。危急之下，特务机关NERV的葛成美里将真嗣救下，并将其带往碇元渡所统领的NERV总部。但迎接真嗣的，却是是父亲冷酷地命令：驾驶称为“EVA”的巨大人型机器人与使徒战斗。本已表示拒绝的真嗣，看到重伤的替补驾驶员绫波丽后，决定遵从父亲的命令。就这样，从未受过作战训练的真嗣，准备驾驶EVA初号机迎战使徒。\r\n　　不断袭来的使徒，身份不明的绫波丽，从德国来的驾驶员惣流·明日香·兰格蕾，14岁的少年要面对远超自己能力的挑战。而碇元渡不动声色地观察一切，一个称为“人类补完计划”的神秘计划正在按照他的计划实现。', 'xinshijifuyinzhanshi.png', 'https://videos.example.com/eva.mp4', 24, 1, 8901234, 67890, '1995-10-04 00:00:00', '1995-09-15 00:00:00', '2025-07-15 15:30:00', 2);
INSERT INTO `video` VALUES (401, '地球脉动2', '由BBC制作的自然纪录片，大卫·爱登堡爵士解说，展现全球多样生态系统与珍稀物种。', 'planetearth2.png', 'https://videos.example.com/planet-earth2.mp4', 59, 1, 8901234, 67890, '2016-11-06 00:00:00', '2016-10-20 00:00:00', '2025-07-15 12:00:00', 3);
INSERT INTO `video` VALUES (402, '蓝色星球2', '《蓝色星球II》将由大卫·爱登堡爵士主持。在长达4年的拍摄过程中, 制作团队共执行了125次的探险，水下拍摄时数长达到6000多个小时。与2001年首播的《藍色星球》相隔16年之后，制作团队透过新的科技技术突破以往限制，将许多过去未知的地带、惊人的生物及其令人瞠目结舌的举动呈现在观众眼前\r\n　　自从《蓝色星球》2001年开播以来，我们对大海之下生命的理解被彻底颠覆了。从北极熊出没的北冰洋到焕发着勃勃生机的蓝色珊瑚环礁，本系列纪录片同大家分享一些令人吃惊的新发现；邂逅在南冰洋深处神出鬼没的奇怪章鱼，观赏巨大的鲹鱼跳出水面，飞跃到半空中捕鱼；骑在虎鲸的背上，同它一起冲向鱼群。《蓝色星球2》带领我们体验让人敬畏称奇的新地方，见识魅力四射的新物种，了解非同寻常的新行为。', 'blueplanet2.png', 'https://videos.example.com/blue-planet2.mp4', 59, 1, 7890123, 56789, '2017-10-29 00:00:00', '2017-10-15 00:00:00', '2025-07-15 12:10:00', 3);
INSERT INTO `video` VALUES (403, '生命的奇迹', '聚焦生命进化历程的纪录片，通过CGI技术重现史前生物与地球演变。', 'wondersohlife.png', 'https://videos.example.com/life-on-earth.mp4', 60, 1, 6789012, 45678, '2009-03-08 00:00:00', '2009-02-20 00:00:00', '2025-07-15 12:20:00', 3);
INSERT INTO `video` VALUES (404, '人类星球', 'BBC8集大型电视系列片 - Human Planet （人类星球），探讨人与自然的关系。8集节目分别探讨极地、山区、海洋、丛林、草原、河流、沙漠和城市的人类活动。世界一流的自然与人类专家以及摄影师，从空中、陆地和水下抓拍珍贵镜头。BBC摄制组前往世界80个地方，抓拍了从未在电视屏幕上出现过的罕见精彩的人类活动。', 'humanplanet.png', 'https://videos.example.com/human-planet.mp4', 59, 1, 5678901, 34567, '2011-10-16 00:00:00', '2011-10-01 00:00:00', '2025-07-15 12:30:00', 3);
INSERT INTO `video` VALUES (405, '宇宙的构造', '一部由 PBS 出品、极富视觉冲击力的科普巨作，一场用画面演绎和探寻宇宙终极奥秘的讲堂。从牛顿因苹果产生的力学顿悟，到爱因斯坦相对论，再到量子论，弦理论……《宇宙的构造》共四部分，取材自同名著作，作者兼物理学家 Brian Greene 和世界名校的专家学者一同为观众介绍时间、空间和宇宙的概念。\r\n　　The Fabric of the Cosmos: What is Space? 什么是空间？\r\n　　The Fabric of the Cosmos: Illusion of Time 时间幻觉\r\n　　The Fabric of the Cosmos: Quantum Leap 量子跃迁\r\n　　The Fabric of the Cosmos: Universe or Multiverse? 单宇宙还是多宇宙？', 'thefabricofthecosmos.png', 'https://videos.example.com/cosmos.mp4', 45, 1, 4567890, 23456, '2011-03-06 00:00:00', '2011-02-20 00:00:00', '2025-07-15 12:40:00', 3);
INSERT INTO `video` VALUES (406, '地球脉动3', '从海洋深处到最偏远的丛林，《地球脉动III》为经典巨制翻开崭新篇章，继续造访地球上众多令人称奇的栖息地，观众将跟随镜头探索这颗星球上最后的天然野境，领略野生动物进化出的绝妙生存策略。同时，也展现出荒野之境和生在其中的野生动物对维持地球健康运转的独特意义，饱含对大自然的敬畏、礼赞与关怀。', 'planetearth3.png', 'https://videos.example.com/planet-earth3.mp4', 59, 1, 3456789, 12345, '2022-10-06 00:00:00', '2022-09-20 00:00:00', '2025-07-15 12:50:00', 3);
INSERT INTO `video` VALUES (407, '黄石公园', '本纪录片将带我们亲历野生动物在季节极限下的生活。领略它们在零下40度采取的保护措施 ，经历狂怒的森林火灾或防治权利滋生……', 'yellowstone.png', 'https://videos.example.com/yellowstone.mp4', 53, 1, 2345678, 90123, '2010-05-02 00:00:00', '2010-04-15 00:00:00', '2025-07-15 13:00:00', 3);
INSERT INTO `video` VALUES (408, '生命的进化', '《生命的进化》这个系列首播于1979年，它开始了电视节目的一个新时代。David Attenborough和他的了不起的团队把一些相当不寻常的画面通过电视展示给世人看，它带领我们去关注世界上多样性的生物以及它们的演化。\r\n　　这些对观众产生了持久的影响。这个系列是当时the Natural History Unit制作的最大的系列节目，使用的胶带超过100万英尺，拍摄的场景有100多个。', 'lifeonearth.png', 'https://videos.example.com/evolution.mp4', 55, 1, 1234567, 89012, '2001-01-01 00:00:00', '2000-12-15 00:00:00', '2025-07-15 13:10:00', 3);
INSERT INTO `video` VALUES (409, '探秘太阳系', '这部纪录片详细介绍了太阳系的起源、形成，探讨人类是否是太空中唯一的智慧生命。通过对专家和宇航员的采访、多方航天航空机构的支持、以及人类在航天航空探索中拍摄到的精彩画面，观众得以全方位探索太空，追溯人类进入太空的惊人旅程以及令人难以置信的发现，见证航天航空的巨大挑战与飞速 发展，形成一部对太阳、邻近行星及其卫星、小行星的权威指南，极具教育意义。', 'secretsofthesolarsystem.png', 'https://videos.example.com/solar-system.mp4', 50, 1, 9012345, 78901, '2012-04-15 00:00:00', '2012-03-30 00:00:00', '2025-07-15 13:20:00', 3);
INSERT INTO `video` VALUES (410, '非洲', '《非洲》由《Life》原班人马打造，是一部大型原生态纪录片。镜头将跟随主持人David Attenborough一起穿越神奇的非洲大陆，探索那些从未被发现、被记录的生物物种和壮观的非洲奇迹。', 'africa.png', 'https://videos.example.com/africa.mp4', 58, 1, 8089012, 67890, '2013-01-20 00:00:00', '2012-12-30 00:00:00', '2025-07-15 13:30:00', 3);
INSERT INTO `video` VALUES (501, '鬼灭之刃混剪', '这部视频展示了《鬼灭之刃》精彩的战斗场景和角色成长', 'guimiezhiren_short.png', 'guimiezhiren.mp4', 371, 13, 991, 574, '2016-02-14 16:03:48', '2019-02-07 04:26:22', '2017-05-18 11:14:06', 4);
INSERT INTO `video` VALUES (502, '赛博朋克边缘行者2先导预告片', '赛博朋克边缘行者2先导预告片带来未来都市的酷炫风格与深刻的科技哲思', 'cyber.png', 'cyber.mp4', 699, 61, 558, 123, '2012-12-31 21:52:31', '2015-03-23 04:19:59', '2021-04-06 10:45:20', 4);
INSERT INTO `video` VALUES (503, '一人之下王也混剪', '《一人之下王也混剪》通过紧凑的剪辑展示了这部作品中的复杂情节与人物关系', 'yirenzhixia.png', 'yirenzhixia.mp4', 508, 113, 133, 272, '2013-02-03 05:16:50', '2020-11-24 22:32:05', '2011-11-13 03:14:40', 4);
INSERT INTO `video` VALUES (504, '24年镰仓花火大会', '24年镰仓花火大会记录了这个美丽节日的火光与烟花，带给观众视觉与情感的双重冲击', 'huahuodahui.png', 'huahuodahui.mp4', 410, 17, 750, 183, '2008-03-12 11:26:23', '2011-09-02 08:25:54', '2025-01-14 15:59:36', 4);
INSERT INTO `video` VALUES (505, '江之岛的蓝调时刻', '江之岛的蓝调时刻，捕捉了这片海域在蓝色光辉下的宁静与壮丽景象', 'jiangzhidao.png', 'jiangzhidao.mp4', 934, 89, 479, 657, '2012-06-10 23:10:38', '2009-02-07 08:36:34', '2014-01-18 17:35:38', 4);
INSERT INTO `video` VALUES (506, '擎天柱纯享', '擎天柱纯享版收录了最具震撼力的变形金刚场面，为影迷呈现史诗级对决', 'qingtianzhu.png', 'qingtianzhu.mp4', 490, 81, 975, 511, '2023-07-11 20:53:13', '2019-04-12 17:14:04', '2019-07-27 19:32:29', 4);
INSERT INTO `video` VALUES (507, '爆燃 ! 这才是忍界的巅峰战力', '忍界的巅峰战力展示了火影忍者中最激烈的战斗和超凡的忍术对决', 'huoyingrenzhe_short.png', 'huoyingrenzhe.mp4', 162, 74, 672, 525, '2020-05-21 07:51:25', '2015-11-12 16:26:28', '2001-06-23 00:17:55', 4);
INSERT INTO `video` VALUES (508, '风景纯享', '风景纯享视频以极致美丽的自然景观为主题，带领观众领略世间绝美风光', 'fengjing.png', 'fengjing.mp4', 17, 117, 577, 344, '2012-07-13 05:40:11', '2017-11-12 01:45:03', '2005-08-19 02:25:03', 4);
INSERT INTO `video` VALUES (509, 'F1赛车比赛超燃混剪', 'F1赛车比赛超燃混剪集中展现了全球赛车赛事中的极速与冲刺，让人屏息凝视', 'F1.png', 'F1.mp4', 89, 21, 764, 72, '2006-09-21 12:48:01', '2022-06-02 08:30:32', '2012-11-25 02:52:41', 4);
INSERT INTO `video` VALUES (510, '你的名字纯享', '《你的名字》纯享版展示了这部跨越时空的爱情故事中的浪漫与感动', 'nidemingzi.png', 'nidemingzi.mp4', 857, 71, 214, 254, '2016-06-20 01:36:15', '2024-02-02 18:16:37', '2015-03-30 23:31:26', 4);

-- ----------------------------
-- Table structure for video_resource
-- ----------------------------
DROP TABLE IF EXISTS `video_resource`;
CREATE TABLE `video_resource`  (
  `resource_id` bigint NOT NULL AUTO_INCREMENT,
  `video_id` bigint NOT NULL,
  `resolution` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_size` bigint NOT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`resource_id`) USING BTREE,
  INDEX `video_id`(`video_id` ASC) USING BTREE,
  CONSTRAINT `video_resource_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of video_resource
-- ----------------------------

-- ----------------------------
-- Table structure for video_tag
-- ----------------------------
DROP TABLE IF EXISTS `video_tag`;
CREATE TABLE `video_tag`  (
  `video_id` bigint NOT NULL,
  `year` int NULL DEFAULT NULL COMMENT '发行年份',
  `region` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '制作地区',
  `genre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '视频题材类型',
  `rating` decimal(3, 1) NULL DEFAULT NULL COMMENT '视频评分，范围0-10',
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`video_id`) USING BTREE,
  CONSTRAINT `video_tag_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of video_tag
-- ----------------------------
INSERT INTO `video_tag` VALUES (101, 2015, '中国', '古装', 9.1, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (102, 1994, '美国', '喜剧', 9.0, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (103, 2011, '中国', '历史', 8.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (104, 2021, '中国', '历史', 9.2, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (105, 2018, '英国', '惊悚', 8.4, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (106, 2016, '美国', '科幻', 8.7, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (107, 2019, '美国', '科幻', 8.0, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (108, 2015, '美国', '犯罪', 8.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (109, 2024, '中国', '古装', 7.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (110, 2017, '中国', '历史', 8.0, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (201, 2023, '中国', '科幻', 8.3, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (202, 2023, '中国', '热血', 7.9, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (203, 2023, '中国', '历史', 8.3, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (204, 2023, '中国', '奇幻', 7.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (205, 2019, '中国', '科幻', 7.9, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (206, 2021, '中国', '喜剧', 8.1, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (207, 2019, '中国', '热血', 8.4, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (208, 2021, '中国', '战争', 7.4, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (209, 2021, '中国', '喜剧', 5.4, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (210, 2017, '中国', '动作', 7.4, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (301, 2019, '日本', '热血', 9.1, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (302, 1999, '日本', '热血', 9.0, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (303, 2002, '日本', '热血', 8.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (304, 1996, '日本', '推理', 8.9, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (305, 1979, '日本', '喜剧', 8.7, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (306, 1986, '日本', '热血', 8.6, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (307, 2013, '日本', '热血', 8.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (308, 2001, '日本', '奇幻', 9.3, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (309, 1988, '日本', '奇幻', 9.2, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (310, 1995, '日本', '科幻', 8.5, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (401, 2016, '英国', '自然', 9.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (402, 2017, '英国', '海洋', 9.8, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (403, 2009, '英国', '生物', 9.4, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (404, 2011, '英国', '人文', 9.7, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (405, 2011, '美国', '科学', 9.2, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (406, 2022, '英国', '自然', 9.5, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (407, 2010, '美国', '自然', 8.9, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (408, 2001, '英国', '科学', 9.1, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (409, 2012, '美国', '天文', 9.0, '2025-07-16 08:45:20');
INSERT INTO `video_tag` VALUES (410, 2013, '英国', '自然', 9.7, '2025-07-16 08:45:20');

-- ----------------------------
-- Table structure for watch_history
-- ----------------------------
DROP TABLE IF EXISTS `watch_history`;
CREATE TABLE `watch_history`  (
  `history_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `video_id` bigint NOT NULL,
  `watch_time` int NOT NULL,
  `last_watch_time` datetime NOT NULL,
  PRIMARY KEY (`history_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `video_id`(`video_id` ASC) USING BTREE,
  CONSTRAINT `watch_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `watch_history_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `video` (`video_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of watch_history
-- ----------------------------
INSERT INTO `watch_history` VALUES (11, 1003, 101, 0, '2025-07-22 03:14:40');
INSERT INTO `watch_history` VALUES (12, 1002, 102, 0, '2025-07-22 03:15:46');
INSERT INTO `watch_history` VALUES (13, 1002, 101, 0, '2025-07-23 04:07:45');
INSERT INTO `watch_history` VALUES (14, 1002, 501, 3, '2025-07-22 06:34:38');
INSERT INTO `watch_history` VALUES (15, 1001, 101, 0, '2025-07-23 03:54:36');

SET FOREIGN_KEY_CHECKS = 1;
