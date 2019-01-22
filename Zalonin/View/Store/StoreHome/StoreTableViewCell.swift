//
//  StoreTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 26/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class StoreTableViewCell : UITableViewCell {
    @IBOutlet weak var productTitleLabel : UILabel!
    @IBOutlet weak var oldPriceLabel : UILabel!
    @IBOutlet weak var newPriceLabel : UILabel!
    @IBOutlet weak var addCartButton : UIButton!
    @IBOutlet weak var likeButton : UIButton!
    @IBOutlet weak var productImageView : UIImageView!
    @IBOutlet weak var subView : UIView!
    
    override func awakeFromNib() {
        self.backgroundColor = Colors.grayColor3
        self.subView.layer.borderColor = Colors.whiteColor.cgColor
        self.subView.layer.borderWidth = 2.0
    }
}
