//
//  simd_float4x4+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 15/08/24.
//

import simd

extension simd_float4x4 {    
    var position: SIMD3<Float> {
        return SIMD3(x: self.columns.3.x, y: self.columns.3.y, z: self.columns.3.z)
    }
}

extension simd_float4 {
    var xyz: simd_float3 {
        return .init(x: self.x, y: self.y, z: self.z)
    }
}

extension simd_float3x3 {
    func orthonormalized() -> simd_float3x3 {
        var x = columns.0
        let y = columns.1
        var z = columns.2
        
        // Assicurati che Y sia normalizzato
        let yNorm = simd_normalize(y)
        
        // Calcola Z ortogonale a Y
        z = simd_cross(yNorm, x)
        z = simd_normalize(z)
        
        // Ricalcola X per essere ortogonale a Y e Z
        x = simd_cross(y, z)
        x = simd_normalize(x)
        
        return simd_float3x3(x, yNorm, z)
    }
}

