//
//  CVPixelBuffer+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/08/24.
//

import CoreVideo

extension CVPixelBuffer {
    
    /// Returns the size of the specified plane in the pixel buffer.
    ///
    /// This method retrieves the width and height of a specific plane in the `CVPixelBuffer`.
    /// If the pixel buffer contains multiple planes, you can specify which plane's size you want to retrieve.
    /// The default value for the `plane` parameter is `0`, which represents the first plane.
    ///
    /// - Parameter plane: The index of the plane whose size you want to retrieve. Defaults to `0`.
    /// - Returns: A `CGSize` representing the width and height of the specified plane.
    func size(ofPlane plane: Int = 0) -> CGSize {
        let width = CVPixelBufferGetWidthOfPlane(self, plane)
        let height = CVPixelBufferGetHeightOfPlane(self, plane)
        return .init(width: width, height: height)
    }
    
    /// Retrieves a value from the pixel buffer at the specified normalized coordinates.
    ///
    /// - Parameters:
    ///   - point: The normalized coordinates of the point where (0,0) is in the Top-Left, (1,1) in the Bottom-Right.
    ///   - as: The type of value you want to retrieve (e.g., `Float.self`, `UInt8.self`).
    /// - Returns: The value at the specified point, or `nil` if the point is out of bounds or the pixel format type does not match.
    func value<T>(at point: CGPoint, as type: T.Type) -> T? {
        guard let expectedPixelFormatType = pixelFormatType(for: type),
              CVPixelBufferGetPixelFormatType(self) == expectedPixelFormatType,
              let (column, row) = pixelCoordinates(from: point) else { return nil }
        
        return pixelBufferValue(column: column, row: row, as: type)
    }
    
    /// Determines the pixel format type for a given type.
    ///
    /// - Parameter type: The type of value to retrieve (e.g., `Float.self`, `UInt8.self`).
    /// - Returns: The `OSType` corresponding to the type, or `nil` if the type is not recognized.
    private func pixelFormatType<T>(for type: T.Type) -> OSType? {
        switch type {
        case is Float.Type:
            return kCVPixelFormatType_DepthFloat32
        case is UInt8.Type:
            return kCVPixelFormatType_OneComponent8
            // Add more cases as needed
        default:
            return nil
        }
    }
    
    /// Calculates pixel coordinates from normalized coordinates.
    ///
    /// - Parameter point: The normalized coordinates of the point (0,0) is in the Top-Left, (1,1) in the Bottom-Right.
    /// - Returns: A tuple containing the column and row pixel coordinates, or `nil` if the point is out of bounds.
    private func pixelCoordinates(from point: CGPoint) -> (column: Int, row: Int)? {
        guard point.x >= 0, point.x <= 1, point.y >= 0, point.y <= 1 else { return nil }
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        let column = Int(point.x * CGFloat(width))
        let row = Int((1 - point.y) * CGFloat(height))
        
        return (column, row)
    }
    
    /// Retrieves a value of a generic type from the pixel buffer.
    ///
    /// - Parameters:
    ///   - column: The column index.
    ///   - row: The row index.
    ///   - type: The type of value to retrieve (e.g., `Float.self`, `UInt8.self`).
    /// - Returns: The value at the specified coordinates, or `nil` if the buffer is inaccessible.
    private func pixelBufferValue<T>(column: Int, row: Int, as type: T.Type) -> T? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else { return nil }
        
        let width = CVPixelBufferGetWidth(self)
        let index = column + (row * width)
        let offset = index * MemoryLayout<T>.stride
        
        return baseAddress.load(fromByteOffset: offset, as: T.self)
    }
}
