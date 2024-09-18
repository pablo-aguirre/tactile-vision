//
//  ARView+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 06/08/24.
//

import RealityKit

extension ARView.DebugOptions {
    static var allOptions: [ARView.DebugOptions] {
        return [
            .showPhysics,
            .showStatistics,
            .showAnchorOrigins,
            .showAnchorGeometry,
            .showWorldOrigin,
            .showFeaturePoints,
            .showSceneUnderstanding
        ]
    }
    
    var description: String {
        return switch self {
        case .showPhysics: "Show Physics"
        case .showStatistics: "Show Statistics"
        case .showAnchorOrigins: "Show Anchor Origins"
        case .showAnchorGeometry: "Show Anchor Geometry"
        case .showWorldOrigin: "Show World Origin"
        case .showFeaturePoints: "Show Feature Points"
        case .showSceneUnderstanding: "Show scene understanding"
        default: "rawValue: \(self.rawValue)"
        }
    }
}

extension ARView.Environment.SceneUnderstanding.Options {
    static var allOptions: [ARView.Environment.SceneUnderstanding.Options] {
        return [
            .collision,
            .occlusion,
            .physics
        ]
    }
    
    var description: String {
        return switch self {
        case .collision: "Collision detection with the environment"
        case .occlusion: "Occlusion of objects by the environment"
        case .physics: "Physics interactions with the environment"
        default: "rawValue: \(self.rawValue)"
        }
    }
}
