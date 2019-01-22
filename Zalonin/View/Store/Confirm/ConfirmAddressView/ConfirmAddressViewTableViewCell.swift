//
//  ConfirmAddressViewTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 28/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class ConfirmAddressViewTableViewCell : UITableViewCell {
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var latLabel : UILabel!
    @IBOutlet weak var lngLabel : UILabel!
    @IBOutlet weak var selectedImageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    
    override func awakeFromNib() {
        //todo
    }
}
