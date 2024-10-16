//
//  CVPixelBuffer+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/08/24.
//

import CoreVideo

extension CVPixelBuffer {
    
    var size: CGSize {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        return .init(width: width, height: height)
    }
    
    func value<T>(at point: CGPoint, as type: T.Type) -> T? {
        guard point.x >= 0, point.x <= 1, point.y >= 0, point.y <= 1, // point must be in normalized coords
              let expectedPixelFormatType = pixelFormatType(for: type),
              CVPixelBufferGetPixelFormatType(self) == expectedPixelFormatType,
              let (column, row) = pixelCoordinates(at: point) else { return nil }
        
        return pixelBufferValue(at: (column, row), as: type)
    }
    
    private func pixelFormatType<T>(for type: T.Type) -> OSType? {
        switch type {
        case is Float.Type: // depth
            return kCVPixelFormatType_DepthFloat32
        case is UInt8.Type: // ARConfidenceLevel raw value
            return kCVPixelFormatType_OneComponent8
        default: // Add more cases as needed
            return nil
        }
    }
    
    func pixelCoordinates(at point: CGPoint) -> (column: Int, row: Int)? {
        guard point.x >= 0, point.x <= 1, point.y >= 0, point.y <= 1 else { return nil }
        
        let column = Int(point.x * size.width)
        let row = Int(point.y * size.height)
        
        return (column, row)
    }
    
    private func pixelBufferValue<T>(at pixel: (column: Int, row: Int), as type: T.Type) -> T? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(self)?.assumingMemoryBound(to: type) else { return nil }
        
        let width = CVPixelBufferGetWidth(self)
        let index = pixel.column + (pixel.row * width)
        
        return baseAddress[index]
    }
}
