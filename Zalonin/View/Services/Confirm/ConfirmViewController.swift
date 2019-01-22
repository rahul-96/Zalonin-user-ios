//
//  ConfirmViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 12/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ConfirmViewController: UIViewController {
    
    @IBOutlet weak var statusCollectionView : UICollectionView!
    @IBOutlet weak var statusCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var referralCodeTextField : UITextField!
    @IBOutlet weak var applyButton : UIButton!
    @IBOutlet weak var redeemButton : UIButton!
    @IBOutlet weak var paymentButton : UIButton!
    
    let titleArray : [String] =  ["Date", "Time", "Services Selected" , "Salon Name", "Amount"]
    let statusArray = ["Choose Date", "Choose Time", "Confirm Order", "Payment Option"]
    let imageArray = ["date", "time", "service", "ladies", "rupee"]
    
    var selectedTime : String = ""
    var selectedDate : Date = Date()
    var selectedSalon : String = ""
    var totalAmount : Int = 0
    var totalServicesString : String = ""
    var salonName : String = ""
    var duration : Int = 0
    var serviceHeight : CGFloat = 0.0
    var keyValue : String = ""
    var selectedTimeDate : Date = Date()
    var keyboardDisplayed : Bool = false
    var selectedCoupon : String = ""
    
    var originalPrice : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentButton.layer.borderColor = Colors.whiteColor.cgColor
        paymentButton.layer.borderWidth = 2.0
        referralCodeTextField.delegate = self
        setupKeyboard()
        
        for service in UserDetails.selectedServicesArray {
            let cost = service["new"] as! Int
            totalAmount += cost
        }
        
        
        for i in 0..<UserDetails.selectedServicesCount {
            let service = UserDetails.selectedServicesArray[i]
            var serviceName = service["name"] as! String
            if i < UserDetails.selectedServicesCount - 1{
                serviceName += ", "
            }
            self.totalServicesString += serviceName
        }
        
        setupTableView()
        setupStatusCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Checkout"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.grayColor3
    }
    
    func setupStatusCollectionView(){
        let width = self.view.frame.width/4
        let itemSize = CGSize(width: width, height: 50.0)
        statusCollectionViewFlowLayout.itemSize = itemSize
        statusCollectionViewFlowLayout.minimumLineSpacing = 0.0
        statusCollectionViewFlowLayout.minimumInteritemSpacing = 0.0
        statusCollectionView.backgroundColor = Colors.whiteColor
        statusCollectionView.dataSource = self
    }
    
    @IBAction func paymentButtonPressed(){
        let paymentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
        
        paymentViewController.from = selectedTime
        paymentViewController.shopId = keyValue
        paymentViewController.keyValue = keyValue
        paymentViewController.selectedTime = selectedTimeDate
        paymentViewController.selectedDate = selectedDate
        paymentViewController.shopName = salonName
        paymentViewController.totalDuration = duration
        paymentViewController.totalServicesString = totalServicesString
        paymentViewController.totalPrice = totalAmount
        paymentViewController.totalOldPrice = originalPrice
        
        if selectedCoupon != "" {
            paymentViewController.coupon = selectedCoupon
        }
        self.navigationController?.pushViewController(paymentViewController, animated: true)
    }
    
    @IBAction func applyButtonPressed(){
        let coupon = referralCodeTextField.text
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        var validCoupon : Bool = false
        
        self.referralCodeTextField.resignFirstResponder()

        
        ref.child("ZALONIN/PROMO").observeSingleEvent(of: .value) { (snapshot) in
            let promoArray = snapshot.children.allObjects as NSArray
            for promo in promoArray {
                let promoSnapshot = promo as! DataSnapshot
                let promoKey = promoSnapshot.key
                if coupon == promoKey {
                    validCoupon = true
                    if let promoDict = promoSnapshot.value as? NSDictionary {
                        let value = promoDict["value"] as! Int
                        let above = promoDict["above"] as! Int
                        let limit = promoDict["limit"] as! Int
                        
                        if self.totalAmount > above {
                            if limit > 0 {
                                self.showAlert(msg: "Coupon code applied successfully")
                                self.totalAmount -= value
                                self.selectedCoupon = self.referralCodeTextField.text!
                                self.tableView.reloadData()
                            } else {

                                self.showAlert(msg: "Coupon no longer available")

                            }
                        } else {
                            self.showAlert(msg: "Total amount should be greater than \(above)")

                        }
                    }
                }
            }
            
            if !validCoupon {
                self.showAlert(msg: "Coupon not valid")

            }
        }
        
    }
    
    func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @objc func keyboardWillAppear(_ notification : Notification){
        if self.view.frame.origin.y >= 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                
                if !keyboardDisplayed  {
                    self.view.frame.origin.y -= keyboardHeight
                    keyboardDisplayed = true
                    
                }
                
            }
        }
    }
    
    @objc func keyboardWillDisappear(_ notification : Notification){
        if self.view.frame.origin.y < 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                if keyboardDisplayed {
                    self.view.frame.origin.y += keyboardHeight
                    keyboardDisplayed = false
                }
            }
        }
    }
    
}

extension ConfirmViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 2 {
            return 55 + serviceHeight
        } else {
            return 75
        }
    }
}

extension ConfirmViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmCell", for: indexPath) as! ConfirmTableViewCell
        cell.titleLabel.text = titleArray[indexPath.item]
        cell.selectionStyle = .none
        cell.confirmImageView.image = UIImage(named : imageArray[indexPath.item])
        
        switch indexPath.item {
        case 0:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            let dateString = dateFormatter.string(from: selectedDate)
            cell.valueLabel.text = dateString
            break
        case 1:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.date(from: selectedTime)
            selectedTimeDate = time!
            dateFormatter.dateFormat = "HH:mm a"
            let timeString = dateFormatter.string(from: time!)
            cell.valueLabel.text = timeString
            break
        case 2:
            cell.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.valueLabel.numberOfLines = 0
            cell.valueLabel.text = totalServicesString
            cell.valueLabel.sizeToFit()
            cell.valueLabel.frame.size.height = cell.valueLabel.frame.height
            self.serviceHeight  = cell.valueLabel.frame.height
            tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
            break
        case 3:
            cell.valueLabel.text = salonName
            break
        case 4:
            cell.valueLabel.text = "₹ \(totalAmount)"
            break
        default:
            break
        }
        return cell
    }
}


extension ConfirmViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! ConfirmCollectionViewCell
        if indexPath.item == 2 {
            cell.statusView.isHidden = false
            cell.statusLabel.textColor = Colors.blackColor
        } else {
            cell.statusView.isHidden = true
            cell.statusLabel.textColor = Colors.grayColor1
        }
        cell.statusLabel.text = statusArray[indexPath.item]
        return cell
    }
}

extension ConfirmViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

