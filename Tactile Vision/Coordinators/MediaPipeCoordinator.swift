//
//  MediaPipeCoordinator.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 17/09/24.
//

import ARKit
import MediaPipeTasksVision
import BlueDress
import SwiftUI
import RealityKit

class MediaPipeCoordinator: NSObject, ARSessionDelegate {
    weak var arView: ARView?
    private let bufferConverter: YCbCrImageBufferConverter? = try? YCbCrImageBufferConverter()
    private var gestureRecognizer: GestureRecognizerService?
    let handTrackingSettings: HandTrackingSettings
    
    init(handTrackingSettings: HandTrackingSettings) {
        self.handTrackingSettings = handTrackingSettings
        super.init()
        self.gestureRecognizer = .liveStreamGestureRecognizerService(
            modelPath: "gesture_recognizer.task",
            minHandDetectionConfidence: 0.8,
            minHandPresenceConfidence: 0.8,
            minTrackingConfidence: 0.8,
            delegate: .GPU,
            liveStreamDelegate: self
        )
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard handTrackingSettings.trackingEnabled, let buffer = try? bufferConverter?.convertToBGRA(imageBuffer: frame.capturedImage) else { return }
        
        gestureRecognizer?.recognizeAsync(pixelBuffer: buffer, timeStamp: frame.timestampInMilliseconds)
    }
}

extension MediaPipeCoordinator: GestureRecognizerLiveStreamDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: GestureRecognizer, didFinishGestureRecognition result: GestureRecognizerResult?, timestampInMilliseconds: Int, error: (any Error)?) {
        guard let result, let landmark = result.landmarks.first, let arView = arView, let currentFrame = arView.session.currentFrame else { return }
        
        let gesture = result.gestures.first?.first
        handTrackingSettings.gesture = gesture?.label ?? ""
        
        let mcp2D = landmark[5].point
        
        guard let (mcp3D, mcpDepthConfidence) = currentFrame.worldPoint(at: mcp2D, withConfidenceIn: handTrackingSettings.mcpConfidence) else { return }
        arView.updateOrAddEntity(named: "MCP", at: mcp3D, color: mcpDepthConfidence.color)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let mcpCollisionResult = arView.scene.raycast(origin: mcp3D, direction: [0, -1, 0], mask: .sceneUnderstanding).max(by: { $0.distance < $1.distance }) {
                arView.updateOrAddEntity(named: "underMCP", at: mcpCollisionResult.position, color: mcpDepthConfidence.color)
                
                if mcpCollisionResult.distance * 100 < handTrackingSettings.heightThreshold && gesture?.categoryName == "Pointing_Up" {
                    let tip2D = landmark[8].point
                    let dip2D = landmark[7].point
                    let target = CGPoint.intermediate(point1: dip2D, point2: tip2D, fraction: handTrackingSettings.dipTipFraction)
                    
                    let query = currentFrame.raycastQuery(from: target, allowing: .estimatedPlane, alignment: .any)
                    if let raycastResult = arView.session.raycast(query).last {
                        arView.updateOrAddEntity(named: "TARGET", at: raycastResult.worldTransform.position, color: .red)
                    }
                }
            }
        }
    }
    
}
