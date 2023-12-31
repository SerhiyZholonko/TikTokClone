//
//  VideoCompositionWriter.swift
//  TikTokClone
//
//  Created by Mac on 13.02.2023.
//

import AVFoundation
import UIKit

class VideoCompositionWriter: NSObject {
    var exportSession: AVAssetExportSession?
    
    func mergeMultipleVideo(urls: [URL], onComplete: @escaping (Bool, URL?) -> Void) {
        var totalDuration = CMTime.zero
        var assets: [AVAsset] = []
        
        for url in urls {
            let asset = AVAsset(url: url)
            assets.append(asset)
            totalDuration = CMTimeAdd(totalDuration, asset.duration)
        }
        
        let outputURL = createOutputUrl(with: urls.first!)
        let mixComposition = merge(arrayVideos: assets)
        handleCreateExportSession(outputURL: outputURL, mixComposition: mixComposition, onComplete: onComplete)
       
    }
    
    func handleCreateExportSession(outputURL: URL, mixComposition: AVMutableComposition, onComplete: @escaping (Bool,URL?) -> Void) {
        exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputURL = outputURL
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.mp4
        
        var exportProgressBarTimer = Timer()
        guard let exportSessionUnwrapped = exportSession else { exportProgressBarTimer.invalidate()
            return}
        exportProgressBarTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            let progress = Float((exportSessionUnwrapped.progress));
            let dict:[String: Float] = ["progress": progress]
        })
        
        guard let exportSession = exportSession else {exportProgressBarTimer.invalidate()
            return
        }
        exportSession.exportAsynchronously {
            exportProgressBarTimer.invalidate();
            switch exportSession.status {
            case .completed:
                DispatchQueue.main.async {
                    let dict: [String: Float] = ["progress": 1.0]
                    
                    onComplete(true, exportSession.outputURL)
                }
            case .failed:
                print("Failed \(exportSession.error.debugDescription)")
                onComplete(false, nil)
                
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
                onComplete(false, nil)
                
            default: break
            }
        }
    }
    
    func createOutputUrl(with videoUrl: URL) -> URL {
        let fileManager = FileManager.default
        let documentDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        
        var outputUrl = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputUrl, withIntermediateDirectories: true)
            outputUrl = outputUrl.appendingPathComponent("\(videoUrl.lastPathComponent)")
        } catch let error {
            print(error)
        }
        
        return outputUrl
    }
    
    func merge(arrayVideos: [AVAsset]) -> AVMutableComposition {
        let mainComposition = AVMutableComposition()
        
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAudioTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let frontCameraTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0).rotated(by: CGFloat(Double.pi/2))
        let backCameraTransform: CGAffineTransform = CGAffineTransform(rotationAngle: .pi/2)
        
        compositionVideoTrack?.preferredTransform = backCameraTransform
        
        var insertTime = CMTime.zero
        
        for videoAsset in arrayVideos {
            try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of:
                                                            videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
            
            if videoAsset.tracks(withMediaType: .audio).count > 0 {
                try! compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)
            }
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        return mainComposition
        
    }
}

func saveVideoTobeUploadedToServerToTempDirectory(sourceURL: URL, completion: ((_ outputUrl: URL) -> Void)? = nil) {

    let fileManager = FileManager.default
    //        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //
    let documentDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    
    let asset = AVAsset(url: sourceURL)
    let length = Float(asset.duration.value) / Float(asset.duration.timescale)
    print("video length: \(length) seconds")
    
    var outputURL = documentDirectory.appendingPathComponent("output")
    do {
        try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
    }catch let error {
        print(error)
    }
    
    //Remove existing file
    try? fileManager.removeItem(at: outputURL)
    
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
    exportSession.outputURL = outputURL
    exportSession.outputFileType = AVFileType.mp4
    
    
    exportSession.exportAsynchronously {
        switch exportSession.status {
        case .completed:
            print("exported at \(outputURL)")
            completion?(outputURL)
        case .failed:
            print("failed \(exportSession.error.debugDescription)")
        case .cancelled:
            print("cancelled \(exportSession.error.debugDescription)")
        default: break
        }
    }
}
