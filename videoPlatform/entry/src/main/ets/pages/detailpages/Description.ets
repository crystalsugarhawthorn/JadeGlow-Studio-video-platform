import {VideoModel} from '../model/appModel'
import {ConfigUtil as Config} from '../common/configUtil'
import router from '@ohos.router';
import {videoStackData} from '../model/videostack'

@Component
export struct Description {
  @Prop videoDetail: VideoModel  // 接收父组件传入的 videoDetail
  @Prop recommendVideoList: VideoModel[]
  @Prop isBack: boolean  // 新增状态控制
  @Prop isFavorited: boolean  // 接收收藏状态
  onToggleFavorite?: () => void  // 接收切换收藏的回调方法

  @State showDescriptionDialog: boolean = false
  scroller: Scroller = new Scroller()
  scroller_total: Scroller = new Scroller()

  aboutToAppear() {
    console.log('description 被显示，isBack:', this.isBack)
    // 也可以用 getContext().getRouter().getParams() 再取一次
  }

  build() {
    Column(){
      Scroll(this.scroller_total){
        Column() {
          Row(){
            Image(`${Config.SERVER_URL_COVERS}${this.videoDetail.cover_url}`)
              .width('25%')
              .margin({right: 10})
            Column(){
              // 将标题和收藏按钮放在同一行
              Row() {
                Text(`${this.videoDetail.title}`)
                  .fontSize(20)
                  .textAlign(TextAlign.Start)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)  // 让标题占据剩余空间

                // 收藏按钮
                Row() {
                  Image($r('app.media.heart'))
                    .width(20)
                    .height(20)
                    .fillColor(this.isFavorited ? '#FF6B6B' : '#666666')
                  Text('收藏')
                    .fontSize(14)
                    .fontColor(this.isFavorited ? '#FF6B6B' : '#666666')
                    .margin({ left: 4 })
                }
                .padding({ left: 8, right: 8 })
                .onClick(() => {
                  if (this.onToggleFavorite) {
                    this.onToggleFavorite()
                  }
                })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              Row(){
                Text(`${this.videoDetail.description.slice(2, 13)}……  简介`)
                  .fontSize(14)
                  .fontColor('#ff4c4e53')
                  .backgroundColor(Color.Transparent)
                  .height(20)
                  .alignSelf(ItemAlign.Start)
                Image($r('app.media.right'))
                  .backgroundColor(Color.Transparent)
                  .height(20)
              }
              .margin({ top: 10, bottom: 10 })
              .width('100%')
              .onClick(() => {
                this.showDescriptionDialog = true
              })

              Row(){
                Button(`${this.videoDetail.video_tag?.year}`)
                  .fontSize(12)
                  .fontColor('#ff4c4e53')
                  .backgroundColor('#dddddd')
                  .height(25)
                  .margin({ right: 10, left: 10 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Search',
                      params: {
                        keywords: this.videoDetail.video_tag?.year
                      }
                    })
                  })
                Button(`${this.videoDetail.video_tag?.region}`).fontSize(16)
                  .fontSize(12)
                  .fontColor('#ff4c4e53')
                  .backgroundColor('#dddddd')
                  .height(25)
                  .margin({ right: 10, left: 10 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Search',
                      params: {
                        keywords: this.videoDetail.video_tag?.region
                      }
                    })
                  })
                Button(`${this.videoDetail.video_tag?.genre}`).fontSize(16)
                  .fontSize(12)
                  .fontColor('#ff4c4e53')
                  .backgroundColor('#dddddd')
                  .height(25)
                  .margin({ right: 10, left: 10 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Search',
                      params: {
                        keywords: this.videoDetail.video_tag?.genre
                      }
                    })
                  })
              }
              .justifyContent(FlexAlign.SpaceAround)
              .width('100%')
            }
            .margin(10)
            .width('70%')

          }
          .padding(10)
          .alignSelf(ItemAlign.Start)
          // 相关推荐
          Text('相关推荐')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 10, left: 10 })
            .width('100%')
            .alignSelf(ItemAlign.Start)

          if(this.recommendVideoList && this.recommendVideoList.length > 0){
            Grid() {
              ForEach(this.recommendVideoList, (item: VideoModel) => {
                GridItem() {
                  Column() {
                    Row() {
                      Image(`${Config.SERVER_URL_COVERS}${item.cover_url}`)
                        .width('90%')
                        .borderRadius(8)
                        .height('35%')
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
                  if (videoStackData.peek() !== this.videoDetail.video_id) {
                    if (!this.isBack) {
                      // 正常打开页面才入栈
                      videoStackData.push(this.videoDetail.video_id)
                    } else {
                      // 如果是回退返回，不要再入栈
                      this.isBack = false // 重置状态
                    }
                  }
                  router.pushUrl({
                    url: 'pages/videoDetail',
                    params: {
                      id: item.video_id
                    }
                  })
                })
              })
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(10)
            .width('100%')
            .height('40%')
          }else {
            Text('暂无推荐视频')
              .fontSize(14)
              .fontColor('#888888')
              .margin({ top: 20 })
          }

          if (this.showDescriptionDialog) {
            Stack() {
              Column(){
                Row(){
                  Image($r('app.media.left'))
                    .fillColor('#6C757D')
                    .backgroundColor(Color.Transparent)
                    .onClick(() => {
                      this.showDescriptionDialog = false
                    })
                    .height(30)
                    .margin({ bottom: 10 , top: 10})
                  Text('影片简介')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 10 , top: 10})
                }
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)
                .width('100%')
                .height(40)
                .margin({bottom: 10})
                Scroll(this.scroller){
                  Column() {
                    Text(this.videoDetail.description)
                      .fontSize(16)
                      .textAlign(TextAlign.Start)
                      .lineHeight(22)
                  }
                  .backgroundColor('#22ffd166')
                  .width('100%')
                }
                .scrollable(ScrollDirection.Vertical) // 滚动方向为垂直方向
                .scrollBar(BarState.On) // 滚动条常驻显示
                .scrollBarColor(Color.Gray) // 滚动条颜色
                .scrollBarWidth(10) // 滚动条宽度
                .edgeEffect(EdgeEffect.Spring) // 滚动到边沿后回弹
              }
              .padding(20)
              .width('100%')
              .height('90%')
              .backgroundColor(Color.White)
              .borderRadius(12)
              .align(Alignment.Center)
            }
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.6)')
            .position({ x: 0, y: 0 }) // 遮罩位置覆盖整个页面
          }


        }
      }
    }
    .width('100%')
    .height('100%')
  }
}