//
//  ARWorldTrackingConfiguration+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 08/08/24.
//

import ARKit

extension ARWorldTrackingConfiguration.PlaneDetection {
    static var allOptions: [ARWorldTrackingConfiguration.PlaneDetection] {
        return [
            .horizontal,
            .vertical
        ]
    }
    
    var description: String {
        return switch self {
        case .horizontal: "Horizontal"
        case .vertical: "Vertical"
        default: "?"
        }
    }
}
