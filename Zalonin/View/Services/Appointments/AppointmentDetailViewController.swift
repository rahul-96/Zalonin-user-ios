//
//  AppointmentDetailViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 12/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MapKit

class AppointmentDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var viewButton : UIButton!
    @IBOutlet weak var bookNowButton : UIButton!
    @IBOutlet weak var salonNameLabel : UILabel!
    @IBOutlet weak var salonLocationLabel : UILabel!
    @IBOutlet weak var ratingLabel : UILabel!
    @IBOutlet weak var rescheduleButton : UIButton!
    @IBOutlet weak var cancelButton : UIButton!
    @IBOutlet weak var salonImageView : UIImageView!
    
    var currentSalon = [String : Any]()
    var salon = [String : Any]()
    var cancelViewArray : [cancelView] = []
    var fromSalon : Bool = false
    var currentStatus : Int = -1
    var currentAppointment = [String: Any]()
    
    var currentButton : Int = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        let fromSalon = currentSalon["fromSalon"] as? Bool ?? false
        self.fromSalon = fromSalon
        
        if !fromSalon {
            bookNowButton.isHidden = true
        } else {
            
        }
        
        if currentStatus != 0 {
            cancelButton.isHidden = true
            rescheduleButton.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupTableView()
        self.view.backgroundColor = Colors.grayColor3
        
        let shopName = currentSalon["shopname"] as! String
        let shopId = currentSalon["shopid"] as! String
        salonNameLabel.text = shopName
        
        viewButton.isEnabled = false
        bookNowButton.isEnabled = false
        
        if fromSalon {
            FirebaseMethods().fetchSalon(shopId) { (detailDict) in
                
                let salonImage = detailDict["image"] as! String
                
                let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
                let storageRef = storage.reference()
                
                let childLocation = salonImage + "/IMAGE1.jpg"
                let imageRef = storageRef.child(childLocation)
                
                if self.salonImageView?.image == UIImage(named : "salon") {
                    imageRef.downloadURL { (url, error) in
                        if error != nil {
                            print("image error")
                        } else {
                            let imageURL = url!
                            self.salonImageView.sd_setImage(with: imageURL, completed: nil)
                        }
                    }
                }
                self.salon = detailDict
                
                self.bookNowButton.isEnabled = true
                self.viewButton.isEnabled = true
                self.viewButton.addTarget(self, action: #selector(self.viewTapped), for: .touchUpInside)
                self.bookNowButton.addTarget(self, action: #selector(self.bookNowTapped), for: .touchUpInside)
                
            }
        } else {
            FirebaseMethods().fetchStylist(shopId) { (detailDict) in
                
                let salonImage = detailDict["image"] as! String
                
                let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
                let storageRef = storage.reference()
                
                let childLocation = salonImage + "/IMAGE1.jpg"
                let imageRef = storageRef.child(childLocation)
                
                if self.salonImageView?.image == UIImage(named : "salon") {
                    imageRef.downloadURL { (url, error) in
                        if error != nil {
                            print("image error")
                        } else {
                            let imageURL = url!
                            self.salonImageView.sd_setImage(with: imageURL, completed: nil)
                        }
                    }
                }
                self.salon = detailDict
                
                self.bookNowButton.isEnabled = true
                self.viewButton.isEnabled = true
                self.viewButton.addTarget(self, action: #selector(self.viewTapped), for: .touchUpInside)
                self.bookNowButton.addTarget(self, action: #selector(self.bookNowTapped), for: .touchUpInside)
            }
        }
    }
    
    @objc func viewTapped(){
        
        let image = salonImageView.image
        
        if fromSalon {
            UserDetails.salonSelected = true
            UserDetails.stylistSelected = false
            
            let lat = salon["lat"] as! CGFloat
            let lng = salon["lng"] as! CGFloat
            let salonImage = salon["image"] as! String
            let number = salon["number"] as! String
            let address = salon["address"] as! String
            let name = salon["name"] as! String
            let fromString = salon["from"] as! String
            let toString = salon["to"] as! String
            
            UserDetails.salonSelected = true
            UserDetails.stylistSelected = false
            let salonProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SalonProfileViewController") as! SalonProfileViewController
            
            salonProfileViewController.toString = toString
            salonProfileViewController.fromString = fromString
            
            salonProfileViewController.lat = lat
            salonProfileViewController.lng = lng
            salonProfileViewController.keyValue = salonImage
            salonProfileViewController.number = number
            salonProfileViewController.image = image!
            salonProfileViewController.locationText = address
            salonProfileViewController.profileText = name
            
            self.navigationController?.pushViewController(salonProfileViewController, animated: true)
        } else  {
            UserDetails.salonSelected = false
            UserDetails.stylistSelected = true
            
            
            let salonImage = salon["image"] as! String
            let address = salon["address"] as! String
            
            let salonProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SalonProfileViewController") as! SalonProfileViewController
            
            
            let lat = salon["lat"] as! CGFloat
            let lng = salon["lng"] as! CGFloat
            salonProfileViewController.keyValue = salonImage
            salonProfileViewController.image = image!
            salonProfileViewController.locationText = address
            salonProfileViewController.profileText = salonImage
            salonProfileViewController.lat = lat
            salonProfileViewController.lng = lng
            
            self.navigationController?.pushViewController(salonProfileViewController, animated: true)
        }
    }
    
    @objc func bookNowTapped(){
        
        if fromSalon {
            
            let image = salon["image"] as! String
            let fromString = salon["from"] as! String
            let toString = salon["to"] as! String
            
            UserDetails.salonSelected = true
            UserDetails.stylistSelected = false
            let servicesHomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesHomeViewController") as! ServicesHomeViewController
            servicesHomeViewController.keyValue = image
            servicesHomeViewController.fromString = fromString
            servicesHomeViewController.toString = toString
            self.navigationController?.pushViewController(servicesHomeViewController, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Booking Information"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.grayColor3
        let nib = UINib(nibName: "AppointmentsTableViewCell", bundle: nil)
        tableView.isScrollEnabled = false
        tableView.register(nib, forCellReuseIdentifier: "appointmentDetailCell")
    }
    
    func setupButtons(){

        viewButton.layer.borderColor = Colors.whiteColor.cgColor
        viewButton.layer.borderWidth = 2.0
        
        bookNowButton.layer.borderColor = Colors.whiteColor.cgColor
        bookNowButton.layer.borderWidth = 2.0
        
    }
    
    @IBAction func cancelButtonPressed(){
        
        self.cancelButton.isEnabled = false
        self.rescheduleButton.isEnabled = false
        self.cancelButton.alpha = 0.5
        self.rescheduleButton.alpha = 0.5
        
        
        cancelViewArray = []
        
        self.tableView.alpha = 0.2
        self.salonImageView.alpha = 0.2
        self.salonNameLabel.alpha = 0.2
        self.salonLocationLabel.alpha = 0.2
        
        self.viewButton.isEnabled = false
        self.bookNowButton.isEnabled = false
        
        let cancelView = Bundle.main.loadNibNamed("cancelView", owner: self, options: [:])?.first as! cancelView
        
        
        let navHeight = (self.navigationController?.navigationBar.frame.height)!/2
        let statusHeight = UIApplication.shared.statusBarFrame.height/2
        
        
        cancelView.frame.size = CGSize(width: self.view.frame.width - 20, height: 270)
        cancelView.frame.origin = CGPoint(x: 10, y: self.view.frame.height/2 - 135 - navHeight - statusHeight)
        
        cancelView.button1.addTarget(self, action: #selector(button1Pressed), for: .touchUpInside)
        cancelView.button2.addTarget(self, action: #selector(button2Pressed), for: .touchUpInside)
        cancelView.button3.addTarget(self, action: #selector(button3Pressed), for: .touchUpInside)
        cancelView.button4.addTarget(self, action: #selector(button4Pressed), for: .touchUpInside)
        cancelView.button5.addTarget(self, action: #selector(button5Pressed), for: .touchUpInside)
        
        cancelView.doneButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
        cancelView.cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        
        cancelViewArray.append(cancelView)
        self.view.addSubview(cancelView)
    }
    
    @objc func button1Pressed(){
        let cancelView = cancelViewArray.first
        cancelView?.button1.setImage(UIImage(named : "on_black"), for: .normal)
        cancelView?.button2.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button3.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button4.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button5.setImage(UIImage(named : "off_black"), for: .normal)
        
        self.currentButton = 1
    }
    
    @objc func button2Pressed(){
        let cancelView = cancelViewArray.first
        cancelView?.button2.setImage(UIImage(named : "on_black"), for: .normal)
        cancelView?.button1.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button3.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button4.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button5.setImage(UIImage(named : "off_black"), for: .normal)
        
        self.currentButton = 2
    }
    
    @objc func button3Pressed(){
        let cancelView = cancelViewArray.first
        cancelView?.button3.setImage(UIImage(named : "on_black"), for: .normal)
        cancelView?.button2.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button1.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button4.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button5.setImage(UIImage(named : "off_black"), for: .normal)
        
        self.currentButton = 3
    }
    
    @objc func button4Pressed(){
        let cancelView = cancelViewArray.first
        cancelView?.button4.setImage(UIImage(named : "on_black"), for: .normal)
        cancelView?.button2.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button3.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button1.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button5.setImage(UIImage(named : "off_black"), for: .normal)
        
        self.currentButton = 4
    }
    
    @objc func button5Pressed(){
        let cancelView = cancelViewArray.first
        cancelView?.button5.setImage(UIImage(named : "on_black"), for: .normal)
        cancelView?.button2.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button3.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button4.setImage(UIImage(named : "off_black"), for: .normal)
        cancelView?.button1.setImage(UIImage(named : "off_black"), for: .normal)
        
        self.currentButton = 5
    }
    
    @objc func cancelPressed(){
        let cancelView = cancelViewArray.first
        cancelView?.removeFromSuperview()
        
        self.tableView.alpha = 1.0
        self.salonImageView.alpha = 1.0
        self.salonNameLabel.alpha = 1.0
        self.salonLocationLabel.alpha = 1.0
        
        self.viewButton.alpha = 1.0
        self.bookNowButton.alpha = 1.0
        
        self.rescheduleButton.isEnabled = true
        self.cancelButton.isEnabled = true
        self.rescheduleButton.alpha = 1.0
        self.cancelButton.alpha = 1.0
        
        self.viewButton.isEnabled = true
        self.bookNowButton.isEnabled = true
    }
    
    @objc func donePressed(){
        //cancel appointment
        FirebaseMethods().cancelAppointment(appointment: currentAppointment)
        let cancelView = cancelViewArray.first
        cancelView?.removeFromSuperview()
        
        self.tableView.alpha = 1.0
        self.salonImageView.alpha = 1.0
        self.salonNameLabel.alpha = 1.0
        self.salonLocationLabel.alpha = 1.0
        
        self.viewButton.alpha = 1.0
        self.bookNowButton.alpha = 1.0
        self.viewButton.isEnabled = true
        self.bookNowButton.isEnabled = true
        
        self.rescheduleButton.isEnabled = true
        self.cancelButton.isEnabled = true
        self.rescheduleButton.alpha = 1.0
        self.cancelButton.alpha = 1.0
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rescheduleButtonPressed(){
        
        FirebaseMethods().cancelAppointment(appointment: currentAppointment)
        
        let dateViewController = UIStoryboard(name: "Main", bundle:
            nil).instantiateViewController(withIdentifier: "DateViewController") as! DateViewController
        
        let shopId = currentAppointment["shopid"] as! String
        let shopName = currentAppointment["shopname"] as! String
        let originalPrice = currentAppointment["originalprice"] as! Int
        let lat = currentAppointment["lat"] as! CGFloat
        let lng = currentAppointment["lng"] as! CGFloat
        
        UserDetails.userLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        
        //fetch salon details
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("MERCHANT").child(shopId).child("TIMINGS").observe(.value) { (snapshot) in
            if let timeValue = snapshot.value as? NSDictionary {
                let fromHour = timeValue["fromhour"] as! Int
                        let fromMinute = timeValue["fromminute"] as! Int
                        let toHour = timeValue["tohour"] as! Int
                        let toMinute = timeValue["tominute"] as! Int
                
                        var fromHourString = ""
                        var fromMinuteString = ""
                        var toHourString = ""
                        var toMinuteString = ""
                
                        var fromString = ""
                        var toString = ""
                
                        if fromHour < 10 {
                            fromHourString = "0\(fromHour)"
                        } else {
                            fromHourString = "\(fromHour)"
                        }
                        if fromMinute == 0 {
                            fromMinuteString = "00"
                        } else {
                            fromMinuteString = "\(fromMinute)"
                        }
                
                        if toMinute == 0 {
                            toMinuteString = "00"
                        } else {
                            toMinuteString = "\(toMinute)"
                        }
                
                        toHourString = "\(toHour)"
                
                        fromString = fromHourString + ":" + fromMinuteString
                        toString = toHourString + ":" + toMinuteString
                
                dateViewController.keyValue = shopId
                dateViewController.salonName = shopName
                dateViewController.fromString = fromString
                dateViewController.toString = toString
                dateViewController.fromAppointment = true
                dateViewController.currentAppointment = self.currentAppointment
                dateViewController.originalPrice = originalPrice
               
                
                self.navigationController?.pushViewController(dateViewController, animated: true)
                
            }
        }
    }
    
}

extension AppointmentDetailViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentDetailCell", for: indexPath) as! AppointmentsTableViewCell
        cell.backgroundColor = Colors.grayColor3
        
        
        let price = currentSalon["price"] ?? 0
        let shopName = currentSalon["shopname"] ?? ""
        let userId = currentSalon["userid"] ?? ""
        let serviceName = currentSalon["shopname"] ?? ""
        let serviceStatus = currentSalon["status"] as! Int
        let hour = currentSalon["hour"] ?? 0
        let minute = currentSalon["minute"] ?? 0
        
        cell.appointmentAmountLabel.text = "₹ \(price as! Int)"
        cell.appointmentCentreLabel.text = shopName as? String
        cell.appointmentIdLabel.text = userId as? String
        cell.appointmentTitleLabel.text = serviceName as? String
        
        switch serviceStatus {
        case 0:
            cell.appointmentStatusLabel.text = "WAITING"
            cell.appointmentStatusLabel.textColor = UIColor(hexString: "f39c11")
            break
        case 1:
            cell.appointmentStatusLabel.text = "ACCEPTED"
            cell.appointmentStatusLabel.textColor = UIColor(hexString: "f39c11")
            break
        case 2:
            cell.appointmentTitleLabel.text = "REJECTED"
            cell.appointmentStatusLabel.textColor = UIColor(hexString: "c1392d")
            break
        case 3:
            cell.appointmentStatusLabel.text = "COMPLETED"
            cell.appointmentStatusLabel.textColor = UIColor(hexString: "27ae61")
            
            break
        case 4:
            cell.appointmentStatusLabel.text = "COMPLETED AND RATED"
            cell.appointmentStatusLabel.textColor = UIColor(hexString: "27ae61")
            break
        case 5:
            cell.appointmentStatusLabel.text = "NOT AVAILED"
            cell.appointmentStatusLabel.textColor = UIColor(hexString: "c1392d")
            break
        default:
            cell.appointmentStatusLabel.text = "CANCELED"
            cell.appointmentStatusLabel.textColor = UIColor(hexString: "c1392d")
            break
        }
        
        let timeString = "\(hour):\(minute)"
        cell.dateLabel.text = timeString
        cell.selectionStyle = .none
        
        return cell
    }
}

extension AppointmentDetailViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
