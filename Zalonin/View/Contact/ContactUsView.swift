//
//  ContactUsView.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 08/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ContactUsView: UIView {
    
    @IBOutlet weak var phoneNumberTextField : UITextField!
    @IBOutlet weak var problemTextView : UITextView!
    @IBOutlet weak var submitButton : UIButton!
    @IBOutlet weak var problemTextField : UITextField!
    @IBOutlet weak var contactUsLabel : UILabel!
    
    override func awakeFromNib() {
        contactUsLabel.text = "Need Help?\nContact us we'll get back to you soon as we can reslove your issue.\nPlease tell us your phone number and issue so our team can contact you."
        problemTextView.text = "Problem"
        phoneNumberTextField.keyboardType = .numberPad
        
        
    
    }
}
