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
    let model: MediaPipeModel
    
    init(model: MediaPipeModel) {
        self.model = model
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
        guard model.trackingEnabled, let buffer = try? bufferConverter?.convertToBGRA(imageBuffer: frame.capturedImage) else { return }
        
        gestureRecognizer?.recognizeAsync(pixelBuffer: buffer, timeStamp: Int(frame.timestamp * 1000))
    }
}

extension MediaPipeCoordinator: GestureRecognizerLiveStreamDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: GestureRecognizer, didFinishGestureRecognition result: GestureRecognizerResult?, timestampInMilliseconds: Int, error: (any Error)?) {
        guard let result else { return }
        
        model.prediction = result.gestures.first?.first?.label ?? ""
        
        if let landmark = result.landmarks.first {
            let point2D = calculateIntermediatePoint(point1: landmark[5].point, point2: landmark[8].point, percentage: model.percentage)
            
            if let (point3D, lidarConfidence) = arView?.session.currentFrame?.worldPoint(at: point2D),
               model.lidarConfidences.contains(lidarConfidence)
            {
                self.arView?.updateOrAddEntity(named: "\(lidarConfidence.label)Index", at: point3D, color: lidarConfidence.color)
                
                DispatchQueue.main.async { [weak self] in
                    if let collisionResult = self?.arView?.scene.raycast(origin: point3D, direction: [0, -1, 0]).max(by: { $0.distance < $1.distance }) {
                        self?.model.distances[lidarConfidence] = collisionResult.distance * 100
                        self?.arView?.updateOrAddEntity(named: lidarConfidence.label, at: collisionResult.position, color: lidarConfidence.color)
                    }
                }
            }
        }
    }
    
    private func calculateIntermediatePoint(point1: (x: Float, y: Float), point2: (x: Float, y: Float), percentage: Float) -> (x: Float, y: Float) {
        let diffX = point2.x - point1.x
        let diffY = point2.y - point1.y
        
        let intermediateX = point1.x + percentage * diffX
        let intermediateY = point1.y + percentage * diffY
        
        return (x: intermediateX, y: intermediateY)
    }
    
}
