//
//  ARView+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 06/08/24.
//

import RealityKit
import ARKit

extension ARView {
    
    func updateOrAddEntity(named entityName: String, at position: SIMD3<Float>, radius: Float = 0.005, color: UIColor = .green) {
        if let existingEntity = self.scene.findEntity(named: entityName) {
            existingEntity.setPosition(position, relativeTo: nil)
        } else {
            DispatchQueue.main.async {
                let anchorEntity = AnchorEntity(world: position)
                anchorEntity.name = entityName
                
                let modelEntity = ModelEntity(
                    mesh: .generateSphere(radius: radius),
                    materials: [SimpleMaterial(color: color, isMetallic: false)]
                )
                
                anchorEntity.addChild(modelEntity)
                
                self.scene.addAnchor(anchorEntity)
            }
        }
    }
    
}

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
