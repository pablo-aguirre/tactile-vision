//
//  CustomButtom.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 30/08/24.
//

import SwiftUI

struct CustomButtom: View {
    let label: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(label, systemImage: systemImage) {
            action()
        }
        .padding()
        .background(.secondary)
        .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
    }
}
