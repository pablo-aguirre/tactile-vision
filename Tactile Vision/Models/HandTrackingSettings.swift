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
    var dipTipFraction: Float = 1
    
    var mcpConfidence: Set<ARConfidenceLevel> = [.high]
    var targetConfidence: Set<ARConfidenceLevel> = [.high, .medium]
    var heightThreshold: Float = 10 // cm
}
