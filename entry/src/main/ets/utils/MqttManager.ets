// src/main/ets/utils/MqttManager.ets
import {
  MqttAsync,
  MqttClient,
  MqttSubscribeOptions,
  MqttPublishOptions, // 🌟 新增：导入 Publish 选项类型
  MqttMessage
} from '@ohos/mqtt';
import util from '@ohos.util';
import { Constants } from './Constants';

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

  public connect() {
    console.info('【MQTT追踪】1. 开始初始化 MQTT 客户端...');

    try {
      this.client = MqttAsync.createMqtt({
        url: 'tcp://broker-cn.emqx.io:1883',
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
            let textDecoder = util.TextDecoder.create("utf-8");
            payload = textDecoder.decodeWithStream(new Uint8Array(rawPayload));
          }

          console.info(`【MQTT追踪】4. 收到云端推送! 主题: [${topic}], 内容: [${payload}]`);

          if (topic === 'smart_car/distance' && payload !== '') {
            this.handleAgvDistance(payload);
          } else if (topic === Constants.TOPIC_STATUS && payload !== '') {
            this.handleFactoryStatus(payload);
          } else if (topic === Constants.TOPIC_COUNT_REPORT && payload !== '') {
            this.handleCountReport(payload);
          }
        }
      });

      this.client.connectLost((err: Error) => {
        console.error('【MQTT追踪】!! 连接意外断开 !! 错误信息: ', JSON.stringify(err));
      });

      console.info('【MQTT追踪】2. 正在向 EMQX 发起网络连接请求...');

      this.client.connect({
        userName: 'hi3861',
        password: 'public',
        cleanSession: true,
        keepAliveInterval: 60
      }).then(() => {
        console.info('【MQTT追踪】3. ✔️ 成功连接至 EMQX 服务器！开始订阅主题...');

        // 🌟 修复点：不再使用对象字面量数组，显式声明 MqttSubscribeOptions
        const sub1: MqttSubscribeOptions = { topic: 'smart_car/distance', qos: 0 };
        const sub2: MqttSubscribeOptions = { topic: Constants.TOPIC_STATUS, qos: 0 };
        const sub3: MqttSubscribeOptions = { topic: Constants.TOPIC_COUNT_REPORT, qos: 0 };

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
        console.error('【MQTT追踪】❌ 网络连接失败: ', JSON.stringify(connErr));
      });

    } catch (error) {
      console.error('【MQTT追踪】❌ 初始化严重崩溃: ', JSON.stringify(error));
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

  public publishLightControl(cmd: string) {
    if (!this.client) return;

    // 🌟 修复点：使用明确的类实例化
    const msg = new LightCommand();
    msg.cmd = cmd;
    const payload = JSON.stringify(msg);

    // 🌟 修复点：使用明确的 MqttPublishOptions 类型
    const pubOpts: MqttPublishOptions = {
      topic: Constants.TOPIC_CONTROL,
      payload: payload,
      qos: 0,
      retained: false
    };

    this.client.publish(pubOpts)
      .then(() => console.info(`【MQTT控制】-> 成功发送灯光指令: ${payload}`))
      .catch((err: Error) => console.error(`【MQTT控制】❌ 发送灯光指令失败:`, JSON.stringify(err))); // 🌟 修复点：显式 Error 类型
  }

  public publishCountControl(cmd: string, model?: string) {
    if (!this.client) return;

    const msg = new CountCommand();
    msg.cmd = cmd;
    if (model) {
      msg.model = model;
    }
    const payload = JSON.stringify(msg);

    const pubOpts: MqttPublishOptions = {
      topic: Constants.TOPIC_COUNT_CONTROL,
      payload: payload,
      qos: 0,
      retained: false
    };

    this.client.publish(pubOpts)
      .then(() => console.info(`【MQTT控制】-> 成功发送计数指令: ${payload}`))
      .catch((err: Error) => console.error(`【MQTT控制】❌ 发送计数指令失败:`, JSON.stringify(err)));
  }
}