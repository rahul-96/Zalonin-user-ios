//
//  UserDetailTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 20/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class UserDetailTableViewController : UITableViewController {
    
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var ageTextField : UITextField!
    @IBOutlet weak var numberTextField : UITextField!
    @IBOutlet weak var userImageView : UIImageView!
    @IBOutlet weak var segmentController : UISegmentedControl!
    
    @IBOutlet weak var saveButton : UIButton!
    
    let datePicker = UIDatePicker()
    
    let genderArray : [String] = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveButton()
        setupTextFields()
        
        let gestureRecogoniser = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(gestureRecogoniser)
        
        FirebaseMethods().fetchUserDetails { (userName, userEmail, userGender, userNumber, references, requestCount, wallet, birthDate) in
            
            if userName == "" {
                self.nameTextField.text = "Name"

            } else {
                self.nameTextField.text = userName
            }
            
            if userNumber == "" {
                self.numberTextField.text = "Mobile Number"
            } else {
                self.numberTextField.text = userNumber
            }
            
            if birthDate == "" {
                self.ageTextField.text = "Birth Date"
            } else {
                self.ageTextField.text = birthDate
            }
            
            let gender = userGender.lowercased()
            if gender == "female" {
                self.userImageView.image = UIImage(named : "female")
                self.segmentController.selectedSegmentIndex = 1
            } else {
                self.userImageView.image = UIImage(named : "Male")
                self.segmentController.selectedSegmentIndex = 0
            }
        }
    }
    
    @objc func viewTapped(){
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        numberTextField.resignFirstResponder()
    }
    
    func setupSaveButton(){
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
    }
    
    func setupTextFields(){
        ageTextField.delegate = self
        nameTextField.delegate = self
        numberTextField.delegate = self
        
        numberTextField.keyboardType = .numberPad
        datePicker.datePickerMode = .date
        ageTextField.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    
    @objc func datePickerChanged(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd, MMMM yyyy"
        let date = datePicker.date
        let dateString = dateFormatter.string(from: date)
        ageTextField.text = dateString
    }
    
    @IBAction func segmentControllerChanged(){
        let index = segmentController.selectedSegmentIndex
        if index == 0 {
            self.userImageView.image = UIImage(named : "Male")
        } else {
            self.userImageView.image = UIImage(named : "female")
        }
    }
    
    @objc func saveButtonPressed(){
        if nameTextField.text == "" || nameTextField.text == "Name" ||  numberTextField.text == "" || numberTextField.text == "Mobile Number" {
            self.showAlert(msg: "Text Fields cannot be empty")
        } else {
            if numberTextField.text?.count != 10 {
                self.showAlert(msg: "Please enter a valid number")
            } else {
                let age = ageTextField.text
                var ageString : String = ""
                
                if age == "Birth Date" || age == "" || age == nil{
                    ageString = ""
                } else {
                    ageString = age!
                }
                
                FirebaseMethods().saveUserDetails(name: nameTextField.text!, mobileNumber: "\(numberTextField.text!)", birthDate: ageString, gender: genderArray[segmentController.selectedSegmentIndex])
               
                let alertController = UIAlertController(title: "Zalonin", message: "User Details updated", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Dismiss", style: .default) { (action) in
                    let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController")
                    self.present(sidePanelViewController, animated: true, completion: nil)
                }
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension UserDetailTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            if textField.text == "" {
                textField.text = "Name"
            }
        } else if textField == ageTextField {
            if textField.text == "" {
                textField.text = "Birth Date"
            }
        } else {
            if textField.text == "" {
                textField.text = "Mobile Number"
            }
        }
    }

    //restrict number count to 10
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == numberTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 10
        } else {
            return true
        }
    }
}
