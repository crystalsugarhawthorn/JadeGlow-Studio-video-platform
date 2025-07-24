import router from '@ohos.router'
import { getUserWatchHistory, deleteWatchHistory } from '../common/api'
import { GroupedWatchHistory, VideoModel, WatchHistoryModel ,UserModel} from '../model/appModel'
import { ConfigUtil } from '../common/configUtil'
import promptAction from '@ohos.promptAction'
import {userLogin} from '../common/userLogin'

// 添加分类选项接口
interface CategoryOption {
  id: string;
  name: string;
}

@Entry
@Component
struct BrowseHistory {
  @State isLogin: boolean = userLogin.isLogin
  @State userInfo: UserModel = userLogin.userInfo
  @State historyData: GroupedWatchHistory[] = []
  @State selectedCategory: string = 'all'
  @State isEditMode: boolean = false
  @State selectedMap: Map<number, boolean> = new Map()  // 使用Map存储选中状态
  @State isLoading: boolean = false
  @State hasNoData: boolean = false
  private scroller: Scroller = new Scroller()

  // 分类选项
  private categories: CategoryOption[] = [
    { id: 'all', name: '全部' },
    { id: '0', name: '电视剧' },
    { id: '1', name: '电影' },
    { id: '2', name: '动漫' },
    { id: '3', name: '纪录片' }
  ]

  aboutToAppear() {
    this.loadWatchHistory()
  }

  // 加载观看历史
  async loadWatchHistory() {
    this.isLoading = true
    try {
      const response = await getUserWatchHistory(
        this.userInfo.user_id || 0,
        this.selectedCategory === 'all' ? undefined : this.selectedCategory
      )

      if (response.success && response.data) {
        this.historyData = response.data as GroupedWatchHistory[]
        this.hasNoData = this.historyData.length === 0
        // 初始化选中状态
        this.initSelectedMap()
      } else {
        this.hasNoData = true
      }
    } catch (error) {
      console.error('加载观看历史失败:', error)
      this.hasNoData = true
    }
    this.isLoading = false
  }

  // 初始化选中状态Map
  initSelectedMap() {
    const newMap = new Map<number, boolean>()
    this.historyData.forEach(group => {
      group.records.forEach(record => {
        newMap.set(record.history_id, false)
      })
    })
    this.selectedMap = newMap
  }

  // 删除选中的历史记录
  async deleteSelectedHistory() {
    const selectedIds = this.getSelectedIds()
    if (selectedIds.length === 0) {
      promptAction.showToast({ message: '请先选择要删除的记录' })
      return
    }

    try {
      const response = await deleteWatchHistory(selectedIds)

      if (response.success) {
        promptAction.showToast({ message: '删除成功' })
        this.isEditMode = false
        await this.loadWatchHistory()
      } else {
        promptAction.showToast({ message: response.message || '删除失败' })
      }
    } catch (error) {
      promptAction.showToast({ message: '删除失败' })
    }
  }

  // 获取选中的ID列表
  getSelectedIds(): number[] {
    const ids: number[] = []
    this.selectedMap.forEach((isSelected, id) => {
      if (isSelected) {
        ids.push(id)
      }
    })
    return ids
  }

  // 获取视频类别名称
  getCategoryName(category: number): string {
    const categoryMap = ['电视剧', '电影', '动漫', '纪录片']
    return categoryMap[category] || '其他'
  }

  // 格式化时间
  formatTime(dateStr: string): string {
    const date = new Date(dateStr)
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    return `${hours}:${minutes}`
  }

  // 选择/取消选择单个项目
  toggleSelectItem(historyId: number) {
    const newMap = new Map(this.selectedMap)
    newMap.set(historyId, !newMap.get(historyId))
    this.selectedMap = newMap
  }

  // 检查是否选中
  isItemSelected(historyId: number): boolean {
    return this.selectedMap.get(historyId) || false
  }

  // 检查是否全选
  isAllSelected(): boolean {
    let allSelected = true
    this.selectedMap.forEach((isSelected) => {
      if (!isSelected) {
        allSelected = false
      }
    })
    return allSelected && this.selectedMap.size > 0
  }

  // 全选
  selectAll() {
    const newMap = new Map(this.selectedMap)
    newMap.forEach((_, id) => {
      newMap.set(id, true)
    })
    this.selectedMap = newMap
  }

  // 取消全选
  deselectAll() {
    const newMap = new Map(this.selectedMap)
    newMap.forEach((_, id) => {
      newMap.set(id, false)
    })
    this.selectedMap = newMap
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.left'))
          .width(24)
          .height(24)
          .onClick(() => router.back())

        Text('浏览历史')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(this.isEditMode ? '完成' : '编辑')
          .fontSize(16)
          .fontColor('#ffe3ac00')
          .visibility(this.hasNoData ? Visibility.Hidden : Visibility.Visible)
          .onClick(() => {
            this.isEditMode = !this.isEditMode
            if (!this.isEditMode) {
              this.deselectAll()
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 分类筛选
      Scroll(this.scroller) {
        Row() {
          ForEach(this.categories, (item: CategoryOption) => {
            Text(item.name)
              .fontSize(14)
              .fontColor(this.selectedCategory === item.id ? '#ffe3ac00' : '#6C757D')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.selectedCategory === item.id ? '#22ffd166' : Color.Transparent)
              .borderRadius(16)
              .onClick(() => {
                this.selectedCategory = item.id
                this.loadWatchHistory()
              })
          })
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      // 历史记录列表
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 100 })
      } else if (this.hasNoData) {
        Text('无浏览记录')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 100 })
      } else {
        List() {
          ForEach(this.historyData, (group: GroupedWatchHistory) => {
            ListItem() {
              Column() {
                // 日期标题
                Text(group.date)
                  .fontSize(14)
                  .fontColor('#999999')
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })

                // 该日期下的视频列表
                ForEach(group.records, (record: WatchHistoryModel) => {
                  Row() {
                    // 编辑模式下的选择框
                    if (this.isEditMode) {
                      Checkbox()
                        .select(this.isItemSelected(record.history_id))
                        .onClick(() => {
                          this.toggleSelectItem(record.history_id)
                        })
                        .margin({ right: 12 })
                    }

                    // 视频封面
                    Stack() {
                      Image(record.video ? ConfigUtil.SERVER_URL_COVERS + record.video.cover_url : '')
                        .width(120)
                        .height(80)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)

                      // 类别标签
                      Text(this.getCategoryName(record.video?.category || 0))
                        .fontSize(10)
                        .fontColor(Color.White)
                        .backgroundColor('rgba(0,0,0,0.6)')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .position({ x: 4, y: 56 })
                    }
                    .alignContent(Alignment.BottomStart)

                    // 视频信息
                    Column() {
                      Text(record.video?.title || '')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')

                      Text(`观看了${record.watch_progress}%`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ top: 8 })

                      Text(this.formatTime(record.last_watch_time))
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .padding({ left: 12 })
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor(Color.White)
                  .onClick(() => {
                    if (!this.isEditMode && record.video) {
                      // 跳转到视频详情页
                      router.pushUrl({
                        url: 'pages/videoDetail',
                        params: { id: record.video_id }
                      })
                    }
                  })
                })
              }
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
      }

      // 编辑模式底部操作栏
      if (this.isEditMode && !this.hasNoData) {
        Row() {
          Row() {
            Checkbox()
              .select(this.isAllSelected())
              .onClick(() => {
                if (this.isAllSelected()) {
                  this.deselectAll()
                } else {
                  this.selectAll()
                }
              })

            Text(this.isAllSelected() ? '取消全选' : '全选')
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                if (this.isAllSelected()) {
                  this.deselectAll()
                } else {
                  this.selectAll()
                }
              })
          }

          Text('删除')
            .fontSize(14)
            .fontColor('#FF3B30')
            .onClick(() => this.deleteSelectedHistory())
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}