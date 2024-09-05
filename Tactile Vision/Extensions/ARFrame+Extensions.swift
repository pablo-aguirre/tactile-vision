//
//  ARFrame+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 11/08/24.
//

import ARKit

extension ARFrame {
    
    var cameraIntrinsicsInverseForDepthMap: simd_float3x3? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap else { return nil }
        
        let capturedImageSize: CGSize = self.capturedImage.size()
        let depthMapSize: CGSize = depthMap.size()
        
        var cameraIntrinsics = self.camera.intrinsics
        
        /// Make the camera intrinsics be with respect to Depth.
        /// This rescaling is crucial for ensuring accurate world point calculations, as the depth map and captured image may have different resolutions.
        let scaleRes = simd_float2(x: Float(capturedImageSize.width / depthMapSize.width),
                                   y: Float(capturedImageSize.height / depthMapSize.height))
        cameraIntrinsics[0][0] /= scaleRes.x
        cameraIntrinsics[1][1] /= scaleRes.y
        cameraIntrinsics[2][0] /= scaleRes.x
        cameraIntrinsics[2][1] /= scaleRes.y
        
        return cameraIntrinsics.inverse
    }
    
    // This one is adapted from:
    // https://developer.apple.com/forums/thread/676368
    func worldPoint(in point: CGPoint) -> (SIMD3<Float>, ARConfidenceLevel)? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap,
              let depth = depthMap.value(at: point, as: Float.self),
              let confidenceMap = self.smoothedSceneDepth?.confidenceMap,
              let confidence = confidenceMap.value(at: point, as: UInt8.self),
              let level = ARConfidenceLevel(rawValue: Int(confidence)),
              let cameraIntrinsicsInverted = self.cameraIntrinsicsInverseForDepthMap else { return nil }
        
        let depthMapSize = depthMap.size()
        let pixelCoordinates = simd_float2(Float(point.x * depthMapSize.width), Float((1 - point.y) * depthMapSize.height))
        
        // This is crucial: you need to always use the view matrix for Landscape Right.
        let viewMatrixInverted = self.camera.viewMatrix(for: .landscapeRight).inverse
        
        let localPoint = cameraIntrinsicsInverted * simd_float3(pixelCoordinates, 1) * -depth
        let localPointSwappedX = simd_float3(-localPoint.x, localPoint.y, localPoint.z)
        let worldPoint = viewMatrixInverted * simd_float4(localPointSwappedX, 1)
        
        return ((worldPoint / worldPoint.w)[SIMD3(0,1,2)], level)
    }
    
    // This one is adapted from:
    // http://nicolas.burrus.name/index.php/Research/KinectCalibration
    func worldPoint2(in point: CGPoint) -> (SIMD3<Float>, ARConfidenceLevel)? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap,
              let depth = depthMap.value(at: point, as: Float.self),
              let confidenceMap = self.smoothedSceneDepth?.confidenceMap,
              let confidenceRawValue = confidenceMap.value(at: point, as: UInt8.self),
              let confidenceLevel = ARConfidenceLevel(rawValue: Int(confidenceRawValue)),
              let cameraIntrinsics = self.cameraIntrinsicsInverseForDepthMap else { return nil }
        
        let depthMapSize = depthMap.size()
        let depthMapPixelPoint = simd_float2(Float(point.x * depthMapSize.width), Float((1 - point.y) * depthMapSize.height))
        // This is crucial: you need to always use the view matrix for Landscape Right.
        let viewMatrixInverted = self.camera.viewMatrix(for: .landscapeRight).inverse
        
        let xrw = ((depthMapPixelPoint.x - cameraIntrinsics[2][0]) * depth / cameraIntrinsics[0][0])
        let yrw = (depthMapPixelPoint.y - cameraIntrinsics[2][1]) * depth / cameraIntrinsics[1][1]
        // Y is UP in camera space, vs it being DOWN in image space.
        let localPoint = simd_float3(xrw, -yrw, -depth)
        let worldPoint = viewMatrixInverted * simd_float4(localPoint, 1)
        
        return (simd_float3(worldPoint.x, worldPoint.y, worldPoint.z), confidenceLevel)
    }
    
}
