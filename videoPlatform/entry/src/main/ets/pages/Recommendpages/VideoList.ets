import { VideoModel } from '../model/appModel'
import { FilterCondition, RecommendVideoResponse, RequestParamsBuilder, TypeChecker } from '../model/recommendModel'
import { getRecommendVideos } from '../common/api'
import { ConfigUtil as Config } from '../common/configUtil'
import { PullToRefresh } from '@ohos/pulltorefresh'

import router from '@ohos.router';
@Component
export struct VideoListComponent {
  @Prop @Watch('onFilterConditionChange') filterCondition: FilterCondition = {}
  @State videoList: VideoModel[] = []
  @State isLoading: boolean = false
  @State hasMore: boolean = true
  @State currentPage: number = 1
  @State pageSize: number = 10  // 改为合理的每页数量
  @State totalCount: number = 0
  @State isInitialLoad: boolean = true
  // 添加一个新的状态来追踪是否正在加载更多
  @State isLoadingMore: boolean = false
  scroller: Scroller = new Scroller()

  aboutToAppear() {
    this.loadVideos(true)
  }

  // 监听筛选条件变化
  onFilterConditionChange() {
    this.loadVideos(true) // 重置并重新加载
  }

  // 加载视频数据 - 支持多选筛选
  async loadVideos(reset: boolean = false) {
    // 防止重复加载
    if (this.isLoading || (this.isLoadingMore && !reset)) {
      return
    }

    // 如果是重置，清空当前数据
    if (reset) {
      this.currentPage = 1
      this.videoList = []
      this.hasMore = true
      this.totalCount = 0
      this.isLoading = true
      this.isLoadingMore = false
    } else {
      // 加载更多时设置标志
      this.isLoadingMore = true
    }

    try {
      // 构建请求参数 - 使用当前页码
      const requestPage = this.currentPage

      const paramsBuilder = new RequestParamsBuilder()
      const params = paramsBuilder
        .add('page', requestPage.toString())
        .add('limit', this.pageSize.toString())

      // 添加多选筛选条件
      if (this.filterCondition.categories && this.filterCondition.categories.length > 0) {
        params.addArray('categories', this.filterCondition.categories)
      }

      if (this.filterCondition.genres && this.filterCondition.genres.length > 0) {
        params.addArray('genres', this.filterCondition.genres)
      }

      if (this.filterCondition.regions && this.filterCondition.regions.length > 0) {
        params.addArray('regions', this.filterCondition.regions)
      }

      if (this.filterCondition.yearRanges && this.filterCondition.yearRanges.length > 0) {
        params.addArray('yearRanges', this.filterCondition.yearRanges)
      }

      const paramsString = params.build()


      const response = await getRecommendVideos(paramsString)

      if (response.success && response.data !== null && typeof response.data === 'object') {
        if (TypeChecker.isRecommendVideoResponse(response.data)) {
          const data = response.data as RecommendVideoResponse
          // 按评分从高到低排序
          const sortedVideos = (data.videos || []).sort((a, b) => {
            const ratingA = a.video_tag?.rating || 0
            const ratingB = b.video_tag?.rating || 0
            return ratingB - ratingA
          })

          // 过滤重复数据
          const existingIds = new Set(this.videoList.map(v => v.video_id))
          const newVideos = sortedVideos.filter(video => !existingIds.has(video.video_id))

          if (newVideos.length === 0 && sortedVideos.length > 0) {
            console.warn('所有视频都是重复的，可能是分页问题')
          }

          if (reset) {
            // 重置时直接替换
            this.videoList = sortedVideos
          } else {
            // 追加时只添加不重复的数据
            this.videoList = [...this.videoList, ...newVideos]
          }

          // 更新分页信息
          this.totalCount = data.total || 0

          // 重要：先根据后端返回的值设置hasMore
          this.hasMore = data.hasMore || false

          // 只有在成功获取数据后才增加页码
          if (!reset && sortedVideos.length > 0) {
            this.currentPage += 1
          }
        } else {
          console.error('响应数据格式不正确')
        }
      } else {
        console.error('请求失败:', response.message)
      }
    } catch (error) {
      console.error('加载视频失败:', error)
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.isInitialLoad = false
    }
  }

  // 懒加载更多视频
  loadMoreVideos(resolve?: (value: string) => void) {
    if (this.isLoading || this.isLoadingMore || !this.hasMore) {
      resolve && resolve(this.hasMore ? '正在加载中...' : '没有更多数据')
      return
    }

    // 加载下一页数据
    this.loadVideos(false).then(() => {
      resolve && resolve('加载完成')
    }).catch(() => {
      resolve && resolve('加载失败')
    })
  }

  // 刷新数据
  async refreshData(resolve?: (value: string) => void) {
    await this.loadVideos(true)
    resolve && resolve('刷新完成')
  }

  // 格式化播放次数
  formatViewCount(count: number): string {
    if (count >= 100000000) {
      return `${(count / 100000000).toFixed(1)}亿`
    } else if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`
    } else {
      return count.toString()
    }
  }

  // 格式化时长
  formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = seconds % 60

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    } else {
      return `${minutes}:${secs.toString().padStart(2, '0')}`
    }
  }

  @Builder
  VideoItem(item: VideoModel) {
    Column() {
      // 视频封面
      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(`${Config.SERVERURL}covers/${item.cover_url}`)
          .width('100%')
          .height(160)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        // 时长标签
        Text(this.formatDuration(item.duration))
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(0, 0, 0, 0.6)')
          .borderRadius(4)
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .margin({ right: 4, bottom: 4 })
      }

      // 视频标题
      Text(item.title)
        .fontSize(14)
        .fontColor('#333333')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })
        .textAlign(TextAlign.Start)
        .width('100%')

      // 视频信息
      Row() {
        // 评分
        if (item.video_tag?.rating && item.video_tag.rating > 0) {
          Text(`${item.video_tag.rating}分`)
            .fontSize(12)
            .fontColor('#FF6B35')
            .margin({ right: 8 })
        }

        // 观看次数
        Text(`${this.formatViewCount(item.view_count)}次播放`)
          .fontSize(12)
          .fontColor('#999999')
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 4 })
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(8)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/videoDetail',
        params: {
          id: item.video_id
        }
      })
    })
  }

  @Builder
  VideoGrid() {
    Column() {
      Grid() {
        ForEach(this.videoList, (item: VideoModel, index: number) => {
          GridItem() {
            this.VideoItem(item)
          }
        }, (item: VideoModel) => `video_${item.video_id}`)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .padding({ left: 16, right: 16 })

      // 加载中提示（加载更多时）
      if (this.isLoadingMore) {
        Row() {
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(50)
        .justifyContent(FlexAlign.Center)
      }

      // 没有更多数据提示
      if (!this.hasMore && this.videoList.length > 0 && !this.isLoadingMore) {
        Text('-----没有更多数据了-----')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 20, bottom: 20 })
          .textAlign(TextAlign.Center)
      }

      // 暂无数据提示
      if (this.videoList.length === 0 && !this.isLoading && !this.isInitialLoad) {
        Text('暂无视频数据')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 50 })
          .textAlign(TextAlign.Center)
      }

      // 初始加载中提示
      if (this.isLoading && this.isInitialLoad) {
        Text('加载中...')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 50 })
          .textAlign(TextAlign.Center)
      }
    }
  }

  @Builder
  VideoListContent() {
    Scroll(this.scroller) {
      this.VideoGrid()
    }
    .scrollBar(BarState.Off)
    .padding({ bottom: 20 })
    .onScrollEdge((side: Edge) => {
      if (side === Edge.Bottom) {
        // 滚动到底部时触发加载更多
        this.loadMoreVideos()
      }
    })
  }

  build() {
    Column() {
      PullToRefresh({
        data: this.videoList,
        scroller: this.scroller,
        customList: () => {
          this.VideoListContent()
        },
        onRefresh: () => {
          return new Promise<string>((resolve) => {
            this.refreshData(resolve)
          })
        },
        onLoadMore: () => {
          return new Promise<string>((resolve) => {
            this.loadMoreVideos(resolve)
          })
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F5F5F5')
  }
}
