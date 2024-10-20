import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    @StateObject private var settingsManager: ARSettingsCoordinator
    let handTrackingSettings: HandTrackingSettings
    let arSettings: ARSettings
    
    init(arSettings: ARSettings, handTrackingSettings: HandTrackingSettings) {
        _settingsManager = StateObject(wrappedValue: ARSettingsCoordinator(arSettings: arSettings))
        self.arSettings = arSettings
        self.handTrackingSettings = handTrackingSettings
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        settingsManager.arView = arView
        
        arView.session.delegate = context.coordinator
        arView.session.delegateQueue = .global(qos: .userInteractive)
        
        configureSession(in: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> MediaPipeCoordinator {
        MediaPipeCoordinator(handTrackingSettings: handTrackingSettings)
    }
    
    private func configureSession(in arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing images resources.")
        }
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        configuration.automaticImageScaleEstimationEnabled = true
        
        if let videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats.first(where: { $0.framesPerSecond == arSettings.fps }) {
            configuration.videoFormat = videoFormat
            print("Configured frames per second to \(arSettings.fps) fps")
        }
        
        arView.debugOptions = arSettings.debugOptions
        arView.environment.sceneUnderstanding.options = arSettings.sceneUnderstandingOptions
        configuration.frameSemantics = arSettings.frameSemantics
        configuration.sceneReconstruction = arSettings.sceneReconstruction
        configuration.planeDetection = arSettings.planeDetection
        
        arView.session.run(configuration)
    }
}
