import { comment, getComment } from '../common/api'
import { CommentModel, CommentParams } from '../model/paramModel'
import promptAction from '@ohos.promptAction'
import inputMethod from '@ohos.inputMethod'

import {userLogin} from '../common/userLogin'
import {ConfigUtil as Config} from '../common/configUtil'
import router from '@ohos.router';


@Component
export struct Comment {
  scroller: Scroller = new Scroller()
  @Prop video_id: number

  @State content: string = ''
  @State commentList: CommentModel[] = []

  // 生命周期钩子，页面加载时拉取评论
  aboutToAppear() {
    this.fetchComments()
  }

  onPageShow(): void {
    this.fetchComments()
  }

  private async handleSubmit() {
    const im = inputMethod.getController()
    im.stopInputSession()

    if (!this.content.trim()) {
      promptAction.showToast({ message: '评论内容不能为空', duration: 3000 })
      return
    }

    const params: CommentParams = {
      user_id: userLogin.userInfo.user_id??0,
      video_id: this.video_id,
      content: this.content.trim()
    }

    if(userLogin.isLogin){
      const res = await comment(params)
      if (res.success) {
        this.content = ''
        await this.fetchComments() // 发表评论成功后刷新评论列表
      } else {
        promptAction.showToast({ message: res.message ?? '评论失败', duration: 3000 })
      }
    } else {
      promptAction.showToast({ message: '登录状态异常，请返回首页刷新', duration: 3000 })
    }


  }

  private async fetchComments() {
    try {
      const res = await getComment(this.video_id)
      if (res.success) {
        this.commentList = JSON.parse(JSON.stringify(res.data))
        console.log(JSON.stringify(res.data))
      } else {
        promptAction.showToast({ message: res.message ?? '获取评论失败', duration: 3000 })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络错误', duration: 3000 })
    }
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


  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          // 评论列表标题
          Text('最新评论')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 30, bottom: 10 })
            .textAlign(TextAlign.Start)
            .width('90%')

          List(){
            // 评论列表内容
            ForEach(this.commentList, (item: CommentModel) => {
              ListItem() {
                Column(){
                  Row() {
                    Image(`${Config.SERVER_URL_USER}${item.user.avatar}`)
                      .width(30)
                      .aspectRatio(1)
                      .borderRadius(20)
                      .margin({ left: 10, right: 10 })
                    Text(`${item.user.username}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .textAlign(TextAlign.Start)
                    Blank()
                    Text(this.formatDate(item.create_time))
                      .fontSize(14)
                      .textAlign(TextAlign.End)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })
                  Text(item.content)
                    .fontSize(16)
                    .margin({ bottom: 4 })
                    .width('90%')
                    .textAlign(TextAlign.Start)
                }
              }
              .width('90%')
              .padding(10)
              .margin({ bottom: 10 })
              .backgroundColor(Color.White)
              .borderRadius(8)
              .alignSelf(ItemAlign.Center)
            },(item: CommentModel) => item.comment_id.toString())
          }
          .width('100%')
          .alignListItem(ListItemAlign.Center)
        }
      }
      .height('55%')
      .width('100%')

      Row() {
        // 评论输入框
        TextInput({
          placeholder: '请输入评论内容',
          text: this.content,
        })
          .onChange((value: string) => {
            this.content = value
          })
          .width('80%')
          .height(40)
          .margin({ right: 10 })
          .fontSize(16)
          .backgroundColor('#6fffd166')
          .padding(10)
          .borderRadius(8)

        // 提交按钮
        Image($r('app.media.send'))
          .width(40)
          .height(40)
          .padding(8)
          .borderRadius(12)
          .backgroundColor('#9557cc99')
          .onClick(() => {
            if (userLogin.isLogin) {
              this.handleSubmit()
            } else {
              promptAction.showToast({ message: '请先登录再发表评论', duration: 3000 })
              router.pushUrl({
                url: 'pages/minepages/Login'
              })
            }
          })
      }
      .width('90%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .margin({top: 10})
    }
    .width('100%')
    .height('100%')
  }


}
