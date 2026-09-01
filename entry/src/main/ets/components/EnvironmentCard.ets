// src/main/ets/components/EnvironmentCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct EnvironmentCard {
  @State currentSafeIndex: number = 100;

  // 严格声明为 number 类型，与 GlobalDataCenter 及 JSON 解析结果对齐
  @StorageProp('env_temp') envTemp: number = 26;
  @StorageProp('env_hum') envHum: number = 55;
  @StorageProp('env_mq7_adc') envCo: number = 18;
  @StorageProp('env_mq2_adc') envSmoke: number = 12;

  build() {
    Column() {
      Row() {
        Text('环境安全指标').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column() {
        Stack() {
          Progress({ value: this.currentSafeIndex, total: 100, type: ProgressType.Ring })
            .width(116).height(116).color(Colors.Normal).style({ strokeWidth: 10 })

          Column({ space: 4 }) {
            Text(`${this.currentSafeIndex}`).fontColor(Colors.Title).fontSize(36).fontWeight(FontWeight.Bold)
            Text('安全指数').fontColor(Colors.TextNormal).fontSize(14)
          }
        }.margin({ top: 15, bottom: 15 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          this.MetricItem('温度', `${this.envTemp}℃`, Colors.Cyan)
          this.MetricItem('湿度', `${this.envHum}%RH`, Colors.Normal)
          this.MetricItem('CO 浓度', `${this.envCo} adc`, Colors.Warning)
          this.MetricItem('烟雾浓度', `${this.envSmoke} adc`, Colors.Normal)
        }.width('90%')
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder MetricItem(name: string, value: string, valueColor: string) {
    Column({ space: 4 }) {
      Text(name).fontColor(Colors.TextNormal).fontSize(14)
      Row({ space: 5 }) {
        Circle({ width: 5, height: 5 }).fill(valueColor)
        Text(value).fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
      }
    }.width('48%').margin({ bottom: 14 }).alignItems(HorizontalAlign.Start)
  }
}