//
//  SettingsView.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 05/08/24.
//
import SwiftUI
import RealityKit
import ARKit

struct ARSettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var arSettings: ARSettings
    
    var body: some View {
        List {
            Section("Debug Options") {
                ForEach(ARView.DebugOptions.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: $arSettings.debugOptions.bind(option))
                }
            }
            Section("Environment options") {
                ForEach(ARView.Environment.SceneUnderstanding.Options.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: $arSettings.sceneUnderstandingOptions.bind(option))
                }
            }
            Section("Frame semantics") {
                ForEach(ARConfiguration.FrameSemantics.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: $arSettings.frameSemantics.bind(option))
                }
            }
            Section("Scene reconstruction") {
                ForEach(ARConfiguration.SceneReconstruction.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: $arSettings.sceneReconstruction.bind(option))
                }
            }
            Section("Plane detection") {
                ForEach(ARWorldTrackingConfiguration.PlaneDetection.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: $arSettings.planeDetection.bind(option))
                }
            }
            Section("FPS") {
                Picker("Frame per second", selection: $arSettings.fps) {
                    Text("30").tag(30)
                    Text("60").tag(60)
                }.pickerStyle(.segmented)
            }
        }
        .navigationTitle("AR Settings")
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



