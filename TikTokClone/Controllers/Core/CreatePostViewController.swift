//
//  CreatePostViewController.swift
//  TikTokClone
//
//  Created by apple on 30.08.2023.
//

import UIKit
import AVFoundation

class CreatePostViewController: UIViewController {
    //MARK: - Properties
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var canselButton: UIButton!
    @IBOutlet weak var captureButtonRingView: UIView!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var flipLabel: UILabel!
    
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var effectsButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var beautylabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var flashLabel: UILabel!
    @IBOutlet weak var timeCounterLabel: UILabel!
    @IBOutlet weak var soundView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    let photoFileOutput = AVCapturePhotoOutput()
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outPutURL : URL!
    var currentCameraDevice: AVCaptureDevice?
    var thumbnailImage: UIImage?
    var recordedClips = [VideoClips]()
    var isRecording = false
    var videoDurationOfLastClip = 0
    var recordingTimer: Timer?
    var total_RecordedTime_In_Secs = 0
    var total_RecordedTime_In_Minutes  = 0
    var currentMaxRecordingDuration: Int = 15 {
        didSet{
            timeCounterLabel.text = "\(currentMaxRecordingDuration)"
        }
    }
    
    private lazy var segmentedProgressView = SegmentedProgressView(width: view.frame.width - 17.5)
    //MARK: - Livecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if setupCaptureSession() {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    //MARK: - Functions
    
    @IBAction func captureButtonDidTapped(_ sender: Any) {
        handleDidTapRecord()
    }
    private func handleDidTapRecord() {
        if movieOutput.isRecording == false {
            startRecording()
        }  else {
            stopRecording()
        }
    }
    
    
    
    @IBAction func flipButtonDidTapped(_ sender: Any) {
        captureSession.beginConfiguration()
        
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        let newCameraDevice = currentInput?.device.position == .back ? getDeviceFront(position: .front) : getDeviceBack(position: .back)
        
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        if captureSession.inputs.isEmpty{
            captureSession.addInput(newVideoInput!)
            activeInput = newVideoInput
        }
        if let microphone = AVCaptureDevice.default (for: .audio) {
            do {
                let micInput = try AVCaptureDeviceInput(device: microphone)
                if captureSession.canAddInput(micInput) {
                    captureSession.addInput(micInput)
                }
            }catch let micInputError {
                print ("Error setting device audio input\(micInputError)")
            }
        }
        captureSession.commitConfiguration()
    }
    private func getDeviceFront (position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera,for:.video, position: .front)
    }
    private func getDeviceBack(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera,for:.video, position: .back)
    }
    
    
    @IBAction func handleDismiss(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    private func tempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent (NSUUID() .uuidString + " .mp4")
            return URL( fileURLWithPath: path)
        }
        return nil
    }
    private func startRecording() {
        if movieOutput.isRecording == false {
            guard let connection = movieOutput.connection (with: .video) else {return}
            if connection.isVideoOrientationSupported {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                let device = activeInput.device
                if device.isSmoothAutoFocusSupported{
                    do {
                        try device.lockForConfiguration()
                        device.isSmoothAutoFocusEnabled = false
                        device.unlockForConfiguration()
                    } catch {
                        print ("Eerror setting configuration: \(error)")
                    }
                }
                outPutURL = tempUrl()
                movieOutput.startRecording(to: outPutURL, recordingDelegate: self)
                handleAnimateRecordButton()
                startTimer()
            }
        }
    }
    private func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            handleAnimateRecordButton()
            stopTimer()
            segmentedProgressView.pauseProgress()
            print("STOP THE COUNT")
        }
    }
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        let previewVC = UIStoryboard (name: "MainTabBar", bundle: .main).instantiateViewController (identifier: "PreviewCapturedViewController", creator: {
            coder -> PreviewCapturedViewController? in
            PreviewCapturedViewController(coder: coder, recordedClips: self.recordedClips)
        })
        previewVC.viewWillDenitRestartVideoSession = {[weak self] in
            guard let self = self else {return}
            if self.setupCaptureSession() {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
        navigationController?.pushViewController(previewVC, animated: true)
    }
    @IBAction func discardButtonDidTapped(_ sender: Any) {
        let alertVC = UIAlertController (title: "Discard the last clip?", message: nil, preferredStyle: .alert)
        let discardAction = UIAlertAction(title: "Discard", style: .default){ [weak self] (_) in
            self?.handleDiscardLastRecordedClip()
        }
        let keepAction = UIAlertAction(title: "Keep", style: .cancel) { _ in
            
        }
        alertVC.addAction (discardAction)
        alertVC.addAction (keepAction)
        present (alertVC, animated: true)
    }
    private func handleDiscardLastRecordedClip() {
        print("discard")
        outPutURL = nil
        thumbnailImage = nil
        recordedClips.removeLast ()
        handleResetAlivisibilityToldendity()
        handleSetNewOutputURLAndThumbnailImage()
        segmentedProgressView.handleRemoveLastSegment()
        
        if recordedClips.isEmpty == true {
            handleResetAlivisibilityToldendity()
        } else if recordedClips.isEmpty == false {
            handleCalculateDurationLeft()
            }
    }
    func handleCalculateDurationLeft() {
        let timeToDiscard = videoDurationOfLastClip
        let currentCombineTime = total_RecordedTime_In_Secs
        let newVideoDuration = currentCombineTime - timeToDiscard
        total_RecordedTime_In_Secs = newVideoDuration
        let countDownSec: Int = Int (currentMaxRecordingDuration) - total_RecordedTime_In_Secs / 10
        timeCounterLabel.text = ("\(countDownSec)")
    }
    func handleSetNewOutputURLAndThumbnailImage() {
        outPutURL = recordedClips.last?.videoUrl
        let currentUrI: URL? = outPutURL
        guard let currentUrlUnwrapped = currentUrI else {return}
        guard let generatedThumbnailImage = generateVideoThumbnail(withFile: currentUrlUnwrapped) else {return}
        if currentCameraDevice?.position == .front{
            thumbnailImage = didTakePicture(generatedThumbnailImage, to: .upMirrored)
        } else {
            thumbnailImage  = generatedThumbnailImage
        }
    }
    private func handleAnimateRecordButton() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations:  { [weak self] in
            guard let self = self else {return}
            if self.isRecording == false {
                self.captureButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.captureButton.layer.cornerRadius = 5
                self.captureButtonRingView.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                
                self.saveButton.alpha = 0
                self.discardButton.alpha = 0
                
                [ self.galleryButton, self.effectsButton, self.soundView].forEach { subView in
                    subView?.isHidden = true
                }
            } else {
                self.captureButton.transform = CGAffineTransform.identity
                self.captureButton.layer.cornerRadius = 68/2
                self.captureButtonRingView.transform = CGAffineTransform.identity
                self.handleResetAlivisibilityToldendity()
            }
        }) { [weak self] onComplete in
            guard let self = self else { return }
            self.isRecording = !self.isRecording
        }
        
    }
    private func handleResetAlivisibilityToldendity() {
        if recordedClips.isEmpty == true {
            [self.galleryButton, self.effectsButton, self.soundView].forEach { subView in
                subView?.isHidden = false
            }
            saveButton.alpha = 0
            discardButton.alpha = 0
            print ("recordedClips: is Empty")
        } else {
            [ self.galleryButton, self.effectsButton, self.soundView].forEach { subView in
                subView?.isHidden = true
            }
            saveButton.alpha = 1
            discardButton.alpha = 1
            print ("recordedClips: is not Empty")
        }
        
    }
}

//MARK: - Setup UI
extension CreatePostViewController {
    private func setupUI() {
        captureButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1)
        captureButton.layer.cornerRadius = 68/2
        captureButtonRingView.layer.borderColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 0.5).cgColor
        captureButtonRingView.layer.borderWidth = 6
        captureButtonRingView.layer.cornerRadius = 85/2
        
        timeCounterLabel.backgroundColor = UIColor.black.withAlphaComponent (0.42)
        timeCounterLabel.layer.cornerRadius = 15
        timeCounterLabel.layer.borderColor = UIColor.white.cgColor
        timeCounterLabel.layer.borderWidth = 1.8
        timeCounterLabel.clipsToBounds = true
        
        soundView.layer.cornerRadius = 12
        saveButton.layer.cornerRadius = 17
        saveButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1)
        saveButton.alpha = 0
        discardButton.alpha = 0
        
        view.addSubview(segmentedProgressView)
        segmentedProgressView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        segmentedProgressView.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        segmentedProgressView.widthAnchor.constraint(equalToConstant:view.frame.width - 17.5).isActive = true
        segmentedProgressView.heightAnchor.constraint(equalToConstant:6).isActive = true
        segmentedProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        [self.captureButton, self.canselButton, self.captureButtonRingView, self.flipButton, self.flipLabel, self.speedButton, self.beautyButton, self.filterButton, self.timerButton, self.flashButton, self.galleryButton, self.effectsButton, self.speedLabel, self.beautylabel, self.filterLabel, self.timerLabel, self.flashLabel, self.timeCounterLabel, self.soundView, self.saveButton, self.discardButton].forEach { subView in
            subView?.layer.zPosition = 1
        }
    }
}

//MARK: -
extension CreatePostViewController {
    private func setupCaptureSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // 1. Setup inputs
        if let captureVideoDevice = AVCaptureDevice.default (for: AVMediaType.video),
           let captureAudioDevice = AVCaptureDevice.default (for: AVMediaType.audio){
            do{
                let inputVideo = try AVCaptureDeviceInput(device: captureVideoDevice)
                let inputAudio = try AVCaptureDeviceInput(device: captureAudioDevice)
                
                if captureSession.canAddInput (inputVideo) {
                    captureSession.addInput(inputVideo)
                    activeInput = inputVideo
                }
                if captureSession.canAddInput(inputAudio) {
                    captureSession.addInput(inputAudio)
                }
                if captureSession.canAddOutput(movieOutput) {
                    captureSession.addOutput(movieOutput)
                }
            } catch let error {
                print ("Could not setup camera input:", error)
                return false
            }
        }
        // 2. setup outputs
        if captureSession.canAddOutput(photoFileOutput) {
            captureSession.addOutput(photoFileOutput)
        }
        
        // 3. setup output previews.
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return true
    }
}


//MARK: -
extension CreatePostViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        let newRecordedClip = VideoClips(videoUrl: fileURL, cameraPosition: currentCameraDevice?.position)
        recordedClips.append(newRecordedClip)
        print ("recordedClips:", recordedClips.count)
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "")
        } else {
            let urlOfVideoRecorded = outPutURL! as URL
            
            guard let generatedThumbnailImage = generateVideoThumbnail(withFile: urlOfVideoRecorded) else { return }
            
            if currentCameraDevice?.position == .front {
                thumbnailImage = didTakePicture(generatedThumbnailImage, to: .upMirrored)
            } else {
                thumbnailImage = generatedThumbnailImage
            }
        }
    }
    
    func didTakePicture(_ picture: UIImage, to orientation: UIImage.Orientation) -> UIImage {
        let flippedImage = UIImage (cgImage: picture.cgImage!, scale: picture.scale, orientation: orientation)
        return flippedImage
    }
    func generateVideoThumbnail(withFile videoUrl: URL) -> UIImage? {
        var thumbnailImage: UIImage?
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        DispatchQueue.global(qos: .background).async {
            let asset = AVAsset(url: videoUrl)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            do {
                let cmTime = CMTimeMake(value: 1, timescale: 60)
                let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
                thumbnailImage = UIImage(cgImage: thumbnailCGImage)
            } catch let error {
                print(error.localizedDescription)
            }
            
            dispatchGroup.leave()
        }
        
        // Wait for the thumbnail generation to complete before returning
        dispatchGroup.wait()
        
        return thumbnailImage
    }
    
    
    
    
}


//MARK: - RECORDING TIMER

extension CreatePostViewController {
    private func startTimer() {
        videoDurationOfLastClip = 0
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _  in
            self?.timerTick()
        })
    }
    private func timerTick() {
        total_RecordedTime_In_Secs += 1
        videoDurationOfLastClip += 1
        let time_limit = currentMaxRecordingDuration * 10
        if total_RecordedTime_In_Secs == time_limit {
            handleDidTapRecord()
        }
        let startTime = 0
        let trimmedTime: Int = Int(currentMaxRecordingDuration) - startTime
        let positiverZero = max (total_RecordedTime_In_Secs, 0)
        let progress = Float (positiverZero) / Float (trimmedTime) / 10
        segmentedProgressView.setProgress(CGFloat(progress))
        let countDownSec: Int = Int(currentMaxRecordingDuration) - total_RecordedTime_In_Secs / 10
        timeCounterLabel.text = "\(countDownSec)s"
    }
    func handleResetTimersAndProgressViewToZero() {
        total_RecordedTime_In_Secs = 0
        total_RecordedTime_In_Minutes = 0
        videoDurationOfLastClip = 0
        stopTimer ()
        segmentedProgressView.setProgress(0)
        timeCounterLabel.text = ("\(currentMaxRecordingDuration)")
    }
    private func stopTimer() {
        recordingTimer?.invalidate()
    }
}
