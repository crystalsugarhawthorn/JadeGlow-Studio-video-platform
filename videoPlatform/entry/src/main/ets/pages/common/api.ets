import {HttpGet, HttpPost} from './httpUtil'
import {FavoriteParam, DeleteFavoritesParam ,UserEditParam, ParamModel, RegisterParams, LoginModel, DeleteWatchHistoryParam, RecordWatchHistoryParam, UpdateWatchProgressParam, CommentParams, AddShortVideoFavorite, UpdateCollectResponse} from '../model/paramModel'

// 1.获取轮播图
export const getSwiperList = ()=> HttpGet('/getSwiper')
// 2.获取视频
export const getVideoList = ()=> HttpGet('/getVideo')
// 3.搜索
export const searchVideo= (params:ParamModel)=> HttpGet(encodeURI(`/searchVideo?keywords=${params.keywords}&page=${params.page}`))
// 4.获取视频详情
export const getVideoDetail= (params:ParamModel)=> HttpGet(encodeURI(`/getVideoDetail?video_id=${params.id}`))
// 5.获取筛选选项
export const getFilterOptions = ()=> HttpGet('/getFilterOptions')
// 6.获取推荐视频
export const getRecommendVideos = (params: string)=> HttpGet(`/getRecommendVideos?${params}`)
// 7.获取相关视频
export const recommendPlayVideo= (params:ParamModel)=> HttpGet(encodeURI(`/recommendPlayVideo?keywords=${params.keywords}`))
// 8.获取榜单视频
export const getRankVideos = (params: string)=> HttpGet(`/getRankVideos?${params}`)
// 9.获取短视频收藏
export const getShortVideoCollect = (user_id: number) => {return HttpGet(`/getShortVideoCollect?user_id=${user_id}`)}
// 10. 获取短视频历史
export const getShortVideoHistory = (user_id: number) => {return HttpGet(`/getShortVideoHistory?user_id=${user_id}`)}
// 11.登陆
export const login = (params:LoginModel) => HttpPost(`/login`,params)
// 12. 获取用户观看历史
export const getUserWatchHistory = (user_id: number, category?: string) => {
  if (category && category !== 'all') {
    return HttpGet(`/getUserWatchHistory?user_id=${user_id}&category=${category}`)
  }
  return HttpGet(`/getUserWatchHistory?user_id=${user_id}`)
}
// 13. 删除观看历史
export const deleteWatchHistory = (history_ids: number[]) => {
  const params: DeleteWatchHistoryParam = { history_ids: history_ids }
  return HttpPost('/deleteWatchHistory', params)
}
// 14. 记录观看历史
export const recordWatchHistory = (user_id: number, video_id: number, watch_time?: number) => {
  const params: RecordWatchHistoryParam = {
    user_id: user_id,
    video_id: video_id,
    watch_time: watch_time || 0
  }
  return HttpPost('/recordWatchHistory', params)
}
// 15. 更新观看进度
export const updateWatchProgress = (user_id: number, video_id: number, watch_time: number) => {
  const params: UpdateWatchProgressParam = {
    user_id: user_id,
    video_id: video_id,
    watch_time: watch_time
  }
  return HttpPost('/updateWatchProgress', params)
}
// 16. 注册
export const register = (params: RegisterParams) => HttpPost(`/register`, params)
// 17. 评论
export const comment = (params: CommentParams) => HttpPost('/comment', params)
// 18. 获取评论列表
export const getComment = (video_id: number) => HttpGet(`/getComment?video_id=${video_id}`)
// 19.添加短视频收藏
export const addShortVideoFavorite = (user_id: number,video_id:number) => {
  const params: AddShortVideoFavorite = {user_id: user_id, video_id:video_id}
  return HttpPost(`/addShortVideoFavorite`, params)
}
// 20.删除短视频收藏
export const removeShortVideoFavorite = (user_id: number,video_id:number) => {
  const params: AddShortVideoFavorite = {user_id: user_id, video_id:video_id}
  return HttpPost(`/removeShortVideoFavorite`, params)
}
// 21.检查是否收藏
export const checkShortVideoFavorite = (user_id: number,video_id:number) => {
  const params: AddShortVideoFavorite = {user_id: user_id, video_id:video_id}
  return HttpPost(`/checkShortVideoFavorite`, params)
}
// 22.更新收藏数据
export const updateCollectResponse = (video_id:number,action: 'add' | 'remove') => {
  const params: UpdateCollectResponse = {video_id:video_id,action: action}
  return HttpPost(`/updateCollectResponse`, params)
}
// 23.修改用户信息
export const userEdit = (params:UserEditParam) => HttpPost(`/userEdit`,params);
// 24.获取用户信息 getUserInfo
export const getUserInfo = () => HttpGet(`/getUserInfo`);
// 25. 获取用户收藏列表
export const getUserFavorites = (user_id: number, category?: string) => {
  if (category && category !== 'all') {
    return HttpGet(`/getUserFavorites?user_id=${user_id}&category=${category}`)
  }
  return HttpGet(`/getUserFavorites?user_id=${user_id}`)
}

// 26. 添加收藏
export const addFavorite = (user_id: number, video_id: number) => {
  const params: FavoriteParam = { user_id, video_id }
  return HttpPost('/addFavorite', params)
}

// 27. 取消收藏
export const removeFavorite = (user_id: number, video_id: number) => {
  const params: FavoriteParam = { user_id, video_id }
  return HttpPost('/removeFavorite', params)
}

// 28. 检查是否已收藏
export const checkFavorite = (user_id: number, video_id: number) => {
  return HttpGet(`/checkFavorite?user_id=${user_id}&video_id=${video_id}`)
}

// 29. 批量删除收藏
export const deleteFavorites = (favorite_ids: number[]) => {
  const params: DeleteFavoritesParam = { favorite_ids }
  return HttpPost('/deleteFavorites', params)
}

