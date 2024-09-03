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
        let sphereAnchor = AnchorEntity()
        sphereAnchor.name = "sphereAnchor"
        sphereAnchor.addChild(sphereModel)
        
        arView.scene.addAnchor(sphereAnchor)
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
    
    // MARK: ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let sphereAnchor = arView?.scene.findEntity(named: "sphereAnchor") as? AnchorEntity else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else { return }
            
            let recognizedPoint = try observation.recognizedPoint(.indexDIP)
            
            if recognizedPoint.confidence > 0.7, let (worldCoordinates, lidarConfidence) = frame.worldPoint(in: recognizedPoint.location), lidarConfidence != .low {
                sphereAnchor.setPosition(worldCoordinates, relativeTo: nil)
                
                if let imageAnchor = arView?.scene.findEntity(named: "imageAnchor") as? AnchorEntity {
                    let coords = imageAnchor.convert(position: worldCoordinates, from: nil)
                    arSettings.coords = coords
                    if coords.y < arSettings.threshold {
                        let model = ModelEntity(mesh: .generateSphere(radius: arSettings.radius), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                        let anchor = AnchorEntity(world: worldCoordinates)
                        anchor.name = "touchAnchor"
                        anchor.addChild(model)
                        arView?.scene.addAnchor(anchor)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let arImageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first,
              let arView = self.arView else {return}
        
        guard let pointInView = arView.project(arImageAnchor.transform.position),
              let result = arView.raycast(from: pointInView, allowing: .existingPlaneInfinite, alignment: .horizontal).first else { return }
        
        let anchor = AnchorEntity(world: arImageAnchor.transform)
        anchor.setPosition(result.worldTransform.position, relativeTo: nil)
        anchor.name = "imageAnchor"
        
        let imageWitdh = Float(arImageAnchor.referenceImage.physicalSize.width)
        let imageHeigth = Float(arImageAnchor.referenceImage.physicalSize.height)
        let model = ModelEntity(mesh: .generatePlane(width: imageWitdh * Float(arImageAnchor.estimatedScaleFactor), depth: imageHeigth * Float(arImageAnchor.estimatedScaleFactor)),
                                materials: [SimpleMaterial(color: .init(red: 0, green: 1, blue: 0, alpha: 0.5), isMetallic: false)])
        model.collision = .init(shapes: [.generateBox(size: .zero)])
        model.name = "imageModel"
        
        anchor.addChild(model)
        arView.scene.addAnchor(anchor)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let arImageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first,
              let arView = self.arView else { return }
        
        guard let pointInView = arView.project(arImageAnchor.transform.position),
              let result = arView.raycast(from: pointInView, allowing: .existingPlaneInfinite, alignment: .horizontal).first else { return }
        
        guard let imageAnchor = arView.scene.findEntity(named: "imageAnchor") as? AnchorEntity else { return }
        imageAnchor.setPosition(result.worldTransform.position, relativeTo: nil)
        imageAnchor.setOrientation(.init(arImageAnchor.transform), relativeTo: nil)
        
        guard let imageModel = arView.scene.findEntity(named: "imageModel") as? ModelEntity else { return }
        let imageWidth = Float(arImageAnchor.referenceImage.physicalSize.width)
        let imageHeight = Float(arImageAnchor.referenceImage.physicalSize.height)
        imageModel.model?.mesh = .generatePlane(width: imageWidth * Float(arImageAnchor.estimatedScaleFactor), depth: imageHeight * Float(arImageAnchor.estimatedScaleFactor))
    }
}
