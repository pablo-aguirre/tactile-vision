//
//  Coordinator.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/08/24.
//

import Foundation
import ARKit
import RealityKit
import Vision

class Coordinator: NSObject, ARSessionDelegate {
    var arView: ARView?
    private let sphereAnchor = AnchorEntity()
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    func setup() {
        handPoseRequest.maximumHandCount = 1
        let model = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: .red, isMetallic: false)])
        sphereAnchor.addChild(model)
        arView?.scene.addAnchor(sphereAnchor)
    }
    
    // MARK: ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else { return }
            
            let recognizedPoint = try observation.recognizedPoint(.indexDIP)
            
            if recognizedPoint.confidence > 0.7, let (worldCoordinates, confidence) = frame.worldPoint(in: recognizedPoint.location), confidence != .low {
                sphereAnchor.move(to: .init(translation: worldCoordinates), relativeTo: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
