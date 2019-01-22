//
//  StoreDetailTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 26/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class StoreDetailTableViewController : UITableViewController {
    
    @IBOutlet weak var ratingLabel : UILabel!
    @IBOutlet weak var productImageView : UIImageView!
    @IBOutlet weak var productTitleLabel : UILabel!
    @IBOutlet weak var newPriceLabel : UILabel!
    @IBOutlet weak var oldPriceLabel : UILabel!
    @IBOutlet weak var reviewLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    
    var currentStore = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRatingLabel()
        self.view.backgroundColor = Colors.grayColor3
        self.navigationItem.title = "Product Detail"
        setupTableView()
    }
    
    func setupTableView(){
        
        let store = currentStore
        let name = store["name"] as! String
        let id = store["id"] as! String
        let oldPrice = store["price"] as! Int
        let discount = store["discount"] as! Int
        
        let newPrice = (oldPrice * (100 - discount))/100
        
        productTitleLabel.text = name
        
        if discount == 0 {
            oldPriceLabel.text = ""
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(oldPrice) ₹")
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
            oldPriceLabel.attributedText = attributedString
            
        }
        newPriceLabel.text = "\(newPrice) ₹"
        
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        
        let childLocation = "STORE/OTHERS/\(id)/IMAGE1.jpg"
        let imageRef = storageRef.child(childLocation)
        
        if productImageView.image == UIImage(named  : "salon") {
            imageRef.downloadURL { (url, error) in
                if let _ = error {
                    self.productImageView.image = UIImage(named : "salon")
                }else {
                    self.productImageView.sd_setImage(with: url!, completed: nil)
                }
            }
        }
        
        descriptionLabel.text = store["decription"] as? String
        reviewLabel.text = "No reviews available for this prooduct"
    }
    
    func setupRatingLabel(){
        ratingLabel.clipsToBounds = true
        ratingLabel.layer.cornerRadius = 75/2
        ratingLabel.layer.borderColor = Colors.greenColor.cgColor
        ratingLabel.layer.borderWidth = 4.0
    }
}
