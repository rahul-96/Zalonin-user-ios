//
//  SignInViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 08/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    @IBOutlet weak var facebookLoginBbutton : UIButton!
    @IBOutlet weak var googleLoginButton : UIButton!
    @IBOutlet weak var forgotPasswordButton : UIButton!
    @IBOutlet weak var signUpButton : UIButton!
    @IBOutlet weak var signInButton : UIButton!
    @IBOutlet weak var activityViewIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupLoginButtons()
        activityViewIndicator.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "Sign In"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDetails.signedIn {
            // if User is already signed in dismiss view controller
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func googleLoginPressed() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupTextFields(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.keyboardType = .emailAddress
    }
    
    func setupLoginButtons(){
        self.googleLoginButton.backgroundColor = Colors.googleRedColor
        self.facebookLoginBbutton.backgroundColor = Colors.facebookBlueColor
    }
    
    @IBAction func signInButtonTapped(){
        if emailTextField.text == "" && passwordTextField.text == "" {
            self.showAlert(msg: "Text Fields cannot be empty")
        } else {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    
                    if (user?.isEmailVerified)! {

                        let userEmail = user?.email
                        let emailIndex = userEmail?.index(of: "@")
                        let editEmail = String((userEmail?.prefix(upTo: emailIndex!))!)
                        
                        let userId = self.removeSpecialCharsFromString(text: editEmail).uppercased()
                        
                        UserDefaults.standard.set(userId, forKey: "user_id")
                        
//                        let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController") as! SidePanelViewController
//                        UserDetails.signedIn = true
//                        UserDefaults.standard.set(true, forKey: "signedIn")
//                        self.present(sidePanelViewController, animated: true, completion: nil)
                        
                        
                        UserDefaults.standard.set(true, forKey: "signedIn")
                  
                        let userDetailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserDetailTableViewController") as! UserDetailTableViewController
                        self.present(userDetailTableViewController, animated: true, completion: nil)
                        
                    } else {
                        self.showAlert(msg: "User is not verified!")
                    }
                } else {
                    self.showAlert(msg: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(){
        if emailTextField.text != "" || emailTextField.text != " " || emailTextField.text == "Email" {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
                if error != nil {
                    //error occured
                    self.showAlert(msg: "Unexpected error occured. Please try again after some time.")
                } else {
                    // show alert
                    self.showAlert(msg: "Reset password instructions have been emailed to the email!")
                }
            }
        } else {
        //show alert
            self.showAlert(msg: "Email cannot be empty!")
        }
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    
    @IBAction func facebookLoginClicked(){
        let fbManager = FBSDKLoginManager()
        self.activityViewIndicator.isHidden = false
        self.activityViewIndicator.startAnimating()
        fbManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                self.activityViewIndicator.isHidden = true
                self.activityViewIndicator.stopAnimating()
                self.showAlert(msg: (error?.localizedDescription)!)
            } else {
                if (result?.isCancelled)! {
                    self.activityViewIndicator.isHidden = true
                    self.activityViewIndicator.stopAnimating()
                    self.showAlert(msg: "Facebook Login Canceled")
                } else {
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential, completion: { (user, error) in
                        if error != nil {
                            self.activityViewIndicator.isHidden = true
                            self.activityViewIndicator.stopAnimating()
                            self.showAlert(msg: (error?.localizedDescription)!)
                        } else {
                            self.activityViewIndicator.isHidden = true
                            self.activityViewIndicator.stopAnimating()
                            
                            
                            let username = user?.displayName ?? ""
                            let userEmail = user?.email ?? ""
                            let userNumber = user?.phoneNumber ?? ""
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "d MMMM yy, HH:mm"
                            let userDate = dateFormatter.string(from: Date())
                            
                            //                            let userId = "F" + username.uppercased()
                            let emailIndex = userEmail.index(of: "@")
                            let editEmail = userEmail.prefix(upTo: emailIndex!)
                            let userId = "F" + self.removeSpecialCharsFromString(text: String(editEmail)).uppercased()
                            
                            FirebaseMethods().createNewUser(userId: userId, username: username, userEmail: userEmail, userNumber: userNumber, userDate: userDate, completionHandler: {(bool) in
                                if bool {
                                    
                                    //present side panel view controller
//                                    let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController")
//                                    UserDetails.signedIn = true
//                                    UserDefaults.standard.set(true, forKey: "signedIn")
//                                    self.present(sidePanelViewController, animated: true, completion: nil)
                                    
                                    
                                    UserDefaults.standard.set(true, forKey: "signedIn")
 
                                    let userDetailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserDetailTableViewController") as! UserDetailTableViewController
                                    self.present(userDetailTableViewController, animated: true, completion: nil)
                                }
                            })
                            
                        }
                    })
                }
            }
        }
    }
}

extension SignInViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if textField.text == "Email" {
                textField.text = ""
            }
        } else {
            if textField.text == "Password" {
                textField.text = ""
            }
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            if textField == emailTextField {
                textField.text = "Email"
            } else {
                textField.text = "Password"
                passwordTextField.isSecureTextEntry = false
            }
        }
    }
    
    func disableButtons(_ bool : Bool){
        self.googleLoginButton.isEnabled = !bool
        self.facebookLoginBbutton.isEnabled = !bool
        self.signInButton.isEnabled = !bool
    }
}


extension SignInViewController : GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        activityViewIndicator.isHidden = false
        activityViewIndicator.startAnimating()
        disableButtons(true)
        if error != nil {
            activityViewIndicator.isHidden = true
            activityViewIndicator.stopAnimating()
            self.showAlert(msg: "Error occured during authenication process")
            self.disableButtons(false)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                self.activityViewIndicator.isHidden = true
                self.activityViewIndicator.stopAnimating()
                self.showAlert(msg: "Error occured during authenication process")
                self.disableButtons(false)
            } else {
                self.activityViewIndicator.isHidden = true
                self.activityViewIndicator.stopAnimating()
                
                //user details to be stored in firebase
                let username = user?.displayName ?? ""
                let userEmail = user?.email ?? ""
                let userNumber = user?.phoneNumber ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM yy, HH:mm"
                let userDate = dateFormatter.string(from: Date())
                
                
                let userID = userEmail.replacingOccurrences(of: "@gmail.com", with: "")
                let editedEmail = self.removeSpecialCharsFromString(text: userID).uppercased()
                
                FirebaseMethods().createNewUser(userId: editedEmail, username: username, userEmail: userEmail, userNumber: userNumber, userDate: userDate, completionHandler: {(bool) in
                    if bool {
                        
                        //present side panel view controller
//                        let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController")
                        UserDetails.signedIn = true

                        UserDefaults.standard.set(true, forKey: "signedIn")
//
                        
                        let userDetailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserDetailTableViewController") as! UserDetailTableViewController
                        self.present(userDetailTableViewController, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
