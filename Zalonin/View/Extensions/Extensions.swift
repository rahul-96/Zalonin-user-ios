//
//  Extensions.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 08/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(msg : String){
        let alertController = UIAlertController(title: "Zalonin", message: msg, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupNavigationBar(){
        //        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 74/255, green: 76/255, blue: 86/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = Colors.startColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
//        self.navigationController?.navigationBar.isTranslucent = true
    }
}
