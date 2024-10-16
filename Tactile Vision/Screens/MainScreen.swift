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
    @State private var showHandTrackingSettings: Bool = false
    @State private var handTrackingSettings = HandTrackingSettings()
    @StateObject private var arSettings = ARSettings()
    
    var body: some View {
        ZStack {
            ARViewContainer(arSettings: arSettings, handTrackingSettings: handTrackingSettings)
                .ignoresSafeArea()
                .overlay { Circle().frame(width: 5, height: 5) }
            VStack {
                Text(handTrackingSettings.gesture)
                    .padding()
                    .background(.secondary)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
                Spacer()
                HStack {
                    CustomButton(systemImage: "arkit") { showARSettings.toggle() }
                    Spacer()
                    CustomButton(systemImage: "hand.point.up.left") { showHandTrackingSettings.toggle() }
                }
            }.padding()
        }
        .sheet(isPresented: $showARSettings) {
            NavigationStack {
                ARSettingsScreen()
                    .environmentObject(arSettings)
            }.presentationDetents([.medium])
        }
        .sheet(isPresented: $showHandTrackingSettings) {
            NavigationStack {
                HandTrackingSettingsScreen()
                    .environment(handTrackingSettings)
            }.presentationDetents([.fraction(0.35)])
        }
    }
}
