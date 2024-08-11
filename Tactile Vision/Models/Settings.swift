//
//  SessionSettings.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 05/08/24.
//

import Foundation
import RealityKit
import ARKit

@Observable
class Settings {
    var debugOptions: ARView.DebugOptions = []
    var environmentOptions: ARView.Environment.SceneUnderstanding.Options = []
    var frameOptions: ARConfiguration.FrameSemantics = []
    var sceneOptions: ARConfiguration.SceneReconstruction = []
    var planeOptions: ARWorldTrackingConfiguration.PlaneDetection = []
}
