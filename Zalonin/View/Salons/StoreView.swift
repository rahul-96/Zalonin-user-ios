//
//  StoreVew.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 10/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class StoreView : UIView {
    @IBOutlet weak var storeView : UIView!
    @IBOutlet weak var storeImageView : UIImageView!
    @IBOutlet weak var storeButton : UIButton!
    
    override func awakeFromNib() {
        let gradient = CAGradientLayer()
        gradient.colors = [Colors.startColor.cgColor,Colors.midColor.cgColor, Colors.blackColor.cgColor]
        gradient.frame = self.storeView.bounds
        
        
        let width = UIScreen.main.bounds.width
        gradient.frame.size.width = width - 20
        
        self.storeView.layer.insertSublayer(gradient, at: 0)
        
        
        let storeColor = UIColor(displayP3Red: 138/255, green: 0, blue: 255/255, alpha: 0.7)
        
        let storeGradient = CAGradientLayer()
        storeGradient.colors = [Colors.clearColor,storeColor.cgColor]
        storeGradient.frame = self.storeImageView.bounds
        storeGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        storeGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        storeGradient.frame.size.width = width - 20

        self.storeImageView.layer.addSublayer(storeGradient)
    }
}
