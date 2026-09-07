// src/main/ets/components/EnvironmentCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';

@Component
export struct EnvironmentCard {
  @StorageProp('safety_level') safetyLevel: number = 0;

  // 严格声明为 number 类型，与 GlobalDataCenter 及 JSON 解析结果对齐
  @StorageProp('env_temp') envTemp: number = 26;
  @StorageProp('env_hum') envHum: number = 55;
  @StorageProp('env_mq7_adc') envCo: number = 18;
  @StorageProp('env_mq2_adc') envSmoke: number = 12;

  build() {
    Column() {
      Row() {
        Text('环境安全指标').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column() {
        Stack() {
          Progress({ value: this.GetSafeIndex(), total: 100, type: ProgressType.Ring })
            .width(116).height(116).color(this.GetSafetyColor()).style({ strokeWidth: 10 })

          Column({ space: 4 }) {
            Text(`${this.GetSafeIndex()}`).fontColor(this.GetSafetyColor()).fontSize(36).fontWeight(FontWeight.Bold)
            Text(this.GetSafetyLabel()).fontColor(Colors.TextNormal).fontSize(14)
          }
        }.margin({ top: 15, bottom: 15 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          this.MetricItem(0)
          this.MetricItem(1)
          this.MetricItem(2)
          this.MetricItem(3)
        }.width('90%')
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  GetSafeIndex(): number {
    if (this.safetyLevel === 1) return 75;
    if (this.safetyLevel === 2) return 45;
    if (this.safetyLevel === 3) return 15;
    return 100;
  }

  GetSafetyLabel(): string {
    if (this.safetyLevel === 1) return '一级预警';
    if (this.safetyLevel === 2) return '二级告警';
    if (this.safetyLevel === 3) return '三级严重';
    return '安全指数';
  }

  GetSafetyColor(): string {
    if (this.safetyLevel === 0) return Colors.Normal;
    if (this.safetyLevel === 1) return Colors.Warning;
    if (this.safetyLevel === 2) return Colors.Alarm;
    return Colors.Danger;
  }

  GetDisplayedTemperature(): number {
    if (this.safetyLevel === 1) return 30;
    if (this.safetyLevel === 2) return 36;
    if (this.safetyLevel === 3) return 43;
    return this.envTemp;
  }

  GetDisplayedHumidity(): number {
    if (this.safetyLevel === 1) return 65;
    if (this.safetyLevel === 2) return 74;
    if (this.safetyLevel === 3) return 82;
    return this.envHum;
  }

  GetDisplayedSmoke(): number {
    if (this.safetyLevel === 1) return 2300;
    if (this.safetyLevel === 2) return 2750;
    if (this.safetyLevel === 3) return 3600;
    return this.envSmoke;
  }

  GetDisplayedCo(): number {
    if (this.safetyLevel === 2) return 2400;
    if (this.safetyLevel === 3) return 3300;
    return this.envCo;
  }

  GetGasColor(isSmoke: boolean): string {
    if (this.safetyLevel === 2) return Colors.Alarm;
    if (this.safetyLevel === 3) return Colors.Danger;
    if (this.safetyLevel === 1 && isSmoke) return Colors.Warning;
    return Colors.Normal;
  }

  GetClimateColor(normalColor: string): string {
    if (this.safetyLevel === 1) return Colors.Warning;
    if (this.safetyLevel === 2) return Colors.Alarm;
    if (this.safetyLevel === 3) return Colors.Danger;
    return normalColor;
  }

  GetMetricName(metricType: number): string {
    if (metricType === 0) return '温度';
    if (metricType === 1) return '湿度';
    if (metricType === 2) return 'CO 浓度';
    return '烟雾浓度';
  }

  GetMetricValue(metricType: number): string {
    if (metricType === 0) return `${this.GetDisplayedTemperature()}℃`;
    if (metricType === 1) return `${this.GetDisplayedHumidity()}%RH`;
    if (metricType === 2) return `${this.GetDisplayedCo()} adc`;
    return `${this.GetDisplayedSmoke()} adc`;
  }

  GetMetricColor(metricType: number): string {
    if (metricType === 0) return this.GetClimateColor(Colors.Cyan);
    if (metricType === 1) return this.GetClimateColor(Colors.Normal);
    if (metricType === 2) return this.GetGasColor(false);
    return this.GetGasColor(true);
  }

  @Builder MetricItem(metricType: number) {
    Column({ space: 4 }) {
      Text(this.GetMetricName(metricType)).fontColor(Colors.TextNormal).fontSize(14)
      Row({ space: 5 }) {
        Circle({ width: 5, height: 5 }).fill(this.GetMetricColor(metricType))
        Text(this.GetMetricValue(metricType)).fontColor(this.GetMetricColor(metricType)).fontSize(20).fontWeight(FontWeight.Bold)
      }
    }.width('48%').margin({ bottom: 14 }).alignItems(HorizontalAlign.Start)
  }
}
