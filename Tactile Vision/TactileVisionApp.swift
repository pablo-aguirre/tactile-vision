//
//  Tactile_VisionApp.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 05/08/24.
//

import SwiftUI

@main
struct TactileVisionApp: App {
    @StateObject var sessionSettings: Settings = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionSettings)
        }
    }
}
