import preferencesUtil from '../common/preferenceUtil'
class SearchService {
  async setHistoryData(keywords: string) {
    try {
      let searchListData = await preferencesUtil.get("searchStore", "searchList", "")
      let tempList: string[] = []

      if (searchListData.toString() !== "") {
        tempList = JSON.parse(searchListData.toString())
      }

      // 如果关键词已存在，先移除它
      const existingIndex = tempList.indexOf(keywords)
      if (existingIndex !== -1) {
        tempList.splice(existingIndex, 1)
      }

      // 将新的关键词添加到数组开头（最新的在前面）
      tempList.unshift(keywords)

      // 可选：限制历史记录数量，比如只保留最近50条
      if (tempList.length > 50) {
        tempList = tempList.slice(0, 50)
      }

      // 保存搜索关键词
      await preferencesUtil.set("searchStore", "searchList", JSON.stringify(tempList))

    } catch (error) {
      console.error("保存搜索历史失败:", error)
    }
  }

  //获取历史记录
  async getHistoryData() {
    try {
      let searchListData = await preferencesUtil.get("searchStore", "searchList", "")
      if (searchListData && searchListData.toString() !== "") {
        let tempList: string[] = JSON.parse(searchListData.toString())
        return tempList
      } else {
        return []
      }
    } catch (error) {
      console.error("获取历史数据失败:", error)
      return []
    }
  }

  //删除历史记录
  async deleteHistoryData(keywords: string) {
    let searchListData = await preferencesUtil.get("searchStore", "searchList", "")
    if (searchListData.toString() != "") {
      let tempList: string[] = JSON.parse(searchListData.toString())
      tempList = tempList.filter((item) => {
        return item != keywords
      })
      await preferencesUtil.set("searchStore", "searchList", JSON.stringify(tempList))
    }
  }

  //清空历史记录
  async cleanHistoryData() {
    await preferencesUtil.set("searchStore", "searchList", "")
  }
}

let searchService = new SearchService()

export default searchService