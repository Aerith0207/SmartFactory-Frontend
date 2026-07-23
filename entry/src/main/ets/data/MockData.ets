export interface AgvData {
  front: number;
  back: number;
  left: number;
  right: number;
}

export interface DashboardData {
  systemTime: string;
  temperature: number;
  humidity: number;
  co: number;
  smoke: number;
  safeIndex: number;
  agv: AgvData;
  onlineCount: number;
  totalCount: number;
  alarmCount: number;
  todayCount: number;
  qualifiedRate: number;
}

export const MockData: DashboardData = {
  systemTime: '2026-07-23 19:21:35',
  temperature: 26,
  humidity: 52,
  co: 18,
  smoke: 0.03,
  safeIndex: 98,
  agv: { front: 120, back: 100, left: 80, right: 65 },
  onlineCount: 5,
  totalCount: 5,
  alarmCount: 0,
  todayCount: 458,
  qualifiedRate: 98.6
};
