const Router = require('koa-router')
const router = new Router()
const controller = require('../controller/api')
const {verifyToken} = require('../utils/token')

const path = require('path')
const multer = require('@koa/multer')
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null,path.join(__dirname, '../public/uploads/user')); // 文件存储的目录
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(
      null,
      file.fieldname +
        "-" +
        uniqueSuffix +
        "." +
        file.originalname.split(".").pop()
    ); // 文件名设置
  },
});
const upload = multer({ storage: storage });

// 1.轮播图获取
router.get('/getSwiper', controller.getSwiper)
// 2.视频列表获取
router.get('/getVideo', controller.getVideo)
// 3.视频详情获取
router.get('/getVideoDetail', controller.getVideoDetail)
// 4 搜索
router.get('/searchVideo', controller.searchVideo)
// 5.标签列表获取
router.get('/getFilterOptions', controller.getFilterOptions)
// 6.推荐视频获取
router.get('/getRecommendVideos', controller.getRecommendVideos)
// 7.视频相关推荐
router.get('/recommendPlayVideo', controller.recommendPlayVideo)
// 8.获取榜单视频
router.get('/getRankVideos', controller.getRankVideos)
// 9.视频流播放（支持 range 请求）
router.get('/videoStream/:filename', controller.streamVideo)
// 10.获取短视频历史记录 (根据 user_id - 不分页)
router.get('/getShortVideoHistory', controller.getShortVideoHistory)
// 11.获取视频收藏记录 (根据 user_id - 不分页)
router.get('/getShortVideoCollect', controller.getShortVideoCollect)
// 12.登录
router.post('/login',controller.login)
// 13. 获取用户观看历史
router.get('/getUserWatchHistory', controller.getUserWatchHistory)
// 14. 删除观看历史
router.post('/deleteWatchHistory', controller.deleteWatchHistory)
// 15. 记录观看历史
router.post('/recordWatchHistory', controller.recordWatchHistory)
// 16. 更新观看进度
router.post('/updateWatchProgress', controller.updateWatchProgress)
// 17. 注册
router.post('/register', controller.register);
// 18. 评论
router.post('/comment', controller.Comment);
// 19. 获取评论
router.get('/getComment', controller.getComment);
// 20.添加收藏
router.post('/addShortVideoFavorite', controller.addShortVideoFavorite);
// 21.删除收藏
router.post('/removeShortVideoFavorite', controller.removeShortVideoFavorite);
// 22.检查收藏
router.post('/checkShortVideoFavorite', controller.checkShortVideoFavorite);
// 23.更新收藏数量
router.post('/updateCollectResponse', controller.updateCollectResponse);
// 24.修改用户信息
router.post('/userEdit',verifyToken(),controller.userEdit)
// 25.获得用户信息
router.get('/getUserInfo',verifyToken(),controller.getUserInfo)
// 26.上传 一定POST请求
router.post('/uploads',upload.single('file'),async (ctx,next)=>{
  const file = ctx.request.file
  console.log(file)
  ctx.body = {code:200,message:'上传成功',data:file.filename}
})
// 27. 获取用户收藏列表
router.get('/getUserFavorites', controller.getUserFavorites)
// 28. 添加收藏
router.post('/addFavorite', controller.addFavorite)
// 29. 取消收藏
router.post('/removeFavorite', controller.removeFavorite)
// 30. 检查是否已收藏
router.get('/checkFavorite', controller.checkFavorite)
// 31. 批量删除收藏
router.post('/deleteFavorites', controller.deleteFavorites)

module.exports = router
