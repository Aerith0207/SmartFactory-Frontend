import { SafetyEvent } from '../utils/SafetySimulationManager';
import { Constants } from '../utils/Constants';

export class GlobalDataCenter {
  static init() {
    // 1. 环境传感与报警状态 (对应 smart_factory/status)
    AppStorage.setOrCreate('env_temp', 0);           // temperature (温度)
    AppStorage.setOrCreate('env_hum', 0);            // humidity (湿度)
    AppStorage.setOrCreate('env_mq2_adc', 0);        // mq2_adc (烟雾浓度)
    AppStorage.setOrCreate('env_mq2_alarm', 0);      // mq2_alarm (烟雾报警 0/1)
    AppStorage.setOrCreate('env_mq7_adc', 0);        // mq7_adc (一氧化碳浓度)
    AppStorage.setOrCreate('env_mq7_alarm', 0);      // mq7_alarm (一氧化碳报警 0/1)

    // 2. 雷达与灯光状态 (对应 smart_factory/status)
    AppStorage.setOrCreate('radar_present', 0);      // radar_present (有人无人 0/1)
    AppStorage.setOrCreate('light_mode', -1);        // light_mode (-1自动，其他根据业务)

    // 3. 生产计数状态 (对应 smart_factory/count/report)
    AppStorage.setOrCreate('count_model', 'A型 ');   // model (当前型号)
    AppStorage.setOrCreate('count_num', 0);          // count (当前计数量)

    // --- 以下保留你原有的 UI 占位控制变量 ---
    AppStorage.setOrCreate('online_temp', true);
    AppStorage.setOrCreate('online_smoke', true);
    AppStorage.setOrCreate('online_co', true);
    AppStorage.setOrCreate('switch_light', false);

    // 4. 安全联动演练状态（正常、一级、二级、三级）
    AppStorage.setOrCreate('safety_level', 0);
    AppStorage.setOrCreate('safety_title', '系统安全');
    AppStorage.setOrCreate('safety_detail', '当前未触发安全演练');
    AppStorage.setOrCreate('safety_action', '设备保持正常运行');
    AppStorage.setOrCreate('safety_time', '--:--:--');
    AppStorage.setOrCreate('safety_event_sequence', 0);
    AppStorage.setOrCreate('safety_events', new Array<SafetyEvent>());
    AppStorage.setOrCreate('agv_running', true);

    // 5. 通信安全运行状态：供控制页如实展示，不再使用固定的 TLS 文案。
    AppStorage.setOrCreate('mqtt_connection_state', '连接中');
    AppStorage.setOrCreate('mqtt_transport_security', Constants.MQTT_TLS_ENABLED ? 'TLS 1.2' : 'TCP 兼容模式');
    AppStorage.setOrCreate('mqtt_payload_security',
      Constants.MQTT_PAYLOAD_ENCRYPTION_ENABLED ? 'AES-256-GCM / HEX' : '明文兼容模式');
    AppStorage.setOrCreate('mqtt_key_security',
      Constants.MQTT_PAYLOAD_ENCRYPTION_ENABLED ? 'HUKS 初始化中' : 'HUKS 待启用');
    AppStorage.setOrCreate('mqtt_last_payload_mode', '--');
  }
}
