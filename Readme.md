# VideoPlatform 项目说明文档

## 项目简介
`VideoPlatform` 是一个基于 ArkTS 的视频平台应用，支持视频推荐、搜索、播放、收藏、用户登录等功能。本项目适用于 HarmonyOS 应用开发，使用 DevEco Studio 5.1.1.820 编写。

## 模块功能说明

### AppScope
- 存放全局资源文件，如多语言配置、主题颜色等。

### entry
- 主模块，包含应用的主要功能实现。
  - **src/main/ets**
    - **entryability**：入口能力相关文件。
    - **entrybackupability**：备份能力相关文件。
    - **pages**：页面组件目录。
      - **Recommendpages**：推荐页面相关组件。
      - **common**：公共模块，包含 API 请求、配置工具、偏好设置等。
      - **detailpages**：视频详情页组件。
      - **homepages**：不同分类的主页（如电影、动漫等）。
      - **mainpages**：主界面模块（如首页、我的、推荐、短视频等）。
      - **minepages**：用户个人中心模块（如登录、注册、收藏）。
      - **model**：数据模型模块。
      - **services**：业务服务模块。
      - **shortvideopages**：短视频相关页面。
      - **widget**：自定义组件模块。
    - **Index.ets**：应用的主入口文件。
    - **Search.ets**：搜索功能主页面。
    - **SearchList.ets**：搜索结果展示页面。
    - **videoDetail.ets**：视频详情展示页面。
  - **resources**：资源文件目录，包含颜色、字符串、图片等。
  - **ohosTest**：HarmonyOS 测试代码。
  - **test**：本地单元测试代码。
  - **hvigorfile.ts**：构建配置文件。

## 开发环境
- **操作系统**：Windows 11（推荐）
- **IDE**：DevEco Studio 5.1.1.820
- **编程语言**：ArkTS
- **目标平台**：HarmonyOS


## 运行与调试
1. 打开 DevEco Studio。
2. 导入本项目。
3. 连接设备或启动模拟器。
4. 点击运行按钮或使用快捷键运行项目。

## 单元测试
- 测试文件位于 `entry/src/test` 和 `entry/src/ohosTest` 目录下。
- 使用 DevEco Studio 运行测试用例。

## 贡献
欢迎提交 PR 和 Issue，帮助我们改进项目！

## 许可证
本项目使用 MIT 许可证。


# MyVideo 视频后台服务

本项目为视频内容管理与分发后端，支持用户注册、登录、视频播放、评论、弹幕、收藏、历史记录等功能。后端基于 Node.js + Koa 框架，使用 Sequelize 进行数据库 ORM 操作。

## 目录结构

```
backend/
├── controller/         # 业务控制器，处理各类接口请求
│   └── api.js          # 主接口实现
├── model/              # 数据库模型定义
│   ├── user.js         # 用户表
│   ├── user_profile.js # 用户扩展信息
│   ├── video.js        # 视频表
│   ├── video_tag.js    # 视频标签
│   ├── comment.js      # 评论表
│   ├── like.js         # 点赞表
│   ├── favorite.js     # 收藏表
│   ├── watch_history.js# 观看历史
│   ├── video_resource.js # 视频资源
│   ├── danmaku.js      # 弹幕表
│   ├── swiper.js       # 轮播图
│   ├── short_video_history.js # 短视频历史
│   ├── short_video_collect.js # 短视频收藏
│   └── index.js        # 模型关系与导出
├── routes/
│   └── index.js        # 路由定义
├── services/
│   └── userService.js  # 用户相关服务
├── utils/
│   ├── token.js        # Token 生成与校验
│   ├── validation.js   # 输入验证
│   └── util.js         # 通用工具函数
├── public/
│   └── uploads/        # 文件上传目录
│       └── user/       # 用户头像等
│       └── videos/     # 视频文件
├── config/
│   └── db.js           # 数据库配置
├── app.js              # 应用入口
└── README.md           # 项目说明
```

## 功能模块

- **用户管理**：注册、登录、信息修改、Token校验、等级与状态管理
- **视频管理**：视频上传、详情、标签、分类、榜单、推荐、搜索
- **评论与弹幕**：视频评论、弹幕发送与展示
- **收藏与历史**：视频收藏、批量操作、观看历史记录
- **短视频支持**：短视频历史与收藏
- **文件上传**：支持用户头像、视频文件上传
- **接口安全**：部分接口需携带 Token

## 启动方式

1. 安装依赖  
   ```
   npm install
   ```
2. 配置数据库连接  
   修改 `config/db.js`，填写数据库信息。
3. 启动服务  
   ```
   node app.js
   ```

## 主要接口说明

- `/register` 用户注册
- `/login` 用户登录
- `/getUserInfo` 获取用户信息（需 Token）
- `/userEdit` 修改用户信息（需 Token）
- `/getVideo` 获取视频列表
- `/getVideoDetail` 获取视频详情
- `/searchVideo` 视频搜索
- `/getFilterOptions` 获取筛选标签
- `/getRecommendVideos` 推荐视频（多条件筛选）
- `/getRankVideos` 榜单视频
- `/videoStream/:filename` 视频流播放（支持 Range 请求）
- `/comment` 评论
- `/getComment` 获取评论
- `/addFavorite` 添加收藏
- `/removeFavorite` 取消收藏
- `/getUserFavorites` 获取用户收藏列表
- `/deleteFavorites` 批量删除收藏
- `/recordWatchHistory` 记录观看历史
- `/getUserWatchHistory` 获取观看历史
- `/deleteWatchHistory` 删除观看历史
- `/updateWatchProgress` 更新观看进度
- `/uploads` 文件上传

## 数据库模型简述

- 用户表（user）：基本信息、登录、注册时间、等级、状态
- 用户扩展表（user_profile）：性别、生日、签名等
- 视频表（video）：标题、描述、封面、时长、分类、状态
- 视频标签（video_tag）：年份、地区、类型、评分
- 评论表（comment）：内容、时间、用户、视频
- 点赞表（like）：用户、视频或评论
- 收藏表（favorite）：用户、视频、分类
- 观看历史（watch_history）：用户、视频、观看时长、时间
- 弹幕表（danmaku）：内容、颜色、位置、时间
- 轮播图（swiper）：首页轮播展示
- 短视频历史/收藏：短视频相关记录

## 其他说明

- 所有接口返回统一 JSON 格式，包含 code、message、data 字段。
- 用户敏感操作需携带 Token（如修改信息、获取个人信息）。
- 收藏、历史等支持批量操作和分类筛选。
- 视频播放支持断点续播（Range 请求）。

如需详细接口参数与返回格式，请参考 `controller/api.js` 和 `routes/index.js` 文件注释。

