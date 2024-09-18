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

class MediaPipeCoordinator: NSObject, ARSessionDelegate {
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
        guard let buffer = try? bufferConverter?.convertToBGRA(imageBuffer: frame.capturedImage) else { return }
        
        gestureRecognizer?.recognizeAsync(pixelBuffer: buffer, timeStamp: Int(frame.timestamp * 1000))
    }
}


extension MediaPipeCoordinator: GestureRecognizerLiveStreamDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: GestureRecognizer, didFinishGestureRecognition result: GestureRecognizerResult?, timestampInMilliseconds: Int, error: (any Error)?) {
        guard let result else { return }
        
        model.prediction = result.gestures.first?.first?.label ?? ""
    }
    
}
