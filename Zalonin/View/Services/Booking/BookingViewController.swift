//
//  BookingViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 16/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class BookingViewController : UIViewController {
    
    @IBOutlet weak var priceLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    
    var username : String = ""
    var time : String = ""
    var date  : String = ""
    var price : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = username
        dateLabel.text = date
        timeLabel.text = time
        priceLabel.text = price
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.title = "Thank You"
        
    }
    
    @IBAction func returnButtonPressed(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController") as! SidePanelViewController
        delegate.window?.rootViewController = sidePanelViewController
    }
}
