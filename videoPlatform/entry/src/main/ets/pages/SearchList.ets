// \entry\src\main\ets\pages\SearchList.ets

import router from '@ohos.router'
import { ConfigUtil as Config } from './common/configUtil'
import { searchVideo } from './common/api'
import { VideoModel, searchCateNameModel } from './model/appModel'
import{ParamModel} from './model/paramModel'
import {SearchNav} from './widget/SearchNavbar'

import { SubHeaderItemWidget } from './widget/SubHeaderItemWidget'
import searchService from './services/SearchService'
import inputMethod from '@ohos.inputMethod'
// 语音识别相关导入
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ICapturerInterface } from './utils/ICapturerInterface';
import FileCapturer from './utils/FileCapturer';
import AudioCapturer from './utils/AudioCapturer'

let asrEngine: speechRecognizer.SpeechRecognitionEngine;

@Entry
@Component
struct videoList {
  @State type: number = 1
  @State cid: string = ""
  @State keywords: string = ""
  @State videoList: VideoModel[] = []
  private scroller: Scroller = new Scroller();
  @State page: number = 1
  @State hasMore: boolean = true
  @State sort: string = ""
  @State selectedSubHeaderIndex: number = 0
  @State subHeaderList: searchCateNameModel[] = [
    new searchCateNameModel(1, "视频", 1,),
  ];

  // 语音识别相关状态
  @State sessionId: string = "123456";
  @State isVoiceRecording: boolean = false; // 语音录制状态
  private mFileCapturer: ICapturerInterface = new FileCapturer();
  private mAudioCapturer: ICapturerInterface = new AudioCapturer();

  aboutToAppear() {
    let params: ParamModel = router.getParams() as ParamModel;
    this.keywords = params.keywords??""
    this.getVideoData()
  }

  async getVideoData(videoCate?:searchCateNameModel | undefined) {
    let params :ParamModel
    params = {
      type: videoCate? videoCate.type :1,
      keywords: this.keywords,
      page: this.page
    }
    const res = await searchVideo(params)
    let tempData: VideoModel[] = JSON.parse(JSON.stringify(res.data)).list
    console.log("tempData"+JSON.stringify(tempData))
    this.videoList = this.videoList.concat(tempData)
    console.log("videoList:" + JSON.stringify(this.videoList))
    this.page++
    if (tempData.length < 6) {
      this.hasMore = false
    }
  }

  //筛选数据
  changeSubHeader(key: number) {
    console.log('changeSubHeader', key)
    this.selectedSubHeaderIndex = key
    //重置数据
    this.videoList = []
    this.page = 1
    this.hasMore = true
    this.type = this.subHeaderList[key].type
    //重新请求数据
    this.getVideoData(this.subHeaderList[key])
  }

  // 语音识别回调监听器
  setListener() {
    let setListener: speechRecognizer.RecognitionListener = {
      // 识别开始回调
      onStart: (sessionId: string, eventMessage: string) => {
        this.keywords = '';
        console.info("setListener onStart sessionId: " + sessionId + "eventMessage: " + eventMessage);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info("setListener onEvent sessionId: " + sessionId + "eventMessage: " + eventCode + "eventMessage: " + eventMessage);
      },
      // 识别结果回调
      onResult: (sessionId: string, res: speechRecognizer.SpeechRecognitionResult) => {
        let isFinal: boolean = res.isFinal;
        let isLast: boolean = res.isLast;
        let result: string = res.result;
        // 去除句号
        let regexp: RegExp = new RegExp(/\。$/, "g");
        result = result.replaceAll(regexp, "");
        this.keywords = result; // 更新识别结果
        console.info('setListener onResult: ' + 'sessionId: ' + sessionId + ' isFinal: ' + isFinal + ' isLast: ' + isLast + ' result: ' + result);
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
        console.info("setListener onComplete sessionId: " + sessionId + "eventMessage: " + eventMessage);
      },
      // 错误回调
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.error("setListener onError sessionId: " + sessionId + "errorCode: " + errorCode + "errorMessage: " + errorMessage);
      }
    }
    asrEngine.setListener(setListener);
  }

  // 开始语音识别录音
  async startRecording() {
    let extraParam: Record<string, Object> = {
      "locate": "CN",
      "recognizerMode": "short",
    };

    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam
    };

    speechRecognizer.createEngine(initParamsInfo)
      .then((speechRecognitionEngine: speechRecognizer.SpeechRecognitionEngine) => {
        asrEngine = speechRecognitionEngine;
        this.setListener();

        // 设置音频参数
        let audioParam: speechRecognizer.AudioInfo = {
          audioType: 'pcm',
          sampleRate: 16000,
          soundChannel: 1,
          sampleBit: 16
        }

        let extraParam: Record<string, Object> = {
          "recognitionMode": 0,
          "vadBegin": 2000,
          "vadEnd": 3000,
          "maxAudioDuration": 20000
        }

        let recognizerParams: speechRecognizer.StartParams = {
          sessionId: this.sessionId,
          audioInfo: audioParam,
          extraParams: extraParam
        }

        console.info('startListening start');
        asrEngine.startListening(recognizerParams);

        // 录音获取音频
        let data: ArrayBuffer;
        this.mFileCapturer = this.mAudioCapturer;
        console.info('create capture success');
        this.mFileCapturer.init((dataBuffer: ArrayBuffer) => {
          console.info('start write');
          data = dataBuffer
          let uint8Array: Uint8Array = new Uint8Array(data);
          // 写入音频流
          asrEngine.writeAudio(this.sessionId, uint8Array);
        });
      })
      .catch((err: BusinessError) => {
        console.error('result' + JSON.stringify(err));
      });
  }

  //顶部导航和状态栏
  @Builder
  AppBarWidget() {
    Column() {
      //导航
      Row() {
        Row() {
          Image($r("app.media.left")).height(22).padding({ left: 6 }).fillColor(Color.Gray)
        }.width(20)
        .height('100%')
        .onClick(() => {
          router.back()
        })

        Row() {
          Search({ value: this.keywords })
            .height('96lpx')
            .backgroundColor('#FCF3EC')
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: "38lpx", weight: 400 })
            .textFont({ size: "38lpx", weight: 400 })
            .margin({
              left: "44lpx",
              right: "44lpx"
            })
            .onChange(async (value) => {
              //保存搜索关键词
              if (value != '') {
                await searchService.setHistoryData(value)
              }
              //执行搜索
              this.keywords = value
              //重置数据
              this.videoList = []
              this.page = 1
              this.hasMore = true
              //重新请求数据
              if (this.selectedSubHeaderIndex==0) {
                this.getVideoData()
              }
              //隐藏键盘
              let im=inputMethod.getController()
              im.stopInputSession()
            })
        }.layoutWeight(1)

        // 语音识别图标 - 录音时变绿色
        Row() {
          Image($r("app.media.voice"))
            .width("38lpx")
            .height("38lpx")
            .margin({ right: "15lpx" })
            .fillColor(this.isVoiceRecording ? Color.Green : Color.Gray)
            .onTouch(async (event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.isVoiceRecording = true;
                await this.startRecording();
              }
              if (event.type === TouchType.Up) {
                setTimeout(() => {
                  this.isVoiceRecording = false;
                  if (asrEngine) {
                    asrEngine.finish(this.sessionId);
                  }
                  // 语音识别完成后自动搜索
                  if (this.keywords != '') {
                    //重置数据
                    this.videoList = []
                    this.page = 1
                    this.hasMore = true
                    //重新请求数据
                    this.getVideoData()
                  }
                }, 1000);
              }
            })
        }
      }.width("100%").height("140lpx")
      .padding({
        left: "34lpx",
        right: "34lpx"
      }).justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.White)
  }

  //列表
  @Builder
  videoWidget() {
    Scroll(this.scroller) {
      Column({
        space: "28lpx"
      }) {
        ForEach(this.videoList, (item: VideoModel) => {
          Row() {
            Image(`${Config.SERVERURL}covers/${item.cover_url}`).width("260lpx").margin({ right: "34lpx" })
            Column() {
              Text(item.title).fontSize("44lpx").fontWeight(FontWeight.Bold)
              if( item.description.length > 200){
                Text(`${item.description.slice(0,200)}……`).fontSize("20lpx").fontStyle(FontStyle.Italic)
              }else{
                Text(item.description).fontSize("20lpx").fontStyle(FontStyle.Italic)
              }

            }.layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.SpaceEvenly)
            .height("100%")
          }
          .width("100%")
          .height("440lpx")
          .backgroundColor("#ffffff")
          .borderRadius("15lpx")
          .padding("20lpx")
          .onClick(() => {
            router.pushUrl({
              url: 'pages/videoDetail',
              params: {
                id: item.video_id
              }
            })
          })
        },(item: VideoModel) => item.title.toString())
        if (!this.hasMore) {
          Text("-----我是有底线的-----").width("100%").margin("10lpx").textAlign(TextAlign.Center)
        }
      }.width("100%")
      .padding("28lpx")
    }.width("100%").edgeEffect(EdgeEffect.None)

  }

  build() {
    Stack({
      alignContent: Alignment.Top
    }) {
      Column() { //内容区域
        this.videoWidget()
      }
      .width('100%')
      .height('100%')
      .backgroundColor("#F4F4F4")
      .padding({
        top: "180lpx"
      })

      Column() { //头部
        this.AppBarWidget()
      }.width('100%')
    }

  }
}