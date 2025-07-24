import { VideoModel } from '../model/appModel'
import { getRankVideos } from '../common/api'
import { ConfigUtil as Config } from '../common/configUtil'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { RequestParamsBuilder } from '../model/recommendModel'

import router from '@ohos.router';

// 定义榜单响应数据类型
interface RankVideoResponse {
  videos: VideoModel[]
  total: number
  page: number
  limit: number
  hasMore: boolean
}

@Component
export struct RankListComponent {
  @State selectedRankType: string = '总榜' // 总榜、热播榜、好评榜、心选热榜
  @State selectedCategory: string = '全部' // 全部、电视剧、电影、动漫、纪录片
  @State isCategoryExpanded: boolean = false
  @State videoList: VideoModel[] = []
  @State isLoading: boolean = false
  @State hasMore: boolean = true
  @State currentPage: number = 1
  @State pageSize: number = 100 // 每页显示5个视频
  scroller: Scroller = new Scroller()

  // 分类选项 - 包含"全部"
  private categoryOptions: string[] = ['全部', '电视剧', '电影', '动漫', '纪录片']
  private categoryMap: Map<string, number> = new Map([
    ['电视剧', 0],
    ['电影', 1],
    ['动漫', 2],
    ['纪录片', 3]
  ])

  aboutToAppear() {
    this.loadRankVideos(true)
  }

  // 获取榜单类型对应的排序字段
  private getRankType(): string {
    switch (this.selectedRankType) {
      case '热播榜':
        return 'hot'
      case '好评榜':
        return 'rating'
      case '心选热榜':
        return 'like'
      default:
        return 'comprehensive' // 总榜
    }
  }

  // 获取分类ID
  private getCategoryId(): number | undefined {
    if (this.selectedCategory === '全部') {
      return undefined
    }
    return this.categoryMap.get(this.selectedCategory)
  }

  // 构建请求参数字符串
  private buildQueryParams(): string {
    const paramsBuilder = new RequestParamsBuilder()
    paramsBuilder.add('page', this.currentPage.toString())
    paramsBuilder.add('limit', this.pageSize.toString())
    paramsBuilder.add('rankType', this.getRankType())

    const categoryId = this.getCategoryId()
    if (categoryId !== undefined) {
      paramsBuilder.add('category', categoryId.toString())
    }

    return paramsBuilder.build()
  }

  // 加载榜单视频
  async loadRankVideos(reset: boolean = false) {
    if (this.isLoading) return

    if (reset) {
      this.currentPage = 1
      this.videoList = []
      this.hasMore = true
    }

    this.isLoading = true

    try {
      const params = this.buildQueryParams()
      const response = await getRankVideos(params)

      if (response.success && response.data !== null && typeof response.data === 'object') {
        const data = response.data as RankVideoResponse

        if (reset) {
          this.videoList = data.videos || []
        } else {
          // 避免使用展开运算符，使用 concat 方法
          const newVideos = data.videos || []
          this.videoList = this.videoList.concat(newVideos)
        }

        this.hasMore = data.hasMore || false

        if (!reset && (data.videos || []).length > 0) {
          this.currentPage += 1
        }
      }
    } catch (error) {
      console.error('加载榜单视频失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  // 刷新数据
  async refreshData(resolve?: (value: string) => void) {
    await this.loadRankVideos(true)
    if (resolve) {
      resolve('刷新完成')
    }
  }

  // 加载更多
  loadMoreVideos(resolve?: (value: string) => void) {
    if (this.isLoading || !this.hasMore) {
      if (resolve) {
        resolve(!this.hasMore ? '没有更多数据' : '正在加载中...')
      }
      return
    }

    this.loadRankVideos(false).then(() => {
      if (resolve) {
        resolve('加载完成')
      }
    }).catch(() => {
      if (resolve) {
        resolve('加载失败')
      }
    })
  }

  // 格式化播放次数
  formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`
    }
    return count.toString()
  }

  // 榜单类型选择器
  @Builder
  RankTypeSelector() {
    Row() {
      // 全部（带下拉）
      Row() {
        Text(this.selectedCategory)
          .fontSize(14)
          .fontColor('#333333')

        Image(this.isCategoryExpanded ? $r('app.media.up') : $r('app.media.down'))
          .width(16)
          .height(16)
          .fillColor('#666666')
          .margin({ left: 4 })
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .onClick(() => {
        this.isCategoryExpanded = !this.isCategoryExpanded
      })

      // 总榜
      Text('总榜')
        .fontSize(14)
        .fontColor(this.selectedRankType === '总榜' ? '#FFD700' : '#333333')
        .fontWeight(this.selectedRankType === '总榜' ? FontWeight.Medium : FontWeight.Normal)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.selectedRankType = '总榜'
          this.loadRankVideos(true)
        })

      // 热播榜
      Text('热播榜')
        .fontSize(14)
        .fontColor(this.selectedRankType === '热播榜' ? '#FFD700' : '#333333')
        .fontWeight(this.selectedRankType === '热播榜' ? FontWeight.Medium : FontWeight.Normal)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.selectedRankType = '热播榜'
          this.loadRankVideos(true)
        })

      // 好评榜
      Text('好评榜')
        .fontSize(14)
        .fontColor(this.selectedRankType === '好评榜' ? '#FFD700' : '#333333')
        .fontWeight(this.selectedRankType === '好评榜' ? FontWeight.Medium : FontWeight.Normal)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.selectedRankType = '好评榜'
          this.loadRankVideos(true)
        })

      // 心选热榜
      Text('心选热榜')
        .fontSize(14)
        .fontColor(this.selectedRankType === '心选热榜' ? '#FFD700' : '#333333')
        .fontWeight(this.selectedRankType === '心选热榜' ? FontWeight.Medium : FontWeight.Normal)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.selectedRankType = '心选热榜'
          this.loadRankVideos(true)
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor('#FFFFFF')
    .padding({ top: 8, bottom: 8 })
  }

  // 分类下拉列表
  @Builder
  CategoryDropdown() {
    if (this.isCategoryExpanded) {
      Row() {
        ForEach(this.categoryOptions, (category: string) => {
          Text(category)
            .fontSize(13)
            .fontColor(this.selectedCategory === category ? '#FFD700' : '#333333')
            .fontWeight(this.selectedCategory === category ? FontWeight.Medium : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.selectedCategory = category
              this.isCategoryExpanded = false
              this.loadRankVideos(true)
            })
        }, (category: string) => category)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .padding({ top: 4, bottom: 8 })
      .shadow({ radius: 2, color: '#00000010', offsetY: 2 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
  }

  // 视频项
  @Builder
  VideoItem(item: VideoModel, index: number) {
    Row() {
      // 左侧：视频封面（占1/4）
      Stack() {
        Image(`${Config.SERVERURL}covers/${item.cover_url}`)
          .width('100%')
          .height('100%')
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        // 排名（左上角）
        Text(`${index + 1}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B35')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .position({ x: 4, y: 4 })

        // 年份（左下角）
        if (item.video_tag?.year) {
          Text(item.video_tag.year.toString())
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(0, 0, 0, 0.6)')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .position({ x: 4, y: '100%' })
            .translate({ y: -24 })
        }
      }
      .width('25%')
      .height(120)
      .margin({ right: 12 })

      // 右侧：视频详情（占3/4）
      Column() {
        // 标题行
        Row() {
          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          // 根据榜单类型显示不同的图标和数据
          Row() {
            if (this.selectedRankType === '热播榜') {
              Image($r('app.media.fire'))
                .width(16)
                .height(16)
                .fillColor('#FF6B35')
                .margin({ right: 4 })
              Text(this.formatCount(item.view_count))
                .fontSize(14)
                .fontColor('#FF6B35')
            } else if (this.selectedRankType === '好评榜') {
              Image($r('app.media.zan'))
                .width(16)
                .height(16)
                .fillColor('#FFB800')
                .margin({ right: 4 })
              Text(item.video_tag?.rating ? `${item.video_tag.rating}分` : '暂无评分')
                .fontSize(14)
                .fontColor('#FFB800')
            } else if (this.selectedRankType === '心选热榜') {
              Image($r('app.media.heart'))
                .width(16)
                .height(16)
                .fillColor('#FF4757')
                .margin({ right: 4 })
              Text(this.formatCount(item.like_count))
                .fontSize(14)
                .fontColor('#FF4757')
            }
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        // 标签
        if (item.video_tag) {
          Row() {
            if (item.video_tag.genre) {
              Text(item.video_tag.genre)
                .fontSize(12)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(4)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .margin({ right: 8 })
            }
            if (item.video_tag.region) {
              Text(item.video_tag.region)
                .fontSize(12)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(4)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            }
          }
          .margin({ top: 8, bottom: 8 })
        }

        // 描述
        Text(item.description || '暂无描述')
          .fontSize(13)
          .fontColor('#999999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
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
  VideoListContent() {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.videoList, (item: VideoModel, index: number) => {
          this.VideoItem(item, index)
        }, (item: VideoModel) => `rank_video_${item.video_id}`)

        // 加载中提示
        if (this.isLoading && this.videoList.length > 0) {
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
        if (!this.hasMore && this.videoList.length > 0) {
          Text('-----没有更多数据了-----')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 20, bottom: 20 })
            .textAlign(TextAlign.Center)
        }

        // 暂无数据提示
        if (this.videoList.length === 0 && !this.isLoading) {
          Text('暂无榜单数据')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 50 })
            .textAlign(TextAlign.Center)
        }
      }
      .padding({ left: 16, right: 16, top: 16 })
    }
    .scrollBar(BarState.Off)
    .onScrollEdge((side: Edge) => {
      if (side === Edge.Bottom) {
        this.loadMoreVideos()
      }
    })
  }

  build() {
    Column() {
      // 榜单类型选择器
      this.RankTypeSelector()

      // 分类下拉列表
      this.CategoryDropdown()

      // 视频列表
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
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
