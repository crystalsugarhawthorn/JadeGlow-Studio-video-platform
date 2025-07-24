import {NavBar} from '../widget/Navbar'
import {detailTabBarModel, detailTabsData} from '../model/detailTabBar'
import {ParamModel} from '../model/paramModel'
import {getVideoDetail} from '../common/api'

import router from '@ohos.router';
import promptAction from '@ohos.promptAction'


import { VideoModel, UserModel } from '../model/appModel';
import {ConfigUtil as Config} from '../common/configUtil'
import {userLogin} from '../common/userLogin'

@Entry
@Component
struct videoDetail {
  @State isLogin: boolean = userLogin.isLogin
  @State userInfo: UserModel = userLogin.userInfo

  @State currentName:string = 'description'
  @State VideoUrl: string = ''
  @State videoDetail: VideoModel = new VideoModel(0,'','','','',0,0,0,0,'','','',0)
  @State recommendVideoList: VideoModel[] = []
  @State isBack: boolean = false  // 新增状态控制

  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  controller: VideoController = new VideoController()
  @State showControls: boolean = true;
  @State isShortcutKeyEnabled: boolean = false;
  @State showFirstFrame: boolean = false;
  @State dataReady: boolean = false

  // 添加观看进度相关的状态
  @State currentTime: number = 0

  aboutToAppear() {
    const params: ParamModel = (this.getUIContext().getRouter().getParams() as ParamModel)
    this.VideoUrl = params.url?? ''
    // 刷新依赖组件
    this.dataReady = !this.dataReady
  }

  // 返回按键处理函数
  private handleBack() {
    router.back()
  }

  build() {
    Column(){
      Stack() {
        Column() {
          Video({
            src: `${Config.SERVER}/videoStream/${this.VideoUrl}`,
            currentProgressRate: this.curRate, //设置播放速度
            controller: this.controller,
            posterOptions: { showFirstFrame: this.showFirstFrame } //关闭首帧送显
          })
            .objectFit(ImageFit.Contain)
            .width('100%')
            .height('80%')
            .autoPlay(true)
            .controls(true)
            .loop(true)

          Row() {
            Button('0.75')
              .onClick(() => {
                this.curRate = PlaybackSpeed.Speed_Forward_0_75_X // 0.75倍速播放
              })
              .fontSize(12)
              .fontColor('#eeeeee')
              .backgroundColor('#ff3b3b3b')
              .height(25)
              .margin({ right: 10, left: 10 })
            Button('1.00')
              .onClick(() => {
                this.curRate = PlaybackSpeed.Speed_Forward_1_00_X // 原倍速播放
              })
              .fontSize(12)
              .fontColor('#eeeeee')
              .backgroundColor('#ff3b3b3b')
              .height(25)
              .margin({ right: 10, left: 10 })
            Button('2.00')
              .onClick(() => {
                this.curRate = PlaybackSpeed.Speed_Forward_2_00_X // 2倍速播放
              })
              .fontSize(12)
              .fontColor('#eeeeee')
              .backgroundColor('#ff3b3b3b')
              .height(25)
              .margin({ right: 10, left: 10 })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Bottom)
          .backgroundColor(Color.Black)
        }

        // 返回按键 - 定位在左上角
        Button('←')
          .onClick(() => {
            this.handleBack()
          })
          .fontSize(24)
          .fontColor('#ffffff')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .width(40)
          .height(40)
          .borderRadius(20)
          .position({
            x: 15,
            y: 15
          })
          .zIndex(10)
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(Color.Black)
  }
}