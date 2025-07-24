import { FilterItem, FilterGroup, CATEGORY_OPTIONS, YEAR_RANGE_OPTIONS } from '../model/filterModel'

@Component
export struct FilterComponent {
  // 将filterGroups改为4个独立的State数组，提高响应速度
  @State categoryItems: FilterItem[] = []
  @State genreItems: FilterItem[] = []
  @State regionItems: FilterItem[] = []
  @State yearItems: FilterItem[] = []
  @State isExpanded: boolean = false
  @Prop genreOptions: string[] = []
  @Prop regionOptions: string[] = []
  onFilterChange: (categories?: number[], genres?: string[], regions?: string[], yearRanges?: string[]) => void = () => {}

  aboutToAppear() {
    this.initFilterGroups()
  }

  // 数组去重函数
  private removeDuplicates(arr: string[]): string[] {
    return Array.from(new Set(arr))
  }

  // 创建FilterItem的工厂方法
  private createFilterItem(id: number, name: string, value: string | number, selected: boolean): FilterItem {
    return {
      id: id,
      name: name,
      value: value,
      selected: selected
    }
  }

  initFilterGroups() {
    // 分类筛选
    const categoryItemList: FilterItem[] = []
    categoryItemList.push(this.createFilterItem(0, '全部', -1, true))
    CATEGORY_OPTIONS.forEach((item) => {
      categoryItemList.push(this.createFilterItem(
        item.id + 1,
        item.name,
        item.value,
        false
      ))
    })
    this.categoryItems = categoryItemList

    // 类型筛选
    const defaultGenres: string[] = ['热血', '历史', '科幻', '喜剧', '奇幻', '古装', '惊悚', '犯罪', '战争', '动作', '自然', '海洋', '生物', '人文', '科学', '天文', '推理']
    const combinedGenres: string[] = defaultGenres.concat(this.genreOptions)
    const allGenres: string[] = this.removeDuplicates(combinedGenres)
    const genreItemList: FilterItem[] = []
    genreItemList.push(this.createFilterItem(0, '全部', '', true))
    allGenres.forEach((genre, index) => {
      genreItemList.push(this.createFilterItem(
        index + 1,
        genre,
        genre,
        false
      ))
    })
    this.genreItems = genreItemList

    // 地区筛选
    const defaultRegions: string[] = ['中国', '美国', '英国', '日本']
    const combinedRegions: string[] = defaultRegions.concat(this.regionOptions)
    const allRegions: string[] = this.removeDuplicates(combinedRegions)
    const regionItemList: FilterItem[] = []
    regionItemList.push(this.createFilterItem(0, '全部', '', true))
    allRegions.forEach((region, index) => {
      regionItemList.push(this.createFilterItem(
        index + 1,
        region,
        region,
        false
      ))
    })
    this.regionItems = regionItemList

    // 年份筛选
    const yearItemList: FilterItem[] = []
    yearItemList.push(this.createFilterItem(0, '全部', '', true))
    YEAR_RANGE_OPTIONS.forEach((item) => {
      yearItemList.push(this.createFilterItem(
        item.id + 1,
        item.name,
        item.value,
        false
      ))
    })
    this.yearItems = yearItemList
  }

  // 处理分类点击
  onCategoryClick(index: number) {
    const newItems = [...this.categoryItems]
    const clickedItem = newItems[index]

    if (clickedItem.name === '全部') {
      // 点击"全部"：取消所有其他选项，只选中"全部"
      newItems.forEach((item, i) => {
        item.selected = i === 0
      })
    } else {
      // 点击具体选项：切换选中状态
      clickedItem.selected = !clickedItem.selected

      // 如果选择了具体选项，取消"全部"的选中
      if (clickedItem.selected) {
        newItems[0].selected = false
      }

      // 如果没有任何具体选项被选中，自动选中"全部"
      const hasSelected = newItems.slice(1).some(item => item.selected)
      if (!hasSelected) {
        newItems[0].selected = true
      }
    }

    this.categoryItems = newItems
    this.emitFilterChange()
  }

  // 处理类型点击
  onGenreClick(index: number) {
    const newItems = [...this.genreItems]
    const clickedItem = newItems[index]

    if (clickedItem.name === '全部') {
      newItems.forEach((item, i) => {
        item.selected = i === 0
      })
    } else {
      clickedItem.selected = !clickedItem.selected

      if (clickedItem.selected) {
        newItems[0].selected = false
      }

      const hasSelected = newItems.slice(1).some(item => item.selected)
      if (!hasSelected) {
        newItems[0].selected = true
      }
    }

    this.genreItems = newItems
    this.emitFilterChange()
  }

  // 处理地区点击
  onRegionClick(index: number) {
    const newItems = [...this.regionItems]
    const clickedItem = newItems[index]

    if (clickedItem.name === '全部') {
      newItems.forEach((item, i) => {
        item.selected = i === 0
      })
    } else {
      clickedItem.selected = !clickedItem.selected

      if (clickedItem.selected) {
        newItems[0].selected = false
      }

      const hasSelected = newItems.slice(1).some(item => item.selected)
      if (!hasSelected) {
        newItems[0].selected = true
      }
    }

    this.regionItems = newItems
    this.emitFilterChange()
  }

  // 处理年份点击
  onYearClick(index: number) {
    const newItems = [...this.yearItems]
    const clickedItem = newItems[index]

    if (clickedItem.name === '全部') {
      newItems.forEach((item, i) => {
        item.selected = i === 0
      })
    } else {
      clickedItem.selected = !clickedItem.selected

      if (clickedItem.selected) {
        newItems[0].selected = false
      }

      const hasSelected = newItems.slice(1).some(item => item.selected)
      if (!hasSelected) {
        newItems[0].selected = true
      }
    }

    this.yearItems = newItems
    this.emitFilterChange()
  }

  emitFilterChange() {
    // 收集选中的值
    const selectedCategories = this.categoryItems
      .filter(item => item.selected && item.name !== '全部')
      .map(item => item.value)

    const selectedGenres = this.genreItems
      .filter(item => item.selected && item.name !== '全部')
      .map(item => item.value)

    const selectedRegions = this.regionItems
      .filter(item => item.selected && item.name !== '全部')
      .map(item => item.value)

    const selectedYearRanges = this.yearItems
      .filter(item => item.selected && item.name !== '全部')
      .map(item => item.value)

    // 处理筛选条件
    const categories = selectedCategories.length > 0 ?
      selectedCategories.map(cat => typeof cat === 'number' ? cat : undefined)
        .filter(cat => cat !== undefined) as number[] : undefined

    const genres = selectedGenres.length > 0 ?
      selectedGenres.map(genre => typeof genre === 'string' ? genre : undefined)
        .filter(genre => genre !== undefined) as string[] : undefined

    const regions = selectedRegions.length > 0 ?
      selectedRegions.map(region => typeof region === 'string' ? region : undefined)
        .filter(region => region !== undefined) as string[] : undefined

    const yearRanges = selectedYearRanges.length > 0 ?
      selectedYearRanges.map(year => typeof year === 'string' ? year : undefined)
        .filter(year => year !== undefined) as string[] : undefined

    this.onFilterChange(categories, genres, regions, yearRanges)
  }

  // 切换展开/收起状态
  toggleExpanded() {
    this.isExpanded = !this.isExpanded
  }

  @Builder
  CategoryRow() {
    Row() {
      Text('分类')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width(60)
        .textAlign(TextAlign.Start)

      Scroll() {
        Row() {
          ForEach(this.categoryItems, (item: FilterItem, index: number) => {
            Text(item.name)
              .fontSize(12)
              .fontColor(item.selected ? '#ffe3ac00' : '#6C757D')
              .backgroundColor(item.selected ? '#22ffd166' : Color.Transparent)
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .onClick(() => {
                this.onCategoryClick(index)
              })
          }, (item: FilterItem) => `category_${item.id}_${item.selected}`)
        }
        .alignItems(VerticalAlign.Center)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  GenreRow() {
    Row() {
      Text('类型')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width(60)
        .textAlign(TextAlign.Start)

      Scroll() {
        Row() {
          ForEach(this.genreItems, (item: FilterItem, index: number) => {
            Text(item.name)
              .fontSize(12)
              .fontColor(item.selected ? '#ffe3ac00' : '#6C757D')
              .backgroundColor(item.selected ? '#22ffd166' : Color.Transparent)
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .onClick(() => {
                this.onGenreClick(index)
              })
          }, (item: FilterItem) => `genre_${item.id}_${item.selected}`)
        }
        .alignItems(VerticalAlign.Center)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  RegionRow() {
    Row() {
      Text('地区')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width(60)
        .textAlign(TextAlign.Start)

      Scroll() {
        Row() {
          ForEach(this.regionItems, (item: FilterItem, index: number) => {
            Text(item.name)
              .fontSize(12)
              .fontColor(item.selected ? '#ffe3ac00' : '#6C757D')
              .backgroundColor(item.selected ? '#22ffd166' : Color.Transparent)
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .onClick(() => {
                this.onRegionClick(index)
              })
          }, (item: FilterItem) => `region_${item.id}_${item.selected}`)
        }
        .alignItems(VerticalAlign.Center)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  YearRow() {
    Row() {
      Text('年份')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width(60)
        .textAlign(TextAlign.Start)

      Scroll() {
        Row() {
          ForEach(this.yearItems, (item: FilterItem, index: number) => {
            Text(item.name)
              .fontSize(12)
              .fontColor(item.selected ? '#ffe3ac00' : '#6C757D')
              .backgroundColor(item.selected ? '#22ffd166' : Color.Transparent)
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .onClick(() => {
                this.onYearClick(index)
              })
          }, (item: FilterItem) => `year_${item.id}_${item.selected}`)
        }
        .alignItems(VerticalAlign.Center)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  ExpandToggleButton() {
    Row() {
      Text(this.isExpanded ? '收起' : '展开')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ right: 4 })

      Image(this.isExpanded ? $r('app.media.up') : $r('app.media.down'))
        .width(16)
        .height(16)
        .fillColor('#666666')
    }
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      this.toggleExpanded()
    })
  }

  build() {
    Column() {
      // 始终显示前两个筛选组
      this.CategoryRow()
      this.GenreRow()

      // 根据展开状态显示剩余的筛选组
      if (this.isExpanded) {
        this.RegionRow()
        this.YearRow()
      }

      // 展开/收起按钮
      this.ExpandToggleButton()
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
}
