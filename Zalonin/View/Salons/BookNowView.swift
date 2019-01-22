//
//  BookNowView.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 09/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class BookNowView : UIView {
    @IBOutlet weak var salonsButton : UIButton!
    @IBOutlet weak var stylistButton : UIButton!
    @IBOutlet weak var bookNowView : UIView!
    
    @IBOutlet weak var salonView : UIImageView!
    @IBOutlet weak var stylistView : UIImageView!
    
    override func awakeFromNib() {
        let gradient = CAGradientLayer()
        gradient.colors = [Colors.startColor.cgColor,Colors.midColor.cgColor, Colors.blackColor.cgColor]
        gradient.frame = self.bookNowView.bounds
        
        let width = UIScreen.main.bounds.width
        gradient.frame.size.width = width - 20
        self.bookNowView.clipsToBounds = true
        self.bookNowView.layer.insertSublayer(gradient, at: 0)
        
        let salonColor = UIColor(displayP3Red: 255/255, green: 114/255, blue: 0, alpha: 0.7)
        let salonMidColor = UIColor(displayP3Red: 255/255, green: 114/255, blue: 0, alpha: 0.4)
        
        let salonGradient = CAGradientLayer()
        salonGradient.colors = [Colors.clearColor,salonMidColor.cgColor,salonColor.cgColor]
        salonGradient.frame = self.salonView.bounds
        salonGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        salonGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.salonView.layer.addSublayer(salonGradient)
        salonGradient.frame.size.width = width/2 - 10
        let stylistColor = UIColor(displayP3Red: 255/255, green: 0/255, blue: 0, alpha: 0.7)
        let stylistMidColor = UIColor(displayP3Red: 255/255, green: 0/255, blue: 0, alpha: 0.4)
        
        let stylistGradient = CAGradientLayer()
        stylistGradient.colors = [stylistColor.cgColor,stylistMidColor.cgColor,Colors.clearColor.cgColor]
        stylistGradient.frame = self.salonView.bounds
        stylistGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        stylistGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        stylistGradient.frame.size.width = width/2 - 10
        self.stylistView.layer.addSublayer(stylistGradient)
        
    }
}
