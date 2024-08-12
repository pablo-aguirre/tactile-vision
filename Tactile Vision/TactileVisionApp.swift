//
//  Tactile_VisionApp.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 05/08/24.
//

import SwiftUI

@main
struct TactileVisionApp: App {
    @StateObject var arSettings: ARSettings = .init()
    @StateObject var settings: Settings = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(arSettings)
                .environmentObject(settings)
        }
    }
}
