import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { register } from '../common/api'

@Entry
@Component
struct Register {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State isLoading: boolean = false
  @State showPassword: boolean = false
  @State showConfirmPassword: boolean = false

  // 表单验证
  private validateForm(): boolean {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' })
      return false
    }

    if (this.username.length < 3) {
      promptAction.showToast({ message: '用户名至少3个字符' })
      return false
    }

    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' })
      return false
    }

    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6个字符' })
      return false
    }

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' })
      return false
    }

    // 邮箱格式验证（如果填写了邮箱）
    if (this.email && !this.isValidEmail(this.email)) {
      promptAction.showToast({ message: '邮箱格式不正确' })
      return false
    }

    // 手机号格式验证（如果填写了手机号）
    if (this.phone && !this.isValidPhone(this.phone)) {
      promptAction.showToast({ message: '手机号格式不正确' })
      return false
    }

    return true
  }

  // 邮箱格式验证
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  // 手机号格式验证
  private isValidPhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/
    return phoneRegex.test(phone)
  }
  // 返回登录页面
  private goToLogin() {
    router.back()
  }
  // 注册API调用
  private async registerUser() {
    if (!this.validateForm()) {
      return
    }

    this.isLoading = true

    try {
      const result = await register({
        username: this.username,
        password: this.password,
        confirmPassword: this.confirmPassword,
        email: this.email || undefined,
        phone: this.phone || undefined
      })

      if (result.success) {
        promptAction.showToast({ message: '注册成功，请登录' })
        // 使用replaceUrl替换当前页，避免返回时回到注册页
        this.goToLogin()
      } else {
        promptAction.showToast({ message: result.message || '注册失败' })
      }
    } catch (error) {
      promptAction.showToast({ message: '网络错误，请稍后重试' })
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Image($r('app.media.left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            this.goToLogin()
          })

        Text('用户注册')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 24 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 表单区域
      Scroll() {
        Column() {
          // 用户名输入框
          Column() {
            Row() {
              Image($r('app.media.user'))
                .width(20)
                .height(20)
                .fillColor('#6C757D')
                .margin({ right: 10 })

              TextInput({ placeholder: '请输入用户名（至少3个字符）' })
                .layoutWeight(1)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .onChange((value: string) => {
                  this.username = value
                })
            }
            .width('100%')
            .height(50)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({ width: 1, color: '#E9ECEF' })
          }
          .margin({ bottom: 20 })

          // 密码输入框
          Column() {
            Row() {
              Image($r('app.media.key_line'))
                .width(20)
                .height(20)
                .fillColor('#6C757D')
                .margin({ right: 10 })

              TextInput({ placeholder: '请输入密码（至少6个字符）' })
                .layoutWeight(1)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.password = value
                })


            }
            .width('100%')
            .height(50)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({ width: 1, color: '#E9ECEF' })
          }
          .margin({ bottom: 20 })

          // 确认密码输入框
          Column() {
            Row() {
              Image($r('app.media.key_line'))
                .width(20)
                .height(20)
                .fillColor('#6C757D')
                .margin({ right: 10 })

              TextInput({ placeholder: '请再次输入密码' })
                .layoutWeight(1)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.confirmPassword = value
                })
            }
            .width('100%')
            .height(50)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({ width: 1, color: '#E9ECEF' })
          }
          .margin({ bottom: 20 })

          // 邮箱输入框（可选）
          Column() {
            Row() {
              Image($r("app.media.mail"))
                .width(20)
                .height(20)
                .fillColor('#6C757D')
                .margin({ right: 10 })

              TextInput({ placeholder: '请输入邮箱（可选）' })
                .layoutWeight(1)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .type(InputType.Email)
                .onChange((value: string) => {
                  this.email = value
                })
            }
            .width('100%')
            .height(50)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({ width: 1, color: '#E9ECEF' })
          }
          .margin({ bottom: 20 })

          // 手机号输入框（可选）
          Column() {
            Row() {
              Image($r('app.media.mobile_line'))
                .width(20)
                .height(20)
                .fillColor('#6C757D')
                .margin({ right: 10 })

              TextInput({ placeholder: '请输入手机号（可选）' })
                .layoutWeight(1)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .type(InputType.PhoneNumber)
                .onChange((value: string) => {
                  this.phone = value
                })
            }
            .width('100%')
            .height(50)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({ width: 1, color: '#E9ECEF' })
          }
          .margin({ bottom: 30 })

          // 注册按钮
          Button(this.isLoading ? '注册中...' : '立即注册')
            .width('100%')
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FFD166')
            .fontColor('#333333')
            .borderRadius(8)
            .enabled(!this.isLoading)
            .onClick(() => {
              this.registerUser()
            })
            .margin({ bottom: 20 })

          // 登录链接
          Row() {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#6C757D')

            Text('立即登录')
              .fontSize(14)
              .fontColor('#FFD166')
              .onClick(() => {
                this.goToLogin()
              })
          }
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ left: 30, right: 30, top: 20, bottom: 30 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}