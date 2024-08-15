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
    var arView: ARView?
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private var subscriptions: Set<AnyCancellable> = []
    
    init(arSettings: ARSettings) {
        self.arSettings = arSettings
        super.init()
        handPoseRequest.maximumHandCount = 1
        
        setupSubscriptions()
    }
    
    func setup() {
        guard let arView = self.arView else { return }
        
        let model = ModelEntity(mesh: .generateSphere(radius: arSettings.radius),
                                materials: [SimpleMaterial(color: .green, isMetallic: false)])
        model.name = "sphereModel"
        model.collision = .init(shapes: [.generateSphere(radius: arSettings.radius)])
        model.generateCollisionShapes(recursive: true)
        
        let anchor = AnchorEntity()
        anchor.name = "sphereAnchor"
        anchor.addChild(model)
        
        arView.scene.addAnchor(anchor)
    }
    
    // MARK: ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let anchor = arView?.scene.findEntity(named: "sphereAnchor") as? AnchorEntity else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else { return }
            
            let recognizedPoint = try observation.recognizedPoint(.indexDIP)
            
            if recognizedPoint.confidence > 0.7, let (worldCoordinates, confidence) = frame.worldPoint(in: recognizedPoint.location), confidence != .low {
                anchor.transform.translation = worldCoordinates
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
            model.collision?.shapes = [.generateSphere(radius: radius)]
        }.store(in: &subscriptions)
    }
}
