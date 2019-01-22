//
//  AppointmentsTableViewCell.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 31/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class AppointmentsTableViewCell : UITableViewCell {
    @IBOutlet weak var appointmentTitleLabel : UILabel!
    @IBOutlet weak var appointmentCentreLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var appointmentIdLabel : UILabel!
    @IBOutlet weak var appointmentStatusLabel : UILabel!
    @IBOutlet weak var appointmentAmountLabel : UILabel!
    @IBOutlet weak var borderView : UIView!
    
    override func awakeFromNib() {
        setupBorder()
        setupLabels()
        self.backgroundColor = Colors.grayColor3
    }
    
    func setupBorder(){
        borderView.clipsToBounds = true
        borderView.layer.borderColor = Colors.whiteColor.cgColor
        borderView.layer.borderWidth = 2.0
    }
    
    func setupLabels(){
        appointmentAmountLabel.textColor = Colors.whiteColor
        appointmentTitleLabel.textColor = Colors.whiteColor
        appointmentCentreLabel.textColor = Colors.whiteColor
        dateLabel.textColor = Colors.whiteColor
        appointmentIdLabel.textColor = Colors.whiteColor
        appointmentAmountLabel.textColor = Colors.whiteColor
        appointmentStatusLabel.textColor = Colors.googleRedColor
    }
}
