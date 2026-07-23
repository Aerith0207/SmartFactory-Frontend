// src/main/ets/components/DeviceStatusCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

interface DeviceStatus {
  name: string;
  isOnline: boolean;
  statusText: string;
}

@Component
export struct DeviceStatusCard {
  @State deviceList: DeviceStatus[] = [
    { name: '温湿度传感器', isOnline: true, statusText: '运行正常' },
    { name: '烟雾传感器', isOnline: true, statusText: '运行正常' },
    { name: 'CO传感器', isOnline: true, statusText: '运行正常' },
    { name: '小车 (AGV)', isOnline: true, statusText: '运行正常' },
    { name: '光电传感器', isOnline: true, statusText: '运行正常' },
    { name: '红外照明模块', isOnline: true, statusText: '自动模式' }
  ];

  // 脉冲动画状态变量
  @State pulseScale: number = 1;
  @State pulseOpacity: number = 1;

  aboutToAppear() {
    // 启动脉冲动画循环
    setInterval(() => {
      // 1. 瞬间重置回原始大小且不透明
      this.pulseScale = 1;
      this.pulseOpacity = 1;
      // 2. 开启动画，逐渐放大并变得完全透明
      animateTo({ duration: 1000, curve: Curve.EaseOut }, () => {
        this.pulseScale = 1.8;
        this.pulseOpacity = 0;
      });
    }, 1500);
  }

  build() {
    Column() {
      Row() {
        Text('01').fontColor(Colors.Cyan).fontSize(15).fontWeight(FontWeight.Bold)
        Text('设备在线状态').fontColor(Colors.Title).fontSize(21).fontWeight(FontWeight.Bold).margin({ left: 8 })
        Blank()
        Text(`${this.deviceList.length} DEVICES`).fontColor(Colors.TextMuted).fontSize(11)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      List({ space: 10 }) {
        ForEach(this.deviceList, (item: DeviceStatus) => {
          ListItem() {
            Row() {
              Stack() {
                // 内层：中心静态实心圆
                Circle({ width: 8, height: 8 }).fill(item.isOnline ? Colors.Normal : Colors.Danger)
                // 外层：不断扩散的脉冲波纹圆
                Circle({ width: 8, height: 8 })
                  .fill('transparent')
                  .stroke(item.isOnline ? Colors.Normal : Colors.Danger)
                  .strokeWidth(2)
                  .scale({ x: this.pulseScale, y: this.pulseScale })
                  .opacity(this.pulseOpacity)
              }.width(28)

              Text(item.name).fontColor(Colors.TextNormal).fontSize(17).layoutWeight(1)
              Text(item.isOnline ? '在线' : '离线').fontColor(item.isOnline ? Colors.Normal : Colors.Danger).fontSize(16).fontWeight(FontWeight.Bold)
              Text(item.statusText).fontColor(Colors.TextMuted).fontSize(14).width(78).textAlign(TextAlign.End)
            }
            .width(Constants.FullWidth).height(44).padding({ left: 12, right: 12 }).backgroundColor(Colors.BackgroundSoft).borderRadius(4)
          }
        })
      }
      .width(Constants.FullWidth).layoutWeight(1).padding({ top: 12, left: 12, right: 12, bottom: 14 })
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }
}