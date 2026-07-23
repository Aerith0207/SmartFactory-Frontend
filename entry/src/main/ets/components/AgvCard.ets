import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct AgvCard {
  @State radarScale: number = 1.0;
  @State radarOpacity: number = 0.8;

  aboutToAppear() {
    animateTo({ duration: 2000, curve: Curve.EaseOut, iterations: -1 }, () => {
      this.radarScale = 1.6;
      this.radarOpacity = 0.0;
    })
  }

  build() {
    Column() {
      Row() {
        Text('05').fontColor(Colors.Cyan).fontSize(16).fontWeight(FontWeight.Bold)
        Text('AGV 空间雷达').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 8 })
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column() {
        this.DistanceItem('前方', `${MockData.agv.front} cm`, '↑', Colors.Cyan)
        Row({ space: 15 }) {
          this.DistanceItem('左侧', `${MockData.agv.left} cm`, '←', Colors.Normal)
          Stack() {
            Circle({ width: 86, height: 86 }).fill('transparent').stroke(Colors.Cyan).strokeWidth(2)
              .scale({ x: this.radarScale, y: this.radarScale }).opacity(this.radarOpacity)
            Circle({ width: 86, height: 86 }).fill(Colors.BackgroundSoft).stroke(Colors.Cyan).strokeWidth(2)
            Circle({ width: 60, height: 60 }).fill('transparent').stroke(Colors.BorderSoft).strokeWidth(1)
            Text('AGV').fontColor(Colors.Title).fontSize(17).fontWeight(FontWeight.Bold)
          }
          this.DistanceItem('右侧', `${MockData.agv.right} cm`, '→', Colors.Warning)
        }
        .width(Constants.FullWidth).justifyContent(FlexAlign.Center)
        this.DistanceItem('后方', `${MockData.agv.back} cm`, '↓', Colors.Cyan)
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder
  DistanceItem(label: string, value: string, direction: string, valueColor: string) {
    Column({ space: 4 }) {
      Text(label).fontColor(Colors.TextNormal).fontSize(13)
      Text(value).fontColor(valueColor).fontSize(20).fontWeight(FontWeight.Bold)
      // 增加行高并微调字号，防止特殊字符被截断
      Text(direction).fontColor(Colors.Cyan).fontSize(20).lineHeight(22)
    }
    .width(80).alignItems(HorizontalAlign.Center).margin({ top: 4, bottom: 4 })
  }
}