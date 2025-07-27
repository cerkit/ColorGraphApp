# Live Color Data SwiftUI App
[![Build macOS App (Latest Xcode)](https://github.com/cerkit/ColorGraphApp/actions/workflows/macos-build.yml/badge.svg)](https://github.com/cerkit/ColorGraphApp/actions/workflows/macos-build.yml)

This README describes how to set up and run the Live Color Data SwiftUI chart application in Xcode.

[![Screenshot](https://github.com/cerkit/ColorGraphApp/blob/main/Screenshot.png?raw=true)]

## Requirements

- macOS 14 Ventura or later
- Xcode 15 or later
- Swift 5.9
- iOS 17 / macOS 14 SDK (for Swift Charts)
- Swift Package Manager support

## Installation

1. **Clone the repository** (or copy the project directory):
   ```bash
   git clone https://github.com/cerkit/ColorGraph.git
   cd https://github.com/cerkit/ColorGraph.git
   ```

2. **Open the Xcode project**:
   ```bash
   open ColorGraph.xcodeproj
   ```

3. **Add the MQTTNIO package**:
   - In Xcode, select **File** → **Add Packages...**
   - Enter URL: `https://github.com/adam-fowler/mqtt-nio.git`
   - Choose the latest version and add it to your project.

## Code Structure

- **`ColorGraphApp.swift`**  
  Entry point of the app. Instantiates a single `MQTTService` via `@StateObject` and injects it into the environment.

- **`MQTTService.swift`**  
  Connects to your MQTT broker, subscribes to `sensors/color`, decodes incoming JSON, and publishes updates to `@Published var incomingData`.

- **`IncomingData.swift`**  
  Model struct representing each payload: `timestamp`, `red`, `green`, `blue`.

- **`ContentView.swift`**  
  Main SwiftUI view. Displays a live chart of RGB values over the last 60 seconds with second-level ticks, updating as new messages arrive.

## Configuration

- **Broker settings**: In `MQTTService.connect()`, edit:
  ```swift
  let client = MQTTClient(
      host: "192.168.4.60",
      port: 1883,
      identifier: "YourClientID",
      eventLoopGroupProvider: .createNew
  )
  ```
- **MQTT Topic**: Default is `sensors/color`. Change to match your publisher.

## Running the App

1. Build and run in Xcode on a macOS target or an iOS 17+ simulator/device.
2. Ensure your MQTT broker publishes JSON payloads in this format:
   ```json
   {
     "red": 1526,
     "green": 1093,
     "blue": 1150,
     "timestamp": "2025-07-23T13:33:55Z"
   }
   ```
3. Watch the chart display three colored lines (Red, Green, Blue), sliding to show the most recent 60 seconds of data.

## Customization

- **Time window**: Adjust the `window` constant in `ContentView` for a different span.
- **Axis formatting**: Modify `chartXAxis` for custom tick intervals or date formats.
- **Legend**: `.chartLegend(position: .top, visibility: .visible)` can be moved or hidden.

## Example CircuitPython Code

You can find example `.py` code at [cerkit.com](https://cerkit.com/posts/macos-rgb-color-sensor-mqtt-graph/)

## License

MIT
