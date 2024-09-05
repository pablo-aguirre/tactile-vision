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
            VStack {
                HStack {
                    Text("Distance sphere-plane: \((arSettings.distance * 100).formatted(.number.precision(.fractionLength(1)))) cm").foregroundStyle(.white)
                }
                HStack {
                    Text("x: \((arSettings.coords * 100).x.formatted(.number.precision(.fractionLength(1)))) cm").foregroundStyle(.red)
                    Text("y: \((arSettings.coords * 100).y.formatted(.number.precision(.fractionLength(1)))) cm").foregroundStyle(.green)
                    Text("z: \((arSettings.coords * 100).z.formatted(.number.precision(.fractionLength(1)))) cm").foregroundStyle(.blue)
                }
                HStack {
                    CustomButtom(label: "Settings", systemImage: "arkit") { showARSettings.toggle() }
                    CustomButtom(label: "Settings", systemImage: "hand.tap.fill") { showSettings.toggle() }
                    CustomButtom(label: "Clean", systemImage: "bubbles.and.sparkles.fill") { arSettings.cleanTouches.toggle() }
                }
            }
        }
        .sheet(isPresented: $showARSettings) {
            NavigationStack {
                ARSettingsScreen()
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsScreen()
            }
            .presentationDetents([.fraction(0.25)])
        }
        .environmentObject(arSettings)
    }
}

#Preview {
    MainScreen()
        .environmentObject(ARSettings())
}
