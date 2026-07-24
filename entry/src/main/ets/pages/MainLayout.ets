// src/main/ets/pages/MainLayout.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { DashboardView } from '../views/DashboardView';
import { ControlView } from '../views/ControlView';
import { ProductionView } from '../views/ProductionView';
import { SystemLogView } from '../views/SystemLogView';

@Entry
@Component
struct MainLayout {
  @State currentIndex: number = 0;

  build() {
    Row() {
      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          DashboardView() // 直接调用大屏视图
        }.tabBar(this.NavigationItem('数据监控', 0))

        TabContent() {
          ControlView()
        }.tabBar(this.NavigationItem('设备控制', 1))

        TabContent() {
          ProductionView()
        }.tabBar(this.NavigationItem('生产管理', 2))

        TabContent() {
          SystemLogView()
        }.tabBar(this.NavigationItem('系统日志', 3))
      }
      .vertical(true)
      .scrollable(false)
      .barWidth(140) // 设定左侧导航栏的固定宽度
      .barHeight(Constants.FullHeight)
      .backgroundColor(Colors.BackgroundSoft)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width(Constants.FullWidth)
    .height(Constants.FullHeight)
    .backgroundColor(Colors.Background)
  }

  @Builder
  NavigationItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === index ? Colors.Cyan : Colors.TextNormal)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .letterSpacing(2)
    }
    .width(Constants.FullWidth)
    .height(80)
    .justifyContent(FlexAlign.Center)
    .border({
      width: { left: this.currentIndex === index ? 4 : 0 },
      color: Colors.Cyan
    })
    .backgroundColor(this.currentIndex === index ? Colors.PanelBgBright : 'transparent')
  }
}