// src/main/ets/components/FactoryOverviewCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct FactoryOverviewCard {
  @State hubScale: number = 1.0;
  @State lineOpacity: number = 0.3;
  @StorageProp('safety_level') safetyLevel: number = 0;
  @StorageProp('agv_running') agvRunning: boolean = true;

  aboutToAppear() {
    animateTo({ duration: 1500, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
      this.hubScale = 1.15;
    })

    animateTo({ duration: 800, curve: Curve.Linear, iterations: -1, playMode: PlayMode.Alternate }, () => {
      this.lineOpacity = 1.0;
    })
  }

  build() {
    Column() {
      Row() {
        Text('车间监控拓扑').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 8 })
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Row({ space: 8 }) {
        this.InfoTag(0)
        this.InfoTag(1)
        this.InfoTag(2)
      }
      .width('90%').margin({ top: 16 })

      Column() {
        Row({ space: 0 }) {
          this.TopoNode(0, '01')
          this.TopoLine()
          this.TopoNode(1, '02')
          this.TopoLine()
          this.TopoNode(2, '03')
        }
        .width(Constants.FullWidth).justifyContent(FlexAlign.Center)

        Divider().vertical(true).color(this.GetTopologyColor()).strokeWidth(2).height(34)
          .opacity(this.lineOpacity)
        this.CenterHub()
        Divider().vertical(true).color(this.GetTopologyColor()).strokeWidth(2).height(28)
          .opacity(this.lineOpacity)

        this.TopoNode(3, '04')
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  GetTopologyColor(): string {
    if (this.safetyLevel === 0) return Colors.Cyan;
    if (this.safetyLevel === 1) return Colors.Warning;
    if (this.safetyLevel === 2) return Colors.Alarm;
    return Colors.Danger;
  }

  GetEnvironmentStatus(): string {
    if (this.safetyLevel === 1) return 'SINGLE WARN';
    if (this.safetyLevel === 2) return 'DUAL ALARM';
    if (this.safetyLevel === 3) return 'RISING';
    return '4 ONLINE';
  }

  GetSafetyStatus(): string {
    if (this.safetyLevel === 1) return 'CAUTION';
    if (this.safetyLevel === 2) return 'ALARM';
    if (this.safetyLevel === 3) return 'CRITICAL';
    return 'STABLE';
  }

  GetAgvStatus(): string {
    if (this.safetyLevel === 1) return 'MONITORING';
    if (this.safetyLevel === 2) return 'STANDBY';
    if (this.safetyLevel === 3 || !this.agvRunning) return 'STOPPED';
    return 'READY';
  }

  GetAgvStatusColor(): string {
    if (this.safetyLevel === 0 && this.agvRunning) return Colors.Normal;
    return this.GetTopologyColor();
  }

  GetAgvNodeTitle(): string {
    if (this.safetyLevel === 1) return 'AGV 监控';
    if (this.safetyLevel === 2) return 'AGV 待命';
    if (this.safetyLevel === 3 || !this.agvRunning) return 'AGV 停摆';
    return 'AGV 调度';
  }

  GetInfoLabel(infoType: number): string {
    if (infoType === 0) return '环境感知';
    if (infoType === 1) return 'AGV 调度';
    return '安全链路';
  }

  GetInfoValue(infoType: number): string {
    if (infoType === 0) return this.GetEnvironmentStatus();
    if (infoType === 1) return this.GetAgvStatus();
    return this.GetSafetyStatus();
  }

  GetInfoColor(infoType: number): string {
    if (infoType === 1) return this.GetAgvStatusColor();
    return this.GetTopologyColor();
  }

  GetTopoNodeTitle(nodeType: number): string {
    if (nodeType === 0) return this.safetyLevel > 0 ? '环境告警' : '环境感知';
    if (nodeType === 1) return this.GetAgvNodeTitle();
    if (nodeType === 2) return this.safetyLevel >= 2 ? '仓储联动' : '仓储管理';
    return this.safetyLevel >= 2 ? '生产联动' : '生产控制';
  }

  @Builder
  InfoTag(infoType: number) {
    Column({ space: 4 }) {
      Text(this.GetInfoLabel(infoType)).fontColor(Colors.TextNormal).fontSize(12)
      Text(this.GetInfoValue(infoType)).fontColor(this.GetInfoColor(infoType)).fontSize(14).fontWeight(FontWeight.Bold)
    }
    .layoutWeight(1).padding({ top: 8, bottom: 8 }).backgroundColor(Colors.BackgroundSoft)
    .border({ width: { left: 2 }, color: this.GetInfoColor(infoType) })
  }

  @Builder
  TopoNode(nodeType: number, index: string) {
    Column({ space: 8 }) {
      Stack() {
        // ✨ 修改点 1：用 Stack + borderRadius 替代 Circle，消除方形阴影
        Stack()
          .width(32).height(32).borderRadius(16)
          .backgroundColor(Colors.BackgroundSoft)
          .border({ width: 2, color: this.GetTopologyColor() })
          .shadow({ radius: 4, color: this.GetTopologyColor(), offsetX: 0, offsetY: 0 }) // 柔和的微光

        Text(index).fontColor(this.GetTopologyColor()).fontSize(12).fontWeight(FontWeight.Bold)
      }
      Text(this.GetTopoNodeTitle(nodeType)).fontColor(this.GetTopologyColor()).fontSize(16).fontWeight(FontWeight.Bold)
    }
    .width(110).alignItems(HorizontalAlign.Center)
  }

  @Builder
  CenterHub() {
    Stack({ alignContent: Alignment.Center }) {
      Circle({ width: 104, height: 104 }).fill('transparent').stroke(Colors.BorderSoft).strokeWidth(1)

      // ✨ 修改点 2：同样用 Stack 替代 Circle，并减小发光 radius
      Stack()
        .width(76).height(76).borderRadius(38)
        .backgroundColor(Colors.BackgroundSoft)
        .border({ width: 3, color: this.GetTopologyColor() })
        .scale({ x: this.hubScale, y: this.hubScale })
        .shadow({ radius: 8, color: this.GetTopologyColor(), offsetX: 0, offsetY: 0 }) // 半径从 25 减小到 8

      Text(this.GetHubTitle()).fontColor(this.GetTopologyColor()).fontSize(18).fontWeight(FontWeight.Bold)
    }
    .width(112).height(112)
  }

  @Builder
  TopoLine() {
    Divider().color(this.GetTopologyColor()).strokeWidth(2).width(60).margin({ bottom: 32 })
      .opacity(this.lineOpacity)
      .shadow({ radius: 6, color: this.GetTopologyColor(), offsetX: 0, offsetY: 0 })
  }

  GetHubTitle(): string {
    if (this.safetyLevel === 1) return '安全预警';
    if (this.safetyLevel === 2) return '告警联动';
    if (this.safetyLevel === 3) return '严重告警';
    return '数据中枢';
  }
}
