import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct FactoryOverviewCard {
  @State hubScale: number = 1.0;

  aboutToAppear() {
    animateTo({ duration: 1500, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
      this.hubScale = 1.15;
    })
  }

  build() {
    Column() {
      Row() {
        Text('03').fontColor(Colors.Cyan).fontSize(16).fontWeight(FontWeight.Bold)
        Text('车间监控拓扑').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 8 })
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Row({ space: 8 }) {
        this.InfoTag('环境感知', '4 ONLINE', Colors.Cyan)
        this.InfoTag('AGV 调度', 'READY', Colors.Normal)
        this.InfoTag('安全链路', 'STABLE', Colors.Normal)
      }
      .width('90%').margin({ top: 16 })

      Column() {
        Row({ space: 0 }) {
          this.TopoNode('环境感知', '01')
          this.TopoLine()
          this.TopoNode('AGV 调度', '02')
          this.TopoLine()
          this.TopoNode('仓储管理', '03')
        }
        .width(Constants.FullWidth).justifyContent(FlexAlign.Center)

        Divider().vertical(true).color(Colors.Cyan).strokeWidth(2).height(34)
        this.CenterHub()
        Divider().vertical(true).color(Colors.Cyan).strokeWidth(2).height(28)

        this.TopoNode('生产控制', '04')
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder
  InfoTag(label: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(label).fontColor(Colors.TextNormal).fontSize(12)
      Text(value).fontColor(color).fontSize(14).fontWeight(FontWeight.Bold)
    }
    .layoutWeight(1).padding({ top: 8, bottom: 8 }).backgroundColor(Colors.BackgroundSoft).border({ width: { left: 2 }, color: color })
  }

  @Builder
  TopoNode(name: string, index: string) {
    Column({ space: 8 }) {
      Stack() {
        Circle({ width: 32, height: 32 }).fill(Colors.BackgroundSoft).stroke(Colors.Cyan).strokeWidth(2)
        Text(index).fontColor(Colors.Cyan).fontSize(12).fontWeight(FontWeight.Bold)
      }
      // 字号从14增大到16
      Text(name).fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
    }
    .width(110).alignItems(HorizontalAlign.Center)
  }

  @Builder
  CenterHub() {
    Stack({ alignContent: Alignment.Center }) {
      Circle({ width: 104, height: 104 }).fill('transparent').stroke(Colors.BorderSoft).strokeWidth(1)
      Circle({ width: 76, height: 76 }).fill(Colors.BackgroundSoft).stroke(Colors.Cyan).strokeWidth(3)
        .scale({ x: this.hubScale, y: this.hubScale })
      // 字号增大到18
      Text('数据中枢').fontColor(Colors.Title).fontSize(18).fontWeight(FontWeight.Bold)
    }
    .width(112).height(112)
  }

  @Builder
  TopoLine() {
    Divider().color(Colors.Cyan).strokeWidth(2).width(60).margin({ bottom: 32 })
  }
}