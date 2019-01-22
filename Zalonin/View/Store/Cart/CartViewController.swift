//
//  CartViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 26/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

class CartViewController : UIViewController {
    
    @IBOutlet weak var paymentButton : UIButton!
    @IBOutlet weak var tableView : UITableView!
    
    var detailDictArray : [[String : Any]] = []
    var cartDictArray : [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.navigationItem.title = "Products"
        self.view.backgroundColor = Colors.grayColor3
        paymentButton.isHidden = true
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        let path = "USER/\(UserDetails.userId)/CART"
        
        FirebaseMethods().fetchStoreDetails(completionHandler: { (allProducts,sizeProducts) in
            ref.child(path).observe(.childAdded) { (snapshot) in
                let value = snapshot.value as! [String : Any]
                self.cartDictArray.append(value)
                for product in allProducts {
                    let id = product["id"] as! String
                    let cartId = value["id"] as! String
                    if id == cartId {
                        self.detailDictArray.append(product)
                    }
                }
                
                if self.detailDictArray.count == 0 {
                    self.paymentButton.isHidden = true
                } else {
                    self.paymentButton.isHidden = false
                }
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func paymentButtonPressed(){
        let confirmCartViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfirmCartViewController") as! ConfirmCartViewController
        confirmCartViewController.detailDictArray = detailDictArray
        confirmCartViewController.cartDictArray = cartDictArray
        self.navigationController?.pushViewController(confirmCartViewController, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Cart"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        let nib = UINib(nibName: "CartTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cartCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func removeButtonPressed(sender : UIButton){
        let tag = sender.tag
        let cartDict = cartDictArray[tag]
        self.cartDictArray.remove(at: tag)
        self.detailDictArray.remove(at: tag)
        self.tableView.reloadData()
        
        if self.detailDictArray.count == 0 {
            self.paymentButton.isHidden = true
        } else {
            self.paymentButton.isHidden = false
        }
        
        FirebaseMethods().removeProductFromCart(dict: cartDict)
    }
    
    @objc func favButtonPressed(sender : UIButton) {
        let tag = sender.tag
        let cartDict = cartDictArray[tag]
        self.cartDictArray.remove(at: tag)
        self.detailDictArray.remove(at: tag)
        self.tableView.reloadData()
        
        if self.detailDictArray.count == 0 {
            self.paymentButton.isHidden = true
        } else {
            self.paymentButton.isHidden = false
        }
        
        FirebaseMethods().moveProductToFav(dict: cartDict)
    }
}

extension CartViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell") as! CartTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = Colors.grayColor3
        
        let currentProduct = detailDictArray[indexPath.item]
        
        let id = currentProduct["id"] as! String
        let name = currentProduct["name"] as! String
        
        let cartProduct = cartDictArray[indexPath.item]
        
        let qty = cartProduct["qty"] as! Int
        let size = cartProduct["size"] as! String
        
        cell.removeButton.tag = indexPath.item
        cell.favButton.tag = indexPath.item
        
        cell.removeButton.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        cell.favButton.addTarget(self, action: #selector(favButtonPressed), for: .touchUpInside)
        
        cell.cartTitleLabel.text = name
        cell.sizeLabel.text = size
        cell.quantityLabel.text = "\(qty)"
        
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        
        let childLocation = "STORE/OTHERS/\(id)/IMAGE1.jpg"
        let imageRef = storageRef.child(childLocation)
        
        if cell.cartImageView.image == UIImage(named  : "salon") {
            imageRef.downloadURL { (url, error) in
                if let _ = error {
                    cell.cartImageView.image = UIImage(named : "salon")
                }else {
                    cell.cartImageView.sd_setImage(with: url!, completed: nil)
                }
            }
        }
        
        let store = currentProduct
        
        let oldPrice = store["price"] as! Int
        let discount = store["discount"] as! Int
        
        let newPrice = (oldPrice * (100 - discount))/100
        
        if discount == 0 {
            cell.oldPriceLabel.text = ""
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(oldPrice) ₹")
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
            cell.oldPriceLabel.attributedText = attributedString
        }
        cell.newPriceLabel.text = "\(newPrice) ₹"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailDictArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
