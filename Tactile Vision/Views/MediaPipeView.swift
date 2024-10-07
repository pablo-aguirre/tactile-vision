//
//  MediaPipeView.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 18/09/24.
//

import SwiftUI
import ARKit

struct MediaPipeView: View {
    @State var model: MediaPipeModel
    
    var body: some View {
        VStack {
            Text(model.prediction)
            HStack {
                Text((model.distances[.high] ?? 0).formatted()).foregroundStyle(.blue)
                Spacer()
                Text((model.distances[.medium] ?? 0).formatted()).foregroundStyle(.green)
                Spacer()
                Text((model.distances[.low] ?? 0).formatted()).foregroundStyle(.red)
            }
            Toggle("Tracking", isOn: $model.trackingEnabled)
            HStack {
                Text("indexDip")
                Slider(value: $model.percentage, in: 0...1)
                Text("indexTip")
            }
            HStack {
                ForEach(ARConfidenceLevel.allCases, id: \.rawValue) { confidence in
                    Toggle(confidence.label, isOn: Binding(
                        get: { model.lidarConfidences.contains(confidence) },
                        set: { if $0 { model.lidarConfidences.insert(confidence) } else { model.lidarConfidences.remove(confidence) } }
                    ))
                }
            }
        }.foregroundStyle(.white)
    }
}


@Observable
class MediaPipeModel {
    var trackingEnabled: Bool = true
    var prediction: String = ""
    var percentage: Float = 0
    var lidarConfidences: Set<ARConfidenceLevel> = [.medium, .high]
    var distances: [ARConfidenceLevel : Float] = [:]
}
