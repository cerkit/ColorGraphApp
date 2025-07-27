//
//  ColorDataPoint.swift
//  ColorGraphApp
//
//  Created by Michael Earls on 7/26/25.
//

import Foundation

struct ColorDataPoint: Identifiable, Codable {
    let id = UUID()
    var timestamp: Date
    let red: Double
    let green: Double
    let blue: Double
}
