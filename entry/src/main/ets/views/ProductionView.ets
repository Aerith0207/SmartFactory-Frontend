// src/main/ets/views/ProductionView.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

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
  @State currentCount: number = 315;
  @State targetCount: number = 500;

  // 用于双向绑定的输入框状态
  @State inputModel: string = 'A100';
  @State inputTarget: string = '500';

  // 随型号联动的展示状态
  @State productName: string = '伺服电机';
  @State orderId: string = 'OD20260701001';

  // 模拟后台数据库的字典
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

  // 实时根据输入的SKU查找并更新产品信息
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

  build() {
    Column() {
      // 1. 顶部标题栏
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
        // 2. 核心三分栏
        Row({ space: Constants.PanelGap }) {
          this.TaskConfigCard()
          this.CounterCenterCard()
          this.StatisticsCard()
        }
        .width(Constants.FullWidth)
        .layoutWeight(2.2)

        // 3. 底部双分栏
        Row({ space: Constants.PanelGap }) {
          this.CountLogCard()
          this.InventorySnapshotCard()
        }
        .width(Constants.FullWidth)
        .layoutWeight(1.3)
      }
      .width(Constants.FullWidth)
      .height(Constants.FullHeight)
      .height('90%')
      .padding(16)
    }
    .width(Constants.FullWidth)
    .height(Constants.FullHeight)
    .backgroundColor(Colors.Background)
  }

  // ---组件拆分---

  // 左侧：当前任务配置
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

        // 修复 1：对于需要动态变化的数据，抛弃 Builder 传参，直接内联书写以保持 @State 响应性
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

        // 修复 2：放宽 TextInput 的高宽限制，防止字体截断
        Row() {
          Text('目标数量').fontColor(Colors.TextMuted).fontSize(13).width(80)
          Blank()
          TextInput({ text: this.inputTarget })
            .type(InputType.Number)
            .fontColor(Colors.Warning)
            .fontSize(15) // 微调字号
            .fontWeight(FontWeight.Bold)
            .backgroundColor(Colors.BackgroundSoft)
            .borderRadius(4)
            .height(34) // 高度从28增加到34，解决遮挡问题
            .width(90)  // 宽度增加到90
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

  // 中间：视觉核心计数中枢
  @Builder
  CounterCenterCard() {
    Column() {
      this.PanelTitle('02', '光电传感器实时计数')

      Column() {
        // 视觉冲击区
        Text(`${this.currentCount}`)
          .fontColor(Colors.Title)
          .fontSize(84)
          .fontWeight(FontWeight.Bolder)
          .letterSpacing(4)
        Text('PCS').fontColor(Colors.Cyan).fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })

        // 任务进度条
        Row({ space: 12 }) {
          Progress({ value: this.currentCount, total: this.targetCount, type: ProgressType.Linear })
            .color(Colors.Normal)
            .backgroundColor(Colors.BackgroundSoft)
            .layoutWeight(1)
            .height(8)
          Text(`${Math.floor((this.currentCount / this.targetCount) * 100)}%`).fontColor(Colors.Normal).fontSize(16).fontWeight(FontWeight.Bold)
        }.width('90%')
        Text(`${this.currentCount} / ${this.targetCount}`).fontColor(Colors.TextMuted).fontSize(12).margin({ top: 6, bottom: 20 })

        // 任务流控制按钮
        Row({ space: 16 }) {
          this.ActionButton('开始任务', Colors.Normal)
          this.ActionButton('暂停任务', Colors.Warning)
        }.width(Constants.FullWidth).margin({ bottom: 12 })

        Row({ space: 16 }) {
          this.ActionButton('结束任务', Colors.Danger)
          this.ActionButton('计数清零', Colors.Cyan)
        }.width(Constants.FullWidth)

        Blank()

        // 硬件数据来源与系统状态
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

  // 右侧：今日计数统计
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

  // 底部左侧：计数记录日志
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

  // 底部右侧：轻量化库存快照
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

  // ---辅助工具与组件---

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

  @Builder ActionButton(label: string, bgColor: string) {
    Button(label)
      .type(ButtonType.Normal)
      .backgroundColor(Colors.BackgroundSoft)
      .fontColor(bgColor)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .borderRadius(4)
      .border({ width: 1, color: bgColor })
      .layoutWeight(1)
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