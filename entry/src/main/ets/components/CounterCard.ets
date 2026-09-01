// src/main/ets/components/CounterCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MqttManager } from '../utils/MqttManager';

@Component
export struct CounterCard {
  // 绑定硬件的实时计数量与当前型号
  @StorageProp('count_num') displayCount: number = 0;
  @StorageProp('count_model') currentModel: string = 'A型 ';

  build() {
    Column() {
      Row() {
        Text('光电计数统计').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text(this.currentModel).fontColor(Colors.Warning).fontSize(14).fontWeight(FontWeight.Bold)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column({ space: 10 }) {
        Row() {
          Column({ space: 2 }) {
            Text('当前型号累计').fontColor(Colors.TextNormal).fontSize(14)
            Text(`${this.displayCount}`)
              .fontColor(Colors.Title).fontSize(40).fontWeight(FontWeight.Bolder).letterSpacing(2)
          }.alignItems(HorizontalAlign.Start)
          Blank()
          Text('PCS').fontColor(Colors.Cyan).fontSize(14).fontWeight(FontWeight.Bold)
        }.width(Constants.FullWidth).margin({ bottom: 8 })

        // 指令下发控制台
        Row({ space: 10 }) {
          Button('开始').type(ButtonType.Normal).backgroundColor(Colors.Normal).layoutWeight(1).borderRadius(4)
            .onClick(() => MqttManager.getInstance().publishCountControl('start', this.currentModel))
          Button('暂停').type(ButtonType.Normal).backgroundColor(Colors.Warning).layoutWeight(1).borderRadius(4)
            .onClick(() => MqttManager.getInstance().publishCountControl('pause'))
          Button('结束(清零)').type(ButtonType.Normal).backgroundColor(Colors.Danger).layoutWeight(1).borderRadius(4)
            .onClick(() => MqttManager.getInstance().publishCountControl('end'))
        }.width(Constants.FullWidth).margin({ top: 15 })
      }
      .padding({ left: 14, right: 14, top: 12, bottom: 12 }).layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }
}