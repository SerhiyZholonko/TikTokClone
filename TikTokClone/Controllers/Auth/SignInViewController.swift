//
//  SingInViewController.swift
//  TikTokClone
//
//  Created by apple on 29.08.2023.
//

import UIKit
import ProgressHUD

class SignInViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var singInButton: UIButton!
    //MARK: - Livecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupEmailTextfield()
        setupPasswordTextfield()
        setupView()
    }
    
    
    //MARK: - Func
   
    @IBAction func singInDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.validatefields()
        signIn {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
                sd.configureInitialviewControlr()
            }
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }

    }
}


//MARK: - Setup UI
extension SignInViewController {
    private func setupNavigationBar() {
        navigationItem.title = "Sing In"
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
        singInButton.layer.cornerRadius = 18
    }
}

//MARK: - Validation
extension SignInViewController {
    private func validatefields() {
       
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

//MARK: - Signin
extension SignInViewController {
    private func signIn(onSuccess: @escaping() -> Void, onError:
                        @escaping(_ errorMessage: String) -> Void) {
        ProgressHUD.show("Loading...")
        Api.User.singIn(email: emailTextField.text!, password: passwordTextField.text!) {
            ProgressHUD.dismiss()
            onSuccess()
        } onError: { errorMessage in
            onError(errorMessage)
        }

    }
}
