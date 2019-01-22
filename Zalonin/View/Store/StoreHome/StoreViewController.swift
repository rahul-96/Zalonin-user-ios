//
//  StoreViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 26/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class StoreViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var likeBarButton : UIBarButtonItem!
    @IBOutlet weak var cartBarButton : UIBarButtonItem!
    @IBOutlet weak var searchTextField : UITextField!
    @IBOutlet weak var filterButton : UIButton!
    @IBOutlet weak var tableView : UITableView!
    
    var dictArray : [[String : Any]] = []
    var sizeDictArray : [[String : Any]] = []
    var currentSizeDict = [String : Any]()
    var currentProduct = [String : Any]()
    var sizeArray : [String] = ["S","M","L","XL","XXL"]
    
    var cartViewArray : [CartView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.navigationItem.title = "Products"
        self.view.backgroundColor = Colors.grayColor3
        self.tableView.backgroundColor = Colors.grayColor3
        FirebaseMethods().fetchStoreDetails { (dictArray,sizeArray) in
            self.dictArray = dictArray
            self.sizeDictArray = sizeArray
            self.tableView.reloadData()
        }
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
//        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(){
        if cartViewArray.count > 0 {
            cartViewArray.first?.removeFromSuperview()
            tableView.alpha = 1.0
            tableView.isUserInteractionEnabled = true
            view.isUserInteractionEnabled = true
            self.cartViewArray = []
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Products"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    @IBAction func likeButtonPressed(){
        let likeTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LikeTableViewController") as! LikeTableViewController
        self.navigationController?.pushViewController(likeTableViewController, animated: true)
    }
    
    @IBAction func cartButtonPressed(){
        let cartViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        self.navigationController?.pushViewController(cartViewController, animated: true)
    }
    
    func setupTableView(){
        let nib = UINib(nibName: "StoreTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "storeCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell") as! StoreTableViewCell
        cell.selectionStyle = .none
        let store = dictArray[indexPath.item]
        let name = store["name"] as! String
        let id = store["id"] as! String
        let oldPrice = store["price"] as! Int
        let discount = store["discount"] as! Int
        
        let newPrice = (oldPrice * (100 - discount))/100
        
        cell.productTitleLabel.text = name
        
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
        
       
        cell.likeButton.tag = indexPath.item
        cell.likeButton.addTarget(self, action: #selector(cellLikeButtonPressed), for: .touchUpInside)
        
        cell.addCartButton.tag = indexPath.item
        cell.addCartButton.addTarget(self, action: #selector(cellCartButtonPressed), for: .touchUpInside)

        let childLocation = "STORE/OTHERS/\(id)/IMAGE1.jpg"
        let imageRef = storageRef.child(childLocation)
        
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
        let currentProduct = dictArray[tag]
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
        self.tableView.alpha = 0.5
        self.tableView.isUserInteractionEnabled = false
        let cartView = Bundle.main.loadNibNamed("CartView", owner: self, options: nil)?.first as! CartView
        cartView.frame.size = CGSize(width: UIScreen.main.bounds.width - 20, height: 100)
        cartView.center.x = self.view.center.x
        cartView.center.y = UIScreen.main.bounds.height/2 - (self.navigationController?.navigationBar.frame.height)!/2 - UIApplication.shared.statusBarFrame.height/2
        
        cartView.closeButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        self.currentProduct = dictArray[sender.tag]
        self.currentSizeDict = sizeDictArray[sender.tag]
        cartView.cartCollectionView.dataSource = self
        cartView.cartCollectionView.delegate = self
        self.view.addSubview(cartView)
        
        cartViewArray.append(cartView)
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictArray.count
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeDetailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreDetailTableViewController") as! StoreDetailTableViewController
        let currentStore = dictArray[indexPath.item]
        storeDetailTableViewController.currentStore = currentStore
        self.navigationController?.pushViewController(storeDetailTableViewController, animated: true)
    }
}

extension StoreViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cartCell", for: indexPath) as! CartCollectionViewCell
        cell.cartLabel.text = sizeArray[indexPath.item]
        let size = sizeArray[indexPath.item].lowercased()
        let value = currentSizeDict[size] as! Int
        if value > 0 {
            cell.backgroundColor = Colors.facebookBlueColor
        } else {
            cell.backgroundColor = Colors.grayColor3
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let size = sizeArray[indexPath.item]
        var dict : [String : Any] = [String : Any]()
        dict["category"] = "OTHERS"
        dict["qty"] = 1
        dict["size"] = size
        
        var id = currentProduct["id"] as! String
        dict["id"] = id
        id += size
        
        FirebaseMethods().addProductToCart(id: id, dict: dict)
        self.showAlert(msg: "Product Added")
        viewTapped()
        
    }
}
