//
//  ReviewTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 11/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var alphabeticalLabel : UILabel!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var reviewLabel : UILabel!
    @IBOutlet weak var ratingLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    
    override func awakeFromNib() {
        alphabeticalLabel.clipsToBounds = true
        alphabeticalLabel.layer.cornerRadius = 20
    }
    
}
