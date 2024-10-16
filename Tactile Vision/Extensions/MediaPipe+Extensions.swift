//
//  MediaPipe+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 18/09/24.
//

import MediaPipeTasksVision

extension ResultCategory {
    var label: String {
        return switch self.categoryName {
        case "None": "❓"
        case "Closed_Fist": "✊"
        case "Open_Palm": "✋"
        case "Pointing_Up": "👆"
        case "Thumb_Down": "👎"
        case "Thumb_Up": "👍"
        case "Victory": "✌️"
        default: self.categoryName ?? "❓"
        }
    }
}

extension NormalizedLandmark {
    var point: CGPoint {
        let x = CGFloat(self.x)
        let y = CGFloat(self.y)
        return CGPoint(x: x, y: y)
    }
}
