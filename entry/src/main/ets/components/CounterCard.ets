// src/main/ets/components/CounterCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct CounterCard {
  // 定义用于显示的动态数字
  @State displayCount: number = 0;
  private targetCount: number = MockData.todayCount;
  private timer: number = -1;

  aboutToAppear() {
    // 实现数字快速滚动的加载动画
    let step = Math.ceil(this.targetCount / 30); // 分30次递增完
    this.timer = setInterval(() => {
      if (this.displayCount + step >= this.targetCount) {
        this.displayCount = this.targetCount;
        clearInterval(this.timer);
      } else {
        this.displayCount += step;
      }
    }, 30); // 每30ms更新一次
  }

  aboutToDisappear() {
    // 组件销毁时清理定时器，防止内存泄漏
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  build() {
    Column() {
      Row() {
        Text('04').fontColor(Colors.Cyan).fontSize(15).fontWeight(FontWeight.Bold)
        Text('光电计数统计').fontColor(Colors.Title).fontSize(21).fontWeight(FontWeight.Bold).margin({ left: 8 })
        Blank()
        Text('TODAY').fontColor(Colors.TextMuted).fontSize(11)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column({ space: 10 }) {
        Row() {
          Column({ space: 2 }) {
            Text('今日通过总数').fontColor(Colors.TextNormal).fontSize(14)
            // 绑定动态显示的数字
            Text(`${this.displayCount}`).fontColor(Colors.Title).fontSize(36).fontWeight(FontWeight.Bold)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text('PCS').fontColor(Colors.Cyan).fontSize(14).fontWeight(FontWeight.Bold)
        }
        .width(Constants.FullWidth)

        this.BarItem('A 类物料', 152, 200, Colors.Cyan)
        this.BarItem('B 类物料', 181, 200, Colors.Warning)
        this.BarItem('C 类物料', 125, 200, Colors.Normal)
      }
      .padding({ left: 14, right: 14, top: 12, bottom: 12 }).layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder
  BarItem(name: string, value: number, max: number, barColor: string) {
    Column({ space: 5 }) {
      Row() {
        Text(name).fontColor(Colors.TextNormal).fontSize(14)
        Blank()
        Text(`${value}`).fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
      }
      .width(Constants.FullWidth)
      Progress({ value: value, total: max, type: ProgressType.Linear })
        .width(Constants.FullWidth).height(6).color(barColor).backgroundColor(Colors.BackgroundSoft)
    }
    .width(Constants.FullWidth)
  }
}