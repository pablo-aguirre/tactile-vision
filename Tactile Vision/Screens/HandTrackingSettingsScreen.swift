//
//  HandTrackingSettings.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 10/10/24.
//

import SwiftUI
import ARKit

struct HandTrackingSettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HandTrackingSettings.self) private var handTrackingSettings: HandTrackingSettings
    
    var body: some View {
        @Bindable var handTrackingSettings = handTrackingSettings
        
        List {
            Section("General") {
                Toggle("Tracking", isOn: $handTrackingSettings.trackingEnabled)
                HStack {
                    Text("indexDip")
                    Slider(value: $handTrackingSettings.dipTipFraction, in: 0...1)
                    Text("indexTip")
                }
                VStack {
                    HStack{
                        Text("Height Threshold: \(handTrackingSettings.heightThreshold.formatted(.number)) cm")
                        Spacer()
                    }
                    Slider(value: $handTrackingSettings.heightThreshold, in: 0...20, step: 0.5, minimumValueLabel: Text("0 cm"), maximumValueLabel: Text("20 cm")) { EmptyView() }
                }
            }
            //Section("Target Confidence") {
            //    ForEach(ARConfidenceLevel.allCases, id: \.rawValue) { confidence in
            //        Toggle(confidence.label, isOn: Binding(
            //            get: { handTrackingSettings.tipConfidence.contains(confidence) },
            //            set: { if $0 { handTrackingSettings.tipConfidence.insert(confidence) } else { handTrackingSettings.tipConfidence.remove(confidence) } }
            //        ))
            //    }
            //}
            Section("MCP Confidence") {
                ForEach(ARConfidenceLevel.allCases, id: \.rawValue) { confidence in
                    Toggle(confidence.label, isOn: Binding(
                        get: { handTrackingSettings.mcpConfidence.contains(confidence) },
                        set: { if $0 { handTrackingSettings.mcpConfidence.insert(confidence) } else { handTrackingSettings.mcpConfidence.remove(confidence) } }
                    ))
                }
            }
        }
        .navigationTitle("Hand Tracking Settings")
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
