//
//  HomeCollectionViewCell.swift
//  TikTokClone
//
//  Created by apple on 01.09.2023.
//

import UIKit
import AVFoundation

protocol HomeCollectionViewCel1Delegate: AnyObject {
    func goToProfileUserVC(userId: String)
}

class HomeCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: HomeCollectionViewCel1Delegate?
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var postVideo: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var queuePlayer: AVQueuePlayer?
    var playerLayer: AVPlayerLayer?
    var playbackLooper: AVPlayerLooper?
    var isPlaying = false
    var post: Post? {
        didSet {
            updateView()
        }
    }
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    //MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 55/2
        let tapestureForAvatar = UITapGestureRecognizer(target: self, action:
        #selector (avatarTouchUpInside))
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tapestureForAvatar)
        avatar.clipsToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        queuePlayer?.pause()
    }
    //MARK: - Functions
    private func updateView() {
        descriptionLabel.text = post?.description
        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string: videoUrlString) {
            let playerItem = AVPlayerItem(url: videoUrl)
            self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
            self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
            guard let playerLayer = self.playerLayer else {return}
            guard let queuePlayer = self.queuePlayer else {return}
            self.playbackLooper = AVPlayerLooper.init(player: queuePlayer, templateItem: playerItem)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = contentView.bounds
            postVideo.layer.insertSublayer(playerLayer, at: 3)
            queuePlayer.play()
        }
    }
    private func setupUserInfo() {
        usernameLabel.text = user?.username
        guard let profileImageUrl = user?.profileImageUrl else {return}
        avatar.loadImage(profileImageUrl)
    }
    func replay() {
        if !isPlaying {
            self.queuePlayer?.seek(to: .zero)
            self.queuePlayer?.play()
            play()
        }
    }
    func play() {
        if isPlaying {
            self.queuePlayer?.play()
            isPlaying = true
        }
    }
    func pause() {
        print("isPlaying " ,isPlaying)
        if !isPlaying {
            self.queuePlayer?.pause()
            isPlaying = false
        }
    }
    
    func stop() {
        self.queuePlayer?.pause()
        self.queuePlayer?.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1))
    }
    @objc private func avatarTouchUpInside() {
        if let id = user?.uid {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
}
