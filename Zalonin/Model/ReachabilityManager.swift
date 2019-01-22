//
//  ReachabilityManager.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 16/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityManager {
    
    // instance of Reachability
    let reachability = Reachability()
    
    //a shared instance of Reachability Manager to access from App Delegate
    static let shared = ReachabilityManager()
    
    // start monitoring network connection
    func startMonitoring(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }
    
    // stop monitoring network connection when application enters background
    func stopMonitoring(){
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: reachability)
    }
    
    // start observing changes in network
    @objc func reachabilityChanged(notification : Notification){
        let reachability = notification.object as! Reachability
        
        switch reachability.connection {
        case .cellular :
            print("Cellular network available")
        case .wifi:
            print("Wifi Network Avaiable")
        case .none:
            // creating a status bar banner to indicate no internet connection
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIApplication.shared.statusBarFrame.height))
            UIView.animate(withDuration: 3.0, animations: {
                view.backgroundColor = Colors.googleRedColor
                let window = UIApplication.shared.keyWindow
                window?.addSubview(view)
            }) { (true) in
                view.removeFromSuperview()
            }
        }
    }
}
