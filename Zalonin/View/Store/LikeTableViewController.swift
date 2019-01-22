//
//  LikeTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 26/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class LikeTableViewController : UITableViewController {
    
    var dictArray : [[String : Any]] = []
    var likeArray : [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.navigationItem.title = "Favourites"
        self.view.backgroundColor = Colors.grayColor3
        
        FirebaseMethods().fetchLikedProducts { (dictArray) in
            self.dictArray = dictArray
            
            FirebaseMethods().fetchStoreDetails(completionHandler: { (allProducts,sizeProducts) in
                self.likeArray = []
                
                for likeProduct in dictArray {
                    for product in allProducts {
                        let id = product["id"] as! String
                        let likeId = likeProduct["id"] as! String
                        if id == likeId {
                            self.likeArray.append(product)
                        }
                    }
                }
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Favourites"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        let nib = UINib(nibName: "StoreTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "storeCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell") as! StoreTableViewCell
        cell.selectionStyle = .none
        let store = likeArray[indexPath.item]
        let name = store["name"] as! String
        let id = store["id"] as! String
        let oldPrice = store["price"] as! Int
        let discount = store["discount"] as! Int
        
        let newPrice = (oldPrice * (100 - discount))/100
        
        cell.productTitleLabel.text = name
        cell.likeButton.setImage(UIImage(named : "like"), for: .normal)
        if discount == 0 {
            cell.oldPriceLabel.text = ""
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(oldPrice) ₹")
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
            cell.oldPriceLabel.attributedText = attributedString
            
        }
        cell.newPriceLabel.text = "\(newPrice) ₹"
        
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        
        let childLocation = "STORE/OTHERS/\(id)/IMAGE1.jpg"
        let imageRef = storageRef.child(childLocation)
        
        cell.likeButton.tag = indexPath.item
        cell.likeButton.addTarget(self, action: #selector(cellLikeButtonPressed), for: .touchUpInside)
        
        cell.addCartButton.tag = indexPath.item
        cell.addCartButton.addTarget(self, action: #selector(cellCartButtonPressed), for: .touchUpInside)
        
        
        if cell.productImageView.image == UIImage(named  : "salon") {
            imageRef.downloadURL { (url, error) in
                if let _ = error {
                    cell.productImageView.image = UIImage(named : "salon")
                }else {
                    cell.productImageView.sd_setImage(with: url!, completed: nil)
                }
            }
        }
        return cell
    }
    
    @objc func cellLikeButtonPressed(sender : UIButton) {
        let tag = sender.tag
        let currentProduct = likeArray[tag]
        let id = currentProduct["id"] as! String
        
        let cell = tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as! StoreTableViewCell
        if cell.likeButton.image(for: .normal) == UIImage(named: "like") {
            FirebaseMethods().unlikeProduct(id: id)
            cell.likeButton.setImage(UIImage(named : "unlike"), for: .normal)
            
        } else {
            
            var likeDict = [String : Any]()
            likeDict["category"] = "OTHERS"
            likeDict["id"] = id
            likeDict["qty"] = 0
            likeDict["size"] = ""
            
            FirebaseMethods().likeProduct(id: id, dict: likeDict)
            cell.likeButton.setImage(UIImage(named : "like"), for: .normal)
            
        }
    }
    
    @objc func cellCartButtonPressed(sender : UIButton) {
        self.showAlert(msg: "\(sender.tag)")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeDetailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreDetailTableViewController") as! StoreDetailTableViewController
        self.navigationController?.pushViewController(storeDetailTableViewController, animated: true)
    }
}
