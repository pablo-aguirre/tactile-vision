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
    private var planeEntity: ModelEntity?
    
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
        guard let sphereAnchor = arView?.scene.findEntity(named: "sphereAnchor") as? AnchorEntity, let arView = self.arView else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else { return }
            
            let recognizedPoint = try observation.recognizedPoint(.indexDIP)
            
            if recognizedPoint.confidence > 0.7, let (worldCoordinates, lidarConfidence) = frame.worldPoint(in: recognizedPoint.location), lidarConfidence != .low {
                sphereAnchor.setPosition(worldCoordinates, relativeTo: nil)
                arSettings.coords = worldCoordinates
                
                let points = [frame.worldPoint(in: .init(x: 0.25, y: 0.25)),
                              frame.worldPoint(in: .init(x: 0.25, y: 0.75)),
                              frame.worldPoint(in: .init(x: 0.75, y: 0.25)),
                              frame.worldPoint(in: .init(x: 0.75, y: 0.75))].compactMap { $0 }.filter { $0.1 == .high }.map { $0.0 }
                
                if points.count == 4 {
                    let toRemove = arView.scene.anchors.filter({ $0.name == "prova" })
                    toRemove.forEach { arView.scene.removeAnchor($0) }
                    
                    points.forEach { position in
                        let anchor = AnchorEntity(world: position)
                        anchor.name = "prova"
                        let model = ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
                        anchor.addChild(model)
                        arView.scene.addAnchor(anchor)
                    }
                    
                    // Calcola i vettori
                    let v1 = points[1] - points[0]
                    let v2 = points[2] - points[0]
                    
                    // Calcola il normale
                    let normal = simd_cross(v1, v2)
                    
                    // Calcola il valore di d nell'equazione del piano
                    let d = -simd_dot(normal, points[0])
                    
                    // Calcolo della distanza del punto dal piano
                    let numerator = abs(simd_dot(normal, worldCoordinates) + d)
                    let denominator = simd_length(normal)
                    let distance = numerator / denominator
                    
                    if distance < arSettings.threshold {
                        let anchor = AnchorEntity(world: worldCoordinates)
                        anchor.name = "touchAnchor"
                        let model = ModelEntity(mesh: .generateSphere(radius: arSettings.radius), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                        anchor.addChild(model)
                        arView.scene.addAnchor(anchor)
                    }
                    
                    arSettings.distance = distance
                }
                
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let arView = self.arView else { return }
        
        for imageAnchor in anchors.compactMap({ $0 as? ARImageAnchor }) {
            if let pointInView = arView.project(imageAnchor.transform.position),
               let raycastResult = arView.raycast(from: pointInView, allowing: .existingPlaneInfinite, alignment: .horizontal).first {
                
                // Estrarre la rotazione dal raycast (solo per l'asse Y)
                let raycastRotation = simd_float3x3(raycastResult.worldTransform.columns.0.xyz,
                                                    raycastResult.worldTransform.columns.1.xyz,
                                                    raycastResult.worldTransform.columns.2.xyz)
                
                // Estrarre la rotazione dall'immagine
                let imageRotation = simd_float3x3(imageAnchor.transform.columns.0.xyz,
                                                  imageAnchor.transform.columns.1.xyz,
                                                  imageAnchor.transform.columns.2.xyz)
                
                // Creare una nuova matrice di rotazione
                var hybridRotation = imageRotation
                hybridRotation.columns.1 = raycastRotation.columns.1  // Usa l'asse Y del raycast
                
                // Normalizzare la matrice di rotazione per assicurarsi che sia ortogonale
                hybridRotation = hybridRotation.orthonormalized()
                
                // Creare la nuova matrice di trasformazione 4x4
                let hybridTransform = simd_float4x4(
                    SIMD4<Float>(hybridRotation.columns.0, 0),
                    SIMD4<Float>(hybridRotation.columns.1, 0),
                    SIMD4<Float>(hybridRotation.columns.2, 0),
                    SIMD4<Float>(raycastResult.worldTransform.columns.3)
                )
                
                // Aggiornare o creare l'ancoraggio
                if let anchor = arView.scene.findEntity(named: "hybridAnchor") as? AnchorEntity {
                    anchor.setTransformMatrix(hybridTransform, relativeTo: nil)
                } else {
                    let anchor = AnchorEntity(world: hybridTransform)
                    anchor.name = "hybridAnchor"
                    let model = ModelEntity(mesh: .generateBox(size: 0.1),
                                            materials: [SimpleMaterial(color: .red.withAlphaComponent(0.5), isMetallic: false)])
                    anchor.addChild(model)
                    arView.scene.addAnchor(anchor)
                }
                
                print("Hybrid transform: \(hybridTransform)")
            }
        }
    }
}
