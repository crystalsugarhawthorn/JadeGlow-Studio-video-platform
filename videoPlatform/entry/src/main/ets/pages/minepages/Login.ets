import router from '@ohos.router'
import { UserModel } from '../model/appModel'
import inputMethod from '@ohos.inputMethod'
import preferencesUtil from './PreferencesUtil'
import promptAction from '@ohos.promptAction'
import { login } from '../common/api'
import {userLogin} from '../common/userLogin'

PersistentStorage.persistProp('userInfo', {})
PersistentStorage.persistProp('isLogin', false)

@Extend(TextInput)
function inputStyle() {
  .placeholderColor('#99182431')
  .height('45vp')
  .fontSize('18fp')
  .backgroundColor('#F1F3F5')
  .width('328vp')
  .margin({ top: 12 })
}

@Extend(Line)
function lineStyle() {
  .width('328vp')
  .height('1vp')
  .backgroundColor('#33182431')
}

@Extend(Text)
function blueTextStyle() {
  .fontColor('#007DFF')
  .fontSize('14fp')
  .fontWeight(FontWeight.Medium)
}

// 在文件顶部添加登录响应接口
interface LoginResponse {
  user: UserModel
}

@Entry
@Component
struct Login {

  @State isShowProgress: boolean = false;
  private timeOutId: number = -1;
  pathStack: NavPathStack = new NavPathStack();
  @State username: string = ''
  @State password: string = ''
  @StorageLink("isLogin") isLogin: boolean = false
  @StorageLink("userInfo") userInfo: UserModel = {}

  //登录
  async doLogin() {
    // 隐藏键盘
    let im = inputMethod.getController()
    im.stopInputSession()

    const response = await login({
      username: this.username,
      password: this.password
    })

    console.log(JSON.stringify(response.success))
    console.log(JSON.stringify(response))

    if (response.success) {
      // 保存用户信息
      let loginData = response.data as LoginResponse
      let user: string = JSON.stringify(loginData ? loginData.user : "")

      await preferencesUtil.set("userinfoStore", "userinfo", user)

      // 同步用户信息
      this.isLogin = true
      this.userInfo = loginData ? loginData.user : {}
      userLogin.isLogin = this.isLogin
      userLogin.userInfo = this.userInfo
      // 跳转到个人中心页面
      router.back()
    } else {
      promptAction.showToast({
        message: response.message,
        duration: 5000
      })
    }
  }

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image(src)
    }
    .height('48vp')
    .width('48vp')
    .backgroundColor('#F1F3F5')
  }

  aboutToDisappear() {
    clearTimeout(this.timeOutId);
    this.timeOutId = -1;
  }

  build() {
    Column() {
      Image($r('app.media.JadeGlow_Studio'))
        .width('78vp')
        .height('78vp')
        .margin({ top: '150vp', bottom: '8vp' })
        .borderRadius(12)
      Text('登录')
        .fontSize('24fp')
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')


      TextInput({ placeholder: '请输入用户' })
        .maxLength(11)
        .type(InputType.Normal)
        .inputStyle()
        .onChange((value: string) => {
          this.username = value;
        })
      Line()
        .lineStyle()

      TextInput({ placeholder: '请输入密码' })
        .maxLength(8)
        .type(InputType.Password)
        .inputStyle()
        .onChange((value: string) => {
          this.password = value;
        })
      Line()
        .lineStyle()


      Button('登录', { type: ButtonType.Capsule })
        .width('328vp')
        .height('40vp')
        .fontSize('16fp')
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#57CC99')
        .margin({
          top: '48vp',
          bottom: '16vp'
        })
        .onClick(() => {
          if (this.username === '' || this.password === '') {
            promptAction.showToast({ message: '用户名或密码不能为空'})
            return
          }
          else {
            this.doLogin()
          }
        })
      Text('注册账号')
        .fontColor('#57CC99')
        .fontSize('16fp')
        .margin({ bottom: '10vp'})
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          router.pushUrl({
            url: "pages/minepages/Register"
          })
        })
      Blank()
      Text('返回')
        .fontColor('#57CC99')
        .fontSize('16fp')
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          router.back()
        })
      if (this.isShowProgress) {
        LoadingProgress()
          .color('#182431')
          .width('30vp')
          .height('30vp')
          .margin({ top: '20vp' })
      }
    }
    .height('100%')
    .width('100%')
    .padding({
      left: '12vp',
      right: '12vp',
      bottom: '24vp'
    })
  }
}