// \entry\src\main\ets\pages\Search.ets

import router from '@ohos.router'
import searchService from './services/SearchService'
import promptAction from '@ohos.promptAction'
import {ParamModel} from './model/paramModel'
// 语音识别相关导入
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ICapturerInterface } from './utils/ICapturerInterface';
import FileCapturer from './utils/FileCapturer';
import AudioCapturer from './utils/AudioCapturer'

let asrEngine: speechRecognizer.SpeechRecognitionEngine;

@Entry
@Component
struct search {
  @State historySearch: string[] = []
  @State hotSearch: string[] = ['白鹿原', '长津湖', '甄嬛传']
  @State keywords: string = ""

  // 语音识别相关状态
  @State sessionId: string = "123456";
  @State isVoiceRecording: boolean = false; // 语音录制状态
  private mFileCapturer: ICapturerInterface = new FileCapturer();
  private mAudioCapturer: ICapturerInterface = new AudioCapturer();

  aboutToAppear() {
    this.getHistoryData()  //获取历史记录
    this.tagSearch()
  }
  //标签搜索,从点击标签处得到传递的参数
  async tagSearch(){
    const params: ParamModel = (router.getParams() as ParamModel)
    this.keywords = params.keywords ? params.keywords : ''
    if(this.keywords != ''){
      this.doSearch()
    }
  }
  //获取历史记录
  async getHistoryData(){
    this.historySearch=await searchService.getHistoryData()
  }
  //保存历史记录执行跳转
  async doSearch(){
    if(this.keywords != ''){
      await searchService.setHistoryData(this.keywords)
      //替换路由
      router.pushUrl({
        url: 'pages/SearchList',
        params: {
          "keywords": this.keywords,
          "cid": ""
        }
      })
    }
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

  //自定义组件必须使用根组件来包裹
  @Builder
  AppBarWidget() {
    Column() {
      //导航
      Row() {
        Row() {
          Image($r("app.media.left")).height("50lpx").padding({ left: "6lpx" })
        }.width("40lpx")
        .height('100%')
        .onClick(() => {
          router.back()
        })
        Row() {
          Search({ value: this.keywords })
            .height('72lpx')
            .backgroundColor('#cccccc')
            .placeholderColor('#999999')
            .placeholderFont({ size: "38lpx", weight: 400 })
            .textFont({ size: "38lpx", weight: 400 })
            .onChange((value: string) => {
              this.keywords = value
            })
            .margin({
              left: "30lpx",
              right: "20lpx"
            })
            .onSubmit(() => {
              if(this.keywords != ''){
                this.doSearch()
              }
            })
            .id("searchId")
        }.layoutWeight(1)

        Row() {
          // 语音识别图标 - 录音时变绿色
          Image($r("app.media.voice"))
            .width("38lpx")
            .margin({ right: "10lpx" })
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
                }, 1000);
              }
            })
          Text("搜索")
            .fontSize("38lpx")
            .padding({ left: "8lpx", right: "8lpx", top: "4lpx", bottom: "4lpx" })
            .onClick(() => {
              if(this.keywords != ''){
                this.doSearch()
              }
            })
        }.width("100lpx")
        .margin({ left: "10lpx" })
      }.width("100%").height("140lpx")
      .padding({
        left: "34lpx",
        right: "34lpx"
      }).justifyContent(FlexAlign.SpaceBetween)
    }
  }

  build() {
    Column() {
      this.AppBarWidget()
      Scroll() {
        Column() {
          if (this.historySearch.length > 0) {
            Row() {
              Text("搜索历史").padding({ left: "28lpx" }).fontSize('44lpx').fontWeight(FontWeight.Bold)
              Image($r("app.media.delete")).width("60lpx").padding({ right: "28lpx" }).onClick(async ()=>{

                promptAction.showDialog({
                  title:"提示信息!",
                  message: '您确定要清空历史记录吗？',
                  buttons: [
                    {
                      text: '取消',
                      color: '#FF0000'
                    },
                    {
                      text: '确认',
                      color: '#0099FF'
                    }
                  ]
                }).then(async (result) =>  {
                  if (result.index === 1) {
                    await searchService.cleanHistoryData()
                    this.getHistoryData()  // 再次获取历史记录
                  }
                })

              })
            }.width("100%")
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: "40lpx", bottom: "20lpx" })

            Flex({
              wrap: FlexWrap.Wrap
            }) {
              ForEach(this.historySearch, (item:string) => {
                Button({
                  type: ButtonType.Normal
                }) {
                  Text(item).fontSize("34lpx")
                }.padding({ left: "34lpx", right: "34lpx", top: "14lpx", bottom: "14lpx" })
                .margin("20lpx")
                .backgroundColor("#eee")
                .borderRadius("14lpx")
                .onClick(()=>{
                  this.keywords = item
                  if(this.keywords != ''){
                    this.doSearch()
                  }
                })
                .gesture(
                  LongPressGesture(
                    {duration:1000}
                  ).onAction(()=>{
                    promptAction.showDialog({
                      title:"提示信息!",
                      message: '您确定要删除吗？',
                      buttons: [
                        {
                          text: '取消',
                          color: '#FF0000'
                        },
                        {
                          text: '确认',
                          color: '#0099FF'
                        }
                      ]
                    }).then(async (result) =>  {
                      if (result.index === 1) {
                        await searchService.deleteHistoryData(item)
                        this.getHistoryData()
                      }
                    })
                  })
                )
              })
            }
          }

          Row() {
            Text("猜你想搜").padding({ left: "28lpx" }).fontSize('44lpx').fontWeight(FontWeight.Bold)
          }.width("100%")
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: "40lpx", bottom: "20lpx" })

          Flex({
            wrap: FlexWrap.Wrap
          }) {
            ForEach(this.hotSearch, (item:string) => {
              Button({
                type: ButtonType.Normal
              }) {
                Text(item).fontSize("34lpx")
              }.padding({ left: "34lpx", right: "34lpx", top: "14lpx", bottom: "14lpx" })
              .margin("20lpx")
              .backgroundColor("#eee")
              .borderRadius("14lpx")
              .onClick(() => {
                this.keywords = item
                if(this.keywords != ''){
                  this.doSearch()
                }
              })
            })
          }

        }.width("100%")
      }
    }
    .width('100%')
    .height('100%')
  }
}