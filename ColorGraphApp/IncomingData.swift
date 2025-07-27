//
//  IncomingData.swift
//  ClimateMonitor
//
//  Created by Michael Earls on 7/25/25.
//

import Foundation

struct IncomingDataPoint: Codable, Identifiable {
    let id = UUID()
    let red: Int
    let green: Int
    let blue: Int
    var timestamp: Date
    

    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case timestamp
    }
}
