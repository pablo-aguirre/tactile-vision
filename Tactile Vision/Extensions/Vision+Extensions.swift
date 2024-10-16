//
//  Vision+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/10/24.
//

import Vision

extension VNRecognizedPoint {
    var point: CGPoint {
        .init(x: self.x, y: self.y)
    }
}
