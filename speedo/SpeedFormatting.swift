//
//  SpeedFormatting.swift
//  speedo
//
//  Pure, testable conversion from GPS speed (meters/second) to a display string.
//

import Foundation

enum SpeedFormatting {
    /// Meters/second to miles/hour.
    private static let mphPerMetersPerSecond = 2.2369362920544

    /// Renders a GPS speed as a whole-number mph string.
    ///
    /// `CLLocation.speed` is `-1` when the speed is unavailable, and `nil` here means
    /// no fix has arrived yet — both render as `"--"`.
    static func mphString(fromMetersPerSecond mps: Double?) -> String {
        guard let mps, mps >= 0 else { return "--" }
        let mph = mps * mphPerMetersPerSecond
        return String(Int(mph.rounded()))
    }
}
