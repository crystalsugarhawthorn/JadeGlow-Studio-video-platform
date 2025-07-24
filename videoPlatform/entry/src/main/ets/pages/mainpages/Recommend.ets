import { FilterComponent } from '../Recommendpages/Filter'
import { VideoListComponent } from '../Recommendpages/VideoList'
import { RankListComponent } from '../Recommendpages/RankList'
import { getFilterOptions } from '../common/api'
import { FilterOptions, FilterCondition, TypeChecker } from '../model/recommendModel'

import router from '@ohos.router';

@Component
export struct Recommend {
  @State currentTab: number = 1 // 0:榜单, 1:筛选（默认进入筛选页面）
  @State filterOptions: FilterOptions = {
    genres: [],
    regions: [],
    years: []
  }
  @State currentFilters: FilterCondition = {} // 默认无筛选条件（显示全部类型）
  @Prop refreshKey: number

  aboutToAppear() {
    this.loadFilterOptions()
  }

  // 加载筛选选项
  async loadFilterOptions() {
    try {
      const response = await getFilterOptions()
      if (response.success && response.data !== null && typeof response.data === 'object') {
        // 使用TypeChecker检查数据类型
        if (TypeChecker.isFilterOptions(response.data)) {
          this.filterOptions = response.data as FilterOptions
        } else {
          console.error('筛选选项数据格式不正确')
        }
      } else {
        console.error('加载筛选选项失败:', response.message)
      }
    } catch (error) {
      console.error('加载筛选选项失败:', error)
    }
  }

  // 筛选条件变化处理 - 支持多选，接收数组参数
  onFilterChange = (categories?: number[], genres?: string[], regions?: string[], yearRanges?: string[]) => {
    this.currentFilters = {
      categories,
      genres,
      regions,
      yearRanges
    }
  }

  // 顶部导航栏
  @Builder
  TopNavigation() {
    Row() {
      // 榜单和筛选居中
      Row() {
        Text('榜单')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTab === 0 ? '#57CC99' : '#6C757D')
          .onClick(() => {
            this.currentTab = 0
          })
          .scale({ x: this.currentTab === 0 ? 1.2 : 1, y: this.currentTab === 0 ? 1.2 : 1 })
          .animation({ duration: 150, curve: Curve.EaseInOut })

        Text('筛选')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTab === 1 ? '#57CC99' : '#6C757D')
          .margin({ left: 40 })
          .onClick(() => {
            this.currentTab = 1
          })
          .scale({ x: this.currentTab === 1 ? 1.2 : 1, y: this.currentTab === 1 ? 1.2 : 1 })
          .animation({ duration: 150, curve: Curve.EaseInOut })
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      // 搜索图标
      Image($r('app.media.search'))
        .width(24)
        .height(24)
        .fillColor('#666666')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Search'
          })
        })
    }
    .width('100%')
    .height(30)
    .padding(1)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
  }


  // 榜单内容
  @Builder
  RankContent() {
    Column() {
      // 榜单组件
      RankListComponent()
    }
    .width('100%')
    .height('100%')
  }

  // 筛选内容
  @Builder
  FilterContent() {
    Column() {
      // 顶部导航和筛选组件放在同一个背景中
      Column() {
        // 顶部导航
        this.TopNavigation()

        // 筛选组件
        FilterComponent({
          genreOptions: this.filterOptions.genres,
          regionOptions: this.filterOptions.regions,
          onFilterChange: this.onFilterChange
        })
      }
      .backgroundColor(Color.White)
      .borderRadius(8)
      .padding(8)

      // 视频列表
      VideoListComponent({
        filterCondition: this.currentFilters
      })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Column() {
      // 主内容
      if (this.currentTab === 1) {
        this.FilterContent()
      } else {
        Column() {
          // 榜单页面也需要顶部导航
          Column() {
            this.TopNavigation()
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(8)

          this.RankContent()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .margin({ top: 0 })
  }
}
