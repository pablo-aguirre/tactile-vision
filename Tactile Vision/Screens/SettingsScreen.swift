//
//  OtherSettings.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 12/08/24.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var settings: ARSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            HStack {
                Image(systemName: "circlebadge.fill").foregroundStyle(.green)
                Stepper("Sphere radius: \((settings.radius * 100).formatted(.number.precision(.fractionLength(1)))) cm",
                        value: $settings.radius, in: 0.001...0.05, step: 0.001)
            }
            HStack {
                Image(systemName: "lines.measurement.vertical").foregroundStyle(.blue)
                Stepper("Threshold: \((settings.threshold * 100).formatted(.number.precision(.fractionLength(1)))) cm",
                        value: $settings.threshold, in: 0.001...0.1, step: 0.001)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "xmark.circle") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
            .environmentObject(ARSettings())
    }
}
