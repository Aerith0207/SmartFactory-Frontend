// src/main/ets/components/TrendChart.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct TrendChart {
  @State chartOpacity: number = 0;

  aboutToAppear() {
    setTimeout(() => {
      animateTo({ duration: 1000, curve: Curve.EaseOut }, () => {
        this.chartOpacity = 1;
      });
    }, 300);
  }

  build() {
    Column() {
      Row() {
        Text('环境数据趋势').fontColor(Colors.Title).fontSize(21).fontWeight(FontWeight.Bold)
        Blank()
        Row({ space: 12 }) {
          this.Legend('温度(℃)', Colors.Cyan)
          this.Legend('湿度(%RH)', Colors.Normal)
          this.Legend('危气(ppm)', Colors.Warning)
        }
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      // 图表核心区域：左Y轴 + 图表 + 右Y轴
      Row() {
        // 左侧 Y 轴 (温湿度刻度)
        Column({ space: 0 }) {
          Text('100').fontColor(Colors.TextMuted).fontSize(10)
          Text('75').fontColor(Colors.TextMuted).fontSize(10)
          Text('50').fontColor(Colors.TextMuted).fontSize(10)
          Text('25').fontColor(Colors.TextMuted).fontSize(10)
          Text('0').fontColor(Colors.TextMuted).fontSize(10)
        }
        .height('70%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 25, right: 8 })

        // 核心图表区
        Stack({ alignContent: Alignment.Bottom }) {
          // 背景参考线
          Column({ space: 24 }) {
            Divider().color(Colors.BorderSoft).opacity(0.4)
            Divider().color(Colors.BorderSoft).opacity(0.4)
            Divider().color(Colors.BorderSoft).opacity(0.4)
            Divider().color(Colors.BorderSoft).opacity(0.4)
          }.width('100%').height('70%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 25 })

          // 危气浓度的底端柱状图
          Row({ space: 30 }) {
            this.BarGroup(40, 20)
            this.BarGroup(60, 30)
            this.BarGroup(35, 50)
            this.BarGroup(80, 25)
            this.BarGroup(50, 40)
            this.BarGroup(30, 20)
            this.BarGroup(45, 35)
          }
          .width('100%').height('70%')
          .alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 25 })
          .opacity(this.chartOpacity)

          // 温湿度折线图
          Stack() {
            Polyline().width('100%').height('100%').points([[0, 72], [45, 60], [90, 68], [135, 42], [180, 52], [225, 26], [270, 38]]).fill('none').stroke(Colors.Cyan).strokeWidth(3)
            Polyline().width('100%').height('100%').points([[0, 28], [45, 38], [90, 18], [135, 50], [180, 42], [225, 72], [270, 58]]).fill('none').stroke(Colors.Normal).strokeWidth(3)
          }
          .width('100%').height('70%').margin({ bottom: 25 }).opacity(this.chartOpacity)

          // X轴时间坐标
          Row() {
            Text('08:00').fontColor(Colors.TextMuted).fontSize(11)
            Text('10:00').fontColor(Colors.TextMuted).fontSize(11)
            Text('12:00').fontColor(Colors.TextMuted).fontSize(11)
            Text('14:00').fontColor(Colors.TextMuted).fontSize(11)
            Text('16:00').fontColor(Colors.TextMuted).fontSize(11)
            Text('18:00').fontColor(Colors.TextMuted).fontSize(11)
            Text('20:00').fontColor(Colors.TextMuted).fontSize(11)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)

        }
        .layoutWeight(1)
        .height(Constants.FullHeight)

        // 右侧 Y 轴 (浓度刻度)
        Column({ space: 0 }) {
          Text('1.0').fontColor(Colors.TextMuted).fontSize(10)
          Text('0.8').fontColor(Colors.TextMuted).fontSize(10)
          Text('0.5').fontColor(Colors.TextMuted).fontSize(10)
          Text('0.2').fontColor(Colors.TextMuted).fontSize(10)
          Text('0.0').fontColor(Colors.TextMuted).fontSize(10)
        }
        .height('70%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 25, left: 8 })

      }
      .layoutWeight(1)
      .width(Constants.FullWidth)
      .padding({ left: 15, right: 15, bottom: 10, top: 15 })
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder
  Legend(label: string, color: string) {
    Row({ space: 4 }) {
      Circle({ width: 6, height: 6 }).fill(color)
      Text(label).fontColor(Colors.TextNormal).fontSize(12)
    }
  }

  @Builder
  BarGroup(coHeight: number, smokeHeight: number) {
    Row({ space: 4 }) {
      Rect({ width: 6, height: `${coHeight}%` }).fill(Colors.Warning).radius(2)
      Rect({ width: 6, height: `${smokeHeight}%` }).fill(Colors.Border).radius(2)
    }.height('100%').alignItems(VerticalAlign.Bottom)
  }
}