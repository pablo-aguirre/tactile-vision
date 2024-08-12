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
    @State private var showARSettings: Bool = false
    @State private var showSettings: Bool = false
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
                .ignoresSafeArea()
            HStack {
                Button("Settings", systemImage: "arkit") {
                    showARSettings.toggle()
                }
                .padding()
                .background(.secondary)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
                Button("Settings", systemImage: "hand.tap.fill") {
                    showSettings.toggle()
                }
                .padding()
                .background(.secondary)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
            }
        }
        .sheet(isPresented: $showARSettings) {
            ARSettingsView(show: $showARSettings)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(show: $showSettings)
                .presentationDetents([.fraction(0.20)])
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ARSettings())
        .environmentObject(Settings())
}
