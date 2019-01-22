//
//  BlogsTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 20/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class BlogsTableViewCell : UITableViewCell {
    @IBOutlet weak var viewsCountLabel : UILabel!
    @IBOutlet weak var messagesCountLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var titeLabel : UILabel!
    @IBOutlet weak var subTitleLabel : UILabel!
    @IBOutlet weak var blogImageView : UIImageView!
    
    override func awakeFromNib() {
        
    }
}
