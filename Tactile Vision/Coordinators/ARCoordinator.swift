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
    var settings: Settings
    var arView: ARView?
    private let sphereAnchor = AnchorEntity()
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private var subscriptions: Set<AnyCancellable> = []
    
    init(arSettings: ARSettings, settings: Settings) {
        self.arSettings = arSettings
        self.settings = settings
        super.init()
        
        handPoseRequest.maximumHandCount = 1
        let model = ModelEntity(mesh: .generateSphere(radius: settings.radius),
                                materials: [SimpleMaterial(color: .green, isMetallic: false)])
        model.collision = .init(shapes: [.generateSphere(radius: settings.radius)])
        model.generateCollisionShapes(recursive: true)
        model.name = "sphere"
        sphereAnchor.addChild(model)
    
        settings.$radius.sink { [weak self] radius in
            guard let model = self?.sphereAnchor.children.first(where: {$0.name == "sphere"}) as? ModelEntity else { return }
            model.model?.mesh = .generateSphere(radius: radius)
            model.collision = .init(shapes: [.generateSphere(radius: radius)])
        }.store(in: &subscriptions)
        
        setupARSubscriptions()
    }
    
    func setup() {
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
    
    private func setupARSubscriptions() {
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
    }
}
