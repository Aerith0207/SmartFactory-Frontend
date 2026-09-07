export class SafetyEvent {
  time: string = '';
  level: number = 0;
  title: string = '';
  detail: string = '';
  action: string = '';
  logLevel: string = 'SUCCESS';
  status: string = '已恢复';
}

/**
 * 安全联动演练状态中心。
 * 当前阶段只模拟前端状态与事件记录，不向真实设备发送危险控制指令。
 */
export class SafetySimulationManager {
  private static events: SafetyEvent[] = [];

  public static applyScenario(level: number): void {
    const event = SafetySimulationManager.createEvent(level);
    SafetySimulationManager.events.unshift(event);

    // 演示页只保留最近 10 条，避免长时间操作导致列表无限增长。
    if (SafetySimulationManager.events.length > 10) {
      SafetySimulationManager.events.pop();
    }

    AppStorage.set('safety_level', event.level);
    AppStorage.set('safety_title', event.title);
    AppStorage.set('safety_detail', event.detail);
    AppStorage.set('safety_action', event.action);
    AppStorage.set('safety_time', event.time);
    AppStorage.set('agv_running', event.level !== 3);
    // 每次替换一个新数组，让首页与日志页都能可靠感知事件列表变化。
    AppStorage.set('safety_events', SafetySimulationManager.events.slice());

    const currentSequence = AppStorage.get<number>('safety_event_sequence') ?? 0;
    AppStorage.set('safety_event_sequence', currentSequence + 1);
  }

  public static getEvents(): SafetyEvent[] {
    return SafetySimulationManager.events;
  }

  public static getAlarmCount(): number {
    let count = 0;
    SafetySimulationManager.events.forEach((event: SafetyEvent) => {
      if (event.level > 0) {
        count += 1;
      }
    });
    return count;
  }

  private static createEvent(level: number): SafetyEvent {
    const event = new SafetyEvent();
    event.time = SafetySimulationManager.getCurrentTime();
    event.level = level;

    switch (level) {
      case 1:
        event.title = '一级预警';
        event.detail = '单路气体 ADC 超过阈值或单路 DO 触发报警';
        event.action = '状态上报、灯光警示';
        event.logLevel = 'WARNING';
        event.status = '预警中';
        break;
      case 2:
        event.title = '二级告警';
        event.detail = '双路气体同时报警或单路持续超限 30 秒';
        event.action = '声光报警、通知值班人员、启动通风';
        event.logLevel = 'ERROR';
        event.status = '告警中';
        break;
      case 3:
        event.title = '三级严重';
        event.detail = 'DO 持续报警且 ADC 浓度继续攀升';
        event.action = '切断危险源、停止 AGV、广播疏散报警';
        event.logLevel = 'CRITICAL';
        event.status = '严重';
        break;
      default:
        event.level = 0;
        event.title = '安全状态恢复';
        event.detail = '气体监测通道恢复正常，解除模拟报警';
        event.action = '解除联动、AGV 恢复运行';
        event.logLevel = 'SUCCESS';
        event.status = '已恢复';
        break;
    }

    return event;
  }

  private static getCurrentTime(): string {
    const now = new Date();
    const hour = now.getHours().toString().padStart(2, '0');
    const minute = now.getMinutes().toString().padStart(2, '0');
    const second = now.getSeconds().toString().padStart(2, '0');
    return `${hour}:${minute}:${second}`;
  }
}
