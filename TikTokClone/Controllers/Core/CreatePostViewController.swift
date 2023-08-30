//
//  CreatePostViewController.swift
//  TikTokClone
//
//  Created by apple on 30.08.2023.
//

import UIKit

class CreatePostViewController: UIViewController {
    //MARK: - Properties
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var canselButton: UIButton!
    @IBOutlet weak var captureButtonRingView: UIView!
    //MARK: - Livecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
}

//MARK: - Setup UI
extension CreatePostViewController {
    func setupUI() {
        captureButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1)
        captureButton.layer.cornerRadius = 68/2
        captureButtonRingView.layer.borderColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 0.5).cgColor
        captureButtonRingView.layer.borderWidth = 6
        captureButtonRingView.layer.cornerRadius = 85/2
    }
}
