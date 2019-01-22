//
//  ComingSoonViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 30/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ComingSoonViewController: UIViewController {
    
    @IBOutlet weak var signUpButton : UIButton!
    
    @IBAction func signUpPressed(){
        let urlString = "http://www.zalonin.com/newsletter"
        let url = URL(string : urlString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.clipsToBounds = true
        signUpButton.layer.cornerRadius = 25
    }
}
