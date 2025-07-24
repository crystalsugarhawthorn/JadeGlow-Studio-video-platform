// pages/videoDetail.ets

import {NavBar} from './widget/Navbar'
import {detailTabBarModel, detailTabsData} from './model/detailTabBar'
import {ParamModel} from './model/paramModel'
import {getVideoDetail, recommendPlayVideo, recordWatchHistory, updateWatchProgress} from './common/api'
import { addFavorite, removeFavorite, checkFavorite } from './common/api'
import router from '@ohos.router';
import promptAction from '@ohos.promptAction'
import { CheckFavoriteResponse } from './model/appModel'
import {Description} from './detailpages/Description'
import {Comment} from './detailpages/Comment'
import { VideoModel, UserModel } from './model/appModel';
import {ConfigUtil as Config} from './common/configUtil'
import {userLogin} from './common/userLogin'

@Entry
@Component
struct videoDetail {
  @State isLogin: boolean = userLogin.isLogin
  @State userInfo: UserModel = userLogin.userInfo

  @State currentName:string = 'description'
  @State videoID: number = 0
  @State videoDetail: VideoModel = new VideoModel(0,'','','','',0,0,0,0,'','','',0)
  @State recommendVideoList: VideoModel[] = []
  @State isBack: boolean = false  // 新增状态控制

  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  controller: VideoController = new VideoController()
  @State showControls: boolean = true;
  @State isShortcutKeyEnabled: boolean = false;
  @State showFirstFrame: boolean = false;
  @State dataReady: boolean = false
  @State isFavorited: boolean = false  // 是否已收藏

  // 添加观看进度相关的状态
  @State currentTime: number = 0
  private updateInterval: number = -1


  async getVideoDetailData(): Promise<void> {
    const params: ParamModel = {
      id: this.videoID
    }

    const res = await getVideoDetail(params)
    if (res.success) {
      this.videoDetail = JSON.parse(JSON.stringify(res.data))
      let resultSet: VideoModel[] = []

      // 封装一个辅助函数，用于调用推荐接口并展开数组结果
      const appendRecommendByKeyword = async (keyword: string | undefined) => {
        if (!keyword || keyword.trim() === '') return
        const tempParams: ParamModel = { keywords: keyword }
        const result = await recommendPlayVideo(tempParams)

        if (result.success && Array.isArray(result.data)) {
          const dataArray = JSON.parse(JSON.stringify(result.data)) as VideoModel[]
          resultSet = resultSet.concat(dataArray)
        } else {
          console.warn('推荐接口调用失败或返回格式错误：', keyword, result)
        }
      }

      // 依次根据标题、地区、类型推荐并收集结果
      await appendRecommendByKeyword(this.videoDetail.title)
      await appendRecommendByKeyword(this.videoDetail.video_tag?.region)
      await appendRecommendByKeyword(this.videoDetail.video_tag?.genre)


      // 去重：根据 video_id 去重
      const uniqueMap = new Map<number, VideoModel>()
      for (const video of resultSet) {
        uniqueMap.set(video.video_id, video)
      }


      this.recommendVideoList = Array.from(uniqueMap.values())
        .filter(video => video.video_id !== this.videoDetail.video_id)
        .filter(video => video.category !== 4)
    } else {
      promptAction.showToast({
        message: '没有找到资源',
        duration: 5000
      })
    }
  }

  // 记录观看历史
  async recordHistory() {
    console.log('记录观看历史')
    try {
      const response = await recordWatchHistory(
        this.userInfo.user_id || 0,
        this.videoID,
        0
      )
      if (response.success) {
        console.info('观看历史记录成功')
      }
    } catch (error) {
      console.error('记录观看历史失败:', error)
    }
  }

  // 保存观看进度
  async saveWatchProgress() {
    if (this.isLogin && this.userInfo.user_id && this.currentTime > 0 && this.videoID > 0) {
      try {
        await updateWatchProgress(
          this.userInfo.user_id,
          this.videoID,
          Math.floor(this.currentTime)
        )
        console.info('观看进度已保存:', Math.floor(this.currentTime))
      } catch (error) {
        console.error('保存观看进度失败:', error)
      }
    }
  }


  // 检查收藏状态
  async checkFavoriteStatus() {
    try {
      const response = await checkFavorite(this.userInfo.user_id || 0, this.videoID)
      if (response.success && response.data) {
        const favoriteData = response.data as CheckFavoriteResponse
        this.isFavorited = favoriteData.is_favorited
      }
    } catch (error) {
      console.error('检查收藏状态失败:', error)
    }
  }

  // 修改 toggleFavorite 方法，显式返回 void
  async toggleFavorite(): Promise<void> {
    if (!this.isLogin) {
      promptAction.showToast({ message: '请先登录' })
      router.pushUrl({ url: 'pages/minepages/Login' })
      return
    }

    try {
      if (this.isFavorited) {
        // 取消收藏
        const response = await removeFavorite(this.userInfo.user_id || 0, this.videoID)
        if (response.success) {
          this.isFavorited = false
          promptAction.showToast({ message: '取消收藏成功' })
        }
      } else {
        // 添加收藏
        const response = await addFavorite(this.userInfo.user_id || 0, this.videoID)
        if (response.success) {
          this.isFavorited = true
          promptAction.showToast({ message: '收藏成功' })
        }
      }
    } catch (error) {
      promptAction.showToast({ message: '操作失败' })
    }
  }


  aboutToAppear() {
    const params: ParamModel = (this.getUIContext().getRouter().getParams() as ParamModel)
    this.videoID = params.id ?? 0
    this.isBack = params.choose ?? false
    this.getVideoDetailData()
    // 刷新依赖组件
    this.dataReady = !this.dataReady
    if (this.isLogin) {
      this.recordHistory()
    }

    // 检查收藏状态
    if (this.isLogin && this.userInfo.user_id) {
      this.checkFavoriteStatus()
    }
  }

  // 添加页面隐藏时的处理
  onPageHide() {
    // 页面隐藏时保存进度并清理定时器
    if (this.updateInterval !== -1) {
      clearInterval(this.updateInterval)
      this.updateInterval = -1
    }
    this.saveWatchProgress()
  }

  // 添加页面销毁时的处理
  aboutToDisappear() {
    // 页面销毁时保存进度并清理定时器
    if (this.updateInterval !== -1) {
      clearInterval(this.updateInterval)
      this.updateInterval = -1
    }
    this.saveWatchProgress()
  }

  @Builder
  TabBarWidget(item: detailTabBarModel){
    Column() {
      Text(item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 5 , bottom: 5})
        .fontColor(item.name === this.currentName ? '#57CC99' : '#6C757D')
        // 使用 ScaleOptions 格式
        .scale({ x: item.name === this.currentName ? 1.2 : 1, y: item.name === this.currentName ? 1.2 : 1 })
        .animation({ duration: 150, curve: Curve.EaseInOut })

    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin(10)
  }


  build() {
    Column(){
      Stack(){
        Column() {
          Video({
            src: `${Config.SERVER}/videoStream/${this.videoDetail.video_url}`,
            currentProgressRate: this.curRate, //设置播放速度
            controller: this.controller,
            posterOptions: { showFirstFrame: this.showFirstFrame } //关闭首帧送显
          })
            .width('100%')
            .height('80%')
            .autoPlay(true)
            .controls(true)
            .loop(true)
            .onStart(() => {
              console.info('视频开始播放')
              // 开始定期更新观看进度（每5秒保存一次）
              if (this.updateInterval === -1) {
                this.updateInterval = setInterval(() => {
                  this.saveWatchProgress()
                }, 5000)
              }
            })
            .onPause(() => {
              console.info('视频暂停')
              // 暂停时立即保存进度
              this.saveWatchProgress()
            })
            .onFinish(() => {
              console.info('视频播放完成')
              // 播放完成时保存进度
              if (this.videoDetail.duration > 0) {
                this.currentTime = this.videoDetail.duration
              }
              this.saveWatchProgress()
            })
            .onUpdate((event) => {
              // 更新当前播放时间
              if (event && event.time) {
                this.currentTime = event.time
              }
            })
          Row() {
            Button('0.75').onClick(() => {
              this.curRate = PlaybackSpeed.Speed_Forward_0_75_X // 0.75倍速播放
            })
              .fontSize(12)
              .fontColor('#eeeeee')
              .backgroundColor('#ff3b3b3b')
              .height(25)
              .margin({ right: 10, left: 10 })
            Button('1.00').onClick(() => {
              this.curRate = PlaybackSpeed.Speed_Forward_1_00_X // 原倍速播放
            })
              .fontSize(12)
              .fontColor('#eeeeee')
              .backgroundColor('#ff3b3b3b')
              .height(25)
              .margin({ right: 10, left: 10 })
            Button('2.00').onClick(() => {
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

        NavBar({title:this.videoDetail.title})

      }.height('35%').width('100%').align(Alignment.TopStart)
      Tabs({barPosition:BarPosition.Start}) {
        ForEach(detailTabsData, (item:detailTabBarModel) => {
          TabContent(){
            if(item.name == 'description'){
              if (this.dataReady) {
                Description({
                  videoDetail: this.videoDetail,
                  recommendVideoList: this.recommendVideoList,
                  isBack: this.isBack,
                  isFavorited: this.isFavorited,
                  onToggleFavorite: this.toggleFavorite.bind(this)
                })
              }
            }else{
              Comment({
                video_id: this.videoID
              })
            }
          }
          .tabBar(this.TabBarWidget(item))
          .backgroundColor('#eeeeee')
        },(item: detailTabBarModel)=>item.name)
      }
      .onChange((index)=>{
        this.currentName = detailTabsData[index].name
      })
      .backgroundColor(Color.White)
      .scrollable(false)
      .outlineColor('#EEEEEE') // 底部导航栏的边框颜色
      .width('100%')
    }
  }
}