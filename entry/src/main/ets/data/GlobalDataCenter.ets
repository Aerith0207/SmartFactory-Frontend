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
  }
}