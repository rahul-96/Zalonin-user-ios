//
//  SignUpViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 08/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var mobileNumberTextField : UITextField!
    @IBOutlet weak var nextButton : UIButton!
    
    let defaultText : String = "XXXXXXXXXX"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileNumberTextField.text = defaultText
        mobileNumberTextField.delegate = self
        mobileNumberTextField.backgroundColor = Colors.grayColor2
        mobileNumberTextField.keyboardType = .numberPad
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
        self.mobileNumberTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Enter Mobile Number"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mobileNumberTextField.text = defaultText
        self.mobileNumberTextField.resignFirstResponder()
        
    }
    
    
    @objc func viewTapped(){
        mobileNumberTextField.resignFirstResponder()
    }
    
    @IBAction func nextButtonTapped(){
        if mobileNumberTextField.text == "" || mobileNumberTextField.text == defaultText {
            self.showAlert(msg : "Mobile Number cannot be empty!")
            self.mobileNumberTextField.resignFirstResponder()
        } else if (mobileNumberTextField.text?.count)! < 10 {
            self.showAlert(msg: "Please enter a valid number")
        } else {
            let signUpDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpDetailViewController") as! SignUpDetailViewController
            signUpDetailViewController.mobileNumber = mobileNumberTextField.text!
            self.navigationController?.pushViewController(signUpDetailViewController, animated: true)
        }
    }
    
   
}

extension SignUpViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            mobileNumberTextField.text = self.defaultText
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
