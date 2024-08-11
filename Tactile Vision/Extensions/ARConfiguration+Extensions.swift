//
//  ARConfiguration+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 08/08/24.
//

import ARKit

extension ARConfiguration.FrameSemantics {
    static var allOptions: [ARConfiguration.FrameSemantics] {
        return [
            .bodyDetection,
            .personSegmentation,
            .personSegmentationWithDepth,
            .sceneDepth,
            .smoothedSceneDepth
        ]
    }
    
    var description: String {
        return switch self {
        case .bodyDetection: "Body detection"
        case .personSegmentation: "Person segmentation"
        case .personSegmentationWithDepth: "Person segmentation with depth"
        case .sceneDepth: "Scene depth"
        case .smoothedSceneDepth: "Smoothed scene depth"
        default: "rawValue : \(self.rawValue)"
        }
    }
}

extension ARConfiguration.SceneReconstruction {
    static var allOptions: [ARConfiguration.SceneReconstruction] {
        return [
            .mesh,
            .meshWithClassification
        ]
    }
    
    var description: String {
        return switch self {
        case .mesh: "Mesh"
        case .meshWithClassification: "Mesh with classification"
        default: "rawValue : \(self.rawValue)"
        }
    }
}
