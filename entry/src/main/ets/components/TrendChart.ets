import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct TrendChart {
  build() {
    Column() {
      Row() {
        Text('07')
          .fontColor(Colors.Cyan)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
        Text('环境数据趋势')
          .fontColor(Colors.Title)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
        Blank()
        Row({ space: 8 }) {
          this.Legend('温度', Colors.Cyan)
          this.Legend('湿度', Colors.Normal)
        }
      }
      .width(Constants.FullWidth)
      .padding(Constants.DefaultPadding)
      .border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 24 }) {
          Divider().color(Colors.BorderSoft).opacity(0.6)
          Divider().color(Colors.BorderSoft).opacity(0.6)
          Divider().color(Colors.BorderSoft).opacity(0.6)
        }
        .width('90%')
        .height('72%')
        .justifyContent(FlexAlign.SpaceBetween)

        Polyline()
          .width('90%')
          .height('72%')
          .points([[0, 72], [50, 60], [100, 68], [150, 42], [200, 52], [250, 26], [300, 38]])
          .fill('none')
          .stroke(Colors.Cyan)
          .strokeWidth(3)

        Polyline()
          .width('90%')
          .height('72%')
          .points([[0, 28], [50, 38], [100, 18], [150, 50], [200, 42], [250, 72], [300, 58]])
          .fill('none')
          .stroke(Colors.Normal)
          .strokeWidth(3)
      }
      .layoutWeight(1)
      .width(Constants.FullWidth)
      .padding({ bottom: 4 })
    }
    .width(Constants.FullWidth)
    .height(Constants.FullHeight)
    .backgroundColor(Colors.PanelBg)
    .borderRadius(Constants.CardRadius)
    .border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder
  Legend(label: string, color: string) {
    Row({ space: 4 }) {
      Circle({ width: 6, height: 6 }).fill(color)
      Text(label).fontColor(Colors.TextNormal).fontSize(12)
    }
  }
}
