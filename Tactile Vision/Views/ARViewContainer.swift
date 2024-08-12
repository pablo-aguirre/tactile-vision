import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject private var arSettings: ARSettings
    @EnvironmentObject private var settings: Settings
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        arView.session.delegate = context.coordinator
        //arView.session.delegateQueue = .global(qos: .userInteractive)

        context.coordinator.arView = arView
        context.coordinator.setup()
        configureSession(in: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(arSettings: arSettings, settings: settings) }
    
    private func configureSession(in arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()
        
        /// set 30 fps to reduce overhead on vision framework
        if let videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats.first(where: { $0.framesPerSecond == 30 }) {
            configuration.videoFormat = videoFormat
            print("Configured frames per second to 30 fps")
        }
        
        arView.debugOptions = arSettings.debugOptions
        arView.environment.sceneUnderstanding.options = arSettings.environmentOptions
        configuration.frameSemantics = arSettings.frameOptions
        configuration.sceneReconstruction = arSettings.sceneOptions
        configuration.planeDetection = arSettings.planeOptions
        arView.session.run(configuration)
    }
    
}
