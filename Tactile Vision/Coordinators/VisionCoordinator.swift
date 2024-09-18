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
import Combine

class VisionCoordinator: NSObject, ARSessionDelegate {
    weak var arView: ARView?
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    override init() {
        super.init()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
    }
    
    func setup() {
        guard let arView = self.arView else { return }
        
        let sphereModel = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: .green, isMetallic: false)])
        sphereModel.name = "sphereModel"
        let sphereAnchor = AnchorEntity()
        sphereAnchor.name = "sphereAnchor"
        sphereAnchor.addChild(sphereModel)
        
        arView.scene.addAnchor(sphereAnchor)
    }
    
    // MARK: ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let sphereAnchor = arView?.scene.findEntity(named: "sphereAnchor") as? AnchorEntity, let arView = self.arView else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else { return }
            
            let recognizedPoint = try observation.recognizedPoint(.indexDIP)
            
            if recognizedPoint.confidence > 0.3, let (indexCoordinates, lidarConfidence) = frame.worldPoint(in: recognizedPoint.location), lidarConfidence == .high {
                sphereAnchor.setPosition(indexCoordinates, relativeTo: nil)
                
                let results = arView.scene.raycast(origin: indexCoordinates, direction: [0, -1, 0],  mask: .sceneUnderstanding)
                
                if let result = results.max(by: { $0.distance < $1.distance }) {
                    if let touchAnchor = arView.scene.findEntity(named: "touchAnchor") {
                        touchAnchor.setPosition(result.position, relativeTo: nil)
                    } else {
                        let touchAnchor = AnchorEntity(world: result.position)
                        touchAnchor.name = "touchAnchor"
                        let model = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                        touchAnchor.addChild(model)
                        arView.scene.addAnchor(touchAnchor)
                    }
                    
                    print(result.distance)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
