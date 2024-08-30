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
    @EnvironmentObject private var settings: ARSettings
    
    var body: some View {
        List {
            Section("Debug Options") {
                ForEach(ARView.DebugOptions.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: Binding(
                        get: { settings.debugOptions.contains(option) },
                        set: { toggleEnabled in
                            if toggleEnabled {
                                settings.debugOptions.insert(option)
                            } else {
                                settings.debugOptions.remove(option)
                            }
                        })
                    )
                }
            }
            Section("Environment options") {
                ForEach(ARView.Environment.SceneUnderstanding.Options.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: Binding(
                        get: { settings.environmentOptions.contains(option) },
                        set: { toggleEnabled in
                            if toggleEnabled {
                                settings.environmentOptions.insert(option)
                            } else {
                                settings.environmentOptions.remove(option)
                            }
                        })
                    )
                }
            }
            Section("Frame semantics") {
                ForEach(ARConfiguration.FrameSemantics.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: Binding(
                        get: { settings.frameOptions.contains(option) },
                        set: { toggleEnabled in
                            if toggleEnabled && ARWorldTrackingConfiguration.supportsFrameSemantics(option.union(settings.frameOptions)) {
                                settings.frameOptions.insert(option)
                            } else if ARWorldTrackingConfiguration.supportsFrameSemantics(option.subtracting(settings.frameOptions)){
                                settings.frameOptions.remove(option)
                            }
                        })
                    )
                }
            }
            Section("Scene reconstruction") {
                ForEach(ARConfiguration.SceneReconstruction.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: Binding(
                        get: { settings.sceneOptions.contains(option) },
                        set: { toggleEnabled in
                            if toggleEnabled && ARWorldTrackingConfiguration.supportsSceneReconstruction(option.union(settings.sceneOptions)) {
                                settings.sceneOptions.insert(option)
                            } else if ARWorldTrackingConfiguration.supportsSceneReconstruction(settings.sceneOptions.subtracting(option)){
                                settings.sceneOptions.remove(option)
                            }
                        })
                    )
                }
            }
            Section("Plane detection") {
                ForEach(ARWorldTrackingConfiguration.PlaneDetection.allOptions, id: \.rawValue) { option in
                    Toggle(option.description, isOn: Binding(
                        get: { settings.planeOptions.contains(option) },
                        set: { toggleEnabled in
                            if toggleEnabled {
                                settings.planeOptions.insert(option)
                            } else {
                                settings.planeOptions.remove(option)
                            }
                        })
                    )
                }
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

#Preview {
    NavigationStack {
        ARSettingsScreen()
            .environmentObject(ARSettings())
    }
}
