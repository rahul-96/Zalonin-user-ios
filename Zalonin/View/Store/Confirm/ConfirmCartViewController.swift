//
//  ConfirmViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 28/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class ConfirmCartViewController : UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var confirmAddressButton : UIButton!
    
    var detailDictArray : [[String : Any]] = []
    var cartDictArray : [[String : Any]] = []
    
    var totalQuantity : Int = 0
    var totalPrice : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        self.navigationItem.title = "Confirm Order"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Confirm Order"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        let productNib = UINib(nibName: "ConfirmProductTableViewCell", bundle: nil)
        let totalNib = UINib(nibName: "ConfirmTotalTableViewCell", bundle: nil)
        
        tableView.register(productNib, forCellReuseIdentifier: "productCell")
        tableView.register(totalNib, forCellReuseIdentifier: "totalCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        setupTableFooterView()
    }
    
    @IBAction func confirmAddressButtonPressed(){
        let confirmAddressViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfirmAddressViewController") as! ConfirmAddressViewController
        confirmAddressViewController.cartDictArray = cartDictArray
        confirmAddressViewController.detailDictArray = detailDictArray
        confirmAddressViewController.totalPrice = totalPrice
        self.navigationController?.pushViewController(confirmAddressViewController, animated: true)
    }
    
    func setupTableFooterView(){
        let referralView = Bundle.main.loadNibNamed("ConfirmReferralView", owner: self, options: nil)?.first as! ConfirmReferralView
        referralView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100)
        referralView.referralTextField.delegate = self
        tableView.tableFooterView = referralView
    }
}

extension ConfirmCartViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item < detailDictArray.count  {
            
            let currentCart = cartDictArray[indexPath.item]
            let currentProduct = detailDictArray[indexPath.item]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! ConfirmProductTableViewCell
            
            let name = currentProduct["name"] as! String
            
            let size = currentCart["size"] as! String
            let qty = currentCart["qty"] as! Int
            
            cell.titleLabel.text = name
            cell.sizeLabel.text = size.uppercased()
            cell.qtyLabel.text = "\(qty)"
            
            let oldPrice = currentProduct["price"] as! Int
            let discount = currentProduct["discount"] as! Int
            
            let newPrice = (oldPrice * (100 - discount))/100
            
            cell.priceLabel.text = "\(newPrice) ₹"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalCell") as! ConfirmTotalTableViewCell
            
            for i in 0...detailDictArray.count - 1 {
                let currentCart = cartDictArray[i]
                let currentProduct = detailDictArray[i]
                
                let qty = currentCart["qty"] as! Int
                let oldPrice = currentProduct["price"] as! Int
                let discount = currentProduct["discount"] as! Int
                
                let newPrice = (oldPrice * (100 - discount))/100
                
                totalPrice += newPrice
                totalQuantity += qty
                
            }
            
            cell.priceLabel.text = "\(totalPrice) ₹"
            cell.qtyLabel.text = "\(totalQuantity)"
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailDictArray.count + 1
    }
}

extension ConfirmCartViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
