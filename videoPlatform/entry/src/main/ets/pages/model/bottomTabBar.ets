export interface  bottomTabBarModel{
  title: ResourceStr;
  name: string;
  icon: ResourceStr;
}
// TabBar 的数据实现
export const bottomTabsData :bottomTabBarModel[] = [
  {
    title: $r('app.string.Home'),
    name: 'Home',
    icon: $r('app.media.home')
  },
  {
    title: $r('app.string.ShortVideo'),
    name: 'ShortVideo',
    icon: $r('app.media.shortVideo')
  },
  {
    title: $r('app.string.Recommend'),
    name: 'Recommend',
    icon: $r("app.media.recommend")
  },
  {
    title: $r('app.string.Mine'),
    name: 'Mine',
    icon: $r('app.media.user')
  }
];