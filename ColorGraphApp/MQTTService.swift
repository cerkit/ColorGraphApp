//  MQTTService.swift
//  ClimateMonitor

import Foundation
import MQTTNIO   // brings in MQTTClient, MQTTSubscribeInfo, MQTTPublishInfo, etc.
import NIOCore   // for ByteBuffer

@MainActor
class MQTTService: ObservableObject {
    @Published var incomingData: [ColorDataPoint] = []
    private var mqttClient: MQTTClient?

    /// Call this once (e.g. in your `.task {}`) to connect & subscribe.
    func connect() async {
        guard mqttClient == nil else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let client = MQTTClient(
            host: "raspberrypi.local",
            port: 1883,
            identifier: "ColorGraphApp-\(UUID().uuidString.prefix(8))",
            //identifier: "macOS-ClimateMonitor",
            eventLoopGroupProvider: .createNew
        )
        self.mqttClient = client

        do {
            try await client.connect()
            print("✅ Connected to MQTT broker")

            // ← subscribe to your new topic
            let info = MQTTSubscribeInfo(topicFilter: "sensors/color", qos: .atLeastOnce)
            _ = try await client.subscribe(to: [info])
            print("📡 Subscribed to sensors/color")

            client.addPublishListener(named: "ColorListener") { [weak self] result in
                switch result {
                case .success(let publishInfo):
                    // ← only process the new topic
                    guard publishInfo.topicName == "sensors/color" else { return }

                    var buffer = publishInfo.payload
                    guard let jsonString = buffer.readString(length: buffer.readableBytes),
                          let data       = jsonString.data(using: .utf8) else {
                        print("⚠️ Failed to read JSON payload")
                        return
                    }
                    print("🌈 Raw JSON:", jsonString)

                    do {
                        var point = try decoder.decode(ColorDataPoint.self, from: data)
                        // override with "now" instead of the JSON value:
                        point.timestamp = Date()
                        
                        Task { @MainActor in
                            self?.incomingData.append(point)
                            print("📈 Appended – total now:", self?.incomingData.count ?? 0)
                        }
                    } catch {
                        print("❌ JSON decode error:", error)
                    }

                case .failure(let error):
                    print("❌ MQTT listener error:", error)
                }
            }

        } catch {
            print("❌ MQTT connection/subscription failed:", error)
        }
    }

    /// Call this when you want to disconnect (e.g. in your App’s shutdown)
    func disconnect() async {
        guard let client = mqttClient else { return }
        do {
            try await client.disconnect()
            try client.syncShutdownGracefully()
            print("✅ MQTT client disconnected")
        } catch {
            print("❌ MQTT shutdown error:", error)
        }
        mqttClient = nil
    }
}


extension MQTTService {
    /// Injects a fake JSON payload for testing
    func handleMockMessage(payload: String) {
        guard let data = payload.data(using: .utf8) else {
            print("❌ Could not convert payload to Data")
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let decoded = try? decoder.decode(ColorDataPoint.self, from: data) else {
            print("❌ Could not decode ColorDataPoint from payload")
            return
        }

        DispatchQueue.main.async {
            self.incomingData.append(decoded)
        }
    }

    
    /// Decodes a JSON payload and appends to incomingData.
    /// Callable from tests.
    func handlePublish(topic: String, payload bufferParam: ByteBuffer) async {
        var buffer = bufferParam

        // Only process the color topic
        guard topic == "sensors/color" else { return }

        // Extract string → Data
        guard let jsonString = buffer.readString(length: buffer.readableBytes),
              let data       = jsonString.data(using: .utf8)
        else { return }

        // Decode
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let point = try decoder.decode(ColorDataPoint.self, from: data)
            await MainActor.run {
                self.incomingData.append(point)
            }
        } catch {
            // swallow in test handler
        }
    }
}

