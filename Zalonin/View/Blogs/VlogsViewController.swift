//
//  VlogsViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 25/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import YouTubePlayer

class VlogsViewController : UIViewController {
    @IBOutlet weak var youtubeView : YouTubePlayerView!
    
    var link : String = ""
    
    override func viewDidLoad() {
        self.navigationItem.title = "Vlog"
        youtubeView.loadVideoID(link)
    }
}
