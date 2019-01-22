//
//  CartCollectionViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 27/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class CartCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var cartLabel : UILabel!
    
    override func awakeFromNib() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 25
    }
}
