//
//  speedoTests.swift
//  speedoTests
//
//  Created by Michael Ball on 6/15/26.
//

import Testing
@testable import speedo

struct SpeedFormattingTests {

    @Test func stoppedReadsZero() async throws {
        #expect(SpeedFormatting.mphString(fromMetersPerSecond: 0) == "0")
    }

    @Test func sixtyMilesPerHour() async throws {
        // 26.8224 m/s == 60 mph exactly
        #expect(SpeedFormatting.mphString(fromMetersPerSecond: 26.8224) == "60")
    }

    @Test func roundsToNearestWhole() async throws {
        // 4.4704 m/s == 10 mph exactly
        #expect(SpeedFormatting.mphString(fromMetersPerSecond: 4.4704) == "10")
    }

    @Test func nilSpeedReadsPlaceholder() async throws {
        #expect(SpeedFormatting.mphString(fromMetersPerSecond: nil) == "--")
    }

    @Test func invalidNegativeSpeedReadsPlaceholder() async throws {
        // CLLocation reports -1 when speed is unavailable
        #expect(SpeedFormatting.mphString(fromMetersPerSecond: -1) == "--")
    }

}
