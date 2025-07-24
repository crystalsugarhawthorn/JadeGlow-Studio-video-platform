import router from '@ohos.router'; // 路由跳转
import { UserModel } from '../model/appModel'
import userService from '../minepages/UserService'
import {userLogin} from '../common/userLogin'
import {ConfigUtil as Config} from '../common/configUtil'
import promptAction from '@ohos.promptAction'

interface ListItem {
  icon: Resource; // 图标资源
  name: string; // 标题
  route: string; // 描述
}

@Component
export struct Mine {
  @StorageLink("isLogin") isLogin: boolean = false
  @StorageLink("userInfo") userInfo: UserModel = {}
  @Prop refreshKey: number


  //退出登录
  loginOut() {
    //清除用户数据
    userService.cleanUserData()
    this.isLogin = false
    this.userInfo = {}
    userLogin.isLogin = false
    userLogin.userInfo = {}
  }

  // 功能选项数据
  @State list: ListItem[] = [
    { icon: $r('app.media.star'), name: '我的收藏', route: 'pages/minepages/MyFavorites' },
    { icon: $r('app.media.eye'), name: '我的浏览记录', route: 'pages/minepages/BrowseHistory' },
    // 设置，未开发
    { icon: $r('app.media.setting'), name: '设置', route: '' }
  ];

  getLoginStatus(){
    this.isLogin = userLogin.isLogin
    this.userInfo = userLogin.userInfo
  }

  build() {
    Column() {
      // 1. 顶部用户信息区
      this.buildUserInfoArea()

      // 2. 功能选项列表
      List() {
        ForEach(this.list, (item: ListItem) => {
          ListItem() {
            this.buildFunctionItem(item)
          }
          .onClick(() => {
            this.getLoginStatus()
            // 检查登录状态
            if (!this.isLogin) {
              promptAction.showToast({
                message: '请先登录',
                duration: 2000
              })
              router.pushUrl({ url: 'pages/minepages/Login' })
              return
            }
            // 跳转至对应页面
            router.pushUrl({ url: item.route })
          })
        })
      }
      .padding(16)
      .margin({ top: 20 })
      .backgroundColor('#F5F5F5')
      .borderRadius(12)
      .width('90%')

      // 3. 底部信息
      this.buildFooter()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEEEEE')
  }

  // 构建用户信息区
  @Builder
  buildUserInfoArea() {
    //用户头像 和用户名
    Column() {
      Row(){
        if (this.isLogin) {
          Image(`${Config.SERVER_URL_USER}${userLogin.userInfo.avatar}`).width("148lpx").height("148lpx").borderRadius("74lpx").margin(20)
        }
        else {
          Image($r("app.media.user")).width("148lpx").height("148lpx").borderRadius("74lpx")
            .fillColor(Color.Grey)
            .onClick(() => {
              router.pushUrl({
                url: "pages/minepages/Login"
              })
            })
            .margin(20)
        }
        Blank()
        Column() {
          if (this.isLogin) {
            Column() {
              Text(`${this.userInfo.username}`).fontSize("33lpx")
              Blank()
              Text("普通会员").fontSize("33lpx")
            }.alignItems(HorizontalAlign.Start)
            .height("30%")
            .width("60%")
          } else {
            Text("登录/注册").fontSize("33lpx").width("100%").onClick(() => {
              router.pushUrl({
                url: "pages/minepages/Login"
              })
            })
              .width("60%")
          }
        }
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .width('90%')
    .height('25%')
    .margin(20)
  }

  // 构建功能选项Item
  @Builder
  buildFunctionItem(item: ListItem) {
    Row() {
      Image(item.icon)
        .width(24)
        .height(24)
        .fillColor(Color.Grey)
      Text(item.name)
        .fontSize(16)
        .margin({ left: 16 })
      Blank() // 推到右侧
      Image($r('app.media.right'))
        .width(16)
        .height(16)
        .opacity(0.6)
    }
    .padding(12)
    .width('100%')
  }

  // 构建底部信息
  @Builder
  buildFooter() {
    Column() {
      Button('退出登录')
        .fontSize(14)
        .fontColor(Color.Black)
        .backgroundColor(Color.White)
        .width('80%')
        .margin({ top: 20 })
        .onClick(() => {
          this.loginOut()
        })
    }
  }
}
