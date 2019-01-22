//
//  SignUpDetailViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 09/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class SignUpDetailViewController: UIViewController {
    
    @IBOutlet weak var googleLoginButton : UIButton!
    @IBOutlet weak var facebookLoginButton : UIButton!
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var emailTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    @IBOutlet weak var confirmPasswordTextField : UITextField!
    @IBOutlet weak var signUpButton : UIButton!
    @IBOutlet weak var activityViewIndicator : UIActivityIndicatorView!
    
    var keyboardDisplayed : Bool = false
    var mobileNumber : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupTextFields()
        setupKeyboard()
        self.activityViewIndicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Sign Up"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupButtons(){
        googleLoginButton.backgroundColor = Colors.googleRedColor
        facebookLoginButton.backgroundColor = Colors.facebookBlueColor
    }
    
    func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @objc func keyboardWillAppear(_ notification : Notification){
        if self.view.frame.origin.y >= 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                
                if !keyboardDisplayed  {
                    self.view.frame.origin.y -= keyboardHeight/2
                    keyboardDisplayed = true
                    
                }
                
            }
        }
    }
    
    @objc func keyboardWillDisappear(_ notification : Notification){
        if self.view.frame.origin.y < 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                if keyboardDisplayed {
                    self.view.frame.origin.y += keyboardHeight/2
                    keyboardDisplayed = false
                }
            }
        }
    }
    
    
    
    func setupTextFields(){
        emailTextField.keyboardType = .emailAddress
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    @IBAction func signUpButtonTapped(){
        if nameTextField.text != "" || emailTextField.text != "" || passwordTextField.text != "" || confirmPasswordTextField.text != "" {
            if passwordTextField.text == confirmPasswordTextField.text  {
                let username = nameTextField.text
                let userEmail = emailTextField.text
                let userNumber = mobileNumber
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM yy, HH:mm"
                let userDate = dateFormatter.string(from: Date())
                let password = passwordTextField.text
                
                //                            let userId = "F" + username.uppercased()
                let emailIndex = userEmail?.index(of: "@")
                let editEmail = String((userEmail?.prefix(upTo: emailIndex!))!)
                
                let userId = removeSpecialCharsFromString(text: editEmail).uppercased()
                
                
                
                Auth.auth().createUser(withEmail: userEmail!, password: password!, completion: { (user, error) in
                    if error == nil {
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                            if error == nil {
                                
                                FirebaseMethods().createNewUser(userId: userId, username: username!, userEmail: userEmail!, userNumber: userNumber, userDate: userDate) { (bool) in
                                    
                                    let email = userEmail!
                                    self.showAlert(msg: "Verification email has been sent to " + email)
                                    self.nameTextField.text = "Name"
                                    self.emailTextField.text = "Email"
                                    self.passwordTextField.text = "Password"
                                    self.confirmPasswordTextField.text = "Confirm Password"
                                    
                                    self.nameTextField.resignFirstResponder()
                                    self.emailTextField.resignFirstResponder()
                                    self.passwordTextField.resignFirstResponder()
                                    self.confirmPasswordTextField.resignFirstResponder()
                                    
                                    UserDefaults.standard.removeObject(forKey: "user_id")
                                }
                                
                            } else {
                                self.showAlert(msg: (error?.localizedDescription)!)
                            }
                        })
                    } else {
                        self.showAlert(msg: (error?.localizedDescription)!)
                    }
                })
            } else {
                self.showAlert(msg: "Passwords don't match")
            }
            
        } else {
            self.showAlert(msg: "Text Fields cannot be empty!")
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
                            let userNumber = self.mobileNumber
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
    
    @IBAction func googleLoginPressed() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
}

extension SignUpDetailViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        if textField == confirmPasswordTextField || textField == passwordTextField {
            textField.isSecureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            if textField.text == "" {
                textField.text = "Name"
            }
        } else if textField == emailTextField {
            if textField.text == "" {
                textField.text = "Email"
            }
        } else if textField == passwordTextField {
            if textField.text == "" {
                textField.text = "Password"
                textField.isSecureTextEntry = false
            }
        } else {
            if textField.text == "" {
                textField.text = "Confirm Password"
                textField.isSecureTextEntry = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpDetailViewController : GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        activityViewIndicator.isHidden = false
        activityViewIndicator.startAnimating()
        if error != nil {
            activityViewIndicator.isHidden = true
            activityViewIndicator.stopAnimating()
            self.showAlert(msg: "Error occured during authenication process")
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
            } else {
                self.activityViewIndicator.isHidden = true
                self.activityViewIndicator.stopAnimating()
                
                //user details to be stored in firebase
                let username = user?.displayName ?? ""
                let userEmail = user?.email ?? ""
                let userNumber = self.mobileNumber
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM yy, HH:mm"
                let userDate = dateFormatter.string(from: Date())
                
                
                let userID = userEmail.replacingOccurrences(of: "@gmail.com", with: "")
                let editedEmail = self.removeSpecialCharsFromString(text: userID).uppercased()
                
                FirebaseMethods().createNewUser(userId: editedEmail, username: username, userEmail: userEmail, userNumber: userNumber, userDate: userDate, completionHandler: {(bool) in
                    if bool {
                        
                        //present side panel view controller
//                        let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController")
//                        UserDetails.signedIn = true
//                        UserDefaults.standard.set(true, forKey: "signedIn")
//                        self.present(sidePanelViewController, animated: true, completion: nil)
                        
                        UserDefaults.standard.set(true, forKey: "signedIn")
                        
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

