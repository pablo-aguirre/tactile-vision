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
        ZStack(alignment: .top) {
            ARViewContainer()
                .ignoresSafeArea()
            HStack {
                Spacer()
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                        .background(.gray, in: RoundedRectangle(cornerRadius: 10))
                }
            }.padding()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(showSettings: $showSettings)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Settings())
}
