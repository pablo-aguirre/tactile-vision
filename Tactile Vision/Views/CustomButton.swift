//
//  CustomButtom.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 30/08/24.
//

import SwiftUI

struct CustomButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
        }
        .padding()
        .background(.secondary)
        .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
    }
}
