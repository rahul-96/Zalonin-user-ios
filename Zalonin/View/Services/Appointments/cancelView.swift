//
//  cancelView.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 13/06/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class cancelView : UIView {
    @IBOutlet weak var cancelButton : UIButton!
    @IBOutlet weak var doneButton : UIButton!
    @IBOutlet weak var button1 : UIButton!
    @IBOutlet weak var button2 : UIButton!
    @IBOutlet weak var button3 : UIButton!
    @IBOutlet weak var button4 : UIButton!
    @IBOutlet weak var button5 : UIButton!

    override func awakeFromNib() {
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = Colors.blackColor.cgColor
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.borderColor = Colors.blackColor.cgColor
    }
}
