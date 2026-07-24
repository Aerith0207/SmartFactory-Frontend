// src/main/ets/views/SystemLogView.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

interface SystemLog {
  time: string;
  module: string;
  content: string;
  level: string;
}

interface HistoryAlarm {
  time: string;
  content: string;
  status: string;
}

interface DeviceStatus {
  device: string;
  status: string;
  runTime: string;
}

@Component
export struct SystemLogView {
  @State currentFilter: string = '全部';

  @State logList: SystemLog[] = [
    { time: '10:05:12', module: '生产指令', content: '下发结束排产指令，订单A100生产完成', level: 'INFO' },
    { time: '09:48:30', module: '环境传感', content: 'CO浓度恢复正常范围内', level: 'SUCCESS' },
    { time: '09:45:11', module: '环境传感', content: 'CO浓度超过预设安全阈值 (>50ppm)', level: 'WARNING' },
    { time: '09:35:00', module: '生产指令', content: '下发开始排产指令，当前目标 A100', level: 'INFO' },
    { time: '09:25:42', module: 'AGV调度', content: 'AGV-01 避障雷达状态异常告警', level: 'WARNING' },
    { time: '09:22:15', module: '环境传感', content: '车间温湿度传感阵列全部上线', level: 'SUCCESS' },
    { time: '09:20:00', module: '系统授权', content: 'Admin (192.168.1.10) 登录系统', level: 'INFO' }
  ];

  @State alarmList: HistoryAlarm[] = [
    { time: '09:45', content: 'CO浓度安全预警', status: '已恢复' },
    { time: '08:30', content: 'AGV避障雷达触发', status: '已处理' },
    { time: '07:15', content: '烟雾传感器离线', status: '已恢复' }
  ];

  @State deviceList: DeviceStatus[] = [
    { device: '温湿度节点', status: '正常', runTime: '12h 45m' },
    { device: '烟雾传感阵列', status: '正常', runTime: '12h 45m' },
    { device: 'CO监测探头', status: '正常', runTime: '12h 45m' },
    { device: 'AGV调度机', status: '运行中', runTime: '05h 20m' },
    { device: '光电计数栅栏', status: '正常', runTime: '12h 45m' }
  ];

  // 定义筛选器数组
  private filterOptions: string[] = ['全部', '设备状态', '安全报警', '控制审计'];

  build() {
    Column() {
      Row() {
        Text('系统运行日志中心')
          .fontFamily('HarmonyOS Sans')
          .fontColor(Colors.Title)
          .fontSize(32)
          .fontWeight(FontWeight.Bolder)
          .letterSpacing(4)
        Blank()
        Text('SYSTEM OPERATION LOG')
          .fontColor(Colors.TextMuted)
          .fontSize(14)
          .letterSpacing(2)
      }
      .width(Constants.FullWidth)
      .height('10%')
      .padding({ left: 32, right: 32 })
      .backgroundColor(Colors.BackgroundSoft)
      .border({ width: { bottom: 2 }, color: Colors.Cyan })

      Column({ space: Constants.PanelGap }) {
        Row({ space: Constants.PanelGap }) {
          this.KpiStatsCard()
          this.SystemStatusCard()
        }
        .width(Constants.FullWidth)
        .height(110)

        this.MainLogCard()

        Row({ space: Constants.PanelGap }) {
          this.RecentAlarmCard()
          this.DeviceRecordCard()
        }
        .width(Constants.FullWidth)
        .layoutWeight(1.5)
      }
      .width(Constants.FullWidth)
      .height('90%')
      .padding(16)
    }
    .width(Constants.FullWidth)
    .height(Constants.FullHeight)
    .backgroundColor(Colors.Background)
  }

  @Builder
  MainLogCard() {
    Column() {
      Row() {
        Text('实时系统运行日志流水').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
        Blank()

        // 核心修复：抛弃 @Builder 传参，改用 ForEach 直接映射渲染，确保 @State 完全响应
        Row({ space: 8 }) {
          ForEach(this.filterOptions, (filterName: string) => {
            Text(filterName)
              .fontColor(this.currentFilter === filterName ? Colors.Background : Colors.TextNormal)
              .fontSize(12)
              .backgroundColor(this.currentFilter === filterName ? Colors.Cyan : Colors.BackgroundSoft)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(12)
              .animation({ duration: 300, curve: Curve.FastOutSlowIn }) // 丝滑过渡动画
              .onClick(() => {
                this.currentFilter = filterName;
              })
          })
        }
      }.width(Constants.FullWidth).padding({ bottom: 12 }).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Row() {
        Text('时间戳').width('15%').fontColor(Colors.TextMuted).fontSize(13)
        Text('归属模块').width('20%').fontColor(Colors.TextMuted).fontSize(13)
        Text('工业事件描述').width('50%').fontColor(Colors.TextMuted).fontSize(13)
        Text('日志级别').width('15%').fontColor(Colors.TextMuted).fontSize(13).textAlign(TextAlign.End)
      }.width(Constants.FullWidth).padding({ top: 12, bottom: 8, left: 12, right: 12 })

      List({ space: 8 }) {
        ForEach(this.logList.filter(item => {
          if (this.currentFilter === '全部') return true;
          if (this.currentFilter === '安全报警') return item.level === 'WARNING' || item.level === 'ERROR';
          if (this.currentFilter === '控制审计') return item.module === '生产指令' || item.module === '系统授权';
          if (this.currentFilter === '设备状态') return item.module === '环境传感' || item.module === 'AGV调度';
          return true;
        }), (item: SystemLog) => {
          ListItem() {
            Row() {
              Text(item.time).width('15%').fontColor(Colors.TextNormal).fontSize(13).fontFamily('Courier New')
              Text(item.module).width('20%').fontColor(Colors.TextNormal).fontSize(13)
              Text(item.content).width('50%').fontColor(this.GetLevelColor(item.level)).fontSize(14)
              Text(item.level).width('15%').fontColor(this.GetLevelColor(item.level)).fontSize(12).fontWeight(FontWeight.Bold).textAlign(TextAlign.End)
            }
            .width(Constants.FullWidth).padding(12).backgroundColor(Colors.BackgroundSoft).borderRadius(4)
          }
        })
      }.layoutWeight(1).width(Constants.FullWidth)
    }
    .layoutWeight(2.5).width(Constants.FullWidth).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  @Builder KpiStatsCard() {
    Column() {
      Row() { Text('今日运行统计').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold) }.width(Constants.FullWidth).padding({ bottom: 8 }).border({ width: { bottom: 1 }, color: Colors.BorderSoft })
      Row() {
        this.KpiItem('今日事件', '152', Colors.Cyan)
        this.KpiItem('报警次数', '3', Colors.Danger)
        this.KpiItem('控制指令', '48', Colors.Warning)
        this.KpiItem('在线设备', '5/5', Colors.Normal)
      }.layoutWeight(1).width(Constants.FullWidth).alignItems(VerticalAlign.Center)
    }.layoutWeight(1).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(12)
  }

  @Builder KpiItem(label: string, value: string, valueColor: string) {
    Column({ space: 4 }) { Text(value).fontColor(valueColor).fontSize(24).fontWeight(FontWeight.Bold); Text(label).fontColor(Colors.TextMuted).fontSize(12) }.layoutWeight(1).alignItems(HorizontalAlign.Center)
  }

  @Builder SystemStatusCard() {
    Column() {
      Row() {
        Text('当前系统底层状态').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
        Blank()
        Circle({ width: 8, height: 8 }).fill(Colors.Normal).margin({ right: 6 })
        Text('链路正常').fontColor(Colors.Normal).fontSize(12)
      }.width(Constants.FullWidth).padding({ bottom: 8 }).border({ width: { bottom: 1 }, color: Colors.BorderSoft })
      Row() {
        this.SysStatusItem('MQTTBroker', '已连接', Colors.Normal)
        this.SysStatusItem('MySQL同步', '正常', Colors.Normal)
        this.SysStatusItem('CPU占用率', '18%', Colors.Cyan)
        this.SysStatusItem('物理内存', '42%', Colors.Cyan)
      }.layoutWeight(1).width(Constants.FullWidth).alignItems(VerticalAlign.Center)
    }.layoutWeight(1).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(12)
  }

  @Builder SysStatusItem(label: string, value: string, valueColor: string) {
    Column({ space: 6 }) { Text(label).fontColor(Colors.TextMuted).fontSize(12); Text(value).fontColor(valueColor).fontSize(16).fontWeight(FontWeight.Bold) }.layoutWeight(1).alignItems(HorizontalAlign.Start).padding({ left: 12 })
  }

  @Builder RecentAlarmCard() {
    Column() {
      Row() { Text('历史报警追溯').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold) }.width(Constants.FullWidth).padding({ bottom: 12 }).border({ width: { bottom: 1 }, color: Colors.BorderSoft })
      List({ space: 10 }) {
        ForEach(this.alarmList, (item: HistoryAlarm) => {
          ListItem() { Row() { Text(item.time).width('20%').fontColor(Colors.TextMuted).fontSize(13); Text(item.content).width('55%').fontColor(Colors.Warning).fontSize(13); Text(item.status).width('25%').fontColor(Colors.Normal).fontSize(13).textAlign(TextAlign.End) }.width(Constants.FullWidth) }
        })
      }.layoutWeight(1).width(Constants.FullWidth).padding({ top: 12 })
    }.layoutWeight(1).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  @Builder DeviceRecordCard() {
    Column() {
      Row() { Text('设备无故障运行档案').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold) }.width(Constants.FullWidth).padding({ bottom: 12 }).border({ width: { bottom: 1 }, color: Colors.BorderSoft })
      Row() { Text('设备阵列').width('40%').fontColor(Colors.TextMuted).fontSize(12); Text('当前状态').width('30%').fontColor(Colors.TextMuted).fontSize(12); Text('连续运行').width('30%').fontColor(Colors.TextMuted).fontSize(12).textAlign(TextAlign.End) }.width(Constants.FullWidth).padding({ top: 8, bottom: 8 })
      List({ space: 10 }) {
        ForEach(this.deviceList, (item: DeviceStatus) => {
          ListItem() { Row() { Text(item.device).width('40%').fontColor(Colors.TextNormal).fontSize(13); Text(item.status).width('30%').fontColor(Colors.Normal).fontSize(13); Text(item.runTime).width('30%').fontColor(Colors.Cyan).fontSize(13).fontFamily('Courier New').textAlign(TextAlign.End) }.width(Constants.FullWidth) }
        })
      }.layoutWeight(1).width(Constants.FullWidth).padding({ top: 4 })
    }.layoutWeight(1.5).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  GetLevelColor(level: string): string {
    switch (level) {
      case 'INFO': return Colors.TextNormal;
      case 'SUCCESS': return Colors.Normal;
      case 'WARNING': return Colors.Warning;
      case 'ERROR': return Colors.Danger;
      default: return Colors.TextNormal;
    }
  }
}