//
//  VideoClips.swift
//  TikTokClone
//
//  Created by apple on 30.08.2023.
//

import UIKit
import AVKit

struct VideoClips: Equatable {
    let videoUrl: URL
    let cameraPosition: AVCaptureDevice.Position
    
    init(videoUrl: URL, cameraPosition: AVCaptureDevice.Position?) {
        self.videoUrl = videoUrl
        self.cameraPosition = cameraPosition ?? .back
    }
    static func ==(Ihs: VideoClips, rhs: VideoClips) -> Bool {
        return Ihs.videoUrl == rhs.videoUrl && Ihs.cameraPosition == rhs.cameraPosition
    }
}

