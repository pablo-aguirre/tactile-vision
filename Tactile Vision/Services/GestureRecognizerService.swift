//
//  GestureRecognizerService.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 17/09/24.
//

import MediaPipeTasksVision

class GestureRecognizerService: NSObject {
    var gestureRecognizer: GestureRecognizer?
    private(set) var runningMode = RunningMode.image
    private var minHandDetectionConfidence: Float
    private var minHandPresenceConfidence: Float
    private var minTrackingConfidence: Float
    private var modelPath: String
    private var delegate: Delegate
    private var liveStreamDelegate: GestureRecognizerLiveStreamDelegate?
    
    static func liveStreamGestureRecognizerService(
        modelPath: String?,
        minHandDetectionConfidence: Float,
        minHandPresenceConfidence: Float,
        minTrackingConfidence: Float,
        delegate: Delegate,
        liveStreamDelegate: GestureRecognizerLiveStreamDelegate) -> GestureRecognizerService?
    {
        let gestureRecognizerService = GestureRecognizerService(
            modelPath: modelPath,
            runningMode: .liveStream,
            minHandDetectionConfidence: minHandDetectionConfidence,
            minHandPresenceConfidence: minHandPresenceConfidence,
            minTrackingConfidence: minTrackingConfidence,
            delegate: delegate,
            liveStreamDelegate: liveStreamDelegate
        )
        
        return gestureRecognizerService
    }
    
    private init?(
        modelPath: String?,
        runningMode: RunningMode,
        minHandDetectionConfidence: Float,
        minHandPresenceConfidence: Float,
        minTrackingConfidence: Float,
        delegate: Delegate,
        liveStreamDelegate: GestureRecognizerLiveStreamDelegate? = nil)
    {
        guard let modelPath = modelPath else { return nil }
        self.modelPath = modelPath
        self.runningMode = runningMode
        self.minHandDetectionConfidence = minHandDetectionConfidence
        self.minHandPresenceConfidence = minHandPresenceConfidence
        self.minTrackingConfidence = minTrackingConfidence
        self.delegate = delegate
        self.liveStreamDelegate = liveStreamDelegate
        super.init()
        
        createGestureRecognizer()
    }
    
    private func createGestureRecognizer() {
        let gestureRecognizerOptions = GestureRecognizerOptions()
        gestureRecognizerOptions.runningMode = runningMode
        gestureRecognizerOptions.minHandDetectionConfidence = minHandDetectionConfidence
        gestureRecognizerOptions.minHandPresenceConfidence = minHandPresenceConfidence
        gestureRecognizerOptions.minTrackingConfidence = minTrackingConfidence
        gestureRecognizerOptions.baseOptions.modelAssetPath = modelPath
        gestureRecognizerOptions.baseOptions.delegate = delegate
        if runningMode == .liveStream {
            gestureRecognizerOptions.gestureRecognizerLiveStreamDelegate = liveStreamDelegate
        }
        do {
            gestureRecognizer = try GestureRecognizer(options: gestureRecognizerOptions)
        }
        catch {
            print(error)
        }
    }
    
    func recognizeAsync(pixelBuffer: CVPixelBuffer, timeStamp: Int) {
        guard let image = try? MPImage(pixelBuffer: pixelBuffer) else { return }
        do {
            try gestureRecognizer?.recognizeAsync(image: image, timestampInMilliseconds: timeStamp)
        } catch {
            print(error)
        }
    }
}

