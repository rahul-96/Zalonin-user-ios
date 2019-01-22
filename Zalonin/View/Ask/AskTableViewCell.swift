//
//  AskTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 25/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class AskTableViewCell : UITableViewCell {
    @IBOutlet weak var askImageView : UIImageView!
    @IBOutlet weak var askLabel : UILabel!
    
    override func awakeFromNib() {
        askImageView.clipsToBounds = true
        askImageView.layer.cornerRadius = askImageView.frame.width/2
        askImageView.layer.borderColor = Colors.whiteColor.cgColor
        askImageView.layer.borderWidth = 3.0
    }
    
    func setupAskTableViewCell(title : String, imageNumber : Int){
        askLabel.text = title
        let imageTitle = "expert_" + "\(imageNumber)"
        askImageView.image = UIImage(named : imageTitle)
    }
}
