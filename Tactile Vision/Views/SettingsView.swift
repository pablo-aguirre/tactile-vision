//
//  OtherSettings.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 12/08/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: ARSettings
    @Binding var show: Bool
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Image(systemName: "circlebadge.fill")
                        .foregroundStyle(.green)
                    Text("Radius: \((settings.radius * 100).formatted(.number.precision(.fractionLength(1)))) cm")
                        .frame(minWidth: 100, alignment: .leading)
                    Slider(value: $settings.radius, in: 0.005...0.1, step: 0.001)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "xmark.circle") {
                        show.toggle()
                    }
                }
            }
        }
    }
}
