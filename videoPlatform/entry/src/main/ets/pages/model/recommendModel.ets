import { VideoModel } from './appModel'

// 筛选选项数据模型
export interface FilterOptions {
  genres: string[]
  regions: string[]
  years: number[]
}

// 筛选条件模型 - 支持多选
export interface FilterCondition {
  categories?: number[]
  genres?: string[]
  regions?: string[]
  yearRanges?: string[]
}

// 推荐视频响应模型
export interface RecommendVideoResponse {
  videos: VideoModel[]
  total: number
  page: number
  limit: number
  hasMore: boolean
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

// 请求参数构建工具类
export class RequestParamsBuilder {
  private params: Record<string, string> = {}

  add(key: string, value: string | number | undefined): RequestParamsBuilder {
    if (value !== undefined && value !== null && value !== '') {
      this.params[key] = value.toString()
    }
    return this
  }

  // 添加数组参数支持
  addArray(key: string, values: (string | number)[] | undefined): RequestParamsBuilder {
    if (values && values.length > 0) {
      this.params[key] = values.join(',')
    }
    return this
  }

  build(): string {
    const paramPairs: string[] = []
    Object.keys(this.params).forEach(key => {
      paramPairs.push(`${key}=${encodeURIComponent(this.params[key])}`)
    })
    return paramPairs.join('&')
  }
}

// 类型检查工具类
export class TypeChecker {
  // 检查是否为推荐视频响应
  static isRecommendVideoResponse(data: object): boolean {
    try {
      const response = data as RecommendVideoResponse
      return response.videos !== undefined &&
        response.hasMore !== undefined &&
      Array.isArray(response.videos)
    } catch (e) {
      return false
    }
  }

  // 检查是否为筛选选项
  static isFilterOptions(data: object): boolean {
    try {
      const options = data as FilterOptions
      return Array.isArray(options.genres) &&
      Array.isArray(options.regions) &&
      Array.isArray(options.years)
    } catch (e) {
      return false
    }
  }
}