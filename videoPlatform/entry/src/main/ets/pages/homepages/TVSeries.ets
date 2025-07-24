import {SwiperModel, VideoModel} from '../model/appModel'
import {getSwiperList, getVideoList} from '../common/api'
import {ConfigUtil as Config} from '../common/configUtil'
import {PullToRefresh} from '@ohos/pulltorefresh'
import { router } from '@kit.ArkUI'


@Component
export struct TVSeries {
  @State swiperList:SwiperModel[] = []
  @State videoList:VideoModel[] = []
  @State allVideoList: VideoModel[] = []
  @State pageCount: number = 0
  scroller: Scroller = new Scroller()
  @State page: number = 1
  @State isMoreData: boolean = true // 是否还有更多数据
  @State MAX_VIDEO_COUNT: number = 99
  @Link scrollerFlag: boolean

  // 获取轮播图接口
  async getSwiperData(){  /// async...await
    const res = await getSwiperList()
    this.swiperList = JSON.parse(JSON.stringify(res.data))
  }

  async getVideoData(resolve?: (value: string) => void){
    if (this.page === 1) {
      const res = await getVideoList()
      this.allVideoList = JSON.parse(JSON.stringify(res.data))
      this.videoList = []
    }

    // 当前已加载数量
    const currentCount = this.videoList.length

    // 如果已经达到或超过最大数量，则不再加载
    if (currentCount >= this.MAX_VIDEO_COUNT) {
      this.isMoreData = false
      resolve && resolve('已加载最大记录数')
      return
    }

    let tempList: VideoModel[] = this.allVideoList.filter(item => item.category === 0).slice(
      6 * this.pageCount,
      Math.min(6 * (this.pageCount + 1), this.allVideoList.length)
    )

    // 添加最大数量截断：避免最终超过100条
    const remainingCount = this.MAX_VIDEO_COUNT - currentCount
    tempList = tempList.slice(0, remainingCount)

    if (tempList.length < 6 || currentCount + tempList.length >= this.MAX_VIDEO_COUNT || 6 * (this.pageCount + 1) >= this.allVideoList.length) {
      this.isMoreData = false
    }

    this.videoList = this.videoList.concat(tempList)
    this.page++
    this.pageCount++

    resolve && resolve('刷新完成')
  }



  // 生命周期
  aboutToAppear(): void {
    this.getSwiperData()
    this.getVideoData()

  }
  @Builder
  getSwiperListWidget(){
    Swiper() {
      ForEach(this.swiperList.slice(0, 3), (item: SwiperModel) => {
        Image(`${Config.SERVERURL}swiper/${item.imgurl}`)
          .width('100%')
          .objectFit(ImageFit.Cover)
      }, (item: SwiperModel) => item.id.toString())
    }
    .loop(true)  //无限循环
    .autoPlay(true) // 自动播放
    .interval(5000) // 轮播间隔时间
    //.displayArrow(true)
    .indicator(  // 指示器
      Indicator.dot()
        .right(0)
        .itemWidth(5)
        .itemHeight(5)
        .selectedItemWidth(10)
        .selectedItemHeight(10)
        .color('#6C757D')
        .selectedColor('#FFD166')
    )
    .height(230)
  }

  @Builder
  TitleBar(title: string) {
    // 标题
    Row() {
      Text(title)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .fontSize(18)
    }
    .width('100%')
    .height(50)
    .padding(8)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  getVideoListWidget() {
    Column() {
      this.TitleBar('热门影视')
      Grid() {
        ForEach(this.videoList, (item: VideoModel) => {
          GridItem() {
            Column() {
              Row() {
                Image(`${Config.SERVER_URL_COVERS}${item.cover_url}`)
                  .width('90%')
                  .borderRadius(8)
                  .height(180)
              }
              Text(item.title)
                .textAlign(TextAlign.Start)
                .fontSize(12)
                .fontColor(Color.Black)
                .maxLines(2)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
                .margin({ top: 8, bottom: 8})
            }
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/videoDetail',
              params: {
                id: item.video_id
              }
            })
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(10)

      if (!this.isMoreData) {
        Text('-----没有更多数据了-----')
          .width('100%')
          .fontColor('#999999')
          .margin(15)
          .textAlign(TextAlign.Center)
      }
    }
  }

  @Builder
  totalWidget(){
    Scroll(this.scroller){  // 包一个块
      Column(){
        this.getSwiperListWidget()
        this.getVideoListWidget()
      }
    }
    .scrollBar(BarState.Off) // 隐藏滚动条
    .padding({bottom:20})
    .onScroll(() => {
      const y = this.scroller.currentOffset().yOffset
      this.scrollerFlag = y <= 70
    })
  }

  build() {
    Column() {
      PullToRefresh({
        data: this.videoList,
        scroller: this.scroller,
        customList:()=>{
          this.totalWidget()  // 初始化UI
        },
        onLoadMore:()=>{  // 上拉分页，判断是否触底，触底则加载下一页数据，必须返回Promise对象
          return new Promise<string>((resolve)=>{
            setTimeout(()=>{
              this.getVideoData(resolve) // 再次调用推荐接口
            }, 1000)
          })
        },
        onRefresh:()=> {
          return new Promise<string>((resolve)=>{
            setTimeout(()=>{
              this.page = 1
              this.pageCount = 0
              this.isMoreData = true
              this.getVideoData(resolve)
            }, 1000)
          })
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}