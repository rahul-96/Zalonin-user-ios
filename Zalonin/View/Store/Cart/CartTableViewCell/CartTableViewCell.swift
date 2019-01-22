//
//  CartTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 26/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class CartTableViewCell : UITableViewCell {
    @IBOutlet weak var cartTitleLabel : UILabel!
    @IBOutlet weak var oldPriceLabel : UILabel!
    @IBOutlet weak var newPriceLabel : UILabel!
    @IBOutlet weak var cartImageView : UIImageView!
    @IBOutlet weak var removeButton : UIButton!
    @IBOutlet weak var favButton : UIButton!
    @IBOutlet weak var quantityLabel : UILabel!
    @IBOutlet weak var sizeLabel : UILabel!
    
    override func awakeFromNib() {
        self.backgroundColor = Colors.grayColor3
        setupBorders(label: quantityLabel)
        setupBorders(label: sizeLabel)
    }
    
    func setupBorders(label : UILabel){
        label.clipsToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 12.5
    }
}
