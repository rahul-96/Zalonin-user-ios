//
//  ReferView.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 14/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class ReferView : UIView {
    @IBOutlet weak var shareButton : UIButton!
    @IBOutlet weak var referCodeLabel : UILabel!
    @IBOutlet weak var referMessageLabel : UILabel!
    
    override func awakeFromNib() {
        setupMessageLabel()
        
        referCodeLabel.layer.borderColor = UIColor.black.cgColor
        referCodeLabel.layer.borderWidth = 2.0
    }
    
    func setupMessageLabel(){
        referMessageLabel.numberOfLines = 0
        referMessageLabel.text = "Use this referral code to earn 50 wallet points.\nShare this app with your friends and ask them to enter this referral code at the time of sign up.\nYou can redeem these wallet points at the time of booking."
        referMessageLabel.sizeToFit()
        referCodeLabel.frame.size.height = referCodeLabel.frame.height
        referCodeLabel.text = UserDetails.userId
    }
}
