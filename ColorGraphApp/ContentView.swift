import SwiftUI
import Charts

struct ContentView: View {
  @EnvironmentObject private var mqtt: MQTTService

  // how wide the window is (e.g. last 60 seconds)
  private let window: TimeInterval = 60

  var body: some View {
    VStack {
      Text("Live Color Data").font(.title)
        Text("Data points: \(mqtt.incomingData.count)")
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.bottom, 4)

      if mqtt.incomingData.isEmpty {
        Text("Waiting for data…")
      } else {
        // compute the domain end = last message's timestamp
        let end = mqtt.incomingData.last!.timestamp
        let start = end.addingTimeInterval(-window)

        Chart {
          ForEach(mqtt.incomingData) { point in
            LineMark(
              x: .value("Time", point.timestamp),
              y: .value("Value", Double(point.red))
            )
            .foregroundStyle(by: .value("Channel", "Red"))

            LineMark(
              x: .value("Time", point.timestamp),
              y: .value("Value", Double(point.green))
            )
            .foregroundStyle(by: .value("Channel", "Green"))

            LineMark(
              x: .value("Time", point.timestamp),
              y: .value("Value", Double(point.blue))
            )
            .foregroundStyle(by: .value("Channel", "Blue"))
          }
        }
        .chartForegroundStyleScale([
          "Red": .red,
          "Green": .green,
          "Blue": .blue
        ])
        .chartLegend(position: .top)
        .chartLegend(.visible)
        // slide the X‐axis to [end–window … end]
        .chartXScale(domain: start...end)
        .frame(height: 300)
        .padding()
      }
    }
    .padding()
    .task { await mqtt.connect() }
  }
}
