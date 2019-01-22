//
//  ConfirmAddAddressViewTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 28/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class ConfirmAddAddressViewTableViewCell : UITableViewCell {
    @IBOutlet weak var imageButton : UIButton!
    @IBOutlet weak var addressButton : UIButton!
    
    override func awakeFromNib() {
        addressButton.layer.borderColor = Colors.blackColor.cgColor
        addressButton.layer.borderWidth = 1.0
    }
}
