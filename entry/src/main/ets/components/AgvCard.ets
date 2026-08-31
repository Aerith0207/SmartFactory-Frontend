// src/main/ets/components/AgvCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
struct DistanceItem {
  @Prop label: string;
  @Prop value: string;
  @Prop dirText: string; // 🌟 修复：将冲突的 direction 改名为 dirText
  @Prop valueColor: string;

  build() {
    Column({ space: 4 }) {
      Text(this.label).fontColor(Colors.TextNormal).fontSize(13)
      Text(this.value).fontColor(this.valueColor).fontSize(20).fontWeight(FontWeight.Bold)
      Text(this.dirText).fontColor(Colors.Cyan).fontSize(20).lineHeight(22) // 🌟 对应修改
    }
    .width(80).alignItems(HorizontalAlign.Center).margin({ top: 4, bottom: 4 })
  }
}

@Component
export struct AgvCard {
  @State radarScale: number = 1.0;
  @State radarOpacity: number = 0.8;

  @StorageProp('agv_radar_front') agvFront: string = '120';
  @StorageProp('agv_radar_left') agvLeft: string = '80';
  @StorageProp('agv_radar_right') agvRight: string = '65';
  @StorageProp('agv_radar_back') agvBack: string = '100';

  aboutToAppear() {
    animateTo({ duration: 2000, curve: Curve.EaseOut, iterations: -1 }, () => {
      this.radarScale = 1.6;
      this.radarOpacity = 0.0;
    })
  }

  build() {
    Column() {
      Row() {
        Text('AGV 空间雷达').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 8 })
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column() {
        // 🌟 对应修改：传入参数名从 direction 改为 dirText
        DistanceItem({ label: '前方', value: `${this.agvFront} cm`, dirText: '↑', valueColor: Colors.Cyan })

        Row({ space: 15 }) {
          DistanceItem({ label: '左侧', value: `${this.agvLeft} cm`, dirText: '←', valueColor: Colors.Normal })

          Stack() {
            Circle({ width: 86, height: 86 }).fill('transparent').stroke(Colors.Cyan).strokeWidth(2)
              .scale({ x: this.radarScale, y: this.radarScale }).opacity(this.radarOpacity)
            Circle({ width: 86, height: 86 }).fill(Colors.BackgroundSoft).stroke(Colors.Cyan).strokeWidth(2)
            Circle({ width: 60, height: 60 }).fill('transparent').stroke(Colors.BorderSoft).strokeWidth(1)
              .shadow({ radius: 8, color: Colors.Cyan, offsetX: 0, offsetY: 0 })
            Text('AGV').fontColor(Colors.Title).fontSize(17).fontWeight(FontWeight.Bold)
          }

          DistanceItem({ label: '右侧', value: `${this.agvRight} cm`, dirText: '→', valueColor: Colors.Warning })
        }
        .width(Constants.FullWidth).justifyContent(FlexAlign.Center)

        DistanceItem({ label: '后方', value: `${this.agvBack} cm`, dirText: '↓', valueColor: Colors.Cyan })
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }
}