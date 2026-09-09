// src/main/ets/utils/MqttManager.ets
import {
  MqttAsync,
  MqttClient,
  MqttConnectOptions,
  MqttSubscribeOptions,
  MqttPublishOptions,
  MqttMessage,
  MQTT_SSL_VERSION
} from '@ohos/mqtt';
import { buffer } from '@kit.ArkTS';
import { Constants } from './Constants';
import { SecurePayloadCodec } from './security/SecurePayloadCodec';

interface AgvPayload {
  front?: number;
  back?: number;
  left?: number;
  right?: number;
  unit?: string;
}

interface FactoryStatusPayload {
  device?: string;
  light_mode?: number;
  temperature?: number;
  humidity?: number;
  mq2_adc?: number;
  mq2_alarm?: number;
  mq7_adc?: number;
  mq7_alarm?: number;
  radar_present?: number;
}

interface FactoryCountPayload {
  model?: string;
  count?: number;
}

// 🌟 新增：为下发指令定义明确的类，避免 ArkTS 报错“无类型对象字面量”
class LightCommand {
  cmd: string = '';
}

class CountCommand {
  cmd: string = '';
  model?: string;
}

export class MqttManager {
  private static instance: MqttManager;
  private client: MqttClient | null = null;

  private constructor() {}

  public static getInstance(): MqttManager {
    if (!MqttManager.instance) {
      MqttManager.instance = new MqttManager();
    }
    return MqttManager.instance;
  }

  public async connect(): Promise<void> {
    console.info('【MQTT追踪】1. 开始初始化 MQTT 客户端...');

    try {
      await SecurePayloadCodec.initialize();
      this.client = MqttAsync.createMqtt({
        url: Constants.getMqttUrl(),
        clientId: 'hi3861_smart_factory_app_' + Math.floor(Math.random() * 10000),
        persistenceType: 1
      });

      this.client.messageArrived((err: Error, msg: MqttMessage) => {
        if (err) {
          console.error('【MQTT追踪】接收消息发生错误:', JSON.stringify(err));
          return;
        }
        if (msg) {
          const topic = (msg.topic as string) ?? '';
          let payload = '';

          const rawPayload = msg.payload as string | ArrayBuffer;

          if (typeof rawPayload === 'string') {
            payload = rawPayload;
          } else if (rawPayload instanceof ArrayBuffer) {
            payload = buffer.from(new Uint8Array(rawPayload)).toString('utf-8');
          }

          if (payload !== '') {
            this.processIncomingMessage(topic, payload).catch((processError: Error) => {
              console.error(`【安全链路】拒绝主题 [${topic}] 的无效报文: ${processError.message}`);
            });
          }
        }
      });

      this.client.connectLost((err: Error) => {
        AppStorage.setOrCreate('mqtt_connection_state', '连接中断');
        console.error('【MQTT追踪】!! 连接意外断开 !! 错误信息: ', JSON.stringify(err));
      });

      console.info('【MQTT追踪】2. 正在向 EMQX 发起网络连接请求...');

      const connectOptions: MqttConnectOptions = {
        userName: Constants.MQTT_USERNAME,
        password: Constants.MQTT_PASSWORD,
        cleanSession: true,
        keepAliveInterval: 60
      };
      if (Constants.MQTT_TLS_ENABLED) {
        connectOptions.sslOptions = {
          enableServerCertAuth: true,
          verify: true,
          sslVersion: MQTT_SSL_VERSION.MQTT_SSL_VERSION_TLS_1_2
        };
      }

      this.client.connect(connectOptions).then(() => {
        AppStorage.setOrCreate('mqtt_connection_state', '已连接');
        console.info('【MQTT追踪】3. ✔️ 成功连接至 EMQX 服务器！开始订阅主题...');

        const sub1: MqttSubscribeOptions = { topic: 'smart_car/distance', qos: Constants.MQTT_TELEMETRY_QOS };
        const sub2: MqttSubscribeOptions = { topic: Constants.TOPIC_STATUS, qos: Constants.MQTT_TELEMETRY_QOS };
        const sub3: MqttSubscribeOptions = { topic: Constants.TOPIC_COUNT_REPORT, qos: Constants.MQTT_TELEMETRY_QOS };

        this.client?.subscribe(sub1)
          .then(() => console.info(`【MQTT追踪】✔️ 成功订阅主题: ${sub1.topic}`))
          .catch((err: Error) => console.error(`【MQTT追踪】❌ 订阅失败: ${sub1.topic}`, JSON.stringify(err)));

        this.client?.subscribe(sub2)
          .then(() => console.info(`【MQTT追踪】✔️ 成功订阅主题: ${sub2.topic}`))
          .catch((err: Error) => console.error(`【MQTT追踪】❌ 订阅失败: ${sub2.topic}`, JSON.stringify(err)));

        this.client?.subscribe(sub3)
          .then(() => console.info(`【MQTT追踪】✔️ 成功订阅主题: ${sub3.topic}`))
          .catch((err: Error) => console.error(`【MQTT追踪】❌ 订阅失败: ${sub3.topic}`, JSON.stringify(err)));

      }).catch((connErr: Error) => {
        AppStorage.setOrCreate('mqtt_connection_state', '连接失败');
        console.error('【MQTT追踪】❌ 网络连接失败: ', JSON.stringify(connErr));
      });

    } catch (error) {
      AppStorage.setOrCreate('mqtt_connection_state', '安全初始化失败');
      console.error('【MQTT追踪】❌ 初始化严重崩溃: ', JSON.stringify(error));
    }
  }

  private async processIncomingMessage(topic: string, transportPayload: string): Promise<void> {
    const decoded = await SecurePayloadCodec.decode(transportPayload, topic);
    AppStorage.setOrCreate('mqtt_last_payload_mode', decoded.encrypted ? 'AES-GCM' : 'PLAINTEXT');
    console.info(`【MQTT追踪】4. 收到主题 [${topic}]，安全模式: ${decoded.encrypted ? 'AES-GCM' : '明文兼容'}`);

    if (topic === 'smart_car/distance') {
      this.handleAgvDistance(decoded.plainText);
    } else if (topic === Constants.TOPIC_STATUS) {
      this.handleFactoryStatus(decoded.plainText);
    } else if (topic === Constants.TOPIC_COUNT_REPORT) {
      this.handleCountReport(decoded.plainText);
    }
  }

  private handleFactoryStatus(payloadString: string) {
    try {
      const data = JSON.parse(payloadString) as FactoryStatusPayload;
      if (data.temperature !== undefined) AppStorage.setOrCreate('env_temp', data.temperature);
      if (data.humidity !== undefined) AppStorage.setOrCreate('env_hum', data.humidity);
      if (data.mq2_adc !== undefined) AppStorage.setOrCreate('env_mq2_adc', data.mq2_adc);
      if (data.mq2_alarm !== undefined) AppStorage.setOrCreate('env_mq2_alarm', data.mq2_alarm);
      if (data.mq7_adc !== undefined) AppStorage.setOrCreate('env_mq7_adc', data.mq7_adc);
      if (data.mq7_alarm !== undefined) AppStorage.setOrCreate('env_mq7_alarm', data.mq7_alarm);
      if (data.radar_present !== undefined) AppStorage.setOrCreate('radar_present', data.radar_present);
      if (data.light_mode !== undefined) AppStorage.setOrCreate('light_mode', data.light_mode);
    } catch (e) {
      console.error('【MQTT追踪】❌ 解析状态 JSON 失败:', payloadString);
    }
  }

  private handleCountReport(payloadString: string) {
    try {
      const data = JSON.parse(payloadString) as FactoryCountPayload;
      if (data.model !== undefined) AppStorage.setOrCreate('count_model', data.model);
      if (data.count !== undefined) AppStorage.setOrCreate('count_num', data.count);
      console.info(`【MQTT追踪】5. 计数报文解析成功! 当前型号: ${data.model}, 实时计数值: ${data.count}`);
      console.info('【MQTT追踪】6. 全局状态已驱动UI重绘');
    } catch (e) {
      console.error('【MQTT追踪】❌ 解析计数 JSON 失败:', payloadString);
    }
  }

  private handleAgvDistance(payloadString: string) {
    try {
      const cleanPayload = payloadString.replace(/^pub\s*/, '');
      const data = JSON.parse(cleanPayload) as AgvPayload;
      if (data.front !== undefined) AppStorage.setOrCreate('agv_radar_front', data.front.toString());
      if (data.back !== undefined) AppStorage.setOrCreate('agv_radar_back', data.back.toString());
      if (data.left !== undefined) AppStorage.setOrCreate('agv_radar_left', data.left.toString());
      if (data.right !== undefined) AppStorage.setOrCreate('agv_radar_right', data.right.toString());
    } catch (e) {
      console.error('【MQTT追踪】❌ 小车 JSON 解析失败:', payloadString);
    }
  }

  public async publishLightControl(cmd: string): Promise<void> {
    const msg = new LightCommand();
    msg.cmd = cmd;
    const payload = JSON.stringify(msg);
    await this.publishJson(Constants.TOPIC_CONTROL, payload, '灯光指令');
  }

  public async publishCountControl(cmd: string, model?: string): Promise<void> {
    const msg = new CountCommand();
    msg.cmd = cmd;
    if (model) {
      msg.model = model;
    }
    const payload = JSON.stringify(msg);
    await this.publishJson(Constants.TOPIC_COUNT_CONTROL, payload, '计数指令');
  }

  private async publishJson(topic: string, plainPayload: string, description: string): Promise<void> {
    if (!this.client) {
      console.error(`【MQTT控制】❌ ${description}发送失败：客户端未连接`);
      return;
    }

    try {
      const transportPayload = await SecurePayloadCodec.encode(plainPayload, topic);
      const pubOpts: MqttPublishOptions = {
        topic: topic,
        payload: transportPayload,
        qos: Constants.MQTT_COMMAND_QOS,
        retained: false
      };

      await this.client.publish(pubOpts);
      console.info(`【MQTT控制】✔️ ${description}发送成功，载荷模式: ${Constants.MQTT_PAYLOAD_ENCRYPTION_ENABLED ? 'AES-GCM' : '明文兼容'}`);
    } catch (error) {
      console.error(`【MQTT控制】❌ ${description}发送失败: ${JSON.stringify(error)}`);
    }
  }
}
