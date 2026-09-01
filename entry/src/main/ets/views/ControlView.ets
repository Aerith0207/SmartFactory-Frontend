// src/main/ets/views/ControlView.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MqttManager } from '../utils/MqttManager';

interface ActionCommand {
  label: string;
  color: string;
}

interface SysCommand {
  name: string;
  status: string;
  color: string;
}

interface SensorRowParams {
  name: string;
  isOnline: boolean;
  val: string;
  isOn: boolean;
  onToggle: (val: boolean) => void;
}

@Component
export struct ControlView {
  // --- 绑定全局 MQTT 数据 ---
  @StorageLink('env_temp') envTemp: number = 26;
  @StorageLink('env_hum') envHum: number = 55;
  @StorageLink('env_mq2_adc') envSmoke: number = 0;
  @StorageLink('env_mq7_adc') envCo: number = 0;

  @StorageLink('agv_radar_front') agvFront: string = '0';
  @StorageLink('agv_radar_left') agvLeft: string = '0';
  @StorageLink('agv_radar_right') agvRight: string = '0';
  @StorageLink('agv_radar_back') agvBack: string = '0';

  @StorageLink('switch_light') switchLight: boolean = false;
  @StorageLink('light_mode') lightMode: number = -1;

  // --- 静态配置数据 ---
  private agvActions: ActionCommand[] = [
    { label: '启动 AGV', color: Colors.Normal },
    { label: '暂停 AGV', color: Colors.Warning },
    { label: '返回起点', color: Colors.Cyan }
  ];

  private sysCommands: SysCommand[] = [
    { name: '设备初始化', status: 'READY', color: Colors.Cyan },
    { name: '设备自检', status: '15:26:33', color: Colors.Normal },
    { name: 'MQTT 重连', status: 'READY', color: Colors.Warning },
    { name: '恢复默认', status: 'STANDBY', color: Colors.Danger }
  ];

  build() {
    Column() {
      // 1. 顶部系统状态栏
      Row() {
        Text('设备控制中枢')
          .fontFamily('HarmonyOS Sans')
          .fontColor(Colors.Title)
          .fontSize(32)
          .fontWeight(FontWeight.Bolder)
          .letterSpacing(4)
        Blank()
        Row({ space: 16 }) {
          this.TopStatusTag('运行模式', 'MANUAL MODE', Colors.Cyan)
          this.TopStatusTag('设备心跳', '5 / 5 ONLINE', Colors.Normal)
          this.TopStatusTag('通信链路', 'MQTT Connected', Colors.Normal)
          this.TopStatusTag('Current User', 'Engineer', Colors.Warning)
        }
      }
      .width(Constants.FullWidth)
      .height('10%')
      .padding({ left: 32, right: 32 })
      .backgroundColor(Colors.BackgroundSoft)
      .border({ width: { bottom: 2 }, color: Colors.Cyan })

      // 主体三分栏区域
      Row({ space: Constants.PanelGap }) {
        // --- 模块一：环境与照明控制 ---
        Column({ space: 16 }) {
          this.PanelTitle('环境安全监测与控制')

          List({ space: 12 }) {
            this.SensorRow({ name: '温湿度传感器', isOnline: true, val: `${this.envTemp}℃ / ${this.envHum}%`, isOn: true, onToggle: (v: boolean) => {} })
            this.SensorRow({ name: '烟雾传感器', isOnline: true, val: `${this.envSmoke} adc`, isOn: true, onToggle: (v: boolean) => {} })
            this.SensorRow({ name: 'CO 传感器', isOnline: true, val: `${this.envCo} adc`, isOn: true, onToggle: (v: boolean) => {} })

            // 真实指令下发：灯光控制
            this.SensorRow({
              name: '红外照明模块',
              isOnline: true,
              val: this.switchLight ? 'Manual On' : (this.lightMode === -1 ? 'Auto Mode' : 'Off'),
              isOn: this.switchLight,
              onToggle: (isOn: boolean) => {
                this.switchLight = isOn;
                MqttManager.getInstance().publishLightControl(isOn ? 'light_on' : 'light_off');
              }
            })
          }
          .layoutWeight(1)
          .width('100%')
          .height('100%')
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(Colors.PanelBg)
        .borderRadius(Constants.CardRadius)
        .border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
        .padding(20)

        // --- 模块二：车间实况与 AGV 调度 ---
        Column({ space: 12 }) {
          this.PanelTitle('车间实况与 AGV 调度')

          Column({ space: 8 }) {
            Row() {
              Text('AGV-01 节点').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
              Blank()
              Text('● 运行中').fontColor(Colors.Normal).fontSize(14).fontWeight(FontWeight.Bold)
            }.width('100%')
            Divider().color(Colors.BorderSoft).opacity(0.5)
            Row() {
              this.RadarItem('前方', `${this.agvFront}cm`, Colors.Normal)
              this.RadarItem('左侧', `${this.agvLeft}cm`, Colors.Warning)
              this.RadarItem('右侧', `${this.agvRight}cm`, Colors.Cyan)
              this.RadarItem('后方', `${this.agvBack}cm`, Colors.Normal)
            }.width('100%')
          }.width('100%').backgroundColor(Colors.BackgroundSoft).padding(12).borderRadius(6)

          Stack({ alignContent: Alignment.Center }) {
            Row({ space: 4 }) {
              Circle({ width: 8, height: 8 })
                .fill(Colors.Danger)
                .animation({ duration: 800, iterations: -1, playMode: PlayMode.Alternate })
              Text('REC').fontColor(Colors.Danger).fontSize(12).fontWeight(FontWeight.Bold)
            }.position({ x: 12, y: 12 })

            Column({ space: 8 }) {
              Text('LIVE VIEW').fontColor(Colors.Cyan).fontSize(20).fontWeight(FontWeight.Bolder).opacity(0.3)
              Text('Workshop Camera - 01').fontColor(Colors.TextMuted).fontSize(12)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#0A0C14')
          .border({ width: 1, color: Colors.BorderSoft })
          .borderRadius(6)
          .margin({ top: 4, bottom: 4 })

          Row() {
            Column({ space: 4 }) {
              Button('▲').type(ButtonType.Circle).width(48).height(48).backgroundColor(Colors.BackgroundSoft).fontColor(Colors.Cyan).fontSize(18)
              Row({ space: 8 }) {
                Button('◀').type(ButtonType.Circle).width(48).height(48).backgroundColor(Colors.BackgroundSoft).fontColor(Colors.Cyan).fontSize(18)
                Button('●').type(ButtonType.Circle).width(48).height(48).backgroundColor(Colors.PanelBgBright).fontColor(Colors.Danger).fontSize(18)
                Button('▶').type(ButtonType.Circle).width(48).height(48).backgroundColor(Colors.BackgroundSoft).fontColor(Colors.Cyan).fontSize(18)
              }
              Button('▼').type(ButtonType.Circle).width(48).height(48).backgroundColor(Colors.BackgroundSoft).fontColor(Colors.Cyan).fontSize(18)
            }
            Blank()
            Column({ space: 12 }) {
              ForEach(this.agvActions, (action: ActionCommand) => {
                Button(action.label)
                  .type(ButtonType.Normal)
                  .backgroundColor(Colors.BackgroundSoft)
                  .fontColor(action.color)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .borderRadius(4)
                  .border({ width: 1, color: action.color })
                  .width(120)
                  .height(36)
              })
            }.justifyContent(FlexAlign.Center)
          }.width('100%').alignItems(VerticalAlign.Center).padding({ left: 16, right: 16 })
        }
        .layoutWeight(1.2)
        .height('100%')
        .backgroundColor(Colors.PanelBg)
        .borderRadius(Constants.CardRadius)
        .border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
        .padding(20)

        // --- 模块三：系统底层与加密传输 ---
        Column({ space: 16 }) {
          this.PanelTitle('系统运维与加密传输')

          Column({ space: 6 }) {
            Row() {
              Text('MQTT Security').fontColor(Colors.TextMuted).fontSize(12)
              Blank()
              Text('● Connected').fontColor(Colors.Normal).fontSize(12).fontWeight(FontWeight.Bold)
            }.width('100%')
            Divider().color(Colors.BorderSoft).margin({ top: 4, bottom: 4 })
            this.MqttParamItem('Broker', 'EMQX Cloud')
            this.MqttParamItem('Protocol', 'MQTT over TLS')
            this.MqttParamItem('Port', '8883')
            this.MqttParamItem('Encryption', 'TLS 1.2 Enabled')
            this.MqttParamItem('QoS Level', '1')
          }.width('100%').backgroundColor(Colors.BackgroundSoft).padding(12).borderRadius(6).margin({ bottom: 8 })

          Column({ space: 12 }) {
            ForEach(this.sysCommands, (cmd: SysCommand) => {
              this.SysCommandItem(cmd.name, cmd.status, cmd.color)
            })
          }.layoutWeight(1)

          Button() {
            Row({ space: 10 }) {
              Circle({ width: 16, height: 16 }).fill(Colors.Title).shadow({ radius: 4, color: Colors.Title, offsetX: 0, offsetY: 0 })
              Text('EMERGENCY STOP')
                .fontColor(Colors.Title).fontSize(22).fontWeight(FontWeight.Bolder).letterSpacing(2)
            }
          }
          .type(ButtonType.Normal)
          .width(Constants.FullWidth)
          .height(72)
          .backgroundColor(Colors.Danger)
          .borderRadius(8)
          .shadow({ radius: 15, color: Colors.Danger, offsetX: 0, offsetY: 0 })
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(Colors.PanelBg)
        .borderRadius(Constants.CardRadius)
        .border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
        .padding(20)
      }
      .width(Constants.FullWidth)
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 16 })

      Row() {
        this.BottomStatItem('CPU Usage', '18%', Colors.Normal)
        Divider().vertical(true).color(Colors.BorderSoft).height(12).margin({ left: 16, right: 16 })
        this.BottomStatItem('Memory', '42%', Colors.Cyan)
        Divider().vertical(true).color(Colors.BorderSoft).height(12).margin({ left: 16, right: 16 })
        this.BottomStatItem('Network', 'Good', Colors.Normal)
        Divider().vertical(true).color(Colors.BorderSoft).height(12).margin({ left: 16, right: 16 })
        this.BottomStatItem('MQTT Delay', '35ms', Colors.Cyan)
        Blank()
        Text('Last Sync: 15:32:10').fontColor(Colors.TextMuted).fontSize(13).fontFamily('Courier New')
      }
      .width(Constants.FullWidth)
      .height('6%')
      .padding({ left: 24, right: 24 })
      .backgroundColor(Colors.Background)
    }
    .width(Constants.FullWidth)
    .height(Constants.FullHeight)
  }

  // =====================================
  // UI 渲染 Builder 函数区
  // =====================================

  @Builder SensorRow($$: SensorRowParams) {
    ListItem() {
      Row() {
        Column({ space: 6 }) {
          Text($$.name).fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
          Row({ space: 12 }) {
            Row({ space: 4 }) {
              Circle({ width: 6, height: 6 }).fill($$.isOnline ? Colors.Normal : Colors.Danger)
              Text($$.isOnline ? 'ONLINE' : 'OFFLINE').fontColor($$.isOnline ? Colors.Normal : Colors.Danger).fontSize(12).fontWeight(FontWeight.Bold)
            }
            Text($$.val).fontColor(Colors.Cyan).fontSize(13).fontFamily('Courier New').fontWeight(FontWeight.Bold)
          }
        }.alignItems(HorizontalAlign.Start)

        Blank()
        Toggle({ type: ToggleType.Switch, isOn: $$.isOn })
          .selectedColor(Colors.Normal)
          .switchPointColor(Colors.Title)
          .onChange((isOn: boolean) => {
            $$.onToggle(isOn);
          })
      }.width(Constants.FullWidth).padding({ left: 8, right: 8, bottom: 12 }).border({ width: { bottom: 1 }, color: Colors.BackgroundSoft })
    }
  }

  @Builder TopStatusTag(label: string, value: string, color: string) {
    Row({ space: 8 }) {
      Text(label).fontColor(Colors.TextMuted).fontSize(12)
      Text(value).fontColor(color).fontSize(14).fontWeight(FontWeight.Bold)
    }.padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor(Colors.PanelBgBright).borderRadius(4)
  }

  @Builder PanelTitle(title: string) {
    Row() {
      Text(title).fontColor(Colors.Title).fontSize(18).fontWeight(FontWeight.Bold)
    }.width(Constants.FullWidth).border({ width: { bottom: 1 }, color: Colors.BorderSoft }).padding({ bottom: 12 })
  }

  @Builder RadarItem(label: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(label).fontColor(Colors.TextMuted).fontSize(12)
      Text(value).fontColor(color).fontSize(14).fontWeight(FontWeight.Bold).fontFamily('Courier New')
    }.layoutWeight(1).alignItems(HorizontalAlign.Center)
  }

  @Builder MqttParamItem(label: string, value: string) {
    Row() {
      Text(label).fontColor(Colors.TextMuted).fontSize(12)
      Blank()
      Text(value).fontColor(Colors.Cyan).fontSize(13).fontFamily('Courier New')
    }.width('100%').padding({ top: 3, bottom: 3 })
  }

  @Builder SysCommandItem(title: string, status: string, highlightColor: string) {
    Row() {
      Text(title).fontColor(Colors.Title).fontSize(15).fontWeight(FontWeight.Bold)
      Blank()
      Text(status).fontColor(Colors.TextMuted).fontSize(12).margin({ right: 12 })
      Text('EXECUTE').fontColor(highlightColor).fontSize(12).fontWeight(FontWeight.Bold).letterSpacing(1)
    }
    .width(Constants.FullWidth)
    .padding(14)
    .backgroundColor(Colors.BackgroundSoft)
    .border({ width: { left: 4 }, color: highlightColor })
    .borderRadius({ topRight: 4, bottomRight: 4 })
  }

  @Builder BottomStatItem(label: string, value: string, color: string) {
    Row({ space: 6 }) {
      Text(label).fontColor(Colors.TextMuted).fontSize(13)
      Text(value).fontColor(color).fontSize(13).fontWeight(FontWeight.Bold).fontFamily('Courier New')
    }
  }
}