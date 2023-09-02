//
//  EditProfileViewController.swift
//  TikTokClone
//
//  Created by apple on 02.09.2023.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class EditProfileViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var avatar: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        observeData()
    }
    //MARK: -
    func setupView() {
        avatar.layer.cornerRadius = 56
        logoutButton.layer.cornerRadius = 35/2
        avatar.contentMode = .scaleToFill
    }
    func observeData() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Api.User.observeUser(withId: uid) { user in
            self.usernameTextfield.text = user.username
            self.avatar.loadImage(user.profileImageUrl)
        }
    }
    @IBAction func deleteAccountDidTapped(_ sender: Any) {
        Api.User.deleteUser()
        Api.User.logOut()
        let scene = UIApplication.shared.connectedScenes.first
        if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
            sd.configureInitialviewControlr()
        }
    }
    @IBAction func logoutButtonDidTapped(_ sender: Any) {
        Api.User.logOut()
        let scene = UIApplication.shared.connectedScenes.first
        if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
            sd.configureInitialviewControlr()
        }
    }
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        var dict = Dictionary<String, Any> ()
        if let username = usernameTextfield.text, !username.isEmpty {
            dict["username"] = username
            Api.User.saveUserProfile(dict: dict) {
                ProgressHUD.showSuccess()
                let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
                let profileVC = storyboard.instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
                self.navigationController?.pushViewController(profileVC, animated: true)
            } onError: { errorMessage in
                ProgressHUD.showError(errorMessage)
            }

        }
    }
}
