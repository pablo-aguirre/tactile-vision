//
//  MediaPipeModel.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 10/10/24.
//

import ARKit

@Observable
class HandTrackingSettings {
    var trackingEnabled: Bool = true
    var gesture: String = ""
    var coords: SIMD3<Float> = .zero
    var distanceFromTable: Float = .zero
    var dipTipFraction: Float = 1
    
    var mcpConfidence: Set<ARConfidenceLevel> = [.high, .medium]
    var targetConfidence: Set<ARConfidenceLevel> = [.high, .medium]
    var heightThreshold: Float = 10 // cm
}
