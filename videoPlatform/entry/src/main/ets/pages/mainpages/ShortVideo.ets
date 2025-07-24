import { first } from '../shortvideopages/first';
import { collect } from '../shortvideopages/collect';
import { history } from '../shortvideopages/history';
import {ShortVideoTopTabBar, shortVideoTopTabsData} from '../model/shortvideoTabBar'
import router from '@ohos.router';

import { ControllerStore } from '../common/shortVideoController'
@Component
export struct ShortVideo {
  @State currentName: string = shortVideoTopTabsData[0].name;
  @State scrollerFlag: boolean = true;
  @Prop isLogin: boolean
  @Prop refreshKey: number

  @Builder
  TabBarWidget(item: ShortVideoTopTabBar) {
    Text(item.title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .margin({ top: 5 , bottom: 5})
      .fontColor(item.name === this.currentName ? Color.White : Color.Gray)
      // 使用 ScaleOptions 格式
      .scale({ x: item.name === this.currentName ? 1.2 : 1, y: item.name === this.currentName ? 1.2 : 1 })
      .animation({ duration: 10, curve: Curve.EaseInOut })
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }){
        Column(){
          Tabs({ barPosition: BarPosition.Start }) {
            ForEach(shortVideoTopTabsData, (item: ShortVideoTopTabBar) => {
              TabContent() {
                if (item.name == 'recommended') {
                  first({
                    isLogin: this.isLogin,
                    refreshKey: this.refreshKey
                  })
                } else if (item.name == 'favourites') {
                  collect({ scrollerFlag: this.scrollerFlag,refreshKey: this.refreshKey})
                }
              }
              .tabBar(this.TabBarWidget(item))
              .backgroundColor('#eeeeee')
            }, (item: ShortVideoTopTabBar) => item.name.toString())
          }
          .vertical(false)
          .barWidth('75%')
          .barMode(BarMode.Fixed)
          .onChange((index) => {
            this.currentName = shortVideoTopTabsData[index].name
            ControllerStore.currentShortTab = this.currentName
            if (this.currentName != 'recommended') {
              ControllerStore.videoController.pause()
            }else {
              ControllerStore.videoController.start()
            }
          })
        }
        Image($r('app.media.search'))
          .width(24)
          .height(24)
          .fillColor(Color.Gray)
          .margin({ right: 15 , top: 15})
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Search'
            })
          })
      }
      .width('100%').height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}