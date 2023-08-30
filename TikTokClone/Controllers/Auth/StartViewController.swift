//
//  ViewController.swift
//  TikTokClone
//
//  Created by apple on 29.08.2023.
//

import UIKit

class StartViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleBotton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - Livecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    //MARK: - func
    private func setupView() {
        signUpButton.layer.cornerRadius = 18
        facebookButton.layer.cornerRadius = 18
        googleBotton.layer.cornerRadius = 18
        loginButton.layer.cornerRadius = 18
    }
    @IBAction func singUpDidTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let viewController = storyboard.instantiateViewController (withIdentifier: "SingUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(viewController,animated:true)
    }
    @IBAction func singInDidTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let viewController = storyboard.instantiateViewController (withIdentifier: "SingInViewController") as! SignInViewController
        self.navigationController?.pushViewController(viewController,animated:true)
    }
}

