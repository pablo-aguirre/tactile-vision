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
    @Published var environmentOptions: ARView.Environment.SceneUnderstanding.Options = []
    @Published var frameOptions: ARConfiguration.FrameSemantics = [.smoothedSceneDepth]
    @Published var sceneOptions: ARConfiguration.SceneReconstruction = [.mesh]
    @Published var planeOptions: ARWorldTrackingConfiguration.PlaneDetection = [.horizontal]
    
    @Published var radius: Float = 0.01
    @Published var height: Float = 0.001
    @Published var cleanTouches: Bool = false
}
