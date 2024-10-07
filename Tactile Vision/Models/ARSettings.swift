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
    @Published var debugOptions: ARView.DebugOptions = [.showSceneUnderstanding]
    @Published var sceneUnderstandingOptions: ARView.Environment.SceneUnderstanding.Options = [.collision]
    @Published var frameSemantics: ARConfiguration.FrameSemantics = [.smoothedSceneDepth]
    @Published var sceneReconstruction: ARConfiguration.SceneReconstruction = [.mesh]
    @Published var planeDetection: ARWorldTrackingConfiguration.PlaneDetection = [.horizontal, .vertical]
    @Published var fps: Int = 30
}
