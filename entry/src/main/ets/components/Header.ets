import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct Header {
  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 1. 绝对居中的主标题
      Text('车间数据监控大屏')
        .fontColor(Colors.Title)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)

      // 2. 靠右侧的系统状态
      Row({ space: 20 }) {
        this.StatusItem('系统状态', '运行中', Colors.Normal)
        this.StatusItem('在线设备', `${MockData.onlineCount}/${MockData.totalCount}`, Colors.Cyan)
        this.StatusItem('实时告警', `${MockData.alarmCount}`, MockData.alarmCount > 0 ? Colors.Warning : Colors.Normal)
        Text(MockData.systemTime)
          .fontColor(Colors.TextNormal)
          .fontSize(16)
      }
      .width(Constants.FullWidth)
      .padding({ right: 24 })
      .justifyContent(FlexAlign.End)
    }
    .width(Constants.FullWidth)
    .height('10%')
    .backgroundColor(Colors.BackgroundSoft)
    .border({ width: { bottom: 1 }, color: Colors.Border })
  }

  @Builder
  StatusItem(label: string, value: string, valueColor: string) {
    Column({ space: 4 }) {
      Text(label).fontColor(Colors.TextMuted).fontSize(12)
      Row({ space: 6 }) {
        Circle({ width: 8, height: 8 }).fill(valueColor)
        Text(value).fontColor(valueColor).fontSize(18).fontWeight(FontWeight.Bold)
      }
    }.alignItems(HorizontalAlign.Start)
  }
}