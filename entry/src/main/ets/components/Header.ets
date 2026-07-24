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
    this.timer = setInterval(() => {
      this.updateTime();
    }, 1000);
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
    Stack({ alignContent: Alignment.Center }) {

      // 中央硬核机甲风标题区
      Row({ space: 15 }) {
        this.TechDecoration(true)
        Text('数据大屏')
          .fontFamily('HarmonyOS Sans')
          .fontColor(Colors.Cyan)
          .fontSize(40)
          .fontWeight(FontWeight.Bolder)
          .letterSpacing(8)
        this.TechDecoration(false)
      }

      // 右侧系统状态区
      Row({ space: 28 }) {
        this.StatusItem('系统状态', '运行中', Colors.Cyan)
        this.StatusItem('在线设备', `${MockData.onlineCount}/${MockData.totalCount}`, Colors.Cyan)
        this.StatusItem('实时告警', `${MockData.alarmCount}`, MockData.alarmCount > 0 ? Colors.Warning : Colors.Normal)

        Text(this.currentTime)
          .fontColor(Colors.Cyan) // 统一时间颜色，融入整体氛围
          .fontSize(16)
          .fontFamily('Courier New')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width(Constants.FullWidth)
      .padding({ right: 32 })
      .justifyContent(FlexAlign.End)
    }
    .width(Constants.FullWidth)
    .height('10%')
    .backgroundColor(Colors.Background) // 使用更深的背景色凸显顶部科技感
    .border({ width: { bottom: 1 }, color: Colors.BorderSoft })
  }

  // 构建两侧对称的科技线条装饰
  @Builder
  TechDecoration(isLeft: boolean) {
    Row() {
      if (isLeft) {
        Text('///').fontColor(Colors.Border).fontSize(20).fontWeight(FontWeight.Bolder).fontStyle(FontStyle.Italic)
        Divider().color(Colors.Cyan).strokeWidth(4).width(60).margin({ left: 8 })
      } else {
        Divider().color(Colors.Cyan).strokeWidth(4).width(60).margin({ right: 8 })
        Text('///').fontColor(Colors.Border).fontSize(20).fontWeight(FontWeight.Bolder).fontStyle(FontStyle.Italic)
      }
    }
  }

  @Builder
  StatusItem(label: string, value: string, valueColor: string) {
    Column({ space: 6 }) {
      Text(label).fontColor(Colors.TextMuted).fontSize(13)
      Row({ space: 8 }) {
        Circle({ width: 8, height: 8 }).fill(valueColor)
        Text(value).fontColor(valueColor).fontSize(18).fontWeight(FontWeight.Bold)
      }
    }.alignItems(HorizontalAlign.Start)
  }
}