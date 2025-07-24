@Component
export struct BirthdayPicker {
  @State yearList: string[] = []
  @State monthList: string[] = []
  @State dayList: string[] = []
  @State yearIndex: number = 0
  @State monthIndex: number = 0
  @State dayIndex: number = 0
  onChange:(v:string)=>void=(v:string)=>{}

  aboutToAppear() {
    this.initData();
  }
  //初始化数据
  initData() {
    // 初始化年份（1900-2025）
    for (let i = 1900; i <= 2025; i++) {
      this.yearList.push(i.toString())
    }

    // 初始化月份（1-12月）
    for (let i = 1; i <= 12; i++) {
      this.monthList.push(i.toString().padStart(2, '0'))
    }

    // 初始化日期（默认为1月的天数）
    this.updateDayList(1900, 1)
  }

  // 根据年份和月份更新日期列表
  updateDayList(year: number, month: number) {
    this.dayList = []
    const daysInMonth = this.getDaysInMonth(year, month)

    for (let i = 1; i <= daysInMonth; i++) {
      this.dayList.push(i.toString().padStart(2, '0'))
    }
  }

  // 获取指定年月的天数
  getDaysInMonth(year: number, month: number): number {
    // 使用Date对象计算天数
    return new Date(year, month, 0).getDate()
  }

  // 判断是否为闰年
  isLeapYear(year: number): boolean {
    return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)
  }

  // 获取当前选中的日期字符串
  getCurrentDateString(): string {
    const year = this.yearList[this.yearIndex]
    const month = this.monthList[this.monthIndex]
    const day = this.dayList[this.dayIndex] || '01'
    return `${year}-${month}-${day}`
  }

  build() {
    Row({ space: "20lpx" }) {
      // 年份选择器
      TextPicker({ range: this.yearList })
        .onChange((value: string | string[], index: number | number[]) => {
          console.info('年份, value: ' + value + ', index: ' + index)
          if (typeof index === 'number') {
            this.yearIndex = index
            const selectedYear = parseInt(this.yearList[index])
            const selectedMonth = parseInt(this.monthList[this.monthIndex])

            // 更新日期列表
            this.updateDayList(selectedYear, selectedMonth)

            // 如果当前选中的日期超出了新月份的天数，调整到最后一天
            if (this.dayIndex >= this.dayList.length) {
              this.dayIndex = this.dayList.length - 1
            }

            this.onChange(this.getCurrentDateString())
          }
        }).layoutWeight(1)

      // 月份选择器
      TextPicker({ range: this.monthList })
        .onChange((value: string | string[], index: number | number[]) => {
          console.info('月份, value: ' + value + ', index: ' + index)
          if (typeof index === 'number') {
            this.monthIndex = index
            const selectedYear = parseInt(this.yearList[this.yearIndex])
            const selectedMonth = parseInt(this.monthList[index])

            // 更新日期列表
            this.updateDayList(selectedYear, selectedMonth)

            // 如果当前选中的日期超出了新月份的天数，调整到最后一天
            if (this.dayIndex >= this.dayList.length) {
              this.dayIndex = this.dayList.length - 1
            }

            this.onChange(this.getCurrentDateString())
          }
        }).layoutWeight(1)

      // 日期选择器
      TextPicker({ range: this.dayList })
        .onChange((value: string | string[], index: number | number[]) => {
          console.info('日期, value: ' + value + ', index: ' + index)
          if (typeof index === 'number') {
            this.dayIndex = index
            this.onChange(this.getCurrentDateString())
          }
        }).layoutWeight(1)
    }.width("100%")
  }
}