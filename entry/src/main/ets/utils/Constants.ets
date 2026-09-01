export class Constants {
  // --- 原有 UI 常量 ---
  static readonly FullWidth: string = '100%';
  static readonly FullHeight: string = '100%';
  static readonly CardRadius: number = 5;
  static readonly DefaultPadding: number = 14;
  static readonly BorderWidth: number = 1;
  static readonly PanelGap: number = 12;

  // --- 新增 MQTT Topic 常量 ---
  // 状态上报
  static readonly TOPIC_STATUS: string = 'smart_factory/status';
  static readonly TOPIC_COUNT_REPORT: string = 'smart_factory/count/report';

  // 指令下发
  static readonly TOPIC_CONTROL: string = 'smart_factory/control';
  static readonly TOPIC_COUNT_CONTROL: string = 'smart_factory/count/control';
}