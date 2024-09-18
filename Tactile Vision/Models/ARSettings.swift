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
    @Published var sceneUnderstandingOptions: ARView.Environment.SceneUnderstanding.Options = []
    @Published var frameSemantics: ARConfiguration.FrameSemantics = []
    @Published var sceneReconstruction: ARConfiguration.SceneReconstruction = []
    @Published var planeDetection: ARWorldTrackingConfiguration.PlaneDetection = []
    @Published var fps: Int = 30
}
