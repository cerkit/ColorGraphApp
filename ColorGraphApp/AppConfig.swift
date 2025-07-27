//
//  AppConfig.swift
//  ColorGraphApp
//
//  Created by Michael Earls on 7/27/25.
//

import Foundation

struct AppConfig {
    static let shared = AppConfig()

    let mqttBrokerAddress: String
    let mqttPort: Int
    let useTLS: Bool

    private init() {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            fatalError("❌ Could not load Config.plist")
        }

        mqttBrokerAddress = plist["MQTTBrokerAddress"] as? String ?? "localhost"
        mqttPort = plist["MQTTPort"] as? Int ?? 1883
        useTLS = plist["UseTLS"] as? Bool ?? false
    }
}
