// src/main/ets/views/ProductionView.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MqttManager } from '../utils/MqttManager';

interface CountLog {
  time: string;
  action: string;
  detail: string;
  color: string;
}

interface ProductInfo {
  name: string;
  order: string;
  defaultTarget: string;
}

interface InventorySnapshot {
  model: string;
  stock: number;
}

@Component
export struct ProductionView {
  // 核心改造1：双向绑定全局AppStorage数据，实时响应硬件上报
  @StorageLink('count_num') currentCount: number = 0;
  @State targetCount: number = 500;

  @State inputModel: string = 'A100';
  @State inputTarget: string = '500';

  @State productName: string = '伺服电机';
  @State orderId: string = 'OD20260701001';

  private mockProductDB: Record<string, ProductInfo> = {
    'A100': { name: '伺服电机', order: 'OD20260701001', defaultTarget: '500' },
    'B201': { name: '合金外壳', order: 'OD20260701002', defaultTarget: '1000' },
    'C105': { name: '主控PCB', order: 'OD20260701003', defaultTarget: '200' }
  };

  @State logList: CountLog[] = [
    { time: '10:15:22', action: '结束计数', detail: '任务完成，最终累计315件', color: Colors.Normal },
    { time: '09:50:00', action: '计数更新', detail: '已累计完成200件', color: Colors.Cyan },
    { time: '09:35:12', action: '计数更新', detail: '已累计完成100件', color: Colors.Cyan },
    { time: '09:20:05', action: '开始计数', detail: '绑定SKU型号: A100', color: Colors.Title }
  ];

  @State inventoryList: InventorySnapshot[] = [
    { model: 'A100', stock: 1200 },
    { model: 'B201', stock: 220 },
    { model: 'C105', stock: 85 }
  ];

  handleSkuChange(value: string) {
    this.inputModel = value;
    const upperValue = value.toUpperCase();

    if (this.mockProductDB[upperValue]) {
      const data = this.mockProductDB[upperValue];
      this.productName = data.name;
      this.orderId = data.order;
      this.inputTarget = data.defaultTarget;
      this.targetCount = parseInt(data.defaultTarget) || 1;
    } else {
      this.productName = '未识别或匹配中...';
      this.orderId = '---';
    }
  }

  private getNowTimeString(): string {
    const now = new Date();
    const h = now.getHours().toString().padStart(2, '0');
    const m = now.getMinutes().toString().padStart(2, '0');
    const s = now.getSeconds().toString().padStart(2, '0');
    return `${h}:${m}:${s}`;
  }

  // 核心改造2：任务启停控制与审计日志生成
  handleStartTask() {
    MqttManager.getInstance().publishCountControl('start', this.inputModel);
    this.logList.unshift({
      time: this.getNowTimeString(),
      action: '开始计数',
      detail: `绑定SKU型号:${this.inputModel}，目标数量:${this.targetCount}件`,
      color: Colors.Title
    });
  }

  handlePauseTask() {
    MqttManager.getInstance().publishCountControl('pause');
    this.logList.unshift({
      time: this.getNowTimeString(),
      action: '暂停计数',
      detail: `工单${this.orderId}已暂停，当前累计:${this.currentCount}件`,
      color: Colors.Warning
    });
  }

  // 核心改造3：结束任务时自动结算入库并更新库存快照
  handleFinishTask() {
    const finishedCount = this.currentCount;
    const currentSku = this.inputModel.trim().toUpperCase();

    const targetIndex = this.inventoryList.findIndex(item => item.model.toUpperCase() === currentSku);
    if (targetIndex !== -1) {
      this.inventoryList[targetIndex].stock += finishedCount;
    } else {
      this.inventoryList.push({ model: this.inputModel, stock: finishedCount });
    }

    this.logList.unshift({
      time: this.getNowTimeString(),
      action: '任务结算',
      detail: `工单${this.orderId}完成，型号${this.inputModel}成功入库${finishedCount}件`,
      color: Colors.Normal
    });

    MqttManager.getInstance().publishCountControl('end');
    this.currentCount = 0;
  }

  // 核心改造4：计数清零与硬件复位
  handleResetTask() {
    MqttManager.getInstance().publishCountControl('end');
    this.currentCount = 0;
    this.logList.unshift({
      time: this.getNowTimeString(),
      action: '计数清零',
      detail: `工单${this.orderId}计数值已手动重置归零`,
      color: Colors.Danger
    });
  }

  build() {
    Column() {
      Row() {
        Text('生产管理中心')
          .fontFamily('HarmonyOS Sans')
          .fontColor(Colors.Title)
          .fontSize(32)
          .fontWeight(FontWeight.Bolder)
          .letterSpacing(4)
        Blank()
        Text('PRODUCTION & COUNTING CENTER')
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
          this.TaskConfigCard()
          this.CounterCenterCard()
          this.StatisticsCard()
        }
        .width(Constants.FullWidth)
        .layoutWeight(2.2)

        Row({ space: Constants.PanelGap }) {
          this.CountLogCard()
          this.InventorySnapshotCard()
        }
        .width(Constants.FullWidth)
        .layoutWeight(1.3)
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
  TaskConfigCard() {
    Column() {
      this.PanelTitle('01', '当前计数任务配置')

      Column({ space: 14 }) {
        Column({ space: 8 }) {
          Text('输入物品型号(SKU)').fontColor(Colors.TextNormal).fontSize(13)
          Row({ space: 8 }) {
            TextInput({ text: this.inputModel, placeholder: '请输入型号' })
              .fontColor(Colors.Cyan)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .backgroundColor(Colors.BackgroundSoft)
              .border({ width: 1, color: Colors.BorderSoft })
              .layoutWeight(1)
              .onChange((value: string) => { this.handleSkuChange(value); })

            Button('📷 SCAN')
              .type(ButtonType.Normal)
              .backgroundColor(Colors.PanelBgBright)
              .fontColor(Colors.Cyan)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .borderRadius(4)
              .border({ width: 1, color: Colors.Cyan })
          }.width(Constants.FullWidth)
        }.alignItems(HorizontalAlign.Start).width(Constants.FullWidth)

        Divider().color(Colors.BorderSoft).margin({ top: 4, bottom: 4 })

        Row() {
          Text('产品名称').fontColor(Colors.TextMuted).fontSize(13).width(80)
          Blank()
          Text(this.productName).fontColor(Colors.Title).fontSize(14).fontWeight(FontWeight.Bold)
        }.width(Constants.FullWidth)

        Row() {
          Text('订单编号').fontColor(Colors.TextMuted).fontSize(13).width(80)
          Blank()
          Text(this.orderId).fontColor(Colors.Cyan).fontSize(14).fontWeight(FontWeight.Bold)
        }.width(Constants.FullWidth)

        this.InfoRow('生产工位', 'A产线(Line A)', Colors.TextNormal)
        this.InfoRow('负责人', 'Admin(白班)', Colors.TextNormal)
        this.InfoRow('批次号', 'Batch-001', Colors.TextNormal)

        Row() {
          Text('目标数量').fontColor(Colors.TextMuted).fontSize(13).width(80)
          Blank()
          TextInput({ text: this.inputTarget })
            .type(InputType.Number)
            .fontColor(Colors.Warning)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(Colors.BackgroundSoft)
            .borderRadius(4)
            .height(34)
            .width(90)
            .textAlign(TextAlign.Center)
            .onChange((value: string) => {
              this.inputTarget = value;
              this.targetCount = parseInt(value) || 1;
            })
          Text('件').fontColor(Colors.TextMuted).fontSize(13).margin({ left: 4 })
        }.width(Constants.FullWidth)

        this.InfoRow('当前工单', 'NO.5', Colors.TextNormal)

      }.layoutWeight(1).justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  @Builder
  CounterCenterCard() {
    Column() {
      this.PanelTitle('02', '光电传感器实时计数')

      Column() {
        Text(`${this.currentCount}`)
          .fontColor(Colors.Title)
          .fontSize(84)
          .fontWeight(FontWeight.Bolder)
          .letterSpacing(4)
        Text('PCS').fontColor(Colors.Cyan).fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })

        Row({ space: 12 }) {
          Progress({ value: this.currentCount, total: this.targetCount, type: ProgressType.Linear })
            .color(Colors.Normal)
            .backgroundColor(Colors.BackgroundSoft)
            .layoutWeight(1)
            .height(8)
          Text(`${this.targetCount > 0 ? Math.floor((this.currentCount / this.targetCount) * 100) : 0}%`)
            .fontColor(Colors.Normal)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.width('90%')
        Text(`${this.currentCount} / ${this.targetCount}`).fontColor(Colors.TextMuted).fontSize(12).margin({ top: 6, bottom: 20 })

        Row({ space: 16 }) {
          this.ActionButton('开始任务', Colors.Normal, () => { this.handleStartTask(); })
          this.ActionButton('暂停任务', Colors.Warning, () => { this.handlePauseTask(); })
        }.width(Constants.FullWidth).margin({ bottom: 12 })

        Row({ space: 16 }) {
          this.ActionButton('结束任务', Colors.Danger, () => { this.handleFinishTask(); })
          this.ActionButton('计数清零', Colors.Cyan, () => { this.handleResetTask(); })
        }.width(Constants.FullWidth)

        Blank()

        Column({ space: 6 }) {
          this.StatusRow('计数来源', 'Photoelectric Sensor', Colors.TextNormal)
          this.StatusRow('PLC Channel', 'COM3(Sampling 50ms)', Colors.TextNormal)
          Divider().color(Colors.BorderSoft).margin({ top: 4, bottom: 4 })
          this.StatusRow('运行状态', '● RUNNING', Colors.Normal)
          this.StatusRow('光电传感器', 'ONLINE', Colors.Normal)
          this.StatusRow('MQTT通讯', 'CONNECTED', Colors.Cyan)
        }.width(Constants.FullWidth).backgroundColor(Colors.BackgroundSoft).padding(10).borderRadius(6)

      }.layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1.2).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  @Builder
  StatisticsCard() {
    Column() {
      this.PanelTitle('03', '今日产线统计')

      Column({ space: 24 }) {
        this.StatBigItem('今日处理订单', '5', '单', Colors.Title)
        this.StatBigItem('已完成计数', '3', '单', Colors.Normal)
        this.StatBigItem('全天累计计数', '1580', '件', Colors.Cyan)
        this.StatBigItem('当前通过效率', '25', '件/min', Colors.Warning)
      }.layoutWeight(1).justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  @Builder
  CountLogCard() {
    Column() {
      Row() {
        Text('计数任务记录').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
        Blank()
        Text('Counting Task Log').fontColor(Colors.TextMuted).fontSize(12)
      }.width(Constants.FullWidth).padding({ bottom: 12 }).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      List({ space: 8 }) {
        ForEach(this.logList, (item: CountLog) => {
          ListItem() {
            Row() {
              Text(item.time).width('15%').fontColor(Colors.TextMuted).fontSize(13).fontFamily('Courier New')
              Text(item.action).width('25%').fontColor(item.color).fontSize(14).fontWeight(FontWeight.Bold)
              Text(item.detail).fontColor(Colors.TextNormal).fontSize(14).layoutWeight(1)
            }.width(Constants.FullWidth).padding(10).backgroundColor(Colors.BackgroundSoft).borderRadius(4)
          }
        })
      }.layoutWeight(1).width(Constants.FullWidth).padding({ top: 12 })
    }
    .layoutWeight(2.2).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  @Builder
  InventorySnapshotCard() {
    Column() {
      Row() {
        Text('底层库存快照').fontColor(Colors.Title).fontSize(16).fontWeight(FontWeight.Bold)
      }.width(Constants.FullWidth).padding({ bottom: 12 }).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Row() {
        Text('型号(SKU)').width('50%').fontColor(Colors.TextMuted).fontSize(12)
        Text('入库计数').width('50%').fontColor(Colors.TextMuted).fontSize(12).textAlign(TextAlign.End)
      }.width(Constants.FullWidth).padding({ top: 8, bottom: 8 })

      List({ space: 8 }) {
        ForEach(this.inventoryList, (item: InventorySnapshot) => {
          ListItem() {
            Row() {
              Text(item.model).width('50%').fontColor(Colors.Cyan).fontSize(13).fontWeight(FontWeight.Bold)
              Text(`${item.stock}`).width('50%').fontColor(this.GetStockColor(item.stock)).fontSize(14).fontWeight(FontWeight.Bold).textAlign(TextAlign.End)
            }.width(Constants.FullWidth).padding({ top: 4, bottom: 4 })
          }
        })
      }.layoutWeight(1).width(Constants.FullWidth).padding({ top: 4 })
    }
    .layoutWeight(1).height('100%').backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft }).padding(16)
  }

  GetStockColor(stock: number): string {
    if (stock > 500) return Colors.Normal;
    if (stock > 100) return Colors.Warning;
    return Colors.Danger;
  }

  @Builder PanelTitle(index: string, title: string) {
    Row() {
      Text(index).fontColor(Colors.Cyan).fontSize(16).fontWeight(FontWeight.Bold)
      Text(title).fontColor(Colors.Title).fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 8 })
    }.width(Constants.FullWidth).border({ width: { bottom: 1 }, color: Colors.BorderSoft }).padding({ bottom: 12 }).margin({ bottom: 12 })
  }

  @Builder InfoRow(label: string, value: string, color: string) {
    Row() {
      Text(label).fontColor(Colors.TextMuted).fontSize(13).width(80)
      Blank()
      Text(value).fontColor(color).fontSize(14).fontWeight(FontWeight.Bold)
    }.width(Constants.FullWidth)
  }

  @Builder StatusRow(label: string, value: string, color: string) {
    Row() {
      Text(label).fontColor(Colors.TextMuted).fontSize(12)
      Blank()
      Text(value).fontColor(color).fontSize(12).fontWeight(FontWeight.Bold).fontFamily('Courier New')
    }.width(Constants.FullWidth).padding({ top: 3, bottom: 3 })
  }

  @Builder ActionButton(label: string, bgColor: string, onClickAction: () => void) {
    Button(label)
      .type(ButtonType.Normal)
      .backgroundColor(Colors.BackgroundSoft)
      .fontColor(bgColor)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .borderRadius(4)
      .border({ width: 1, color: bgColor })
      .layoutWeight(1)
      .onClick(() => {
        onClickAction();
      })
  }

  @Builder StatBigItem(label: string, value: string, unit: string, color: string) {
    Row() {
      Text(label).fontColor(Colors.TextNormal).fontSize(14)
      Blank()
      Row() {
        Text(value).fontColor(color).fontSize(28).fontWeight(FontWeight.Bold).margin({ right: 4 })
        Text(unit).fontColor(Colors.TextMuted).fontSize(12).margin({ top: 8 })
      }.alignItems(VerticalAlign.Bottom)
    }.width(Constants.FullWidth)
  }
}