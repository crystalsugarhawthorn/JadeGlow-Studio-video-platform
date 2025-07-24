export interface detailTabBarModel{
  title: string;
  name: string;
}
// TabBar 的数据实现
export const detailTabsData: detailTabBarModel[] = [
  {
    title: '详情',
    name: 'description'
  },
  {
    title: '讨论',
    name: 'comment'
  }
];