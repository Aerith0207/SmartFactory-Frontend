// src/main/ets/components/Header.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct Header {
  @State currentTime: string = '';
  private timer: number = -1;

  aboutToAppear() {
    this.updateTime();
    this.timer = setInterval(() => { this.updateTime(); }, 1000);
  }

  aboutToDisappear() {
    if (this.timer !== -1) clearInterval(this.timer);
  }

  updateTime() {
    const now = new Date();
    const y = now.getFullYear();
    const m = (now.getMonth() + 1).toString().padStart(2, '0');
    const d = now.getDate().toString().padStart(2, '0');
    const h = now.getHours().toString().padStart(2, '0');
    const min = now.getMinutes().toString().padStart(2, '0');
    const s = now.getSeconds().toString().padStart(2, '0');
    this.currentTime = `${y}-${m}-${d}  ${h}:${min}:${s}`;
  }

  build() {
    Row() { // 放弃 Stack，改用 Row 弹性布局

      // 左侧机甲风标题
      Row({ space: 12 }) {
        this.TechDecoration(true)
        Text('数据大屏')
          .fontFamily('HarmonyOS Sans')
          .fontColor(Colors.Cyan)
          .fontSize(34) // 略微缩小字号防止拥挤
          .fontWeight(FontWeight.Bolder)
          .letterSpacing(6)
        this.TechDecoration(false)
      }

      Blank() // 核心修改：利用 Blank 自动撑开剩余空间，将右侧推过去

      // 右侧系统状态区
      Row({ space: 24 }) { // 缩小了各项间距
        this.StatusItem('系统状态', '运行中', Colors.Cyan)
        this.StatusItem('在线设备', `${MockData.onlineCount}/${MockData.totalCount}`, Colors.Cyan)
        this.StatusItem('实时告警', `${MockData.alarmCount}`, MockData.alarmCount > 0 ? Colors.Warning : Colors.Normal)

        Text(this.currentTime)
          .fontColor(Colors.Cyan)
          .fontSize(16)
          .fontFamily('Courier New')
          .fontWeight(FontWeight.Bold)
      }
    }
    .width(Constants.FullWidth)
    .height('10%')
    .padding({ left: 24, right: 24 }) // 调整两侧内边距
    .backgroundColor(Colors.Background)
    .border({ width: { bottom: 1 }, color: Colors.BorderSoft })
  }

  @Builder
  TechDecoration(isLeft: boolean) {
    Row() {
      if (isLeft) {
        Text('///').fontColor(Colors.Border).fontSize(18).fontWeight(FontWeight.Bolder).fontStyle(FontStyle.Italic)
        Divider().color(Colors.Cyan).strokeWidth(4).width(40).margin({ left: 8 })
      } else {
        Divider().color(Colors.Cyan).strokeWidth(4).width(40).margin({ right: 8 })
        Text('///').fontColor(Colors.Border).fontSize(18).fontWeight(FontWeight.Bolder).fontStyle(FontStyle.Italic)
      }
    }
  }

  @Builder
  StatusItem(label: string, value: string, valueColor: string) {
    Column({ space: 4 }) {
      Text(label).fontColor(Colors.TextMuted).fontSize(12)
      Row({ space: 6 }) {
        Circle({ width: 8, height: 8 }).fill(valueColor)
        Text(value).fontColor(valueColor).fontSize(16).fontWeight(FontWeight.Bold)
      }
    }.alignItems(HorizontalAlign.Start)
  }
}