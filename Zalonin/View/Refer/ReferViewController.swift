//
//  ReferViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 14/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ReferViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Refer a Friend"
        setupReferView()
    }
    
    func setupReferView(){
        let referView = Bundle.main.loadNibNamed("ReferView", owner: self, options: nil)?.first as! ReferView
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        referView.frame = CGRect(x: 10, y: 10 + statusBarHeight, width: self.view.frame.width - 20, height: 400.0)
        referView.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        self.view.addSubview(referView)
    }
    
    @objc func shareButtonTapped(){
        let appLink : String = "Care for a super cool grooming session? Book a service at a salon near you! Use 'Zalonin' app to book now and get amazing discounts. Enter this referral code to get additional points in your wallet.\nREFERRAL CODE:\n\(UserDetails.userId)\nhttps://itunes.apple.com/in/app/zalonin/id1378586401?mt=8"
        let activityViewController = UIActivityViewController(activityItems: [appLink], applicationActivities: [])
        self.present(activityViewController, animated: true, completion: nil)
    }
}
