//
//  ProfileViewController.swift
//  TikTokClone
//
//  Created by apple on 30.08.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    //MARK: - Properties
    
    
    //MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    
    @IBAction func signOutDidTapped(_ sender: Any) {
        Api.User.signOut()
        let scene = UIApplication.shared.connectedScenes.first
        if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
            sd.configureInitialviewControlr()
        }
    }
}
