// src/main/ets/components/EnvironmentCard.ets
import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { MockData } from '../data/MockData';

@Component
export struct EnvironmentCard {
  // 控制安全指数进场动画的状态变量
  @State currentSafeIndex: number = 0;

  // 注入全局单向绑定变量
  @StorageProp('env_temp') envTemp: string = '26';
  @StorageProp('env_hum') envHum: string = '52';
  @StorageProp('env_co') envCo: string = '18';
  @StorageProp('env_smoke') envSmoke: string = '0.03';

  aboutToAppear() {
    // 延迟一点时间后触发动画，让进场更自然
    setTimeout(() => {
      animateTo({ duration: 1500, curve: Curve.FastOutSlowIn }, () => {
        this.currentSafeIndex = MockData.safeIndex;
      });
    }, 200);
  }

  build() {
    Column() {
      Row() {
        Text('环境安全指标').fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
      }
      .width(Constants.FullWidth).padding(Constants.DefaultPadding).border({ width: { bottom: 1 }, color: Colors.BorderSoft })

      Column() {
        Stack() {
          // 环形进度条，加入了霓虹发光阴影
          Progress({ value: this.currentSafeIndex, total: 100, type: ProgressType.Ring })
            .width(116)
            .height(116)
            .color(Colors.Normal)
            .style({ strokeWidth: 10 })

          Column({ space: 4 }) {
            // 中心数值跟随动画进度动态增长
            Text(`${Math.floor(this.currentSafeIndex)}`)
              .fontColor(Colors.Title)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
            Text('安全指数')
              .fontColor(Colors.TextNormal)
              .fontSize(14)
          }
        }
        .margin({ top: 15, bottom: 15 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          // 修改点：将 MockData 替换为绑定的全局变量
          this.MetricItem('温度', `${this.envTemp}℃`, Colors.Cyan)
          this.MetricItem('湿度', `${this.envHum}%RH`, Colors.Normal)
          this.MetricItem('CO 浓度', `${this.envCo} ppm`, Colors.Warning)
          this.MetricItem('烟雾浓度', `${this.envSmoke}%`, Colors.Normal)
        }
        .width('90%')
      }
      .layoutWeight(1).width(Constants.FullWidth).justifyContent(FlexAlign.Center)
    }
    .width(Constants.FullWidth).height(Constants.FullHeight).backgroundColor(Colors.PanelBg).borderRadius(Constants.CardRadius).border({ width: Constants.BorderWidth, color: Colors.BorderSoft })
  }

  @Builder
  MetricItem(name: string, value: string, valueColor: string) {
    Column({ space: 4 }) {
      Text(name).fontColor(Colors.TextNormal).fontSize(14)
      Row({ space: 5 }) {
        Circle({ width: 5, height: 5 }).fill(valueColor)
        Text(value).fontColor(Colors.Title).fontSize(20).fontWeight(FontWeight.Bold)
      }
    }.width('48%').margin({ bottom: 14 }).alignItems(HorizontalAlign.Start)
  }
}