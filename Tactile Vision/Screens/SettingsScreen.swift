//
//  OtherSettings.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 12/08/24.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ARSettings.self) private var settings: ARSettings
    
    var body: some View {
        @Bindable var settings = settings
        
        List {
            //HStack {
            //    Image(systemName: "circlebadge.fill").foregroundStyle(.green)
            //    Stepper("Sphere radius: \((settings.radius * 100).formatted(.number.precision(.fractionLength(1)))) cm",
            //            value: settings.radius, in: 0.001...0.05, step: 0.001)
            //}
            //HStack {
            //    Image(systemName: "lines.measurement.vertical").foregroundStyle(.blue)
            //    Stepper("Threshold: \((settings.threshold * 100).formatted(.number.precision(.fractionLength(1)))) cm",
            //            value: settings.threshold, in: 0.001...0.1, step: 0.001)
            //}
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
            .environment(ARSettings())
    }
}
