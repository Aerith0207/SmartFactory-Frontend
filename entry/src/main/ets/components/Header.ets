import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct Header {
  // 1. 定义一个状态变量，用于控制呼吸灯的透明度
  @State blinkOpacity: number = 1;

  aboutToAppear() {
    // 2. 组件加载时启动定时器，实现呼吸动效
    setInterval(() => {
      // 使用 easeInOut 曲线让透明度在 0.3 和 1 之间平滑过渡
      animateTo({ duration: 800, curve: Curve.EaseInOut }, () => {
        this.blinkOpacity = this.blinkOpacity === 1 ? 0.3 : 1;
      })
    }, 1000);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 主标题区
      Text('车间数据监控大屏')
        .fontColor(Colors.Title)
        .fontSize(38) // 稍微放大字号
        .fontWeight(FontWeight.Bolder)
        .letterSpacing(6) // 增加字间距，提升大屏的宽阔感
        .shadow({ radius: 4, color: Colors.Cyan, offsetX: 0, offsetY: 0 }) // 尝试添加微弱的发光投影

      // 系统状态区
      Row({ space: 28 }) { // 拉大各项之间的间距
        // 传入 true 开启呼吸动效
        this.StatusItem('系统状态', '运行中', Colors.Cyan, true)
        this.StatusItem('在线设备', `${MockData.onlineCount}/${MockData.totalCount}`, Colors.Cyan, false)
        // 如果有告警，让告警红灯也闪烁起来
        this.StatusItem('实时告警', `${MockData.alarmCount}`, MockData.alarmCount > 0 ? Colors.Warning : Colors.Normal, MockData.alarmCount > 0)

        Text(MockData.systemTime)
          .fontColor(Colors.TextNormal)
          .fontSize(18)
          .fontFamily('Courier New') // 时间使用等宽字体更有数字感
          .margin({ left: 12 })
      }
      .width(Constants.FullWidth)
      .padding({ right: 32 })
      .justifyContent(FlexAlign.End)
    }
    .width(Constants.FullWidth)
    .height('10%')
    .backgroundColor(Colors.BackgroundSoft)
    .border({
      width: { bottom: 2 },
      color: Colors.Cyan // 使用青色作为底边框，模拟科技氛围
    })
  }

  // 3. 改造 Builder，增加 isAnimated 参数
  @Builder
  StatusItem(label: string, value: string, valueColor: string, isAnimated: boolean = false) {
    Column({ space: 6 }) {
      Text(label)
        .fontColor(Colors.TextMuted)
        .fontSize(14)
      Row({ space: 8 }) {
        Circle({ width: 10, height: 10 })
          .fill(valueColor)
          .opacity(isAnimated ? this.blinkOpacity : 1) // 动态绑定透明度
        Text(value)
          .fontColor(valueColor)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
    }.alignItems(HorizontalAlign.Start)
  }
}