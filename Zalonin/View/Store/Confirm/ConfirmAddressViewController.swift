//
//  ConfirmAddressViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 28/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class ConfirmAddressViewController : UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var confirmOrderButton : UIButton!
    
    var addressArray : [[String : Any]] = []
    var totalPrice : Int = 0
    var currentAddressIndex : Int = 0
    
    var detailDictArray : [[String : Any]] = []
    var cartDictArray : [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        let addressPath = "USER/\(UserDetails.userId)/ADDRESS"
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child(addressPath).observe(.childAdded) { (snapshot) in
            let addressValue = snapshot.value as! [String : Any]
            self.addressArray.append(addressValue)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Confirm Address"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        let nib = UINib(nibName: "ConfirmAddressViewTableViewCell", bundle: nil)
        let addressNib = UINib(nibName: "ConfirmAddAddressViewTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "addressCell")
        tableView.register(addressNib, forCellReuseIdentifier: "addAddressCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Colors.grayColor3
    }
    
    @IBAction func comfirmOrderPressed(){
        if currentAddressIndex == 0 {
            self.showAlert(msg: "Please select an address before placing order!")
        } else {
            
            
            var dict = [String : Any]()
            let currentAddress = addressArray[currentAddressIndex - 1]
            
            let address = currentAddress["address"] as! String
            let lat = currentAddress["lat"] as! CGFloat
            let lng = currentAddress["lng"] as! CGFloat
            var sizeString : String = ""
            var qtyString : String = ""
            var categoryString : String = ""
            var pidString : String = ""
            
            for i in 0..<detailDictArray.count {
                let cart = cartDictArray[i]
                
                let size = cart["size"] as! String
                let qty = cart["qty"] as! Int
                let category = cart["category"] as! String
                let id = cart["id"] as! String
                
                sizeString += size + ", "
                qtyString += "\(qty) ,"
                categoryString += category + ", "
                pidString += id + ", "
            }
            
            dict["address"] = address
            dict["lat"] = lat
            dict["lng"] = lng
            dict["size"] = sizeString
            dict["qty"] = qtyString
            dict["category"] = categoryString
            dict["pid"] = pidString
            dict["status"] = 0
            
            FirebaseMethods().placeStoreOrder(detailDict: dict)
            
            let alertController = UIAlertController(title: "Zalonin", message: "Order Placed", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Dismiss", style: .default) { (action) in
                let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController")
                self.present(sidePanelViewController, animated: true, completion: nil)
            }
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ConfirmAddressViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addAddressCell") as! ConfirmAddAddressViewTableViewCell
            cell.imageButton.isUserInteractionEnabled = false
            cell.addressButton.isUserInteractionEnabled = false
            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell") as! ConfirmAddressViewTableViewCell
            
            if indexPath.item == currentAddressIndex {
                cell.selectedImageView.isHidden = false
            } else {
                cell.selectedImageView.isHidden = true
            }
            
            let address = addressArray[indexPath.item - 1]
            let addressString = address["address"] as! String
            let lat = address["lat"] as! CGFloat
            let lng = address["lng"] as! CGFloat
            
            cell.addressLabel.text = addressString
            cell.latLabel.text = "\(lat)"
            cell.lngLabel.text = "\(lng)"
            cell.titleLabel.text = "ADDRESS \(indexPath.item)"
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let newAddressViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewAddressViewController") as! NewAddressViewController
            self.navigationController?.pushViewController(newAddressViewController, animated: true)
        } else {
            currentAddressIndex = indexPath.item
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
