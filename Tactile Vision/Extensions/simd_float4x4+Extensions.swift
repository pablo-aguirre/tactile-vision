//
//  simd_float4x4+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 15/08/24.
//

import simd

extension simd_float4x4 {
    init(translation: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        )
    }
    
    var position: SIMD3<Float> {
        return SIMD3(x: self.columns.3.x, y: self.columns.3.y, z: self.columns.3.z)
    }
}
