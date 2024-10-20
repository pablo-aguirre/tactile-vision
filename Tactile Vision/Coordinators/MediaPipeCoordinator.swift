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
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let arView, let imageAnchor = anchors.first as? ARImageAnchor else { return }
        
        let anchor = AnchorEntity(anchor: imageAnchor)
        anchor.name = "image"
        arView.scene.addAnchor(anchor)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let arView, let currentFrame = arView.session.currentFrame,
              let imageAnchor = anchors.first as? ARImageAnchor else { return }
        
        let width = Float(imageAnchor.referenceImage.physicalSize.width * imageAnchor.estimatedScaleFactor)
        let height = Float(imageAnchor.referenceImage.physicalSize.height * imageAnchor.estimatedScaleFactor)
        
        let lowerLeft = SIMD3<Float>(-width/2, 0, height/2)
        let lowerRight = SIMD3<Float>(width/2, 0, height/2)
        let upperLeft = SIMD3<Float>(-width/2, 0, -height/2)
        let upperRight = SIMD3<Float>(width/2, 0, -height/2)
        
        DispatchQueue.main.async {
            guard let imageEntity = arView.scene.findEntity(named: "image") else { return }
            let origin = currentFrame.camera.transform.position
            let cornerNames = ["lowerLeft", "lowerRight", "upperRight", "upperLeft"]
            let cornerPositions = [lowerLeft, lowerRight, upperRight, upperLeft].map { imageEntity.convert(position: $0, to: nil) }
            
            let cornerPositionsOnTable = zip(cornerNames, cornerPositions).compactMap { (name, position) in
                let direction = position - origin
                
                if let position = arView.scene.raycast(origin: origin, direction: direction, mask: .sceneUnderstanding).max(by: { $0.distance < $1.distance })?.position {
                    return (name, position)
                }
                return nil
            }
            
            for (name, position) in cornerPositionsOnTable {
                if let entity = arView.scene.findEntity(named: name) {
                    entity.setPosition(position, relativeTo: nil)
                } else {
                    let anchor = AnchorEntity(world: position)
                    anchor.name = name
                    let model = ModelEntity(mesh: .generateBox(size: 0.01), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                    anchor.addChild(model)
                    arView.scene.addAnchor(anchor)
                }
            }
            
            if let o = arView.scene.findEntity(named: "lowerLeft"),
               let x = arView.scene.findEntity(named: "upperLeft")
            {
                o.look(at: x.position(relativeTo: nil), from: o.position(relativeTo: nil), relativeTo: nil)
            }
        }
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
                handTrackingSettings.distanceFromTable = mcpCollisionResult.distance * 100
                if mcpCollisionResult.distance * 100 < handTrackingSettings.heightThreshold && gesture?.categoryName == "Pointing_Up" {
                    let tip2D = landmark[8].point
                    let dip2D = landmark[7].point
                    let target = CGPoint.intermediate(point1: dip2D, point2: tip2D, fraction: handTrackingSettings.dipTipFraction)
                    
                    let query = currentFrame.raycastQuery(from: target, allowing: .estimatedPlane, alignment: .any)
                    if let raycastResult = arView.session.raycast(query).last {
                        
                        if let entity = arView.scene.findEntity(named: "lowerLeft") {
                            let localCoords = entity.convert(position: raycastResult.worldTransform.position, from: nil)
                            handTrackingSettings.coords = .init(x: localCoords.x * 100, y: localCoords.y * 100, z: -localCoords.z * 100)
                            
                            if let target = entity.findEntity(named: "TARGET") {
                                target.setPosition(localCoords, relativeTo: entity)
                            } else {
                                let model = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                                model.name = "TARGET"
                                model.setPosition(localCoords, relativeTo: entity)
                                entity.addChild(model)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
