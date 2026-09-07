// src/main/ets/components/AlarmCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { SafetyEvent } from '../utils/SafetySimulationManager';

@Component
export struct AlarmCard {
  @StorageProp('env_mq2_alarm') mq2Alarm: number = 0;
  @StorageProp('env_mq7_alarm') mq7Alarm: number = 0;
  @StorageProp('safety_events') safetyEvents: SafetyEvent[] = [];
  @State warningOpacity: number = 1;

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 800, curve: Curve.EaseInOut }, () => {
        this.warningOpacity = this.warningOpacity === 1 ? 0.3 : 1;
      });
    }, 1000);
  }

  build() {
    Column() {
      Row() {
        Text('安全事件记录').fontColor(Colors.Title).fontSize(21).fontWeight(FontWeight.Bold).margin({ left: 8 })
        Blank()
        Text('ALERT LOG').fontColor(Colors.TextMuted).fontSize(11)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      // 依据硬件标志位实时渲染报警 UI
      List({ space: 7 }) {
        if (this.GetSimulationEvents().length > 0) {
          ForEach(this.GetSimulationEvents(), (event: SafetyEvent) => {
            this.SimulationAlarmItem(event)
          })
        } else {
          if (this.mq2Alarm === 1) {
            this.AlarmItemUI('烟雾浓度超标', '紧急告警', false)
          }
          if (this.mq7Alarm === 1) {
            this.AlarmItemUI('CO 浓度超界', '危险', false)
          }
          if (this.mq2Alarm === 0 && this.mq7Alarm === 0) {
            this.AlarmItemUI('车间环境正常', '巡检通过', true)
          }
        }
      }.width(Constants.FullWidth).layoutWeight(1).padding({ left: 12, right: 12, top: 12, bottom: 12 })
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  private GetSimulationEvents(): SafetyEvent[] {
    return this.safetyEvents.slice(0, 3);
  }

  private GetSafetyColor(level: number): string {
    if (level === 0) return Colors.Normal;
    if (level === 1) return Colors.Warning;
    if (level === 2) return Colors.Alarm;
    return Colors.Danger;
  }

  @Builder SimulationAlarmItem(event: SafetyEvent) {
    ListItem() {
      Column({ space: 3 }) {
        Row() {
          Text(event.title).fontColor(this.GetSafetyColor(event.level)).fontSize(15).fontWeight(FontWeight.Bold)
          Blank()
          Text(event.time).fontColor(Colors.TextMuted).fontSize(12).fontFamily('Courier New')
          Text(event.status).fontColor(this.GetSafetyColor(event.level)).fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 8 })
        }.width(Constants.FullWidth)
        Text(`采取措施：${event.action}`).fontColor(Colors.TextNormal).fontSize(13).maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width(Constants.FullWidth).padding({ left: 10, right: 10, top: 7, bottom: 7 })
      .backgroundColor(Colors.BackgroundSoft)
      .border({ width: { left: 3 }, color: this.GetSafetyColor(event.level) })
      .borderRadius(4)
      .opacity(event.level === 0 ? 1 : this.warningOpacity)
    }
  }

  @Builder AlarmItemUI(content: string, status: string, isResolved: boolean) {
    ListItem() {
      Row() {
        Text(content).width('50%').fontColor(isResolved ? Colors.TextNormal : Colors.Danger).fontSize(13)
        Text(status).width('50%').fontColor(isResolved ? Colors.Normal : Colors.Danger).fontSize(13).textAlign(TextAlign.End)
      }
      .width(Constants.FullWidth).height(34).padding({ left: 10, right: 10 })
      .backgroundColor(isResolved ? Colors.BackgroundSoft : '#1AFFF5E5')
      .opacity(isResolved ? 1 : this.warningOpacity)
      .borderRadius(4)
    }
  }
}
