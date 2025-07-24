// 定义筛选项值的类型
export type FilterValue = number | string | boolean

// 筛选项模型
export interface FilterItem {
  id: number
  name: string
  value: FilterValue  // 使用联合类型替代any
  selected: boolean
}

// 筛选组模型
export interface FilterGroup {
  title: string
  items: FilterItem[]
  selectedIndex: number
}

// 分类选项接口
export interface CategoryOption {
  id: number
  name: string
  value: number
}

// 年份范围选项接口
export interface YearRangeOption {
  id: number
  name: string
  value: string
}

// 分类常量 - 明确类型定义
export const CATEGORY_OPTIONS: CategoryOption[] = [
  { id: 0, name: '电视剧', value: 0 },
  { id: 1, name: '电影', value: 1 },
  { id: 2, name: '动漫', value: 2 },
  { id: 3, name: '纪录片', value: 3 }
]

// 年份范围选项 - 明确类型定义
export const YEAR_RANGE_OPTIONS: YearRangeOption[] = [
  { id: 0, name: '2025-2020', value: '2025-2020' },
  { id: 1, name: '2019-2011', value: '2019-2011' },
  { id: 2, name: '2010-2000', value: '2010-2000' },
  { id: 3, name: '更早', value: '更早' }
]