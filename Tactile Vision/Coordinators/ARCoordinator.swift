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
        
        setupSubscriptions()
    }
    
    func setup() {
        guard let arView = self.arView else { return }
        
        let sphereModel = ModelEntity(mesh: .generateSphere(radius: arSettings.radius), materials: [SimpleMaterial(color: .green, isMetallic: false)])
        sphereModel.name = "sphereModel"
        sphereModel.collision = .init(shapes: [.generateSphere(radius: arSettings.radius)], mode: .trigger, filter: .init(group: .default, mask: .default))
        sphereModel.generateCollisionShapes(recursive: true)
        let sphereAnchor = AnchorEntity()
        sphereAnchor.name = "sphereAnchor"
        sphereAnchor.addChild(sphereModel)
        
        let planeModel = ModelEntity(mesh: .generatePlane(width: 0.4, depth: 0.2), materials: [SimpleMaterial(color: .init(red: 0, green: 0, blue: 1, alpha: 0.25), isMetallic: false)])
        planeModel.name = "planeModel"
        planeModel.collision = .init(shapes: [.generateBox(width: 0.4, height: arSettings.height, depth: 0.2)])
        planeModel.generateCollisionShapes(recursive: true)
        let planeAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: .zero))
        planeAnchor.name = "planeAnchor"
        planeAnchor.addChild(planeModel)
        
        arView.scene.addAnchor(sphereAnchor)
        arView.scene.addAnchor(planeAnchor)
        
        arView.scene.subscribe(to: CollisionEvents.Began.self, on: sphereModel) { [weak self] event in
            let model = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: .red, isMetallic: false)])
            let anchor = AnchorEntity(world: event.position)
            anchor.name = "touchAnchor"
            anchor.addChild(model)
            self?.arView?.scene.addAnchor(anchor)
        }.store(in: &subscriptions)
    }
    
    // MARK: ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let sphereAnchor = arView?.scene.findEntity(named: "sphereAnchor") as? AnchorEntity else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else { return }
            
            let recognizedPoint = try observation.recognizedPoint(.indexDIP)
            
            if recognizedPoint.confidence > 0.7, let (worldCoordinates, lidarConfidence) = frame.worldPoint(in: recognizedPoint.location), lidarConfidence != .low {
                sphereAnchor.transform.translation = worldCoordinates
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
        
        arSettings.$cleanTouches.sink { [weak self] _ in
            guard let arView = self?.arView else { return }
            
            let anchorsToRemove = arView.scene.anchors.filter { $0.name == "touchAnchor" }
            for anchor in anchorsToRemove {
                arView.scene.anchors.remove(anchor)
            }
        }.store(in: &subscriptions)
        
        arSettings.$height.sink { [weak self] height in
            guard let plane = self?.arView?.scene.findEntity(named: "planeModel") as? ModelEntity else { return }
            plane.collision?.shapes = [.generateBox(width: 0.4, height: height, depth: 0.2)]
        }.store(in: &subscriptions)
    }
}
