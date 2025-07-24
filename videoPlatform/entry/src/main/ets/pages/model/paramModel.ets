// \entry\src\main\ets\pages\model\paramModel.ets

import { FilterOptions, RecommendVideoResponse } from './recommendModel'

// 定义可能的响应数据类型
export type ResponseData =
  | object[]                    // 数组类型（视频列表、轮播图列表等）
    | FilterOptions               // 筛选选项类型
    | RecommendVideoResponse      // 推荐视频响应类型
    | object                      // 其他对象类型
    | string                      // 字符串类型
    | number                      // 数字类型
    | boolean                     // 布尔类型
    | null                        // 空值

// 接口返回值
export class ResponseModel {
  success: boolean;
  message: string;
  data: ResponseData;

  constructor() {
    this.success = false;
    this.message = "";
    this.data = null;
  }
}

// 传值参数
export class ParamModel{
  id?:number;
  page?:number;
  keywords?:string;
  type?:number;
  choose?:boolean;
  url?:string;
}

//登录
export  interface  LoginModel {
  username:string,
  password:string
}
// 修改用户信息
export interface UserEditParam {
  user_id: number
  username: string
  password: string
  birthday: Date
  gender: number
  phone: string
  signature: string
  nickname: string
  avatar: string
}
// 注册请求参数接口
export interface RegisterParams {
  username: string;
  password: string;
  confirmPassword: string;
  email?: string;
  phone?: string;
}
// 删除观看历史参数接口
export interface DeleteWatchHistoryParam {
  history_ids: number[];
}

// 记录观看历史参数接口
export interface RecordWatchHistoryParam {
  user_id: number;
  video_id: number;
  watch_time?: number;
}

// 更新观看进度参数接口
export interface UpdateWatchProgressParam {
  user_id: number;
  video_id: number;
  watch_time: number;
}

// 评论参数接口
export interface CommentParams {
  user_id: number;
  video_id: number;
  content: string;
}

// 评论用户接口
interface CommentUser {
  username: string;
  avatar: string;
}
// 评论接口返回数据接口
export interface CommentModel {
  comment_id: number
  user_id: number
  content: string
  create_time: Date // ISO 格式
  user: CommentUser
}

export interface UpdateCollectResponse {
  video_id: number;
  action: 'add' | 'remove';
}

export interface UpdateLikeResponse {
  video_id: number;
  action: 'add' | 'remove';
}

export interface AddShortVideoFavorite {
  video_id: number;
  user_id: number;
}

// 收藏参数接口
export interface FavoriteParam {
  user_id: number;
  video_id: number;
}

// 删除收藏参数接口
export interface DeleteFavoritesParam {
  favorite_ids: number[];
}
