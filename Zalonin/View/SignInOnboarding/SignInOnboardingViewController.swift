//
//  SignInOnboardingViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 08/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class SignInOnboardingViewController: UIViewController {

    @IBOutlet weak var signUpButton : UIButton!
    @IBOutlet weak var signInButton : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        signInButton.backgroundColor = Colors.grayColor3
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButtonTapped(){
        let signUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.present(signUpViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
       
        self.navigationController?.navigationBar.barTintColor = Colors.startColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [Colors.startColor.cgColor,Colors.midColor.cgColor, Colors.blackColor.cgColor]
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, at: 0)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Sign in / Sign up"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    @IBAction func signInButtonTapped(){
        //todo
    }

}
