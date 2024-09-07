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

class Coordinator: NSObject, ARSessionDelegate {
    var arSettings: ARSettings
    weak var arView: ARView?
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private var subscriptions: Set<AnyCancellable> = []
    
    init(arSettings: ARSettings) {
        self.arSettings = arSettings
        super.init()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        setupSubscriptions()
    }
    
    func setup() {
        guard let arView = self.arView else { return }
        
        let sphereModel = ModelEntity(mesh: .generateSphere(radius: arSettings.radius), materials: [SimpleMaterial(color: .green, isMetallic: false)])
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
            
            if recognizedPoint.confidence > 0.3, let (indexCoordinates, _) = frame.worldPoint(in: recognizedPoint.location) {
                sphereAnchor.setPosition(indexCoordinates, relativeTo: nil)
                arSettings.coords = indexCoordinates
                
                let query = ARRaycastQuery(origin: indexCoordinates, direction: [0,-1,0], allowing: .estimatedPlane, alignment: .any)
                if let result = session.raycast(query).first {
                    if let touchAnchor = arView.scene.findEntity(named: "touchAnchor") {
                        touchAnchor.setPosition(result.worldTransform.position, relativeTo: nil)
                    } else {
                        let touchAnchor = AnchorEntity(raycastResult: result)
                        touchAnchor.name = "touchAnchor"
                        let model = ModelEntity(mesh: .generateSphere(radius: arSettings.radius), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                        touchAnchor.addChild(model)
                        arView.scene.addAnchor(touchAnchor)
                    }
                    arSettings.distance = simd_distance(result.worldTransform.position, indexCoordinates)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupSubscriptions() {
        arSettings.$debugOptions.sink { [weak self] debugOptions in
            self?.arView?.debugOptions = debugOptions
            print("Updated ARView debug options")
        }.store(in: &subscriptions)
        
        arSettings.$environmentOptions.sink { [weak self] environmentOptions in
            self?.arView?.environment.sceneUnderstanding.options = environmentOptions
            print("Updated ARView environment scene understanding options")
        }.store(in: &subscriptions)
        
        arSettings.$frameOptions.sink { [weak self] frameOptions in
            guard let configuration = self?.arView?.session.configuration else { return }
            configuration.frameSemantics = frameOptions
            self?.arView?.session.run(configuration)
            print("Updated session configuration frame semantics")
        }.store(in: &subscriptions)
        
        arSettings.$sceneOptions.sink { [weak self] sceneOptions in
            guard let configuration = self?.arView?.session.configuration as? ARWorldTrackingConfiguration else { return }
            configuration.sceneReconstruction = sceneOptions
            self?.arView?.session.run(configuration)
            print("Updated session configuration scene reconstruction")
        }.store(in: &subscriptions)
        
        arSettings.$planeOptions.sink { [weak self] planeOptions in
            guard let configuration = self?.arView?.session.configuration as? ARWorldTrackingConfiguration else { return }
            configuration.planeDetection = planeOptions
            self?.arView?.session.run(configuration)
            print("Updated session configuration plane detection")
        }.store(in: &subscriptions)
        
        arSettings.$radius.sink { [weak self] radius in
            guard let model = self?.arView?.scene.findEntity(named: "sphereModel") as? ModelEntity else { return }
            model.model?.mesh = .generateSphere(radius: radius)
        }.store(in: &subscriptions)
        
        arSettings.$cleanTouches.sink { [weak self] _ in
            guard let arView = self?.arView else { return }
            
            let anchorsToRemove = arView.scene.anchors.filter { $0.name == "touchAnchor" }
            for anchor in anchorsToRemove {
                arView.scene.anchors.remove(anchor)
            }
        }.store(in: &subscriptions)
    }
}
