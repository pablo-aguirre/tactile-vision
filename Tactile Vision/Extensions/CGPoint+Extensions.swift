//
//  CGPoint+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/10/24.
//

import Foundation


extension CGPoint {
    init(x: Float, y: Float) {
        let x = CGFloat(x)
        let y = CGFloat(y)
        self.init(x: x, y: y)
    }
    
    static func intermediate(point1: CGPoint, point2: CGPoint, fraction: Float) -> CGPoint {
        let diffX = Float(point2.x - point1.x)
        let diffY = Float(point2.y - point1.y)
        
        let intermediateX = Float(point1.x) + fraction * diffX
        let intermediateY = Float(point1.y) + fraction * diffY
        
        return CGPoint(x: intermediateX, y: intermediateY)
    }
}
