//
//  ARDepthData+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 19/09/24.
//

import ARKit

extension ARConfidenceLevel: @retroactive CaseIterable {
    
    public init?(rawValue: UInt8) {
        self.init(rawValue: Int(rawValue))
    }
    
    public static var allCases: [ARConfidenceLevel] {
        [.low, .medium, .high]
    }
    
    var label: String {
        return switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        default: "Unknown"
        }
    }
    
    var color: UIColor {
        return switch self {
        case .low: .red
        case .medium: .green
        case .high: .blue
        default: .white
        }
    }
}
