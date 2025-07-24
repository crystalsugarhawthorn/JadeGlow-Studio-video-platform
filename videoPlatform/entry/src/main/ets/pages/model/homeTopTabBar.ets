export interface  homeTopTabBar{
  title: ResourceStr;
  name: string;
}
// TabBar 的数据实现
export const homeTopTabsData :homeTopTabBar[] = [
  {
    title: $r('app.string.TVSeries'),
    name: 'TVSeries'
  },
  {
    title: $r('app.string.Movie'),
    name: 'movie'
  },
  {
    title: $r('app.string.Anime'),
    name: 'anime'
  },
  {
    title: $r('app.string.Documentary'),
    name: 'documentary'
  }
];