//
//  SingUpViewController.swift
//  TikTokClone
//
//  Created by apple on 29.08.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import PhotosUI
import ProgressHUD

class SignUpViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var sianUpButton: UIButton!
    
    var image: UIImage? = nil
    //MARK: - Livecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUsernameTextfield()
        setupEmailTextfield()
        setupPasswordTextfield()
        setupView()
    }
    //MARK: - func

  
    @IBAction func singUpDidTapped(_ sender: Any) {
        self.validatefields()
        self.signUp {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
                sd.configureInitialviewControlr()
            }
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)

        }
    }
}

//MARK: - validation
extension SignUpViewController {
    private func validatefields() {
        guard let username = self.usernameTextfield.text, !username.isEmpty else {
            ProgressHUD.showError("Please enter an username")
            return
        }
        guard let email = self.emailTextField.text, !email.isEmpty else {
            ProgressHUD.showError("Please enter a email")
            return
            }
            guard let password = self.passwordTextField.text, !password.isEmpty else {
                ProgressHUD.showError("Please enter a password")
                return
            }
    }
}
//MARK: - setupUI
extension SignUpViewController {
    private func setupNavigationBar() {
        navigationItem.title = "Create new account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    private func setupUsernameTextfield() {
        usernameContainerView.layer.borderWidth = 1
        usernameContainerView.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        usernameContainerView.layer.cornerRadius = 20
        usernameContainerView.clipsToBounds = true
        usernameTextfield.borderStyle = .none
    }
    private func setupEmailTextfield() {
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        emailContainerView.layer.cornerRadius = 20
        emailContainerView.clipsToBounds = true
        emailTextField.borderStyle = .none
    }
    private func setupPasswordTextfield() {
        passwordContainerView.layer.borderWidth = 1
        passwordContainerView.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        passwordContainerView.layer.cornerRadius = 20
        passwordContainerView.clipsToBounds = true
        passwordTextField.borderStyle = .none
    }
    private func setupView() {
        avatar.layer.cornerRadius = 60
        sianUpButton.layer.cornerRadius = 18
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        let tapesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer (tapesture)
    }
}

//MARK: - PHPickerViewControllerDelegate
extension SignUpViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let imageSelected = image as? UIImage {
                    DispatchQueue.main.async { [weak self] in
                        self?.avatar.image = imageSelected
                        self?.image = imageSelected
                    }
                }
            }
        }
        dismiss(animated: true)
    }
    @objc private func presentPicker() {
        var configuration: PHPickerConfiguration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.images
        configuration.selectionLimit = 1
        let picker: PHPickerViewController = PHPickerViewController (configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
   
    
}

//MARK: - SingUp
extension SignUpViewController {
    private func signUp(onSuccess: @escaping() -> Void, onError:
                        @escaping(_ errorMessage: String) -> Void) {
        ProgressHUD.show("Loading...")
        Api.User.signUp(withUsername: usernameTextfield.text!, email: emailTextField.text!, password: passwordTextField.text!, image: image) {
            ProgressHUD.dismiss()
            ProgressHUD.showSucceed("Done")
            onSuccess()
        } onError: { errorMessage in
            onError(errorMessage)

        }

    }
}
