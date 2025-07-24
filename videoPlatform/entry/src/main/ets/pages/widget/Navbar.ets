import router from '@ohos.router'
import {videoStack, videoStackData} from '../model/videostack'
import {VideoModel} from '../model/appModel'
@Component
export struct NavBar {
  title?:string=""
  build(){
    Column(){
      Row(){
        Row() {
          Image($r("app.media.left")).fillColor(Color.Gray).height(18)
        }.width("120lpx")
        .height('100%')
        .onClick(() => {
          if (videoStackData.isEmpty()) {
            videoStackData.clear()
            router.back({
              url: 'pages/Index',
            })
          }
          else {
            const last_id = videoStackData.pop()
            if (last_id !== undefined) {
              router.back({
                url: 'pages/videoDetail',
                params: { id: last_id, choose: true }
              })
            }
          }
        })
        .justifyContent(FlexAlign.Center)

        Row(){
          if(this.title!=""){
            Text(this.title)
              .fontColor('#333333')
              .textAlign(TextAlign.Center)
              .fontSize(22)
          }
        }
        .layoutWeight(1)

      }
      .height("40")
      .width('100%')

    }.backgroundColor(Color.Transparent)
  }
}