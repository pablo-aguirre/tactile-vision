//
//  ARFrame+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/08/24.
//

import ARKit

extension ARFrame {
    
    // MARK: - Cached Properties
    private static var cachedIntrinsicsInverse: simd_float3x3?
    private static var cachedDepthMapSize: (width: Float, height: Float) = (0, 0)
    
    var cameraIntrinsicsInverseForDepthMap: simd_float3x3? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap else { return nil }
        
        let depthMapSize = depthMap.size()
        
        if ARFrame.cachedDepthMapSize.width != depthMapSize.width ||
            ARFrame.cachedDepthMapSize.height != depthMapSize.height ||
            ARFrame.cachedIntrinsicsInverse == nil
        {
            var cameraIntrinsics = self.camera.intrinsics
            let capturedImageSize = self.capturedImage.size()
            
            let scaleRes = simd_float2(
                x: Float(capturedImageSize.width) / depthMapSize.width,
                y: Float(capturedImageSize.height) / depthMapSize.height
            )
            cameraIntrinsics[0][0] /= scaleRes.x
            cameraIntrinsics[1][1] /= scaleRes.y
            cameraIntrinsics[2][0] /= scaleRes.x
            cameraIntrinsics[2][1] /= scaleRes.y
            
            ARFrame.cachedIntrinsicsInverse = cameraIntrinsics.inverse
            ARFrame.cachedDepthMapSize = depthMapSize
        }
        
        return ARFrame.cachedIntrinsicsInverse
    }
    
    // This one is adapted from:
    // https://developer.apple.com/forums/thread/676368
    func worldPoint(at point: (x: Float, y: Float)) -> (SIMD3<Float>, ARConfidenceLevel)? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap,
              let depth = depthMap.value(at: point, as: Float.self),
              let confidenceMap = self.smoothedSceneDepth?.confidenceMap,
              let confidenceRawValue = confidenceMap.value(at: point, as: UInt8.self),
              let confidence = ARConfidenceLevel(rawValue: Int(confidenceRawValue)),
              let cameraIntrinsicsInverted = self.cameraIntrinsicsInverseForDepthMap else { return nil }
        
        let depthMapSize = depthMap.size()
        let pixelCoordinates = simd_float2(
            point.x * depthMapSize.width,
            point.y * depthMapSize.height
        )
        
        // This is crucial: you need to always use the view matrix for Landscape Right.
        let viewMatrixInverted = self.camera.viewMatrix(for: .landscapeRight).inverse
        
        let localPoint = cameraIntrinsicsInverted * simd_float3(pixelCoordinates, 1) * -depth
        let localPointSwappedX = simd_float3(-localPoint.x, localPoint.y, localPoint.z)
        let worldPointHomogeneous = viewMatrixInverted * simd_float4(localPointSwappedX, 1)
        
        let worldPoint = simd_float3(
            worldPointHomogeneous.x,
            worldPointHomogeneous.y,
            worldPointHomogeneous.z
        ) / worldPointHomogeneous.w
        
        return (worldPoint, confidence)
    }
    
    // This one is adapted from:
    // http://nicolas.burrus.name/index.php/Research/KinectCalibration
    private func worldPoint2(at point: (x: Float, y: Float)) -> (SIMD3<Float>, ARConfidenceLevel)? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap,
              let depth = depthMap.value(at: point, as: Float.self),
              let confidenceMap = self.smoothedSceneDepth?.confidenceMap,
              let confidenceRawValue = confidenceMap.value(at: point, as: UInt8.self),
              let confidence = ARConfidenceLevel(rawValue: Int(confidenceRawValue)),
              let cameraIntrinsics = self.cameraIntrinsicsInverseForDepthMap else { return nil }
        
        let depthMapSize = depthMap.size()
        let depthMapPixelPoint = simd_float2(point.x * depthMapSize.width, point.y * depthMapSize.height)
        // This is crucial: you need to always use the view matrix for Landscape Right.
        let viewMatrixInverted = self.camera.viewMatrix(for: .landscapeRight).inverse
        
        let xrw = ((depthMapPixelPoint.x - cameraIntrinsics[2][0]) * depth / cameraIntrinsics[0][0])
        let yrw = (depthMapPixelPoint.y - cameraIntrinsics[2][1]) * depth / cameraIntrinsics[1][1]
        // Y is UP in camera space, vs it being DOWN in image space.
        let localPoint = simd_float3(xrw, -yrw, -depth)
        let worldPoint = viewMatrixInverted * simd_float4(localPoint, 1)
        
        return (simd_float3(worldPoint.x, worldPoint.y, worldPoint.z), confidence)
    }
    
}
