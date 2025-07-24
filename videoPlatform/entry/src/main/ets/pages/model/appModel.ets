// 轮播图接口
export interface SwiperModel{
  id: number,
  title: string,
  url: string,
  imgurl: string,
  state: number,
  order: number,
  createdAt: string,
  updatedAt: string

}

// 视频接口
export class VideoModel{
  video_id: number;
  title: string;
  description: string;
  cover_url: string;
  video_url: string;
  duration: number;
  status: number;
  view_count: number;
  like_count: number;
  publish_time: string;
  create_time: string;
  update_time: string;
  category: number;
  video_tag?: VideoTagModel; // 关联的视频标签信息
  controller?:VideoController;
  isFavourite?: boolean;
  constructor(video_id: number, title: string, description: string, cover_url: string, video_url: string, duration: number, status: number, view_count: number, like_count: number, publish_time: string, create_time: string, update_time: string, category: number) {
    this.video_id = video_id;
    this.title = title;
    this.description = description;
    this.cover_url = cover_url;
    this.video_url = video_url;
    this.duration = duration;
    this.status = status;
    this.view_count = view_count;
    this.like_count = like_count;
    this.publish_time = publish_time;
    this.create_time = create_time;
    this.update_time = update_time;
    this.category = category;
  }
}

// 视频详情
export interface videoDetailModel {
  videos?:VideoModel[];
}

// 搜索分类
@Observed
export class searchCateNameModel{
  id:number;
  title:string;
  type:number;
  constructor(id:number,title:string,type:number) {
    this.id = id;
    this.title = title;
    this.type = type;
  }
}

// 视频标签模型
export interface VideoTagModel {
  video_id: number
  year: number
  region: string
  genre: string
  rating: number
  create_time: string
}

export class ShortVideoCollect {
  id: number; // Corresponds to 'id' in the short_video_collect table
  user_id: number; // Corresponds to 'user_id' in the short_video_collect table
  video_id: number; // Corresponds to 'video_id' in the short_video_collect table
  collect_time: string; // Corresponds to 'collect_time' in the short_video_collect table

  // 新增：包含关联的视频详情
  videoDetails?: VideoModel; // 注意：这里使用了可选属性 ?, 因为在某些情况下（例如，数据不完整或关联失败）它可能不存在

  constructor(
    id: number,
    user_id: number,
    video_id: number,
    collect_time: string,
    videoDetails?: VideoModel, // 构造函数也需要接收
  ) {
    this.id = id;
    this.user_id = user_id;
    this.video_id = video_id;
    this.collect_time = collect_time;
    this.videoDetails = videoDetails;
  }
}

// 修改 ShortVideoHistory 结构以包含关联数据
export class ShortVideoHistory {
  // 对应 short_video_history 表的字段
  id: number;
  user_id: number;
  video_id: number;
  watch_time: string; // 观看时间
  last_watched_progress?: number; // 上次观看进度，可选，因为可以有默认值或不传

  // 新增：包含关联的视频详情
  videoDetails?: VideoModel; // 可选


  constructor(
    id: number,
    user_id: number,
    video_id: number,
    watch_time: string,
    last_watched_progress?: number, // 可选参数
    videoDetails?: VideoModel, // 构造函数也需要接收
  ) {
    this.id = id;
    this.user_id = user_id;
    this.video_id = video_id;
    this.watch_time = watch_time;
    this.last_watched_progress = last_watched_progress;
    this.videoDetails = videoDetails;
  }
}

export  interface  UserModel {
  user_id?: number;
  username?: string;
  password?: string;
  avatar?: string;
  createdAt?: string;
  updatedAt?: string;
  birthday?: Date;
  gender?: number;
  phone?: string;
  signature?: string;
  nickname?: string;
}


// 观看历史模型
export interface WatchHistoryModel {
  history_id: number;
  video_id: number;
  watch_time: number;
  last_watch_time: string;
  watch_progress: number; // 观看进度百分比
  video?: VideoModel; // 关联的视频信息
}

// 按日期分组的观看历史
export interface GroupedWatchHistory {
  date: string;
  records: WatchHistoryModel[];
}

export  interface  UserModel2 {
  user_id?: number;
  username?: string;
  password?: string;
  birthday?: string;
  sex?: number;
  phone?: string;
  introduction?: string;
  nickname?: string;
  avatar?: string;
  createdAt?: string;
  updatedAt?: string;
}

// 收藏模型
export interface FavoriteModel {
  favorite_id: number;
  video_id: number;
  create_time: string;
  video?: VideoModel;
}

// 按日期分组的收藏
export interface GroupedFavorites {
  date: string;
  records: FavoriteModel[];
}

// 检查收藏状态响应
export interface CheckFavoriteResponse {
  is_favorited: boolean;
}