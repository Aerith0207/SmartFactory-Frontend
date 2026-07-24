// src/main/ets/data/GlobalDataCenter.ets

export class GlobalDataCenter {
  static init() {
    // 1. 环境传感实时采样值
    AppStorage.setOrCreate('env_temp', '26.8');
    AppStorage.setOrCreate('env_hum', '55');
    AppStorage.setOrCreate('env_smoke', '12');
    AppStorage.setOrCreate('env_co', '35');
    AppStorage.setOrCreate('env_photoelectric', '315');

    // 2. 设备在线状态 (心跳)
    AppStorage.setOrCreate('online_temp', true);
    AppStorage.setOrCreate('online_smoke', true);
    AppStorage.setOrCreate('online_co', true);
    AppStorage.setOrCreate('online_agv', true);
    AppStorage.setOrCreate('online_light', true);

    // 3. 设备开关控制状态
    AppStorage.setOrCreate('switch_temp', true);
    AppStorage.setOrCreate('switch_smoke', true);
    AppStorage.setOrCreate('switch_co', true);
    AppStorage.setOrCreate('switch_photoelectric', true);
    AppStorage.setOrCreate('switch_light', false); // 红外照明模块

    // 4. AGV 雷达与运行状态
    AppStorage.setOrCreate('agv_status', '运行中');
    AppStorage.setOrCreate('agv_radar_front', '120');
    AppStorage.setOrCreate('agv_radar_left', '65');
    AppStorage.setOrCreate('agv_radar_right', '80');
    AppStorage.setOrCreate('agv_radar_back', '150');
  }
}