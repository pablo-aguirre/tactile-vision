//
//  ContentView.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 08/07/24.
//

import SwiftUI
import RealityKit
import ARKit

struct MainScreen: View {
    @State private var showARSettings: Bool = false
    @State private var mediaPipeModel = MediaPipeModel()
    @StateObject private var arSettings = ARSettings()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ARViewContainer(arSettings: arSettings, mediaPipeModel: mediaPipeModel)
                .ignoresSafeArea()
            CustomButtom(label: "Settings", systemImage: "arkit") { showARSettings.toggle() }.padding()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MediaPipeView(model: mediaPipeModel)
                    Spacer()
                }
            }.padding()
        }
        .sheet(isPresented: $showARSettings) {
            NavigationStack {
                ARSettingsScreen()
                    .environmentObject(arSettings)
            }.presentationDetents([.medium])
        }
    }
}
