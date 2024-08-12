//
//  ContentView.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 08/07/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State private var showSettings: Bool = false
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
                .ignoresSafeArea()
            HStack {
                Button("Show Settings", systemImage: "arkit") {
                    showSettings.toggle()
                }
            }
            .padding()
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(showSettings: $showSettings)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Settings())
}
