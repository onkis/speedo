//
//  ContentView.swift
//  speedo
//
//  Created by Michael Ball on 6/15/26.
//

import SwiftUI

struct ContentView: View {
    @State private var provider = LocationSpeedProvider()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text(SpeedFormatting.mphString(fromMetersPerSecond: provider.speedMetersPerSecond))
                .font(.system(size: 200, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .padding()
        }
        .onAppear { provider.start() }
        .onChange(of: scenePhase, initial: true) { _, phase in
            // Keep the screen awake only while the app is foregrounded.
            UIApplication.shared.isIdleTimerDisabled = (phase == .active)
        }
    }
}

#Preview {
    ContentView()
}
