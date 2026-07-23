// src/main/ets/components/TrendChart.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct TrendChart {
  // 新增：控制图表进场透明度
  @State chartOpacity: number = 0;

  aboutToAppear() {
    // 页面加载时的渐显动画
    setTimeout(() => {
      animateTo({ duration: 1500, curve: Curve.EaseOut }, () => {
        this.chartOpacity = 1;
      });
    }, 300);
  }

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
          this.Legend('温度', Colors.Cyan) // 维持温度图例[cite: 8]
          this.Legend('湿度', Colors.Normal) // 维持湿度图例[cite: 8]
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

        // 温度折线[cite: 8]
        Polyline()
          .width('90%')
          .height('72%')
          .points([[0, 72], [50, 60], [100, 68], [150, 42], [200, 52], [250, 26], [300, 38]])
          .fill('none')
          .stroke(Colors.Cyan)
          .strokeWidth(3)
          .shadow({ radius: 8, color: Colors.Cyan, offsetX: 0, offsetY: 0 }) // 添加青色荧光
          .opacity(this.chartOpacity)

        // 湿度折线[cite: 8]
        Polyline()
          .width('90%')
          .height('72%')
          .points([[0, 28], [50, 38], [100, 18], [150, 50], [200, 42], [250, 72], [300, 58]])
          .fill('none')
          .stroke(Colors.Normal)
          .strokeWidth(3)
          .shadow({ radius: 8, color: Colors.Normal, offsetX: 0, offsetY: 0 }) // 添加绿色荧光
          .opacity(this.chartOpacity)
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