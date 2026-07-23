import { Colors } from '../utils/Colors';
import { Constants } from '../utils/Constants';
import { Header } from '../components/Header';
import { DeviceStatusCard } from '../components/DeviceStatusCard';
import { EnvironmentCard } from '../components/EnvironmentCard';
import { AgvCard } from '../components/AgvCard';
import { CounterCard } from '../components/CounterCard';
import { AlarmCard } from '../components/AlarmCard';
import { FactoryOverviewCard } from '../components/FactoryOverviewCard';
import { TrendChart } from '../components/TrendChart';

@Entry
@Component
struct DashboardPage {
  build() {
    Column() {
      Header()

      Row({ space: Constants.PanelGap }) {
        Column({ space: Constants.PanelGap }) {
          DeviceStatusCard().layoutWeight(1)
          EnvironmentCard().layoutWeight(1)
        }
        .layoutWeight(1.05)
        .height(Constants.FullHeight)

        Column({ space: Constants.PanelGap }) {
          FactoryOverviewCard().layoutWeight(1.15)
          TrendChart().layoutWeight(0.85)
        }
        .layoutWeight(2.15)
        .height(Constants.FullHeight)

        Column({ space: Constants.PanelGap }) {
          AgvCard().layoutWeight(1.05)
          CounterCard().layoutWeight(1)
          AlarmCard().layoutWeight(0.95)
        }
        .layoutWeight(1.05)
        .height(Constants.FullHeight)
      }
      .width(Constants.FullWidth)
      .height('88%')
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    }
    .width(Constants.FullWidth)
    .height(Constants.FullHeight)
    .backgroundColor(Colors.Background)
  }
}
