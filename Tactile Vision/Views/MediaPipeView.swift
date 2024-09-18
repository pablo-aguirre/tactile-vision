//
//  MediaPipeView.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 18/09/24.
//

import SwiftUI

struct MediaPipeView: View {
    @State var model: MediaPipeModel
    
    var body: some View {
        Text(model.prediction)
    }
}


@Observable
class MediaPipeModel {
    var prediction: String = ""
}
