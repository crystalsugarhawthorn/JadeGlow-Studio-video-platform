import { GroupedWatchHistory, VideoModel ,UserModel, WatchHistoryModel} from '../model/appModel'
import { getUserWatchHistory } from '../common/api' // 只需导入获取历史的API
import { ConfigUtil as Config } from '../common/configUtil'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { router } from '@kit.ArkUI'
import { userLogin } from '../common/userLogin'

@Component
export struct history {
  @State user_id: number = 0 // 示例用户ID，实际应用中应从登录状态或全局管理中获取
  // allVideoList 和 videoList 现在应该存储 ShortVideoHistory 类型
  @State allVideoList: VideoModel[] = [] // 存储从后端一次性获取到的所有历史记录
  @State videoList: VideoModel[] = [] // 存储当前在UI上显示的，经过本地分页处理的历史记录

  @State pageCount: number = 0 // 用于本地分页的页码计数（代表已加载了多少批次）
  scroller: Scroller = new Scroller()
  @State page: number = 1 // 用于触发初始加载或重置本地分页状态
  @State isMoreData: boolean = true // 是否还有更多数据可供本地分页加载
  @Link scrollerFlag: boolean // 用于外部控制滚动状态的链接变量（如果需要的话）

  // 登录状态相关
  @State isLogin: boolean = false
  @State userInfo: UserModel = {}

  // 假设每个视频列表项显示的数量
  private readonly ITEMS_PER_PAGE: number = 9; // 例如，每页显示9条

  // 获取登录状态
  getLoginStatus() {
    this.isLogin = userLogin.isLogin
    this.userInfo = userLogin.userInfo

    // 如果已登录且有用户信息，更新user_id
    if (this.isLogin && this.userInfo && this.userInfo.user_id) {
      this.user_id = this.userInfo.user_id
    }
  }

  // 检查登录状态，未登录则跳转
  checkLoginAndNavigate(): boolean {
    this.getLoginStatus()

    if (!this.isLogin) {
      // 未登录，跳转到登录页
      router.pushUrl({
        url: 'pages/minepages/Login'
      }).catch((error: Error) => {
        console.error('跳转到登录页面失败:', error)
      })
      return false
    }
    return true
  }

  async getVideoData(resolve?: (value: string) => void) {
    // 检查登录状态
    if (!this.checkLoginAndNavigate()) {
      // 未登录，清空数据并返回
      this.allVideoList = []
      this.videoList = []
      this.isMoreData = false
      resolve && resolve('未登录，无法获取观看历史')
      return
    }

    if (this.page === 1) { // 第一次加载或下拉刷新时
      try {
        const res = await getUserWatchHistory(this.user_id) // 调用后端接口获取所有历史记录

        if (res && res.data && Array.isArray(res.data)) {
          // 修复：先过滤再赋值，确保逻辑正确
          const temp: GroupedWatchHistory[] = JSON.parse(JSON.stringify(res.data));
          const extractedVideos: VideoModel[] = [];

          for (const group of temp) {
            for (const record of group.records) {
              if (record.video && record.video.category === 4) {
                extractedVideos.push(record.video);
              }
            }
          }
          this.allVideoList = extractedVideos;

          console.log("获取观看历史成功:", this.allVideoList.toString())
        } else {
          this.allVideoList = [];
          console.error("getUserWatchHistory API 返回数据结构异常或为空:", res);
        }

        this.videoList = [] // 清空当前显示列表
        this.pageCount = 0; // 重置本地分页计数
        this.isMoreData = this.allVideoList.length > 0; // 根据实际数据判断是否有更多数据
      } catch (error) {
        console.error("获取观看历史初始数据失败:", error);
        this.allVideoList = [];
        this.videoList = [];
        this.isMoreData = false;
        resolve && resolve('观看历史加载失败');
        return; // 发生错误，提前退出
      }
    }

    // --- 以下是模拟本地分页和截断逻辑 ---
    const currentDisplayedCount = this.videoList.length // 当前已显示在UI上的数量
    const totalAvailableCount = this.allVideoList.length // 总共有多少条历史记录

    console.log(`当前已加载: ${currentDisplayedCount}, 总共可用: ${totalAvailableCount}`)

    // 如果当前已显示数量已经等于或超过总可用数量，则没有更多数据了
    if (currentDisplayedCount >= totalAvailableCount) {
      this.isMoreData = false
      resolve && resolve('已加载全部观看历史')
      return
    }

    // 从 allVideoList 中切片下一批要加载的数据
    const startIndex = this.ITEMS_PER_PAGE * this.pageCount
    const endIndex = Math.min(this.ITEMS_PER_PAGE * (this.pageCount + 1), this.allVideoList.length)
    let tempList: VideoModel[] = this.allVideoList.slice(startIndex, endIndex)

    // 修复：判断是否还有更多数据的逻辑
    const newDisplayedCount = currentDisplayedCount + tempList.length
    if (newDisplayedCount >= totalAvailableCount) {
      this.isMoreData = false
    }

    this.videoList = this.videoList.concat(tempList) // 追加到当前显示列表

    // 修复：只在首次加载时递增page，避免在上拉加载时重复递增
    if (this.page === 1) {
      this.page++ // 标记已完成首次加载
    }
    this.pageCount++ // 增加本地分页批次计数

    resolve && resolve('刷新完成') // 通知 PullToRefresh 加载/刷新完成
  }

  // 生命周期：组件首次出现时加载数据
  aboutToAppear(): void {
    // 修复：去掉不必要的user_id检查，统一使用刷新方法
    this.refreshLoginStatusAndData()
  }

  // 统一的登录状态检查和数据刷新方法
  refreshLoginStatusAndData(): void {
    const previousLoginStatus = this.isLogin
    this.getLoginStatus() // 获取最新登录状态

    if (this.isLogin) {
      // 如果是刚登录或首次加载，重新获取数据
      if (!previousLoginStatus || this.videoList.length === 0) {
        this.page = 1
        this.pageCount = 0
        this.isMoreData = true
        this.videoList = []
        this.allVideoList = []
        this.getVideoData()
      }
    } else {
      // 未登录时清空数据
      this.allVideoList = []
      this.videoList = []
      this.isMoreData = false
    }
  }

  @Builder
  TitleBar(title: string) {
    Row() {
      Text(title)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .fontSize(18)
    }
    .width('100%')
    .height(50)
    .padding(8)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  getHistoryListWidget() {
    Column() {
      this.TitleBar('我的观看历史')

      // 检查登录状态
      if (!this.isLogin) {
        // 未登录状态显示
        Column() {
          Text('请先登录查看观看历史')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 50, bottom: 20 })

          Button('去登录')
            .fontSize(16)
            .fontColor('#ffe3ac00')
            .backgroundColor('#22ffd166')
            .borderRadius(20)
            .padding({ left: 30, right: 30, top: 10, bottom: 10 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/minepages/Login'
              }).catch((error: Error) => {
                console.error('跳转到登录页面失败:', error)
              })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.videoList.length > 0) {
        // 已登录且有历史数据
        // 使用 List 组件来垂直排列历史记录项
        List() {
          ForEach(this.videoList, (item: VideoModel) => {
            ListItem() {
              // 黑色矩形框作为背景
              Row() {
                // 左侧：视频封面图片
                Image(`${Config.SERVERURL}covers/${item.cover_url}`)
                  .width('20%') // 调整宽度
                  .aspectRatio(9/16) // 保持视频宽高比
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                  .margin({ right: 10 })

                // 右侧：视频标题和播放时长
                Column() {
                  Text(item.title || '未知标题')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .textAlign(TextAlign.Start)
                    .alignSelf(ItemAlign.Start) // 确保文本左对齐

                  // 播放时长 (从 videoDetails.duration 获取)
                  Text(`时长: ${this.formatDuration(item.duration || 0)}`)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .margin({ top: 5 })
                    .textAlign(TextAlign.Start)
                    .alignSelf(ItemAlign.Start)

                  // 观看时间 (从 watch_time 获取)
                  Text(`观看于: ${new Date(item.update_time).toLocaleString()}`)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .margin({ top: 5 })
                    .textAlign(TextAlign.Start)
                    .alignSelf(ItemAlign.Start)

                }
                .layoutWeight(1) // 占据剩余空间
                .alignItems(HorizontalAlign.Start) // 列内元素左对齐
              }
              .width('100%')
              .padding(10)
              .backgroundColor(Color.Black) // 黑色背景框
              .borderRadius(8)
            }
            .padding({ bottom: 10 }) // 每条记录底部留白
            .onClick(() => {
              // 点击跳转到视频播放页面
              if (item.video_id) {
                router.pushUrl({
                  url: 'pages/shortvideopages/VideoPlayPage', // 假设这是你的视频播放页面路由
                  params: {
                    url: item.video_url
                  }
                })
              } else {
                console.warn('点击的历史记录项没有有效的视频详情或视频ID');
              }
            })
          }, (item: VideoModel) => item.video_id?.toString() || Math.random().toString()) // 添加key函数提高性能
        }
        .width('100%')
        .padding({ left: 10, right: 10 }) // 列表左右内边距
      } else {
        // 已登录但暂无历史数据时显示提示
        Text('-----暂无观看历史-----')
          .width('100%')
          .fontColor('#999999')
          .margin(15)
          .textAlign(TextAlign.Center)
      }

      // 如果没有更多数据，并且上面没有显示"暂无观看历史"，则显示这个
      if (!this.isMoreData && this.videoList.length > 0 && this.isLogin) {
        Text('-----没有更多数据了-----')
          .width('100%')
          .fontColor('#999999')
          .margin(15)
          .textAlign(TextAlign.Center)
      }
    }
  }

  // 辅助函数：格式化视频时长 (秒) 为 MM:SS 格式
  private formatDuration(seconds: number): string {
    if (typeof seconds !== 'number' || isNaN(seconds) || seconds < 0) {
      return '00:00';
    }
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    const formattedMinutes = minutes < 10 ? `0${minutes}` : `${minutes}`;
    const formattedSeconds = remainingSeconds < 10 ? `0${remainingSeconds}` : `${remainingSeconds}`;
    return `${formattedMinutes}:${formattedSeconds}`;
  }

  @Builder
  totalWidget() {
    Scroll(this.scroller) {
      Column() {
        this.getHistoryListWidget()
      }
    }
    .scrollBar(BarState.Off)
    .padding({ bottom: 20 })
    .onScroll(() => {
      const y = this.scroller.currentOffset().yOffset
      this.scrollerFlag = y <= 70
    })
  }

  build() {
    Column() {
      PullToRefresh({
        data: this.videoList, // data 绑定到 videoList
        scroller: this.scroller,
        customList: () => {
          this.totalWidget()
        },
        onLoadMore: () => { // 上拉分页
          return new Promise<string>((resolve, reject) => {
            setTimeout(() => {
              if (this.isLogin && this.isMoreData) { // 只有在登录且有更多数据时才尝试加载
                this.getVideoData(resolve)
              } else {
                resolve(this.isLogin ? '没有更多数据了' : '请先登录'); // 根据登录状态返回不同消息
              }
            }, 1000)
          })
        },
        onRefresh: () => { // 下拉刷新
          return new Promise<string>((resolve, reject) => {
            setTimeout(() => {
              this.getLoginStatus() // 刷新时重新检查登录状态

              if (!this.isLogin) {
                // 未登录状态下清空数据
                this.allVideoList = []
                this.videoList = []
                this.isMoreData = false
                resolve('请先登录')
                return
              }

              this.page = 1 // 重置页码
              this.pageCount = 0 // 重置本地分页计数
              this.isMoreData = true // 重新标记有更多数据
              this.videoList = [] // 清空当前显示列表
              this.allVideoList = [] // 清空所有数据，确保从头加载
              this.getVideoData(resolve)
            }, 1000)
          })
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}