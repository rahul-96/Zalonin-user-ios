//
//  SalonTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 22/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class SalonTableViewCell : UITableViewCell {
    
    @IBOutlet weak var salonImageView : UIImageView!
    @IBOutlet weak var bookNowButton : UIButton!
    @IBOutlet weak var salonLabel : UILabel!
    @IBOutlet weak var locationLabel : UILabel!
    @IBOutlet weak var distanceLabel : UILabel!
    @IBOutlet weak var ratingLabel : UILabel!
    
    @IBOutlet weak var oldPriceLabel : UILabel!
    @IBOutlet weak var newPriceLabel : UILabel!
    
    override func awakeFromNib() {
        setupButton(button: bookNowButton)
        self.backgroundColor = Colors.grayColor3
        
        if UserDetails.salonSelected {
            oldPriceLabel.isHidden = true
            newPriceLabel.isHidden = true
        } else {
            oldPriceLabel.isHidden = false
            newPriceLabel.isHidden = false
        }
        
    }
    
    func setupButton(button : UIButton){
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.5
    }
}
