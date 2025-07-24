import { VideoModel, UserModel } from '../model/appModel'
import { getVideoList, comment, getComment, addShortVideoFavorite, removeShortVideoFavorite, updateCollectResponse, checkShortVideoFavorite } from '../common/api'
import { ConfigUtil as Config } from '../common/configUtil'
import { ControllerStore } from '../common/shortVideoController'
import { CommentModel, CommentParams } from '../model/paramModel'
import promptAction from '@ohos.promptAction'
import inputMethod from '@ohos.inputMethod'
import { userLogin } from '../common/userLogin'
import router from '@ohos.router'

@Component
struct Side {
  @State likeCount: string = ''
  @State favoriteCount: string = ''
  @Prop isFavorite: boolean
  @Prop index: number
  @Link showComment: boolean

  private changeFavoriteCount(isIncrease: boolean) {
    let count = Number(this.favoriteCount)
    this.favoriteCount = (isIncrease ? ++count : --count).toString()
    this.isFavorite = !this.isFavorite
  }

  private handleCollect() {
    if (!userLogin.isLogin) {
      promptAction.showToast({ message: '请先登录', duration: 3000 })
      router.pushUrl({ url: 'pages/minepages/Login' })
      return
    }
    const userId = userLogin.userInfo.user_id
    if (userId === 0) {
      promptAction.showToast({ message: '用户信息异常', duration: 3000 })
      return
    }
    this.changeFavoriteCount(!this.isFavorite)
    toggleFavorite(userId??0, this.index, this.isFavorite)
  }

  build() {
    Column() {
      Column() {
        Image($r('app.media.comment'))
          .height(30).width(35).margin({ bottom: 5 })
      }.width('60%').height(60).onClick(() => this.showComment = true)

      Column() {
        Image(this.isFavorite ? $r('app.media.ic_public_highlightsed_yellow') : $r('app.media.ic_public_highlightsed_white'))
          .height(30).width(35).onClick(() => this.handleCollect()).margin({ bottom: 5 })
        Text(this.favoriteCount).fontSize(10).fontColor(Color.White).opacity(0.7)
      }.width('60%').height(60)
    }
    .margin({ bottom: 36 })
    .height('70%').width(60).justifyContent(FlexAlign.End)
  }
}

async function toggleFavorite(userID: number, videoId: number, isAdd: boolean) {
  if (isAdd) {
    await updateCollectResponse(videoId, 'add')
    await addShortVideoFavorite(userID, videoId)
  } else {
    await updateCollectResponse(videoId, 'remove')
    await removeShortVideoFavorite(userID, videoId)
  }
}


@Component
struct VideoDes {
  @State name: string = '';
  @State description: string = '';
  //@State hotspot: string = '';
  @State time: string = '';

  build() {
    Column() {
      Text(this.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 18 })

      Text(this.description)
        .fontSize(14)
        .fontColor(Color.White)
        .width('70%')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 15 })

      Row() {
        Text(this.time)
          .fontSize(10)
          .fontColor('#bbbbbb')
      }
    }
    .padding({ left: 10 })
    .alignItems(HorizontalAlign.Start)
    .width('80%')

  }
}

@Component
export struct first {
  @State videoDataList: VideoModel[] = []
  @State currentIndex: number = 0
  @State isRefreshing: boolean = false
  @State showComment: boolean = false
  @State commentList: CommentModel[] = []
  @State content: string = ''
  @State previewUris: string = ''
  @Prop isLogin: boolean
  @Prop isShortVideo: boolean
  private scroller: Scroller = new Scroller()
  @Prop refreshKey: number

  aboutToAppear(): void {
    this.fetchVideoData()
  }




  async fetchVideoData(): Promise<void> {
    try {
      this.isRefreshing = false
      const res = await getVideoList()
      this.videoDataList = JSON.parse(JSON.stringify(res.data)).filter((video: VideoModel) => video.category === 4)
      this.videoDataList.forEach(video => video.controller = new VideoController())
      ControllerStore.videoController = this.videoDataList[0].controller ?? new VideoController()
      this.isRefreshing = true
      await this.handleLike()
      await this.fetchComments()
    } catch (e) {
      console.error('加载视频失败', e)
      this.isRefreshing = false
    }
  }

  async fetchComments(): Promise<void> {
    try {
      const video = this.videoDataList[this.currentIndex]
      const res = await getComment(video.video_id)
      this.commentList = res.success ? JSON.parse(JSON.stringify(res.data)) : []
    } catch (e) {
      console.error('加载评论失败', e)
    }
  }

  async handleLike() {
    if (userLogin.isLogin){
      for (const video of this.videoDataList) {
        try {
          const res = await checkShortVideoFavorite(userLogin.userInfo.user_id ?? 0, video.video_id)
          video.isFavourite = JSON.parse(JSON.stringify(res.data))
        } catch (e) {
          console.error(`获取视频 ${video.video_id} 的收藏状态失败`, e)
        }
      }
    }
  }

  private handleSubmit(): void {
    const im = inputMethod.getController()
    im.stopInputSession()

    if (!this.content.trim()) {
      promptAction.showToast({ message: '评论不能为空', duration: 3000 })
      return
    }

    if (!this.isLogin) {
      promptAction.showToast({ message: '请先登录再发表评论', duration: 3000 })
      router.pushUrl({ url: 'pages/minepages/Login' })
      return
    }

    const video = this.videoDataList[this.currentIndex]
    const params: CommentParams = {
      user_id: userLogin.userInfo.user_id ?? 0,
      video_id: video.video_id,
      content: this.content.trim()
    }

    comment(params).then(res => {
      if (res.success) {
        this.content = ''
        this.fetchComments()
      } else {
        promptAction.showToast({ message: '评论失败', duration: 3000 })
      }
    })
  }

  // 新增日期格式化方法
  private formatDate(dateInput: Date | string): string {
    const date = new Date(dateInput) // 统一转换
    if (isNaN(date.getTime())) return ''

    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
  }

  build(): void {
    Stack() {
      Swiper() {
        ForEach(this.videoDataList, (item: VideoModel, index: number) => {
          Stack() {
            if (this.currentIndex === index && this.isRefreshing) {
              Video({ src: `${Config.SERVER}/videoStream/${item.video_url}`, controller: item.controller })
                .autoPlay(true).loop(true).objectFit(ImageFit.Contain)
                .onPrepared(() => item.controller?.start())
            } else {
              Text('Loading...').fontColor('#999').fontSize(16)
            }
            Side({
              likeCount: '',
              favoriteCount: '' + item.like_count,
              index: item.video_id,
              showComment: $showComment,
              isFavorite: item.isFavourite
            })
          }.width('100%').height('100%')
          .alignContent(Alignment.End)
        }, (item: VideoModel) => item.video_id.toString())
      }
      .index(this.currentIndex)
      .vertical(true)
      .indicator(false)
      .onChange(index => {
        this.videoDataList[this.currentIndex]?.controller?.pause()
        this.currentIndex = index
        this.videoDataList[index]?.controller?.start()
        this.fetchComments()
      })

      if (this.showComment) {
        Stack() {
          Column() {
            // 评论区头部
            Row() {
              Image($r('app.media.left'))
                .fillColor('#333333')
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.showComment = false
                })
                .width(24)
                .height(24)
                .margin({ right: 12 })

              Text('评论区')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')

              Blank()

              Text(`${this.commentList.length}条评论`)
              .fontSize(14)
                .fontColor('#666666')
            }
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
            .borderRadius({ topLeft: 12, topRight: 12 })

            // 评论列表区域
            Scroll(this.scroller) {
              Column() {
                if (this.commentList.length === 0) {
                  // 空状态
                  Column() {
                    Image($r('app.media.comment'))
                      .width(60)
                      .height(60)
                      .fillColor('#CCCCCC')
                      .margin({ bottom: 16 })

                    Text('暂无评论')
                      .fontSize(16)
                      .fontColor('#999999')
                      .margin({ bottom: 8 })

                    Text('快来发表第一条评论吧~')
                      .fontSize(14)
                      .fontColor('#CCCCCC')
                  }
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .width('100%')
                  .height(200)
                } else {
                  // 评论列表
                  List() {
                    ForEach(this.commentList, (item: CommentModel) => {
                      ListItem() {
                        Column() {
                          Row() {
                            // 用户头像
                            Image(`${Config.SERVER_URL_USER}${item.user.avatar}`)
                            .width(36)
                              .height(36)
                              .borderRadius(18)
                              .border({ width: 1, color: '#F0F0F0' })
                              .margin({ right: 12 })

                            Column() {
                              Row() {
                                Text(`${item.user.username}`)
                                .fontSize(15)
                                  .fontWeight(FontWeight.Medium)
                                  .fontColor('#333333')
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                                Blank()

                                Text(this.formatDate(item.create_time))
                                  .fontSize(12)
                                  .fontColor('#999999')
                              }
                              .width('100%')
                              .margin({ bottom: 6 })

                              // 评论内容
                              Text(item.content)
                                .fontSize(15)
                                .fontColor('#333333')
                                .lineHeight(22)
                                .textAlign(TextAlign.Start)
                                .width('100%')
                            }
                            .layoutWeight(1)
                            .alignItems(HorizontalAlign.Start)
                          }
                          .width('100%')
                          .alignItems(VerticalAlign.Top)

                        }
                        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
                        .width('100%')
                        .alignItems(HorizontalAlign.Start)
                      }
                      .backgroundColor(Color.White)
                      .margin({ bottom: 1 }) // 用细线分隔评论
                    }, (item: CommentModel) => item.comment_id.toString())
                  }
                  .width('100%')
                  .divider({
                    strokeWidth: 1,
                    color: '#F5F5F5',
                    startMargin: 64, // 从头像右侧开始分隔线
                    endMargin: 16
                  })
                }
              }
              .width('100%')
            }
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Auto) // 自动显示滚动条
            .scrollBarColor('#E0E0E0')
            .scrollBarWidth(3)
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring)
            .backgroundColor(Color.White)

            // 评论输入区域
            Row() {
              TextInput({
                placeholder: '发表你的观点……',
                text: this.content
              })
                .onChange((value: string) => {
                  this.content = value
                })
                .backgroundColor('#F8F8F8')
                .height(40)
                .layoutWeight(1)
                .borderRadius(20)
                .padding({ left: 16, right: 16 })
                .margin({ right: 12 })
                .placeholderColor('#AAAAAA')
                .placeholderFont({ size: 14 })
                .fontSize(15)
                .fontColor('#333333')
                .border({ width: 1, color: '#E8E8E8' })

              Button() {
                Image($r('app.media.send'))
                  .width(20)
                  .height(20)
                  .fillColor(this.content.trim() ? '#FFD166' : '#CCCCCC')
                  .onClick(() => {
                    if (this.isLogin) {
                      this.handleSubmit()
                    } else {
                      promptAction.showToast({ message: '请先登录再发表评论', duration: 3000 })
                      router.pushUrl({
                        url: 'pages/minepages/Login'
                      })
                    }
                  })
              }
              .width(40)
              .height(40)
              .borderRadius(20)
              .backgroundColor(Color.Transparent)
            }
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .width('100%')
            .backgroundColor(Color.White)
            .border({
              width: { top: 1 },
              color: { top: '#F0F0F0' }
            })
          }
          .width('100%')
          .height('90%')
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .position({ x: 0, y: '10%' }) // 从屏幕10%的位置开始显示
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .position({ x: 0, y: 0 })
      }

    }.width('100%').height('100%')
  }
}
