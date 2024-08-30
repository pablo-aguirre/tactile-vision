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
    @State private var showSettings: Bool = false
    @StateObject private var arSettings = ARSettings()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
                .ignoresSafeArea()
            HStack {
                CustomButtom(label: "Settings", systemImage: "arkit") { showARSettings.toggle() }
                CustomButtom(label: "Settings", systemImage: "hand.tap.fill") { showSettings.toggle() }
                CustomButtom(label: "Clean", systemImage: "bubbles.and.sparkles.fill") { arSettings.cleanTouches.toggle() }
            }
        }
        .sheet(isPresented: $showARSettings) {
            NavigationStack {
                ARSettingsScreen()
                    .presentationDetents([.medium, .large])                
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsScreen()
                    .presentationDetents([.fraction(0.20)])
            }
        }
        .environmentObject(arSettings)
    }
}

#Preview {
    MainScreen()
        .environmentObject(ARSettings())
}
