//
//  CartView.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 27/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class CartView : UIView {
    @IBOutlet weak var cartLabel : UILabel!
    @IBOutlet weak var cartCollectionView : UICollectionView!
    @IBOutlet weak var closeButton : UIButton!
    
    override func awakeFromNib() {
        let nib = UINib(nibName: "CartCollectionViewCell", bundle: nil)
        cartCollectionView.register(nib, forCellWithReuseIdentifier: "cartCell")
    }
}
