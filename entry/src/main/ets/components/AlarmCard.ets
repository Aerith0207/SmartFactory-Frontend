// src/main/ets/components/AlarmCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

interface AlarmItem {
  time: string;
  content: string;
  status: string;
  isResolved: boolean;
}

@Component
export struct AlarmCard {
  @State alarmList: AlarmItem[] = [
    { time: '14:21', content: 'CO 浓度超限', status: '已恢复', isResolved: true },
    { time: '15:05', content: 'AGV 避障触发', status: '处理中', isResolved: false },
    { time: '15:12', content: '烟雾预警', status: '已恢复', isResolved: true }
  ];

  // 新增：告警呼吸灯的透明度状态
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
        Text('06')
          .fontColor(Colors.Cyan)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
        Text('安全事件记录')
          .fontColor(Colors.Title)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
        Blank()
        Text('ALERT LOG')
          .fontColor(Colors.TextMuted)
          .fontSize(11)
      }
      .width(Constants.FullWidth)
      .padding(Constants.DefaultPadding)
      .border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Row() {
        Text('时间').width('25%').fontColor(Colors.TextMuted).fontSize(12)
        Text('事件').width('45%').fontColor(Colors.TextMuted).fontSize(12)
        Text('状态').width('30%').fontColor(Colors.TextMuted).fontSize(12).textAlign(TextAlign.End)
      }
      .width(Constants.FullWidth)
      .padding({ left: 14, right: 14, top: 10, bottom: 4 })

      List({ space: 7 }) {
        ForEach(this.alarmList, (item: AlarmItem) => {
          ListItem() {
            Row() {
              Text(item.time).width('25%').fontColor(Colors.TextNormal).fontSize(13)
              Text(item.content)
                .width('45%')
                .fontColor(item.isResolved ? Colors.TextNormal : Colors.Danger) // 异常内容直接标红
                .fontSize(13)
              Text(item.status)
                .width('30%')
                .fontColor(item.isResolved ? Colors.Normal : Colors.Danger)
                .fontSize(13)
                .textAlign(TextAlign.End)
            }
            .width(Constants.FullWidth)
            .height(34)
            .padding({ left: 10, right: 10 })
            // 正常条目背景为软背景，未处理异常条目背景微红并增加呼吸效果
            .backgroundColor(item.isResolved ? Colors.BackgroundSoft : '#1AFFF5E5')
            .opacity(item.isResolved ? 1 : this.warningOpacity)
            .borderRadius(4)
          }
        })
      }
      .width(Constants.FullWidth)
      .layoutWeight(1)
      .padding({ left: 12, right: 12, bottom: 12 })
    }
    .width(Constants.FullWidth)
    .height(Constants.FullHeight)
    .backgroundColor(Colors.PanelBg)
    .borderRadius(Constants.CardRadius)
    .border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }
}