//
//  ColorGraphApp.swift
//  ColorGraph
//
//  Created by Michael Earls on 7/23/25.
//
import SwiftUI

@main
struct ColorGraphAppApp: App {
    // Create exactly one MQTTService for the whole app
    @StateObject private var mqtt = MQTTService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mqtt)   // inject it into SwiftUI’s environment
        }
    }
}
