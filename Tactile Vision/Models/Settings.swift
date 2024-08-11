//
//  SessionSettings.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 05/08/24.
//

import Foundation
import RealityKit
import ARKit

class Settings: ObservableObject {
    @Published var debugOptions: ARView.DebugOptions = []
    @Published var environmentOptions: ARView.Environment.SceneUnderstanding.Options = []
    @Published var frameOptions: ARConfiguration.FrameSemantics = [.smoothedSceneDepth]
    @Published var sceneOptions: ARConfiguration.SceneReconstruction = []
    @Published var planeOptions: ARWorldTrackingConfiguration.PlaneDetection = [.horizontal]
}
