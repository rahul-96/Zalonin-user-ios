//
//  ConfirmTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 12/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ConfirmTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var valueLabel : UILabel!
    @IBOutlet weak var confirmImageView : UIImageView!
    
    override func awakeFromNib() {
        valueLabel.textColor = Colors.goldenColor
        titleLabel.textColor = Colors.whiteColor
        self.backgroundColor = Colors.grayColor3
    }

}
