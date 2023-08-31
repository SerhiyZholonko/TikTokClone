//
//  PreviewCapturedViewController.swift
//  TikTokClone
//
//  Created by apple on 31.08.2023.
//

import UIKit
import AVKit

class PreviewCapturedViewController: UIViewController {
    //MARK: - Properies
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    var player: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer = AVPlayerLayer ()
    var urlsForVids: [URL] = [] {
        didSet {
            print("outputURLunwrapped:", urlsForVids)
        }
    }
    var hideStatusBar: Bool = true {
        didSet {
            UIView.animate (withDuration: 0.3) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    var currentlyPlayingVideoClip: VideoClips
    let recordedClips: [VideoClips]
    var viewWillDenitRestartVideoSession: (() -> Void)?
    //MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleStartPlayingFirstClip()
        setupView()
        hideStatusBar = true
        recordedClips.forEach { clip in
            urlsForVids.append(clip.videoUrl)
        }
        print("\(recordedClips.count))")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        player.play()
        hideStatusBar = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        player.pause()
    }
    init? (coder: NSCoder, recordedClips: [VideoClips]){
        self.currentlyPlayingVideoClip = recordedClips.first!
        self.recordedClips = recordedClips
        super.init(coder: coder)
    }
    deinit {
        print ("PreviewCaptureVideoVC was deineted")
        (viewWillDenitRestartVideoSession)?()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Functions
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        hideStatusBar = true
        navigationController?.popViewController(animated:true)
    }
  
    @IBAction func nextButtonDidTapped(_ sender: Any) {
        handleMergeClips()
        hideStatusBar = false
        let shareVC = UIStoryboard(name: "MainTabBar", bundle: .main).instantiateViewController(identifier: "SharePostViewController") { coder ->
            SharePostViewController? in
            SharePostViewController(coder: coder, videoUrl: self.currentlyPlayingVideoClip.videoUrl)
        }
        
        shareVC.selectedPhoto = thumbnailImageView.image
        navigationController?.pushViewController(shareVC,animated:true)
        return
    }
    func handleMergeClips(){
        VideoCompositionWriter().mergeMultipleVideo(urls:urlsForVids){ success, outputURL in
            if success {
                guard let outputURLunwrapped = outputURL else {return}
                
                DispatchQueue.main.async {
                    let player = AVPlayer (url: outputURLunwrapped)
                    let vc = AVPlayerViewController ()
                    vc.player = player
                    self.present (vc , animated: true) {
                        vc.player?.play()
                    }
                }
            }
        }
    }
    func handleStartPlayingFirstClip() {
        DispatchQueue.main.asyncAfter (deadline: .now() + 0.5) {
            guard let firstClip = self.recordedClips.first else {return}
            self.currentlyPlayingVideoClip = firstClip
            self.setupPlayerView(with: firstClip)
        }
    }
    func setupPlayerView (with videoClip: VideoClips) {
        let player = AVPlayer (url: videoClip.videoUrl)
        let plaverLayer = AVPlayerLayer(player: player)
        self.player = player
        self.playerLayer = plaverLayer
        playerLayer.frame = thumbnailImageView.frame
        self.player = player
        self.playerLayer = plaverLayer
        thumbnailImageView.layer.insertSublayer(plaverLayer, at: 3)
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidPlayTondTime(notification: )), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        handleMirrorPlayer(cameraPosition: videoClip.cameraPosition)
    }
    func removePeriodicTimeObserver() {
        player.replaceCurrentItem(with: nil)
        playerLayer.removeFromSuperlayer()
    }
    func handleMirrorPlayer (cameraPosition: AVCaptureDevice.Position) {
        if cameraPosition == .front {
            thumbnailImageView.transform = CGAffineTransform(scaleX: -1, y: -1) }
        else {
            thumbnailImageView.transform = .identity
        }
    }
    @objc func avPlayerItemDidPlayTondTime(notification: Notification) {
        if let currentIndex = recordedClips.firstIndex(of: currentlyPlayingVideoClip) {
            let nextIndex = currentIndex + 1
            if nextIndex > recordedClips.count - 1 {
                removePeriodicTimeObserver()
                guard let firstClip = recordedClips.first else {return}
                setupPlayerView(with: firstClip)
                currentlyPlayingVideoClip = firstClip
            } else {
                for (index ,clip) in recordedClips.enumerated() {
                    if index == nextIndex {
                        removePeriodicTimeObserver()
                        setupPlayerView(with: clip)
                        currentlyPlayingVideoClip = clip
                    }
                }
            }
        }
    }
}


//MARK: - SetupUI
extension PreviewCapturedViewController {
    private func setupView() {
        nextButton.layer.cornerRadius = 2
        nextButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 88/255, alpha: 1.0)
    }
}
