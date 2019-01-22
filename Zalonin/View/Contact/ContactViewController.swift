//
//  ContactViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 14/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: UIViewController {
    
    var contactViewArray : [ContactUsView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contact Us"
        
        let contactView = Bundle.main.loadNibNamed("ContactUsView", owner: self, options: nil)?.first as! ContactUsView
        contactView.frame = CGRect(x: 10, y: 10, width: self.view.frame.width - 20, height: 450)
        self.view.addSubview(contactView)
        contactView.problemTextView.delegate = self
        contactView.phoneNumberTextField.delegate = self
        contactView.problemTextView.textColor = Colors.placeholderColor
        contactView.submitButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        contactViewArray.append(contactView)
        
        
        contactView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contactViewTapped)))
    }
    
    @objc func contactViewTapped(){
        let contactView = contactViewArray.first
        contactView?.phoneNumberTextField.resignFirstResponder()
        contactView?.problemTextView.resignFirstResponder()
    }
    
    @objc func buttonTapped(){
        
        let contactView = contactViewArray.first
        
        if contactView?.phoneNumberTextField.text == "" {
            showAlert(msg: "Phone Number cannot be empty!")
        } else if contactView?.problemTextView.text == "Problem" {
            showAlert(msg: "Content of the mail cannot be empty!")
        } else {
            let mailController = configureMailComponentViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailController, animated: true, completion: nil)
            } else {
                showAlert(msg: "Could not send mail!")
            }
        }
    }
    
    func configureMailComponentViewController() -> MFMailComposeViewController {
        let contactView = contactViewArray.first

        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients(["shelp@zalonin.com"])
        mailController.setSubject("Zalonin User Query")
        
        let mailSubject = "Phone Number :" + (contactView?.phoneNumberTextField.text)! + "\n" + (contactView?.problemTextView.text)!
        
        mailController.setMessageBody(mailSubject, isHTML: false)
        return mailController
    }
}

extension ContactViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 10
    }
}

extension ContactViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = Colors.blackColor
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Problem"
            textView.textColor = Colors.placeholderColor
        }
    }
}


extension ContactViewController : MFMailComposeViewControllerDelegate , UINavigationControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.sent :
            showAlert(msg: "Mail sent successfully!")
            controller.dismiss(animated: true, completion: nil)
            break
        case MFMailComposeResult.failed :
            showAlert(msg: "Could not send mail!")
            controller.dismiss(animated: true, completion: nil)
            break
        case MFMailComposeResult.saved :
            showAlert(msg: "Mail saved successfully!")
            controller.dismiss(animated: true, completion: nil)
            break
        case MFMailComposeResult.cancelled :
            controller.dismiss(animated: true, completion: nil)
            break
        }
        // remove text field and text view text
       
    }
}
