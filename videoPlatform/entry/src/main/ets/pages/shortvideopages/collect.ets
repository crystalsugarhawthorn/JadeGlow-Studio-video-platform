import { VideoModel,ShortVideoCollect,ShortVideoHistory} from '../model/appModel'
import { getVideoList,getShortVideoCollect,getShortVideoHistory} from '../common/api'
import {ConfigUtil as Config} from '../common/configUtil'
import {PullToRefresh} from '@ohos/pulltorefresh'
import router from '@ohos.router';
import { userLogin } from '../common/userLogin'



@Component
export struct collect {
  @State user_id:number = 0
  @State isLogin:boolean = userLogin.isLogin
  @State videoList:ShortVideoCollect[] = []
  @State allVideoList: ShortVideoCollect[] = []
  @Prop refreshKey: number

  @State pageCount: number = 0
  scroller: Scroller = new Scroller()
  @State page: number = 1
  @State isMoreData: boolean = true // 是否还有更多数据
  @Link scrollerFlag: boolean

  async getVideoData(resolve?: (value: string) => void){
    if (!userLogin.isLogin) {
      resolve && resolve('未登录，无法加载数据')
      return
    }

    if (this.page === 1) {
      const res = await getShortVideoCollect(this.user_id)
      //const res = await getVideoList()
      this.allVideoList = JSON.parse(JSON.stringify(res.data))
      this.videoList = []
    }

    // 当前已加载数量
    const currentCount = this.videoList.length
    const MAX_VIDEO_COUNT = this.allVideoList.length
    console.log(String(currentCount))

    this.isMoreData = true
    // 如果已经达到或超过最大数量，则不再加载
    if (currentCount >= MAX_VIDEO_COUNT) {
      this.isMoreData = false
      resolve && resolve('已加载全部收藏视频')
      return
    }

    let tempList: ShortVideoCollect[] = this.allVideoList.slice(
      9 * this.pageCount,
      Math.min(9 * (this.pageCount + 1), this.allVideoList.length)
    )

    // 添加最大数量截断：避免最终超过100条
    const remainingCount = MAX_VIDEO_COUNT - currentCount
    tempList = tempList.slice(0, remainingCount)

    if (tempList.length < 9 || currentCount + tempList.length >= MAX_VIDEO_COUNT || 9 * (this.pageCount + 1) >= this.allVideoList.length) {
      this.isMoreData = false
    }

    this.videoList = this.videoList.concat(tempList)
    this.page++
    this.pageCount++

    resolve && resolve('刷新完成')
  }

  // 生命周期
  aboutToAppear(): void {
    this.user_id = userLogin.userInfo?.user_id ?? 0
    this.isLogin = userLogin.isLogin
    if (this.isLogin) {
      this.page = 1
      this.pageCount = 0
      this.isMoreData = true
      this.getVideoData()
    }
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
      this.TitleBar('我的收藏')

      if (!this.isLogin) {
        Column() {
          Text('您尚未登录，无法查看收藏内容')
            .fontColor('#999999')
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .margin({ top: 50 })
          Button('去登录')
            .margin({ top: 20 })
            .fontColor('#ffe3ac00')
            .backgroundColor('#22ffd166')
            .onClick(() => {
              router.pushUrl({ url: 'pages/minepages/Login' })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else{
        Grid() {
          ForEach(this.videoList, (item: ShortVideoCollect) => {
            GridItem() {
              Column() {
                Row() {
                  Image(`${Config.SERVERURL}covers/${item.videoDetails?.cover_url}`)
                    .width('90%')
                    .borderRadius(8)
                    .height(180)
                }
                Text(item.videoDetails?.title)
                  .textAlign(TextAlign.Start)
                  .fontSize(12)
                  .fontColor(Color.Black)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 8, bottom: 8})
              }
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/shortvideopages/VideoPlayPage',
                params: {
                  url: item.videoDetails?.video_url
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
  }


  @Builder
  totalWidget(){
    Scroll(this.scroller){  // 包一个块
      Column(){
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
          return new Promise<string>((resolve, reject)=>{
            setTimeout(()=>{
              if (this.isLogin && this.isMoreData) { // 只有在登录且有更多数据时才尝试加载
                this.getVideoData(resolve)
              } else {
                resolve(this.isLogin ? '没有更多数据了' : '请先登录'); // 根据登录状态返回不同消息
              }
              this.user_id = userLogin.userInfo.user_id ?? 0
              this.isLogin = userLogin.isLogin
            }, 1000)
          })
        },
        onRefresh:()=> {
          return new Promise<string>((resolve, reject)=>{
            setTimeout(()=>{
              if (!userLogin.isLogin) {
                // 未登录状态下清空数据
                this.allVideoList = []
                this.videoList = []
                this.isMoreData = false
                resolve('请先登录')
                return
              }
              this.user_id = userLogin.userInfo.user_id ?? 0
              this.isLogin = userLogin.isLogin
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