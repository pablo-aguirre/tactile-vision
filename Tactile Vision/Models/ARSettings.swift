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
    @Published var frameSemantics: ARConfiguration.FrameSemantics = [.smoothedSceneDepth, .personSegmentationWithDepth]
    @Published var sceneReconstruction: ARConfiguration.SceneReconstruction = [.mesh]
    @Published var planeDetection: ARWorldTrackingConfiguration.PlaneDetection = [.horizontal]
    @Published var fps: Int = 30
}
