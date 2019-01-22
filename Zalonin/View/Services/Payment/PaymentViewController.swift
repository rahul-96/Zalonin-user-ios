//
//  PaymentViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 12/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var statusCollectionView : UICollectionView!
    @IBOutlet weak var statusCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var bookNowButton : UIButton!
    @IBOutlet weak var paymentCollectionView : UICollectionView!
    @IBOutlet weak var paymentCollectionViewFlowLayout : UICollectionViewFlowLayout!
    
    let statusArray = ["Choose Date", "Choose Time", "Confirm Order", "Payment Option"]
    let paymentArray = ["Mastercard", "Debit/Credit Card", "Paytm", "Cash"]
    let imageArray = ["creditcard", "creditcard", "paytm2", "rupee2"]
    var shopId : String = ""
    var shopName : String = ""
    var from : String = ""
    var duration : String = ""
    var keyValue : String = ""
    var selectedDate : Date = Date()
    var selectedTime : Date = Date()
    var coupon : String = ""
    
    var totalDuration : Int = 0
    var totalPrice : Int = 0
    var totalOldPrice : Int = 0
    var totalServicesString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaymnetCollectionView()
        setupStatusCollectionView()
        view.backgroundColor = Colors.grayColor3
        
        bookNowButton.layer.borderColor = Colors.whiteColor.cgColor
        bookNowButton.layer.borderWidth = 2.0
    }
    
    func setupPaymnetCollectionView(){
        paymentCollectionView.dataSource = self
        let width = self.view.frame.width - 40.0
        let height : CGFloat = 45.0
        let itemSize = CGSize(width: width, height: height)
        paymentCollectionViewFlowLayout.itemSize = itemSize
        paymentCollectionViewFlowLayout.minimumLineSpacing = 20.0
        paymentCollectionViewFlowLayout.minimumInteritemSpacing = 20.0
        paymentCollectionView.backgroundColor = Colors.grayColor3
        paymentCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
    }
    
    @IBAction func bookNowButtonPressed(){

        var ref  : DatabaseReference
        ref = Database.database().reference()

        if coupon != "" {
            let childRef = ref.child("ZALONIN/PROMO/\(coupon)")
            
            ref.child("ZALONIN/PROMO/\(coupon)").observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String : Int]{
                    var snapDict = dictionary
                    var limit = dictionary["limit"] as! Int
                    limit -= 1
                    snapDict["limit"] = limit
                    childRef.updateChildValues(snapDict)

                }
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let serviceNode = dateFormatter.string(from: selectedDate)
        dateFormatter.dateFormat = "HHmmss"
        let serviceSubnode = dateFormatter.string(from: selectedTime)
        let subnode = serviceNode + serviceSubnode
        
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: selectedTime)
        let hour = Int(hourString)
        dateFormatter.dateFormat = "mm"
        let minuteString = dateFormatter.string(from: selectedTime)
        let minute = Int(minuteString)
        
       
        
        for service in UserDetails.selectedServicesArray {
            let duration = service["duration"] as! Int
            totalDuration += duration
            let price = service["new"] as! Int
            totalPrice = price
            let oldPrice = service["price"] as! Int
            totalOldPrice += oldPrice
        }
        
//        for i in 0..<UserDetails.selectedServicesCount {
//            let service = UserDetails.selectedServicesArray[i]
//            var serviceName = service["name"] as! String
//            if i < UserDetails.selectedServicesCount - 1{
//                serviceName += ", "
//            }
//            totalServicesString += serviceName
//        }
        
        FirebaseMethods().fetchUserDetails { (userName, userEmail, userGender, userNumber, references, requestCount , wallet, birthDate) in
            UserDetails.userName = userName
            UserDetails.userEmail = userEmail
            UserDetails.userNumber = userNumber
            UserDetails.references = references
            UserDetails.userBirthDate = birthDate
            
            var serviceDict = [String : AnyObject]()
            serviceDict["duration"] = self.totalDuration as AnyObject
            serviceDict["emailid"] = UserDetails.userEmail as AnyObject
            serviceDict["flexibility"] = 0 as AnyObject
            serviceDict["hour"] = hour as AnyObject
            serviceDict["lat"] = UserDetails.userLocation.latitude as AnyObject
            serviceDict["lng"] = UserDetails.userLocation.longitude as AnyObject
            serviceDict["minute"] = minute as AnyObject
            serviceDict["originalprice"] = self.totalOldPrice as AnyObject
            serviceDict["phonenoe"] = UserDetails.userNumber as AnyObject
            serviceDict["price"] = self.totalPrice as AnyObject
            serviceDict["seat"] = 0 as AnyObject
            serviceDict["service_name"] = self.totalServicesString as AnyObject
            serviceDict["shopid"] = self.shopId as AnyObject
            serviceDict["shopname"] = self.shopName as AnyObject
            serviceDict["status"] = 0 as AnyObject
            serviceDict["userid"] = subnode as AnyObject
            serviceDict["username"] = UserDetails.userName as AnyObject
            
            let delegate = UIApplication.shared.delegate as! AppDelegate

            if UserDetails.salonSelected {
                serviceDict["fromSalon"] = true as AnyObject
                ref.child("MERCHANT").child(self.keyValue).child("BOOKINGS").child(serviceNode).child(subnode).setValue(serviceDict)
                


            } else {
                serviceDict["fromSalon"] = false as AnyObject
                ref.child("MERCHANT").child(self.keyValue).child("BOOKINGS").child(serviceNode).child(subnode).setValue(serviceDict)
                ref.child("STYLIST").child(self.keyValue).child("BOOKINGS").child(serviceNode).child(subnode).setValue(serviceDict)
                

            }
            ref.child("USER").child(UserDetails.userId).child("REQUESTS").child(serviceNode).child(subnode).setValue(serviceDict)
            
            
            let bookingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
            bookingViewController.username = UserDetails.userName
            bookingViewController.price = "₹ \(self.totalPrice)"
            
            dateFormatter.dateFormat = "HH:mm"
            bookingViewController.time = dateFormatter.string(from: self.selectedTime)
            dateFormatter.dateFormat = "dd,MMMM yy"
            bookingViewController.date = dateFormatter.string(from: self.selectedDate)
            

            self.present(bookingViewController, animated: true, completion: nil)
        }
    }
    
    func setupStatusCollectionView(){
        let width = self.view.frame.width/4
        let itemSize = CGSize(width: width, height: 50)
        statusCollectionViewFlowLayout.itemSize = itemSize
        statusCollectionViewFlowLayout.minimumLineSpacing = 0.0
        statusCollectionViewFlowLayout.minimumInteritemSpacing = 0.0
        statusCollectionView.backgroundColor = Colors.whiteColor
        statusCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Checkout"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
}

extension PaymentViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == paymentCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentCell", for: indexPath) as! PaymentCollectionViewCell
            cell.paymentLabel.text = paymentArray[indexPath.item]
            cell.paymentImageView.image = UIImage(named : imageArray[indexPath.item])
            
            if indexPath.item == 3 {
                cell.selectedImageView.image = UIImage(named : "on_black")
            } else {
                cell.selectedImageView.image = UIImage(named : "off_black")
            }
            
            cell.backgroundColor = Colors.whiteColor
            return cell
        } else  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! PaymentStatusCollectionViewCell
            
            if indexPath.item == 3 {
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
}


