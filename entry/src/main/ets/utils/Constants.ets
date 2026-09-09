export class Constants {
  // --- 原有 UI 常量 ---
  static readonly FullWidth: string = '100%';
  static readonly FullHeight: string = '100%';
  static readonly CardRadius: number = 5;
  static readonly DefaultPadding: number = 14;
  static readonly BorderWidth: number = 1;
  static readonly PanelGap: number = 12;

  // --- MQTT 连接与安全策略 ---
  // 当前硬件仍使用 1883 明文连接，默认保持兼容，避免影响现阶段联调。
  // 硬件切换到 TLS 后，只需修改以下集中配置，无需改动大屏组件。
  static readonly MQTT_HOST: string = 'broker-cn.emqx.io';
  static readonly MQTT_TCP_PORT: number = 1883;
  static readonly MQTT_TLS_PORT: number = 8883;
  static readonly MQTT_USERNAME: string = 'hi3861';
  static readonly MQTT_PASSWORD: string = 'public';
  static readonly MQTT_TLS_ENABLED: boolean = true;
  static readonly MQTT_PAYLOAD_ENCRYPTION_ENABLED: boolean = true;
  static readonly MQTT_ALLOW_PLAINTEXT_RECEIVE: boolean = true;
  static readonly MQTT_TELEMETRY_QOS: 0 | 1 | 2 = 0;
  static readonly MQTT_COMMAND_QOS: 0 | 1 | 2 = 1;

  // AES-256 共享密钥必须由安全配置流程注入，禁止提交真实密钥到源码仓库。
  // 启用 MQTT_PAYLOAD_ENCRYPTION_ENABLED 前，应填写联调临时密钥或接入正式密钥配置服务。
  static readonly PROVISIONED_AES_KEY_HEX: string = '';
  static readonly HUKS_AES_KEY_ALIAS: string = 'smart_factory_aes_gcm_v1';

  static getMqttUrl(): string {
    const scheme = Constants.MQTT_TLS_ENABLED ? 'ssl' : 'tcp';
    const port = Constants.MQTT_TLS_ENABLED ? Constants.MQTT_TLS_PORT : Constants.MQTT_TCP_PORT;
    return `${scheme}://${Constants.MQTT_HOST}:${port}`;
  }

  static getMqttPort(): number {
    return Constants.MQTT_TLS_ENABLED ? Constants.MQTT_TLS_PORT : Constants.MQTT_TCP_PORT;
  }

  // --- 新增 MQTT Topic 常量 ---
  // 状态上报
  static readonly TOPIC_STATUS: string = 'smart_factory/status';
  static readonly TOPIC_COUNT_REPORT: string = 'smart_factory/count/report';

  // 指令下发
  static readonly TOPIC_CONTROL: string = 'smart_factory/control';
  static readonly TOPIC_COUNT_CONTROL: string = 'smart_factory/count/control';
}
