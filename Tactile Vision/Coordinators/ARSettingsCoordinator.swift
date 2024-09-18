//
//  ARSettingsCoordinator.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 18/09/24.
//
import RealityKit
import ARKit
import Combine

class ARSettingsCoordinator: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    let arSettings: ARSettings
    var arView: ARView?
    
    init(arSettings: ARSettings) {
        self.arSettings = arSettings
        setupSubscriptions()
    }
    
    func setupSubscriptions() {
        arSettings.$debugOptions.sink { [weak self] debugOptions in
            guard let arView = self?.arView else { return }
            
            arView.debugOptions = debugOptions
            print("Updated debug options: \(debugOptions)")
        }.store(in: &subscriptions)
        
        arSettings.$sceneUnderstandingOptions.sink { [weak self] environmentOptions in
            guard let arView = self?.arView else { return }
            
            arView.environment.sceneUnderstanding.options = environmentOptions
            print("Updated scene understanding options: \(environmentOptions)")
        }.store(in: &subscriptions)
        
        arSettings.$frameSemantics.sink { [weak self] frameSemantics in
            guard let session = self?.arView?.session,
                  let configuration = session.configuration as? ARWorldTrackingConfiguration else { return }
            
            if ARWorldTrackingConfiguration.supportsFrameSemantics(frameSemantics) {
                configuration.frameSemantics = frameSemantics
                session.run(configuration)
                print("Updated frame semantics: \(frameSemantics). Restarting session...")
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.arSettings.frameSemantics = configuration.frameSemantics
                }
            }
        }.store(in: &subscriptions)
        
        arSettings.$sceneReconstruction.sink { [weak self] sceneOptions in
            guard let session = self?.arView?.session,
                  let configuration = session.configuration as? ARWorldTrackingConfiguration else { return }
            
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(sceneOptions) {
                configuration.sceneReconstruction = sceneOptions
                session.run(configuration)
                print("Updated scene options: \(sceneOptions). Restarting session...")
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.arSettings.sceneReconstruction = configuration.sceneReconstruction
                }
            }
        }.store(in: &subscriptions)
        
        arSettings.$planeDetection.sink { [weak self] planeDetection in
            guard let session = self?.arView?.session,
                  let configuration = session.configuration as? ARWorldTrackingConfiguration else { return }
            
            configuration.planeDetection = planeDetection
            session.run(configuration)
            print("Updated plane detection: \(planeDetection). Restarting session...")
        }.store(in: &subscriptions)
        
        arSettings.$fps.sink { [weak self] fps in
            guard let session = self?.arView?.session,
                  let configuration = self?.arView?.session.configuration as? ARWorldTrackingConfiguration else { return }
            
            if let videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats.first(where: { $0.framesPerSecond == fps }) {
                configuration.videoFormat = videoFormat
                session.run(configuration)
                print("Updated fps: \(fps). Restarting session...")
            } else {
                DispatchQueue.main.async {  [weak self] in
                    self?.arSettings.fps = configuration.videoFormat.framesPerSecond
                }
            }
        }.store(in: &subscriptions)
    }
}
