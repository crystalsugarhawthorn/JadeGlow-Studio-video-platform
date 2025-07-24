const model = require('../model/index')
const Swiper = model.swiper  // 轮播图表
const Video = model.video  // 视频表
const VideoTag = model.videoTag  // 视频标签表
const User = model.user
const ShortVideoHistory = model.short_video_history
const ShortVideoCollect = model.short_video_collect
const WatchHistory = model.watchHistory
const Comment = model.comment
const UserProfile = model.userProfile
const Favorite = model.favorite  // 收藏表

const Sequelize = require('sequelize')
const Op = Sequelize.Op
const fs = require('fs');
const path = require('path');
const md5 = require('md5')
const {generateToken} = require( '../utils/token')
const UserService = require('../services/userService'); 
const {validateRegisterInput} = require('../utils/validation');




// 1.获得轮播图
module.exports.getSwiper = async (ctx, next) => {
     const swiper = await Swiper.findAll()
     ctx.body = {code: 200, message:'轮播图成功',data: swiper}
}

// 2.获得视频
module.exports.getVideo = async (ctx, next) => {
     const video = await Video.findAll()
     ctx.body = {code: 200, message:'视频成功',data: video}
}

// 3.获得视频详情
module.exports.getVideoDetail = async (ctx, next) => {
    const {video_id}= ctx.request.query
    const video = await Video.findOne({
        where: {
            video_id: video_id
        },
        include: [{
            model: VideoTag,
            attributes: ['year', 'region', 'genre'] // 只要这几个字段
        }]
    })
    ctx.body = {code: 200, message:'视频详情成功',data: video}
}

// 4.搜索视频
module.exports.searchVideo = async (ctx) => {
  const { keywords, page = 1, pageSize = 6 } = ctx.query

  const list = await Video.findAll({
     where: {
          [Op.or]: [
               { title: { [Op.like]: `%${keywords}%` } },
               { '$video_tag.year$': { [Op.like]: `%${keywords}%` } },
               { '$video_tag.region$': { [Op.like]: `%${keywords}%` } },
               { '$video_tag.genre$': { [Op.like]: `%${keywords}%` } },
          ]
     },
     include: [{
          model: VideoTag,
          attributes: ['year', 'region', 'genre'],
          required: false // 保持 false，允许只有 title 匹配的也能出
     }],
     limit: Number(pageSize),
     offset: (page - 1) * pageSize,
     order: [['video_id', 'asc']]
     })

  ctx.body = {
    code: 200,
    message: '获取成功',
    data: { list }
  }
}

// 5.获得视频标签
module.exports.getFilterOptions = async (ctx, next) => {
     try {
          // 获取所有不重复的类型
          const genres = await VideoTag.findAll({
               attributes: ['genre'],
               where: {
                    genre: {
                         [Op.not]: null,
                         [Op.ne]: ''
                    }
               },
               group: ['genre'],
               raw: true
          })

          // 获取所有不重复的地区
          const regions = await VideoTag.findAll({
               attributes: ['region'],
               where: {
                    region: {
                         [Op.not]: null,
                         [Op.ne]: ''
                    }
               },
               group: ['region'],
               raw: true
          })

          // 获取所有不重复的年份
          const years = await VideoTag.findAll({
               attributes: ['year'],
               where: {
                    year: {
                         [Op.not]: null
                    }
               },
               group: ['year'],
               order: [['year', 'DESC']],
               raw: true
          })

          ctx.body = {
               code: 200,
               message: '筛选选项获取成功',
               data: {
                    genres: genres.map(item => item.genre).filter(Boolean),
                    regions: regions.map(item => item.region).filter(Boolean),
                    years: years.map(item => item.year).filter(Boolean)
               }
          }
     } catch (error) {
          console.error('获取筛选选项失败:', error)
          ctx.body = {
               code: 500,
               message: '获取筛选选项失败',
               data: null
          }
     }
}

// 6.根据筛选条件获得推荐视频 - 支持多选
module.exports.getRecommendVideos = async (ctx, next) => {
     try {
          const {
               page = 1,
               limit = 50,
               categories,    // 支持多个分类，逗号分隔
               genres,        // 支持多个类型，逗号分隔
               regions,       // 支持多个地区，逗号分隔
               yearRanges     // 支持多个年份范围，逗号分隔
          } = ctx.request.query

          // 解析多选参数的辅助函数
          const parseMultipleValues = (param) => {
               if (!param || param === '') return null
               return param.split(',').map(item => item.trim()).filter(item => item !== '')
          }

          // 解析各个筛选参数
          const categoryList = parseMultipleValues(categories)
          const genreList = parseMultipleValues(genres)
          const regionList = parseMultipleValues(regions)
          const yearRangeList = parseMultipleValues(yearRanges)

          console.log('接收到的筛选参数:')
          console.log('- categoryList:', categoryList)
          console.log('- genreList:', genreList)
          console.log('- regionList:', regionList)
          console.log('- yearRangeList:', yearRangeList)

          // 构建视频表查询条件
          let videoWhere = {
               status: 1  // 只查询已发布的视频
          }

          // 构建标签表查询条件
          let tagWhere = {}
          let needJoin = false

          // 分类筛选 - 支持多选
          if (categoryList && categoryList.length > 0) {
               const categoryNumbers = categoryList.map(cat => parseInt(cat)).filter(cat => !isNaN(cat))
               if (categoryNumbers.length > 0) {
                    videoWhere.category = {
                         [Op.in]: categoryNumbers  // 使用 IN 操作符支持多选
                    }
               }
          }

          // 类型筛选 - 支持多选
          if (genreList && genreList.length > 0) {
               // 构建 OR 条件，匹配任一类型
               tagWhere[Op.or] = tagWhere[Op.or] || []
               tagWhere[Op.or].push({
                    genre: {
                         [Op.or]: genreList.map(genre => ({
                              [Op.like]: `%${genre}%`
                         }))
                    }
               })
               needJoin = true
          }

          // 地区筛选 - 支持多选
          if (regionList && regionList.length > 0) {
               if (!tagWhere[Op.or]) tagWhere[Op.or] = []
               tagWhere[Op.or].push({
                    region: {
                         [Op.or]: regionList.map(region => ({
                              [Op.like]: `%${region}%`
                         }))
                    }
               })
               needJoin = true
          }

          // 年份筛选 - 支持多选
          if (yearRangeList && yearRangeList.length > 0) {
               const currentYear = new Date().getFullYear()
               const yearConditions = []

               yearRangeList.forEach(yearRange => {
                    switch (yearRange) {
                         case '2025-2020':
                              yearConditions.push({ [Op.between]: [2020, currentYear + 1] })
                              break
                         case '2019-2011':
                              yearConditions.push({ [Op.between]: [2011, 2019] })
                              break
                         case '2010-2000':
                              yearConditions.push({ [Op.between]: [2000, 2010] })
                              break
                         case '更早':
                              yearConditions.push({ [Op.lt]: 2000 })
                              break
                    }
               })

               if (yearConditions.length > 0) {
                    if (!tagWhere[Op.or]) tagWhere[Op.or] = []
                    tagWhere[Op.or].push({
                         year: { [Op.or]: yearConditions }
                    })
                    needJoin = true
               }
          }

          // 如果有多个 OR 条件，需要用 AND 连接
          if (tagWhere[Op.or] && tagWhere[Op.or].length > 1) {
               // 将多个条件组合为 AND 关系
               const orConditions = tagWhere[Op.or]
               tagWhere = { [Op.and]: orConditions }
          } else if (tagWhere[Op.or] && tagWhere[Op.or].length === 1) {
               // 只有一个条件时直接使用
               tagWhere = tagWhere[Op.or][0]
          }

          console.log('构建的查询条件:')
          console.log('- videoWhere:', JSON.stringify(videoWhere, null, 2))
          console.log('- tagWhere:', JSON.stringify(tagWhere, null, 2))
          console.log('- needJoin:', needJoin)

          // 构建查询选项
          const queryOptions = {
               where: videoWhere,
               offset: (page - 1) * limit,
               limit: parseInt(limit),
               order: [
                    ['create_time', 'DESC']  // 默认按创建时间倒序
               ]
          }

          // 如果需要关联查询
          if (needJoin) {
               queryOptions.include = [{
                    model: VideoTag,
                    where: tagWhere,
                    required: true
               }]
               // 如果有标签筛选条件，按评分倒序排列
               queryOptions.order = [
                    [{ model: VideoTag }, 'rating', 'DESC'],
                    ['create_time', 'DESC']
               ]
          } else {
               // 没有标签筛选条件时，可以选择性包含标签信息
               queryOptions.include = [{
                    model: VideoTag,
                    required: false
               }]
          }

          // 执行查询
          let videos = await Video.findAll(queryOptions)

          // 在应用层按评分排序（确保排序正确）
          videos = videos.sort((a, b) => {
               const ratingA = (a.video_tag && a.video_tag.rating) ? parseFloat(a.video_tag.rating) : 0
               const ratingB = (b.video_tag && b.video_tag.rating) ? parseFloat(b.video_tag.rating) : 0

               // 先按评分排序
               if (ratingB !== ratingA) {
                    return ratingB - ratingA
               }

               // 评分相同则按创建时间排序
               const timeA = new Date(a.create_time).getTime()
               const timeB = new Date(b.create_time).getTime()
               return timeB - timeA
          })

          // 获取总数
          const countOptions = {
               where: videoWhere
          }
          if (needJoin) {
               countOptions.include = [{
                    model: VideoTag,
                    where: tagWhere,
                    required: true
               }]
          }
          const total = await Video.count(countOptions)

          console.log(`查询结果: 找到 ${videos.length} 个视频，总计 ${total} 个`)

          ctx.body = {
               code: 200,
               message: '推荐视频获取成功',
               data: {
                    videos,
                    total,
                    page: parseInt(page),
                    limit: parseInt(limit),
                    hasMore: page * limit < total
               }
          }
     } catch (error) {
          console.error('获取推荐视频失败:', error)
          ctx.body = {
               code: 500,
               message: '获取推荐视频失败',
               data: null
          }
     }
}

// 7. 根据播放视频推荐视频
module.exports.recommendPlayVideo = async (ctx) => {
  const { keywords } = ctx.query

  const list = await Video.findAll({
     where: {
          [Op.or]: [
               { title: { [Op.like]: `%${keywords}%` } },
               { '$video_tag.region$': { [Op.like]: `%${keywords}%` } },
               { '$video_tag.genre$': { [Op.like]: `%${keywords}%` } },
          ]
     },
     include: [{
          model: VideoTag,
          attributes: ['region', 'genre'],
          required: false // 保持 false，允许只有 title 匹配的也能出
     }],
     order: [['title', 'asc']]
     })

  ctx.body = {
    code: 200,
    message: '获取成功',
    data: list
  }
}

// 8.获取榜单视频
module.exports.getRankVideos = async (ctx, next) => {
     try {
          const {
               page = 1,
               limit = 5,
               rankType = 'comprehensive', // comprehensive(总榜), hot(热播), rating(好评), like(心选)
               category // 分类筛选
          } = ctx.request.query

          console.log('获取榜单请求参数:', {
               page,
               limit,
               rankType,
               category
          })

          // 构建查询条件
          let videoWhere = {
               status: 1 // 只查询已发布的视频
          }

          // 分类筛选 - 适用于所有榜单类型
          if (category !== undefined && category !== '') {
               videoWhere.category = parseInt(category)
          }

          // 查询选项
          const queryOptions = {
               where: videoWhere,
               include: [{
                    model: VideoTag,
                    required: false
               }],
               offset: (page - 1) * limit,
               limit: parseInt(limit)
          }

          // 获取所有符合条件的视频用于排序
          const allVideosOptions = {
               where: videoWhere,
               include: [{
                    model: VideoTag,
                    required: false
               }]
          }

          let allVideos = await Video.findAll(allVideosOptions)

          // 根据榜单类型进行排序
          if (rankType === 'hot') {
               // 热播榜：按播放量排序
               allVideos.sort((a, b) => b.view_count - a.view_count)
          } else if (rankType === 'rating') {
               // 好评榜：按评分排序
               allVideos.sort((a, b) => {
                    const ratingA = (a.video_tag && a.video_tag.rating) ? parseFloat(a.video_tag.rating) : 0
                    const ratingB = (b.video_tag && b.video_tag.rating) ? parseFloat(b.video_tag.rating) : 0
                    return ratingB - ratingA
               })
          } else if (rankType === 'like') {
               // 心选热榜：按点赞数排序
               allVideos.sort((a, b) => b.like_count - a.like_count)
          } else {
               // 总榜：综合评分排序
               // 先计算最大值用于归一化
               const maxViewCount = Math.max(...allVideos.map(v => v.view_count), 1)
               const maxLikeCount = Math.max(...allVideos.map(v => v.like_count), 1)

               allVideos.sort((a, b) => {
                    const ratingA = (a.video_tag && a.video_tag.rating) ? parseFloat(a.video_tag.rating) : 0
                    const ratingB = (b.video_tag && b.video_tag.rating) ? parseFloat(b.video_tag.rating) : 0

                    // 综合评分算法：评分权重40% + 播放量权重30% + 点赞数权重30%
                    const scoreA = (ratingA / 10) * 0.4 +
                         (a.view_count / maxViewCount) * 0.3 +
                         (a.like_count / maxLikeCount) * 0.3

                    const scoreB = (ratingB / 10) * 0.4 +
                         (b.view_count / maxViewCount) * 0.3 +
                         (b.like_count / maxLikeCount) * 0.3

                    return scoreB - scoreA
               })
          }

          // 分页处理
          const startIndex = (page - 1) * limit
          const endIndex = startIndex + parseInt(limit)
          const paginatedVideos = allVideos.slice(startIndex, endIndex)

          const total = allVideos.length

          console.log(`榜单查询结果: 找到 ${paginatedVideos.length} 个视频，总计 ${total} 个`)

          ctx.body = {
               code: 200,
               message: '榜单视频获取成功',
               data: {
                    videos: paginatedVideos,
                    total,
                    page: parseInt(page),
                    limit: parseInt(limit),
                    hasMore: endIndex < total
               }
          }
     } catch (error) {
          console.error('获取榜单视频失败:', error)
          ctx.body = {
               code: 500,
               message: '获取榜单视频失败',
               data: null
          }
     }
}

// 9.视频流
module.exports.streamVideo = async (ctx) => {
  const videoPath = path.join(__dirname, '../public/uploads/videos', ctx.params.filename);

  try {
    // 检查文件是否存在
    if (!fs.existsSync(videoPath)) {
      ctx.status = 404;
      ctx.body = 'Video Not Found';
      return;
    }

    const stat = fs.statSync(videoPath);
    const fileSize = stat.size;
    const range = ctx.headers.range;

    // 设置通用响应头
    ctx.set("Accept-Ranges", "bytes");
    ctx.set("Content-Type", "video/mp4");
    ctx.set("Cache-Control", "no-cache");
    
    // 添加 CORS 头部（如果需要）
    ctx.set("Access-Control-Allow-Origin", "*");
    ctx.set("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS");
    ctx.set("Access-Control-Allow-Headers", "Range");

    if (range) {
      // 处理 Range 请求
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

      // 验证范围
      if (start >= fileSize || end >= fileSize || start > end) {
        ctx.status = 416; // Range Not Satisfiable
        ctx.set("Content-Range", `bytes */${fileSize}`);
        ctx.body = 'Range Not Satisfiable';
        return;
      }

      const chunkSize = end - start + 1;
      
      // 创建文件流
      const fileStream = fs.createReadStream(videoPath, { start, end });

      // 设置 206 部分内容响应
      ctx.status = 206;
      ctx.set("Content-Range", `bytes ${start}-${end}/${fileSize}`);
      ctx.set("Content-Length", chunkSize);

      // 错误处理
      fileStream.on('error', (err) => {
        console.error(`文件读取错误 [${ctx.params.filename}]:`, err.message);
        if (!ctx.res.headersSent) {
          ctx.status = 500;
          ctx.body = 'Internal Server Error';
        }
        // 确保流被正确关闭
        if (!fileStream.destroyed) {
          fileStream.destroy();
        }
      });

      // 客户端连接关闭处理
      const onClientDisconnect = () => {
        console.log(`客户端断开连接 [${ctx.params.filename}]`);
        if (!fileStream.destroyed) {
          fileStream.destroy();
        }
      };

      // 监听客户端断开事件
      ctx.req.on('close', onClientDisconnect);
      ctx.req.on('error', onClientDisconnect);
      ctx.res.on('close', onClientDisconnect);
      ctx.res.on('error', (err) => {
        console.error(`响应错误 [${ctx.params.filename}]:`, err.message);
        onClientDisconnect();
      });

      // 流结束时清理监听器
      fileStream.on('end', () => {
        ctx.req.removeListener('close', onClientDisconnect);
        ctx.req.removeListener('error', onClientDisconnect);
        ctx.res.removeListener('close', onClientDisconnect);
        ctx.res.removeListener('error', onClientDisconnect);
      });

      ctx.body = fileStream;

    } else {
      // 处理完整文件请求
      ctx.status = 200;
      ctx.set("Content-Length", fileSize);

      const fileStream = fs.createReadStream(videoPath);

      // 错误处理
      fileStream.on('error', (err) => {
        console.error(`文件读取错误 [${ctx.params.filename}]:`, err.message);
        if (!ctx.res.headersSent) {
          ctx.status = 500;
          ctx.body = 'Internal Server Error';
        }
        if (!fileStream.destroyed) {
          fileStream.destroy();
        }
      });

      // 客户端连接关闭处理
      const onClientDisconnect = () => {
        console.log(`客户端断开连接 [${ctx.params.filename}]`);
        if (!fileStream.destroyed) {
          fileStream.destroy();
        }
      };

      ctx.req.on('close', onClientDisconnect);
      ctx.req.on('error', onClientDisconnect);
      ctx.res.on('close', onClientDisconnect);
      ctx.res.on('error', (err) => {
        console.error(`响应错误 [${ctx.params.filename}]:`, err.message);
        onClientDisconnect();
      });

      // 流结束时清理监听器
      fileStream.on('end', () => {
        ctx.req.removeListener('close', onClientDisconnect);
        ctx.req.removeListener('error', onClientDisconnect);
        ctx.res.removeListener('close', onClientDisconnect);
        ctx.res.removeListener('error', onClientDisconnect);
      });

      ctx.body = fileStream;
    }

  } catch (error) {
    console.error(`视频流处理错误 [${ctx.params.filename}]:`, error);
    if (!ctx.res.headersSent) {
      ctx.status = 500;
      ctx.body = 'Internal Server Error';
    }
  }
};

// 10.获取短视频历史记录 (根据 user_id - 不分页)
module.exports.getShortVideoHistory = async (ctx) => {
    const { user_id } = ctx.query; // 只接收 user_id

    if (!user_id) {
        ctx.status = 400;
        ctx.body = { code: 400, message: '缺少用户ID', data: null };
        return;
    }

    try {
        const rows = await ShortVideoHistory.findAll({
            where: {
                user_id: user_id // 根据 user_id 筛选
            },
            include: [{ // 联结 video 表获取视频详情
                model: Video,
                as: 'videoDetails',
            }],
            order: [['watch_time', 'DESC']] // 按观看时间降序排列，最新观看的在前
        });

        ctx.status = 200;
        ctx.body = {
            code: 200,
            message: '用户短视频历史获取成功',
            data: rows // 直接返回所有符合条件的记录列表
        };
    } catch (error) {
        console.error('获取用户视频历史失败:', error);
        ctx.status = 500;
        ctx.body = { code: 500, message: '服务器内部错误', data: null };
    }
};

// 11. 获取视频收藏记录 (根据 user_id - 不分页)
module.exports.getShortVideoCollect = async (ctx) => {
    const { user_id } = ctx.query; // 只接收 user_id

    if (!user_id) {
        ctx.status = 400;
        ctx.body = { code: 400, message: '缺少用户ID', data: null };
        return;
    }

    try {
        // 使用 findAll 而不是 findAndCountAll，且不设置 limit/offset
        const rows = await ShortVideoCollect.findAll({
            where: {
                user_id: user_id // 根据 user_id 筛选
            },
            include: [{ // 联结 video 表获取视频详情
                model: Video,
                as: 'videoDetails',
            }],
            order: [['collect_time', 'DESC']] // 按收藏时间降序排列，最新收藏的在前
        });

        ctx.status = 200;
        ctx.body = {
            code: 200,
            message: '用户短视频收藏获取成功',
            data: rows // 直接返回所有符合条件的记录列表
        };
    } catch (error) {
        console.error('获取用户视频收藏失败:', error);
        ctx.status = 500;
        ctx.body = { code: 500, message: '服务器内部错误', data: null };
    }
};

// 12. 登录
module.exports.login = async (ctx, next) => {
  const { username, password } = ctx.request.body;
  // 1. 检查是否为空
  if (!username || !password) {
    ctx.body = { code: 400, message: "用户名或密码不能为空", success: false };
    return;
  }

  // 2. 查询用户
  const user = await User.findOne({ where: { username } });

  console.log(JSON.stringify(user))
  // 3. 判断密码
  if (user === null) {
    ctx.body = { code: 400, message: "用户不存在", success: false };
    return;
  }

  if (user.password !== md5(password)) {
    ctx.body = { code: 400, message: "密码错误", success: false };
    return;
  }

  // 4. 登录成功
  const token = await generateToken({ username: user.username, id: user.user_id });
  ctx.body = { code: 200, message: "登录成功", data: { user, token }, success: true };
};

// 13. 获取用户观看历史记录（支持分类筛选）
module.exports.getUserWatchHistory = async (ctx) => {
     const { user_id, category } = ctx.query;

     if (!user_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少用户ID', data: null };
          return;
     }

     try {
          // 构建查询条件
          let whereCondition = { user_id: user_id };

          // 如果指定了分类，添加视频分类筛选
          let videoWhereCondition = {};
          if (category !== undefined && category !== '' && category !== 'all') {
               videoWhereCondition.category = parseInt(category);
          }

          // 查询观看历史
          const historyRecords = await WatchHistory.findAll({
               where: whereCondition,
               include: [{
                    model: Video,
                    where: videoWhereCondition,
                    include: [{
                         model: VideoTag,
                         required: false
                    }]
               }],
               order: [['last_watch_time', 'DESC']]
          });

          // 按日期分组
          const groupedHistory = {};
          historyRecords.forEach(record => {
               const watchDate = new Date(record.last_watch_time);
               const dateKey = `${watchDate.getFullYear()}-${String(watchDate.getMonth() + 1).padStart(2, '0')}-${String(watchDate.getDate()).padStart(2, '0')}`;

               if (!groupedHistory[dateKey]) {
                    groupedHistory[dateKey] = [];
               }

               // 计算观看进度百分比
               const watchProgress = record.video && record.video.duration > 0
                    ? Math.min(100, Math.round((record.watch_time / record.video.duration) * 100))
                    : 0;

               groupedHistory[dateKey].push({
                    history_id: record.history_id,
                    video_id: record.video_id,
                    watch_time: record.watch_time,
                    last_watch_time: record.last_watch_time,
                    watch_progress: watchProgress,
                    video: record.video
               });
          });

          // 转换为数组格式，方便前端使用
          const result = Object.keys(groupedHistory)
               .sort((a, b) => b.localeCompare(a)) // 日期降序
               .map(date => ({
                    date: date,
                    records: groupedHistory[date]
               }));

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '用户观看历史获取成功',
               data: result
          };
     } catch (error) {
          console.error('获取用户观看历史失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 14. 删除用户观看历史记录
module.exports.deleteWatchHistory = async (ctx) => {
     const { history_ids } = ctx.request.body;

     if (!history_ids || !Array.isArray(history_ids) || history_ids.length === 0) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少历史记录ID', data: null };
          return;
     }

     try {
          // 删除指定的历史记录
          const deletedCount = await WatchHistory.destroy({
               where: {
                    history_id: {
                         [Op.in]: history_ids
                    }
               }
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '删除成功',
               data: { deletedCount }
          };
     } catch (error) {
          console.error('删除观看历史失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 15. 记录用户观看历史
module.exports.recordWatchHistory = async (ctx) => {
     const { user_id, video_id, watch_time } = ctx.request.body;

     if (!user_id || !video_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          // 查找是否已存在该用户对该视频的观看记录
          let watchHistory = await WatchHistory.findOne({
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });

          if (watchHistory) {
               // 如果存在，更新观看时间和最后观看时间
               await watchHistory.update({
                    watch_time: watch_time || 0,
                    last_watch_time: new Date()
               });
          } else {
               // 如果不存在，创建新的观看记录
               watchHistory = await WatchHistory.create({
                    user_id: user_id,
                    video_id: video_id,
                    watch_time: watch_time || 0,
                    last_watch_time: new Date()
               });
          }

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '观看历史记录成功',
               data: watchHistory
          };
     } catch (error) {
          console.error('记录观看历史失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 16. 更新观看进度
module.exports.updateWatchProgress = async (ctx) => {
     const { user_id, video_id, watch_time } = ctx.request.body;

     if (!user_id || !video_id || watch_time === undefined) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          const [updated] = await WatchHistory.update({
               watch_time: watch_time,
               last_watch_time: new Date()
          }, {
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: updated ? '更新成功' : '记录不存在',
               data: { updated: updated > 0 }
          };
     } catch (error) {
          console.error('更新观看进度失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 17. 注册
module.exports.register = async (ctx, next) => {
  try {
    const { username, password, confirmPassword, email, phone } = ctx.request.body;

    // 输入验证
    const validation = validateRegisterInput({ 
      username, 
      password, 
      confirmPassword, 
      email, 
      phone 
    });

    if (!validation) {
      ctx.status = 400;
      ctx.body = {
        success: false,
        message: validation.errors[0]
      };
      return;
    }

    // 检查用户名是否已存在
    if (await UserService.isUsernameExists(username.trim())) {
      ctx.status = 405;
      ctx.body = {
        success: false,
        message: '用户名已存在'
      };
      return;
    }

    // 检查邮箱是否已存在
    if (email && email.trim() && await UserService.isEmailExists(email.trim())) {
      ctx.status = 406;
      ctx.body = {
        success: false,
        message: '该邮箱已被注册'
      };
      return;
    }

    // 检查手机号是否已存在
    if (phone && phone.trim() && await UserService.isPhoneExists(phone.trim())) {
      ctx.status = 407;
      ctx.body = {
        success: false,
        message: '该手机号已被注册'
      };
      return;
    }

    // 创建新用户
    const newUser = await UserService.createUser({
      username: username.trim(),
      password,
      avatar: `https://picsum.photos/200/200?random=${Date.now()}`,
      email: email && email.trim() ? email.trim() : null,
      phone: phone && phone.trim() ? phone.trim() : null
    });

    // 返回成功响应
    const userInfo = {
      user_id: newUser.user_id,
      username: newUser.username,
      nickname: newUser.nickname,
      email: newUser.email,
      phone: newUser.phone,
      register_time: newUser.register_time,
      user_level: newUser.user_level
    };

    ctx.status = 200;
    ctx.body = {
      success: true,
      message: '注册成功',
      data: userInfo
    };

  } catch (error) {
    console.error('注册错误:', error);

    // 处理Sequelize唯一约束错误
    if (error.name === 'SequelizeUniqueConstraintError') {
      const field = error.errors[0].path;
      let message = '数据已存在';

      switch (field) {
        case 'username':
          message = '用户名已存在';
          break;
        case 'email':
          message = '该邮箱已被注册';
          break;
        case 'phone':
          message = '该手机号已被注册';
          break;
      }

      ctx.status = 409;
      ctx.body = {
        success: false,
        message: message
      };
      return;
    }

    ctx.status = 500;
    ctx.body = {
      success: false,
      message: '服务器内部错误'
    };
  }
};

// 18. 评论
module.exports.Comment = async (ctx) => { 
     try {
          const { user_id, video_id, content } = ctx.request.body;
          const comment = await Comment.create({
               user_id: user_id,
               video_id: video_id,
               content: content
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '评论成功',
               data: comment
          };
     } catch (error) {
          console.error('评论失败:', error);
          ctx.status = 500;
          ctx.body = {
               code: 500,
               message: '服务器内部错误',
               data: null
          };        
     }
};

// 19. 获取评论
module.exports.getComment = async (ctx) => {
  try {
    const { video_id } = ctx.query

    const comments = await Comment.findAll({
      where: {
        video_id: video_id
      },
      include: [
        {
          model: User,
          attributes: ['username', 'avatar']  // 只选取需要的字段
        }
      ],
      order: [['create_time', 'DESC']]
    })

    ctx.status = 200
    ctx.body = {
      code: 200,
      message: '获取评论成功',
      data: comments
    }
  } catch (error) {
    console.error('获取评论失败：', error)
    ctx.status = 500
    ctx.body = {
      code: 500,
      message: '服务器错误',
      data: error
    }
  }
}

// 20. 更新收藏
exports.updateCollectResponse = async (ctx, next) => {
  try {
    const { video_id, action } = ctx.request.body;

    // 参数校验
    if (!video_id || !['add', 'remove'].includes(action)) {
      ctx.body = { code: 400, message: '参数不完整或操作类型不合法' };
      return;
    }

    // 查询视频是否存在
    const video = await Video.findOne({ where: { video_id: video_id } });

    if (!video) {
      ctx.body = { code: 404, message: '视频不存在' };
      return;
    }

    // 更新收藏数量
    let newCount = video.like_count;
    if (action === 'add') {
      newCount += 1;
    } else if (action === 'remove' && newCount > 0) {
      newCount -= 1;
    }

    // 保存新值
    await Video.update(
      { like_count: newCount },
      { where: { video_id: video_id } }
    );

    ctx.body = { code: 200, message: '收藏数量更新成功', like_count: newCount };
  } catch (err) {
    console.error("更新收藏数量失败：", err);
    ctx.status = 500;
    ctx.body = { code: 500, message: "服务器内部错误" };
  }
}

// 21. 添加收藏
exports.addShortVideoFavorite = async (ctx) => {
     const { user_id, video_id } = ctx.request.body;

     if (!user_id || !video_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          // 先查询视频信息获取分类
          const video = await Video.findOne({
               where: { video_id: video_id }
          });

          if (!video) {
               ctx.status = 404;
               ctx.body = { code: 404, message: '视频不存在', data: null };
               return;
          }

          // 检查是否已收藏
          const existingFavorite = await ShortVideoCollect.findOne({
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });

          if (existingFavorite) {
               ctx.status = 200;
               ctx.body = {
                    code: 200,
                    message: '已经收藏过了',
                    data: { is_favorited: true }
               };
               return;
          }

          // 创建收藏记录
          const favorite = await ShortVideoCollect.create({
               user_id: user_id,
               video_id: video_id,
               collect_time: new Date()
          });
          console.log('收藏记录创建成功:', favorite);

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '收藏成功',
               data: favorite
          };
     } catch (error) {
     console.error('添加收藏失败:', error); // 这里会打印出详细错误信息
     console.error(error.stack); // 打印堆栈信息
     ctx.status = 500;
     ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }

};

// 22. 取消收藏
exports.removeShortVideoFavorite = async (ctx) => {
     const { user_id, video_id } = ctx.request.body;

     if (!user_id || !video_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          const deleted = await ShortVideoCollect.destroy({
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });
          console.log('收藏记录删除成功:', deleted);
          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: deleted > 0 ? '取消收藏成功' : '未找到收藏记录',
               data: { deleted: deleted > 0 }
          };
     } catch (error) {
          console.error('取消收藏失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 21. 检查是否已收藏
exports.checkShortVideoFavorite = async (ctx) => {
     const { user_id, video_id } = ctx.request.body;

     if (!user_id || !video_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          const favorite = await ShortVideoCollect.findOne({
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '查询成功',
               data: { is_favorited: !!favorite }
          };
     } catch (error) {
          console.error('检查收藏状态失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 22. 用户编辑方法
exports.userEdit = async (ctx, next) => {
    // 获取当前用户信息
    const {
       user_id, username, password, birthday, gender, phone, signature, nickname, avatar
    } = ctx.request.body;

    const baseParams = {
       user_id, username, password, birthday, phone, nickname, avatar
    };
     const profileParams = {
       user_id, signature, gender
    };

    // 验证必填字段
    if (!user_id) {
      ctx.body = { code: 400, message: '缺少必要参数' };
      return;
    }

    try {
      // 更新用户基本信息
      await User.update(baseParams, { where: { user_id } });

      // 更新用户扩展信息
      await UserProfile.update(profileParams, { where: { user_id } });

      ctx.body = { code: 200, message: '用户信息更新成功' };
    }
    catch (error) {
      console.error('用户信息更新失败:', error);
      ctx.body = { code: 500, message: '用户信息更新失败' };
    }
}

exports.getUserInfo = async (ctx, next) => {
    const userId = ctx.user.id;

    try {
        // 获取基本信息
        const user = await User.findOne({ 
            where: { user_id: userId },
            attributes: ['user_id', 'username', 'nickname', 'avatar', 'phone', 'email']
        });

        // 获取扩展信息
        const profile = await UserProfile.findOne({ 
            where: { user_id: userId },
            attributes: ['gender', 'birthday', 'signature', 'introduction']
        });

        // 合并数据
        const userData = {
            ...user.get({ plain: true }),
            ...(profile ? profile.get({ plain: true }) : {})
        };

        ctx.body = { 
            code: 200, 
            message: "用户信息",
            data: { user: userData } 
        };
    } catch (error) {
        ctx.body = { code: 500, message: "获取用户信息失败" };
    }
}

// 23. 获得用户信息方法
exports.getUserInfo = async (ctx, next) => {
    const userId = ctx.user.id;

    try {
        // 查询用户基本信息和关联的个人资料
        const user = await User.findOne({
            where: { user_id: userId },
            include: [{
                model: UserProfile,
                as: 'profile',
                attributes: ['gender', 'birthday', 'signature', 'update_time']
            }],
            attributes: [
                'user_id', 'username', 'nickname', 'avatar', 
                'phone', 'email', 'register_time', 
                'status', 'user_level', 'last_login_time'
            ]
        });

        if (!user) {
            ctx.body = { code: 404, message: "用户不存在" };
            return;
        }

        // 格式化返回数据
        const userData = {
            id: user.user_id,
            username: user.username,
            nickname: user.nickname,
            avatar: user.avatar,
            phone: user.phone,
            email: user.email,
            register_time: user.register_time,
            status: user.status,
            user_level: user.user_level,
            last_login_time: user.last_login_time,
            profile: {
                sex: user.profile ? user.profile.gender : null,
                birthday: user.profile ? user.profile.birthday : null,
                introduction: user.profile ? user.profile.signature : null,
                update_time: user.profile ? user.profile.update_time : null
            }
        };

        ctx.body = { code: 200, message: "用户信息", data: { user: userData } };
    } catch (error) {
        console.error("获取用户信息失败:", error);
        ctx.body = { code: 1, message: "获取失败", error: error.message };
    }
};

// 24. 获取用户收藏列表（支持分类筛选）
exports.getUserFavorites = async (ctx) => {
     const { user_id, category } = ctx.query;

     if (!user_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少用户ID', data: null };
          return;
     }

     try {
          // 构建查询条件
          let whereCondition = { user_id: user_id };

          // 如果指定了分类，添加视频分类筛选
          let videoWhereCondition = {};
          if (category !== undefined && category !== '' && category !== 'all') {
               videoWhereCondition.category = parseInt(category);
          }

          // 查询收藏记录
          const favoriteRecords = await Favorite.findAll({
               where: whereCondition,
               include: [{
                    model: Video,
                    where: videoWhereCondition,
                    include: [{
                         model: VideoTag,
                         required: false
                    }]
               }],
               order: [['create_time', 'DESC']]
          });

          // 按日期分组
          const groupedFavorites = {};
          favoriteRecords.forEach(record => {
               const createDate = new Date(record.create_time);
               const dateKey = `${createDate.getFullYear()}-${String(createDate.getMonth() + 1).padStart(2, '0')}-${String(createDate.getDate()).padStart(2, '0')}`;

               if (!groupedFavorites[dateKey]) {
                    groupedFavorites[dateKey] = [];
               }

               groupedFavorites[dateKey].push({
                    favorite_id: record.favorite_id,
                    video_id: record.video_id,
                    create_time: record.create_time,
                    video: record.video
               });
          });

          // 转换为数组格式
          const result = Object.keys(groupedFavorites)
               .sort((a, b) => b.localeCompare(a))
               .map(date => ({
                    date: date,
                    records: groupedFavorites[date]
               }));

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '用户收藏获取成功',
               data: result
          };
     } catch (error) {
          console.error('获取用户收藏失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 25. 添加收藏
exports.addFavorite = async (ctx) => {
     const { user_id, video_id } = ctx.request.body;

     if (!user_id || !video_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          // 先查询视频信息获取分类
          const video = await Video.findOne({
               where: { video_id: video_id }
          });

          if (!video) {
               ctx.status = 404;
               ctx.body = { code: 404, message: '视频不存在', data: null };
               return;
          }

          // 检查是否已收藏
          const existingFavorite = await Favorite.findOne({
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });

          if (existingFavorite) {
               ctx.status = 200;
               ctx.body = {
                    code: 200,
                    message: '已经收藏过了',
                    data: { is_favorited: true }
               };
               return;
          }

          // 创建收藏记录
          const favorite = await Favorite.create({
               user_id: user_id,
               video_id: video_id,
               category_id: video.category, // 使用视频的分类作为category_id
               create_time: new Date()
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '收藏成功',
               data: favorite
          };
     } catch (error) {
          console.error('添加收藏失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 26. 取消收藏
exports.removeFavorite = async (ctx) => {
     const { user_id, video_id } = ctx.request.body;

     if (!user_id || !video_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          const deleted = await Favorite.destroy({
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: deleted > 0 ? '取消收藏成功' : '未找到收藏记录',
               data: { deleted: deleted > 0 }
          };
     } catch (error) {
          console.error('取消收藏失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 27. 检查是否已收藏
exports.checkFavorite = async (ctx) => {
     const { user_id, video_id } = ctx.query;

     if (!user_id || !video_id) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少必要参数', data: null };
          return;
     }

     try {
          const favorite = await Favorite.findOne({
               where: {
                    user_id: user_id,
                    video_id: video_id
               }
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '查询成功',
               data: { is_favorited: !!favorite }
          };
     } catch (error) {
          console.error('检查收藏状态失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};

// 28. 删除收藏记录（批量）
exports.deleteFavorites = async (ctx) => {
     const { favorite_ids } = ctx.request.body;

     if (!favorite_ids || !Array.isArray(favorite_ids) || favorite_ids.length === 0) {
          ctx.status = 400;
          ctx.body = { code: 400, message: '缺少收藏记录ID', data: null };
          return;
     }

     try {
          const deletedCount = await Favorite.destroy({
               where: {
                    favorite_id: {
                         [Op.in]: favorite_ids
                    }
               }
          });

          ctx.status = 200;
          ctx.body = {
               code: 200,
               message: '删除成功',
               data: { deletedCount }
          };
     } catch (error) {
          console.error('删除收藏失败:', error);
          ctx.status = 500;
          ctx.body = { code: 500, message: '服务器内部错误', data: null };
     }
};