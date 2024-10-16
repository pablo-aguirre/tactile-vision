//
//  simd_float4x4+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 15/08/24.
//

import simd
import CoreGraphics

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

extension simd_float2 {
    init(_ v0: Int, _ v1: Int) {
        let v0 = Float(v0)
        let v1 = Float(v1)
        self.init(x: v0, y: v1)
    }
    
    init(x: CGFloat, y: CGFloat) {
        let x = Float(x)
        let y = Float(y)
        self.init(x: x, y: y)
    }
}

