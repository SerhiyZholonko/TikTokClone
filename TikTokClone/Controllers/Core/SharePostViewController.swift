//
//  SharePostViewController.swift
//  TikTokClone
//
//  Created by apple on 31.08.2023.
//

import UIKit
import AVFoundation
import ProgressHUD

class SharePostViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var draftsButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    let placeholder = "please write a description"
    var encodedVideoURL: URL?
    let originalVideoUrl : URL
    var selectedPhoto: UIImage?
    //MARK: - Livecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewDidChanged()
        self.view.addGestureRecognizer (UITapGestureRecognizer(target: self, action: #selector (hideKeyboard)))
        if let thumbnailImage = self.thumbnailImageForFileUrl(originalVideoUrl) {
            self.selectedPhoto = thumbnailImage.imageRotated(by: .pi/2)
            thumbnailImageView.image = thumbnailImage
        }
        saveVideoTobeUploadedToServerToTempDirectory(sourceURL: originalVideoUrl) {[weak self] (outputURL) in
            self?.encodedVideoURL = outputURL
            print("encodedVideoURL", outputURL)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    init?(coder: NSCoder, videoUrl: URL) {
        self.originalVideoUrl = videoUrl
        super.init (coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset (url: fileUrl)
        let imageGenerator = AVAssetImageGenerator (asset: asset)
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 7, timescale: 1), actualTime: nil)
            return UIImage (cgImage: thumbnailCGImage)
        }
        catch let err{
            print (err)
            return nil
        }
    }
    func setupView() {
        draftsButton.layer.borderColor = UIColor.lightGray.cgColor
        draftsButton.layer.borderWidth = 0.3
    }
    @objc func hideKeyboard() {
        self.view.endEditing (true)
    }
    
    @IBAction func sharePostDidTapped(_ sender: Any) {
        self.sharePost {
            self.dismiss (animated: true) {
                self.tabBarController?.selectedIndex = 0
            }
        }
        onError: { errorMessage in
            ProgressHUD.showError (errorMessage)
        }
        
    }
    func sharePost(onSuccess: @escaping() -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        ProgressHUD.show("Loading...")
        Api.Post.sharePost(encodedVideoURL: encodedVideoURL, selectedPhoto: selectedPhoto, textView: textView) {
            ProgressHUD.dismiss()
            onSuccess()
        } onError: { errorMessage in onError (errorMessage)
        }
    }
}



//MARK: - UITextFieldDelegate
extension SharePostViewController: UITextViewDelegate {
    func textViewDidChanged(){
    textView.delegate = self
    textView.text = placeholder
    textView.textColor = .lightGray
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .lightGray{
                textView.text = ""
                textView.textColor = .black
            }
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            
        }
}
}

extension UIImage {
    
    func imageRotated(by radian: CGFloat) -> UIImage{
        let rotatedSize = CGRect (origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle:radian))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x,
                                y: origin.y)
            context.rotate (by: radian)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage ?? self
            
        }
        return self
    }
}
