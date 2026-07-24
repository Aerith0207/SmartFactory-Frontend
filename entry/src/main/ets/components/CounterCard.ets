// src/main/ets/components/CounterCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct CounterCard {
  @State displayCount: number = 0;
  private targetCount: number = MockData.todayCount;
  private timer: number = -1;

  aboutToAppear() {
    let step = Math.ceil(this.targetCount / 30);
    this.timer = setInterval(() => {
      if (this.displayCount + step >= this.targetCount) {
        this.displayCount = this.targetCount;
        clearInterval(this.timer);
      } else {
        this.displayCount += step;
      }
    }, 30);
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  build() {
    Column() {
      Row() {
        Text('光电计数统计').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text('TODAY').fontColor(Colors.TextMuted).fontSize(11)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column({ space: 10 }) {
        Row() {
          Column({ space: 2 }) {
            Text('今日通过总数').fontColor(Colors.TextNormal).fontSize(14)
            // 新增：给大数字加上科技感投影和间距
            Text(`${this.displayCount}`)
              .fontColor(Colors.Title)
              .fontSize(40)
              .fontWeight(FontWeight.Bolder)
              .letterSpacing(2)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text('PCS').fontColor(Colors.Cyan).fontSize(14).fontWeight(FontWeight.Bold)
        }
        .width(Constants.FullWidth)
        .margin({ bottom: 8 })

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