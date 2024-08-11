import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
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

    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.debugOptions = settings.debugOptions
        uiView.environment.sceneUnderstanding.options = settings.environmentOptions
        print("Updating debug and sceneUnderstanding options...")
        
        if let configuration = uiView.session.configuration as? ARWorldTrackingConfiguration {
            configuration.frameSemantics = settings.frameOptions
            configuration.sceneReconstruction = settings.sceneOptions
            configuration.planeDetection = settings.planeOptions
            uiView.session.run(configuration, options: [.removeExistingAnchors, .resetSceneReconstruction])
            print("Restarting session with new configuration...")
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    private func configureSession(in arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()
        
        /// set 30 fps to reduce overhead on vision framework
        if let videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats.first(where: { $0.framesPerSecond == 30 }) {
            print("Configuring framesPerSecond to 30...")
            configuration.videoFormat = videoFormat
        }
        
        configuration.frameSemantics = [.smoothedSceneDepth]
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
    }
    
}
