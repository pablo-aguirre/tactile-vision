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
        
        let planeModel = ModelEntity(mesh: .generatePlane(width: 1, depth: 1), materials: [SimpleMaterial(color: .init(red: 0, green: 0, blue: 1, alpha: 0.25), isMetallic: false)])
        planeModel.name = "planeModel"
        planeModel.collision = .init(shapes: [.generateBox(width: 1, height: arSettings.height, depth: 1)])
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
            
            if let prova = self?.arView?.scene.findEntity(named: "imageAnchor") {
                print(anchor.convert(position: event.position, to: prova))
            }
            self?.arView?.scene.addAnchor(anchor)
        }.store(in: &subscriptions)
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
            plane.collision?.shapes = [.generateBox(width: 1, height: height, depth: 1)]
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
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let imageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first,
              let arView = self.arView else { return }
        
        let anchor = AnchorEntity(anchor: imageAnchor)
        anchor.name = "imageAnchor"
        let imageWitdh = Float(imageAnchor.referenceImage.physicalSize.width)
        let imageHeigth = Float(imageAnchor.referenceImage.physicalSize.height)
        let model = ModelEntity(mesh: .generatePlane(width: imageWitdh * Float(imageAnchor.estimatedScaleFactor), depth: imageHeigth * Float(imageAnchor.estimatedScaleFactor)),
                                materials: [SimpleMaterial(color: .init(red: 0, green: 1, blue: 0, alpha: 0.25), isMetallic: false)])
        model.name = "imageModel"
        anchor.addChild(model)
        arView.scene.addAnchor(anchor)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let imageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first,
              let imageModel = self.arView?.scene.findEntity(named: "imageModel") as? ModelEntity else { return }
        let imageWitdh = Float(imageAnchor.referenceImage.physicalSize.width)
        let imageHeigth = Float(imageAnchor.referenceImage.physicalSize.height)
        imageModel.model?.mesh = .generatePlane(width: imageWitdh * Float(imageAnchor.estimatedScaleFactor), depth: imageHeigth * Float(imageAnchor.estimatedScaleFactor))
    }
}
