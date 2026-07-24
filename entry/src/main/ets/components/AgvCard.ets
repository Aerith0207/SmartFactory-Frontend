// src/main/ets/components/AgvCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct AgvCard {
  @State radarScale: number = 1.0;
  @State radarOpacity: number = 0.8;

  // 新增：注入全局单向绑定变量，接管 AGV 雷达数据
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
        // 修改点：使用全局绑定的 agvFront 替换 MockData
        this.DistanceItem('前方', `${this.agvFront} cm`, '↑', Colors.Cyan)

        Row({ space: 15 }) {
          // 修改点：使用全局绑定的 agvLeft
          this.DistanceItem('左侧', `${this.agvLeft} cm`, '←', Colors.Normal)

          Stack() {
            // 外层扩散雷达波
            Circle({ width: 86, height: 86 }).fill('transparent').stroke(Colors.Cyan).strokeWidth(2)
              .scale({ x: this.radarScale, y: this.radarScale }).opacity(this.radarOpacity)

            // 中间固定环
            Circle({ width: 86, height: 86 }).fill(Colors.BackgroundSoft).stroke(Colors.Cyan).strokeWidth(2)

            // 内层AGV实体圈 (新增微发光)
            Circle({ width: 60, height: 60 }).fill('transparent').stroke(Colors.BorderSoft).strokeWidth(1)
              .shadow({ radius: 8, color: Colors.Cyan, offsetX: 0, offsetY: 0 })

            Text('AGV').fontColor(Colors.Title).fontSize(17).fontWeight(FontWeight.Bold)
          }

          // 修改点：使用全局绑定的 agvRight
          this.DistanceItem('右侧', `${this.agvRight} cm`, '→', Colors.Warning)
        }
        .width(Constants.FullWidth).justifyContent(FlexAlign.Center)

        // 修改点：使用全局绑定的 agvBack
        this.DistanceItem('后方', `${this.agvBack} cm`, '↓', Colors.Cyan)
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
      Text(direction).fontColor(Colors.Cyan).fontSize(20).lineHeight(22)
    }
    .width(80).alignItems(HorizontalAlign.Center).margin({ top: 4, bottom: 4 })
  }
}