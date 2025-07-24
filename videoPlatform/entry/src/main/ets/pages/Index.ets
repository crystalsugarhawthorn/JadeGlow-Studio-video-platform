import {Home} from './mainpages/Home'
import {Mine} from './mainpages/Mine'
import {ShortVideo} from './mainpages/ShortVideo'
import {Recommend} from './mainpages/Recommend'

import {userLogin} from './common/userLogin'

//引入底部导航栏组件
import {bottomTabBarModel, bottomTabsData} from './model/bottomTabBar'
import { ControllerStore } from './common/shortVideoController'


@Entry
@Component
export struct Index {
  @State currentName:string = 'Home'
  @State shortVideoTabName: string = 'recommended' // 子tab当前项
  private videoController: VideoController = new VideoController()
  @State isLogin: boolean = false
  @State refreshKey: number = 0
  @Builder
  TabBarWidget(item: bottomTabBarModel){
    Column() {
      Row() {
        Image(item.icon)
          .fillColor(item.name === this.currentName ? '#FFD166' : '#6C757D')
          .width(22)
          .aspectRatio(1)
          // 使用 ScaleOptions 格式
          .scale({ x: item.name === this.currentName ? 1.2 : 1, y: item.name === this.currentName ? 1.2 : 1 })
          .animation({ duration: 150, curve: Curve.EaseInOut })

      }
      .width(28)
      .aspectRatio(1)
      .borderRadius(15)
      .justifyContent(FlexAlign.Center)
      Text(item.title)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 5 , bottom: 5})
        .fontColor(item.name === this.currentName ? '#FFD166' : '#6C757D')
        // 使用 ScaleOptions 格式
        .scale({ x: item.name === this.currentName ? 1.2 : 1, y: item.name === this.currentName ? 1.2 : 1 })
        .animation({ duration: 150, curve: Curve.EaseInOut })

    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin(10)
  }

  build() {
    Column() {
      Tabs({barPosition:BarPosition.End}) {
        ForEach(bottomTabsData, (item:bottomTabBarModel) => {
          TabContent(){
            if(item.name == 'Home'){
              Home({
                isLogin: this.isLogin,
                refreshKey: this.refreshKey
              })
            }else if(item.name == 'Recommend') {
              Recommend({
                refreshKey: this.refreshKey
              })
            }else if(item.name == 'ShortVideo'){
              ShortVideo({
                isLogin: this.isLogin,
                refreshKey: this.refreshKey
              })
            }else if(item.name == 'Mine') {
              Mine({
                refreshKey: this.refreshKey
              })
            }
          }
          .tabBar(this.TabBarWidget(item))
          .backgroundColor('#eeeeee')
        },(item: bottomTabBarModel)=>item.name)
      }
      .onChange((index)=>{
        this.isLogin = userLogin.isLogin
        this.currentName = bottomTabsData[index].name

        this.refreshKey = this.refreshKey + 1
        ControllerStore.currentIndexTab = this.currentName
        if(ControllerStore.currentIndexTab != 'ShortVideo'){
          ControllerStore.videoController.stop()
        }else{
          ControllerStore.videoController.start()
        }
      })
      .backgroundColor(this.currentName === 'ShortVideo'?'#000000':'#ffffff')
      .scrollable(false)
      .outlineColor('#EEEEEE') // 底部导航栏的边框颜色

    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F8F9FA')
  }
}