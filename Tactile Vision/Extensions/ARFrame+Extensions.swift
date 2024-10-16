//
//  ARFrame+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/08/24.
//

import ARKit

extension ARFrame {
    
    var timestampInMilliseconds: Int {
        Int(self.timestamp * 1000)
    }
    
    private static var cachedIntrinsicsInverse: simd_float3x3?
    
    var cameraIntrinsicsInverseForDepthMap: simd_float3x3? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap else { return nil }
        
        if ARFrame.cachedIntrinsicsInverse == nil {
            let depthMapSize = depthMap.size
            let capturedImageSize = self.capturedImage.size
            var cameraIntrinsics = self.camera.intrinsics
            
            let scaleRes: SIMD2<Float> = .init(
                x: capturedImageSize.width / depthMapSize.width,
                y: capturedImageSize.height / depthMapSize.height
            )
            cameraIntrinsics[0][0] /= scaleRes.x
            cameraIntrinsics[1][1] /= scaleRes.y
            cameraIntrinsics[2][0] /= scaleRes.x
            cameraIntrinsics[2][1] /= scaleRes.y
            
            ARFrame.cachedIntrinsicsInverse = cameraIntrinsics.inverse
        }
        
        return ARFrame.cachedIntrinsicsInverse
    }
    
    func worldPoint(at normalizedPoint: CGPoint, withConfidenceIn acceptableConfidences: Set<ARConfidenceLevel>) -> (SIMD3<Float>, ARConfidenceLevel)? {
        guard let depthConfidenceRawValue = self.smoothedSceneDepth?.confidenceMap?.value(at: normalizedPoint, as: UInt8.self),
              let depthConfidence = ARConfidenceLevel(rawValue: depthConfidenceRawValue),
              acceptableConfidences.contains(depthConfidence),
              let depth = self.smoothedSceneDepth?.depthMap.value(at: normalizedPoint, as: Float.self),
              let point3D = self.worldPoint(at: normalizedPoint, with: depth)
        else { return nil }
        
        return (point3D, depthConfidence)
    }
    
    private func worldPoint(at normalizedPoint: CGPoint, with depth: Float) -> SIMD3<Float>? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap,
              let pixelCoordinates = depthMap.pixelCoordinates(at: normalizedPoint),
              let cameraIntrinsicsInverseForDepthMap = self.cameraIntrinsicsInverseForDepthMap else { return nil }
        
        let viewMatrixInverted = self.camera.viewMatrix(for: .landscapeRight).inverse
        
        let localPoint = cameraIntrinsicsInverseForDepthMap * simd_float3(simd_float2(pixelCoordinates.column, pixelCoordinates.row), 1) * -depth
        let localPointSwappedX = simd_float3(-localPoint.x, localPoint.y, localPoint.z)
        let worldPointHomogeneous = viewMatrixInverted * simd_float4(localPointSwappedX, 1)
        
        let worldPoint = simd_float3(
            worldPointHomogeneous.x,
            worldPointHomogeneous.y,
            worldPointHomogeneous.z
        ) / worldPointHomogeneous.w
        
        return worldPoint
    }
    
    // This one is adapted from:
    // https://developer.apple.com/forums/thread/676368
    private func worldPoint(at point: CGPoint) -> (SIMD3<Float>, ARConfidenceLevel)? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap,
              let depth = depthMap.value(at: point, as: Float.self),
              let confidenceMap = self.smoothedSceneDepth?.confidenceMap,
              let confidenceRawValue = confidenceMap.value(at: point, as: UInt8.self),
              let confidence = ARConfidenceLevel(rawValue: confidenceRawValue),
              let cameraIntrinsicsInverted = self.cameraIntrinsicsInverseForDepthMap else { return nil }
        
        guard let pixelCoordinates = depthMap.pixelCoordinates(at: point) else { return nil }
        
        // This is crucial: you need to always use the view matrix for Landscape Right.
        let viewMatrixInverted = self.camera.viewMatrix(for: .landscapeRight).inverse
        
        let localPoint = cameraIntrinsicsInverted * simd_float3(simd_float2(pixelCoordinates.column, pixelCoordinates.row), 1) * -depth
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
    private func worldPoint2(at point: CGPoint) -> (SIMD3<Float>, ARConfidenceLevel)? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap,
              let depth = depthMap.value(at: point, as: Float.self),
              let confidenceMap = self.smoothedSceneDepth?.confidenceMap,
              let confidenceRawValue = confidenceMap.value(at: point, as: UInt8.self),
              let confidence = ARConfidenceLevel(rawValue: confidenceRawValue),
              let cameraIntrinsics = self.cameraIntrinsicsInverseForDepthMap else { return nil }
        
        let depthMapSize = depthMap.size
        let depthMapPixelPoint = simd_float2(x: point.x * depthMapSize.width, y: point.y * depthMapSize.height)
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
