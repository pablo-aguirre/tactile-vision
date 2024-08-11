import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    @Environment(Settings.self) private var settings: Settings
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        arView.session.run(ARWorldTrackingConfiguration())
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.debugOptions = settings.debugOptions
        uiView.environment.sceneUnderstanding.options = settings.environmentOptions
        
        if let configuration = uiView.session.configuration as? ARWorldTrackingConfiguration {
            configuration.frameSemantics = settings.frameOptions
            configuration.sceneReconstruction = settings.sceneOptions
            configuration.planeDetection = settings.planeOptions
            uiView.session.run(configuration, options: [.removeExistingAnchors, .resetSceneReconstruction])
        }
    }
    
}
