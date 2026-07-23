import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct EnvironmentCard {
  build() {
    Column() {
      Row() {
        Text('02').fontColor(Colors.Cyan).fontSize(16).fontWeight(FontWeight.Bold)
        Text('环境安全指标').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 8 })
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column() {
        Stack() {
          // 替换为 Progress 组件，精确控制线条粗细
          Progress({ value: MockData.safeIndex, total: 100, type: ProgressType.Ring })
            .width(116)
            .height(116)
            .color(Colors.Normal)
            .style({ strokeWidth: 10 })

          Column({ space: 4 }) {
            Text(`${MockData.safeIndex}`)
              .fontColor(Colors.Title) // 改为白色，解决看不清的问题
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
            Text('安全指数')
              .fontColor(Colors.TextNormal)
              .fontSize(14)
          }
        }
        .margin({ top: 15, bottom: 15 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          this.MetricItem('温度', `${MockData.temperature}℃`, Colors.Cyan)
          this.MetricItem('湿度', `${MockData.humidity}%RH`, Colors.Normal)
          this.MetricItem('CO 浓度', `${MockData.co} ppm`, Colors.Warning)
          this.MetricItem('烟雾浓度', `${MockData.smoke}%`, Colors.Normal)
        }
        .width('90%')
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder
  MetricItem(name: string, value: string, valueColor: string) {
    Column({ space: 4 }) {
      Text(name).fontColor(Colors.TextNormal).fontSize(14)
      Row({ space: 5 }) {
        Circle({ width: 5, height: 5 }).fill(valueColor)
        Text(value).fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
      }
    }.width('48%').margin({ bottom: 14 }).alignItems(HorizontalAlign.Start)
  }
}