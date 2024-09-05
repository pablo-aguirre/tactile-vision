//
//  SessionSettings.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 05/08/24.
//

import Foundation
import RealityKit
import ARKit

class ARSettings: ObservableObject {
    @Published var debugOptions: ARView.DebugOptions = []
    @Published var environmentOptions: ARView.Environment.SceneUnderstanding.Options = [.physics]
    @Published var frameOptions: ARConfiguration.FrameSemantics = [.smoothedSceneDepth]
    @Published var sceneOptions: ARConfiguration.SceneReconstruction = [.mesh, .meshWithClassification]
    @Published var planeOptions: ARWorldTrackingConfiguration.PlaneDetection = [.horizontal]
    
    @Published var radius: Float = 0.005
    @Published var threshold: Float = 0.001
    @Published var cleanTouches: Bool = false
    
    @Published var coords: SIMD3<Float> = .zero
    @Published var distance: Float = 0
}
