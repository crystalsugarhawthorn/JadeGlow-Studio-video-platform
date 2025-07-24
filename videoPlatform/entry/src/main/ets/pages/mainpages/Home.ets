import {TVSeries} from '../homepages/TVSeries'
import {movie} from '../homepages/movie'
import {anime} from '../homepages/anime'
import {documentary} from '../homepages/documentary'

import {homeTopTabBar, homeTopTabsData} from '../model/homeTopTabBar'
import {userLogin} from '../common/userLogin'
import {ConfigUtil as Config} from '../common/configUtil'

import router from '@ohos.router';

@Component
export struct Home {
  @State currentName: string = 'TVSeries'
  @State canvasWidth: number = 120; // 默认宽度
  @State canvasHeight: number = 40; // 默认高度
  @State scrollerFlag: boolean = true
  @Prop isLogin: boolean
  @Prop refreshKey: number

  @Builder
  TabBarWidget(item: homeTopTabBar) {
    Text(item.title)
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .fontStyle(FontStyle.Italic)
      .margin({ top: 5 , bottom: 5})
      .fontColor(item.name === this.currentName ? '#57CC99' : '#495057')
      // 使用 ScaleOptions 格式
      .scale({ x: item.name === this.currentName ? 1.2 : 1, y: item.name === this.currentName ? 1.2 : 1 })
      .animation({ duration: 10, curve: Curve.EaseInOut })
  }

  // 头部导航
  @Builder
  NavBarWidget(){
    Column(){
      //行布局导航
      Row(){
        // logo :svg 格式可以换颜色
        if (this.scrollerFlag){
          if (this.isLogin) {
            Image(`${Config.SERVER_URL_USER}${userLogin.userInfo.avatar}`)
              .width(30)
              .height(30)
              .borderRadius(15)
              .fitOriginalSize(true)
          }
          else {
            Image($r("app.media.user"))
              .width(30)
              .height(30)
              .borderRadius(15)
              .backgroundColor('#e7e7e7')
          }
        }
        // 搜索框
        Row(){
          Image($r('app.media.search'))
            .width(20)
            .height(20)
            .fillColor(this.scrollerFlag?'#8a8a8a' : '#495057')
            .margin({left:10})
          Text("搜索内容").fontSize(16).padding({left:14})
            .fontColor(this.scrollerFlag ? '#495057' : '#8a8a8a')
        }
        .width(this.scrollerFlag?'60%':'80%').animation({duration:200})  // 宽变化 给动画
        .height('72lpx')
        .backgroundColor(this.scrollerFlag? '#6fffd166' : '#eeeeee')
        .borderRadius(24)
        .margin({left:10,right:10})
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Search'
          })
        })
        // 图
        if (this.scrollerFlag){
          Image($r('app.media.bars'))
            .width(20)
            .height(20)
            .fillColor(this.scrollerFlag?'#8a8a8a' : '#495057')
        }
        Row(){
          Image($r('app.media.message'))
            .width(20)
            .height(20)
            .fillColor(this.scrollerFlag?'#8a8a8a' : '#495057')
            .margin({left:10})
        }

      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({bottom:13})
    }
    .backgroundColor(this.scrollerFlag?Color.White:Color.Transparent)
  }

  build() {
    Column() {
      this.NavBarWidget()
      Tabs({ barPosition: BarPosition.Start }) {
        ForEach(homeTopTabsData, (item: homeTopTabBar) => {
          TabContent() {
            if (item.name == 'TVSeries') {
              TVSeries({ scrollerFlag: this.scrollerFlag })
            } else if (item.name == 'movie') {
              movie({ scrollerFlag: this.scrollerFlag })
            } else if (item.name == 'anime') {
              anime({ scrollerFlag: this.scrollerFlag })
            } else if (item.name == 'documentary') {
              documentary({ scrollerFlag: this.scrollerFlag })
            }
          }
          .tabBar(this.TabBarWidget(item))
          .backgroundColor('#eeeeee')
        }, (item: homeTopTabBar) => item.name.toString())
      }
      .barMode(BarMode.Fixed)
      .onChange((index) => {
        this.currentName = homeTopTabsData[index].name
      })
      .height('90%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}