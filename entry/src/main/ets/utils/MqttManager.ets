// src/main/ets/utils/MqttManager.ets
import {
  MqttAsync,
  MqttClient,
  MqttSubscribeOptions,
  MqttMessage // 🌟 新增：导入 MqttMessage 标准类型
} from '@ohos/mqtt';
import util from '@ohos.util';

interface AgvPayload {
  front?: number;
  back?: number;
  left?: number;
  right?: number;
  unit?: string;
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

      // 🌟 修复点：明确给 msg 加上 MqttMessage 类型，消除 arkts-no-any-unknown 报错
      this.client.messageArrived((err: Error, msg: MqttMessage) => {
        if (err) {
          console.error('【MQTT追踪】接收消息发生错误:', JSON.stringify(err));
          return;
        }
        if (msg) {
          // 🌟 修复点：使用显式类型断言 (as string) 保证 ArkTS 校验通过
          const topic = (msg.topic as string) ?? '';
          let payload = '';

          // 提取真实载荷并断言类型
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

        const subOpts: MqttSubscribeOptions = {
          topic: 'smart_car/distance',
          qos: 0
        };

        this.client?.subscribe(subOpts)
          .then(() => {
            console.info('【MQTT追踪】✔️ 成功订阅小车测距主题: smart_car/distance，等待数据...');
          })
          .catch((subErr: Error) => {
            console.error('【MQTT追踪】❌ 订阅失败: ', JSON.stringify(subErr));
          });
      }).catch((connErr: Error) => {
        console.error('【MQTT追踪】❌ 网络连接失败: ', JSON.stringify(connErr));
      });

    } catch (error) {
      console.error('【MQTT追踪】❌ 初始化严重崩溃: ', JSON.stringify(error));
    }
  }

  private handleAgvDistance(payloadString: string) {
    console.info(`【MQTT追踪】5. 开始解析 JSON 载荷: ${payloadString}`);
    try {
      const cleanPayload = payloadString.replace(/^pub\s*/, '');
      const data = JSON.parse(cleanPayload) as AgvPayload;

      console.info(`【MQTT追踪】6. JSON解析成功! 提取数值 -> 前:${data.front}, 后:${data.back}, 左:${data.left}, 右:${data.right}`);

      if (data.front !== undefined) AppStorage.setOrCreate('agv_radar_front', data.front.toString());
      if (data.back !== undefined) AppStorage.setOrCreate('agv_radar_back', data.back.toString());
      if (data.left !== undefined) AppStorage.setOrCreate('agv_radar_left', data.left.toString());
      if (data.right !== undefined) AppStorage.setOrCreate('agv_radar_right', data.right.toString());

      console.info('【MQTT追踪】7. ✨ AppStorage 全局状态已更新，UI 应该已经刷新！');

    } catch (e) {
      console.error('【MQTT追踪】❌ 小车 JSON 数据格式不对，解析失败:', payloadString, JSON.stringify(e));
    }
  }
}