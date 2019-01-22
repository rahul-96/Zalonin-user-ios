//
//  ExploreView.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 09/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class ExploreView : UIView {
    @IBOutlet weak var exploreView : UIView!
    @IBOutlet weak var askView : UIView!
    @IBOutlet weak var askButton : UIButton!
    @IBOutlet weak var exploreButton : UIButton!
    
    @IBOutlet weak var exploreImageView : UIImageView!
    @IBOutlet weak var askImageView : UIImageView!
    
    override func awakeFromNib() {
        makeLabelGradient(exploreView)
        makeLabelGradient(askView)
        let width = UIScreen.main.bounds.width


        let exploreColor = UIColor(displayP3Red: 5/255, green: 0, blue: 210/255, alpha: 0.7)
        let exploreGradient = CAGradientLayer()
        exploreGradient.colors = [Colors.clearColor,exploreColor.cgColor]
        exploreGradient.frame = self.exploreImageView.bounds
        exploreGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        exploreGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        exploreImageView.clipsToBounds = true
        exploreGradient.frame.size.width = width/2 - 12.6
        self.exploreImageView.layer.addSublayer(exploreGradient)
        let askColor = UIColor(displayP3Red: 48/255, green: 255/255, blue: 0, alpha: 0.5)
        let askMidColor = UIColor(displayP3Red: 48/255, green: 255/255, blue: 0, alpha: 0.2)
        let askGradient = CAGradientLayer()
        askGradient.colors = [askColor.cgColor,askMidColor.cgColor,Colors.clearColor.cgColor]
        askGradient.frame = self.askImageView.bounds
        askImageView.clipsToBounds = true
        askGradient.frame.size.width = width/2 - 12.6
        askGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        askGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.askImageView.layer.addSublayer(askGradient)
    }
    
    func makeLabelGradient(_ view : UIView) {
        let width = UIScreen.main.bounds.width
        let gradient = CAGradientLayer()
        gradient.colors = [Colors.startColor.cgColor,Colors.midColor.cgColor, Colors.blackColor.cgColor]
        gradient.frame = view.bounds
        gradient.frame.size.width = width/2 - 12.5
        view.clipsToBounds = true
        view.layer.insertSublayer(gradient, at: 0)
    }
}
