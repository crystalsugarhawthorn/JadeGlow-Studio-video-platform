import searchService from '../services/SearchService'
import router from '@ohos.router';
import { VideoModel, videoDetailModel } from '../model/appModel'
import inputMethod from '@ohos.inputMethod'
@Component
export struct SearchNav {
  @Link keywords: string
  @Link videoList: VideoModel[] |videoDetailModel[]
  @Link page: number
  @Link hasMore: boolean
  @Link selectedSubHeaderIndex: number
  getVideoData:()=>void = ()=>{}  //接收父组件的方法


  build() {
    Column() {
      //导航
      Row() {
        Row() {
          Image($r("app.media.left")).height(22).padding({ left: 6 }).fillColor(Color.Gray)
        }.width(20)
        .height('100%')
        .onClick(() => {
          router.back()
        })

        Row() {
          Search({ value: this.keywords})
            .height('72lpx')
            .backgroundColor('#6fffd166')
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: "38lpx", weight: 400 })
            .textFont({ size: "38lpx", weight: 400 })
            .margin({
              left: "44lpx",
              right: "44lpx"
            })
            .onChange(async (value) => {
              //保存搜索关键词
              await searchService.setHistoryData(value)
              //执行搜索
              this.keywords = value
              //重置数据
              this.videoList = []
              this.page = 1
              this.hasMore = true
              //重新请求数据
              if (this.selectedSubHeaderIndex==0) {
                this.getVideoData()
              }
              //隐藏键盘
              let im=inputMethod.getController()
              im.stopInputSession()
            })
        }.layoutWeight(1)
      }.width("100%").height("140lpx")
      .padding({
        left: "34lpx",
        right: "34lpx"
      }).justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.White)
  }
}