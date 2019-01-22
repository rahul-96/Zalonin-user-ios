//
//  AppointmentsViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 31/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class AppointmentsViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    var detailArray : [[String:Any]] = []
    var appointmentDetail : [String : Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        FirebaseMethods().fetchAppointments { (detailArray) in
            self.detailArray = detailArray
            self.tableView.reloadData()
        }
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.backgroundColor = Colors.grayColor3
        tableView.separatorStyle = .none
        let nib = UINib(nibName: "AppointmentsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "appointmentCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "My Appointments"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
}

extension AppointmentsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appointment = detailArray[indexPath.item]
        let currentAppointment = detailArray[indexPath.item]
        let status = appointment["status"] as? Int ?? 0
        
        let appointmentDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppointmentDetailViewController") as! AppointmentDetailViewController
        
        appointmentDetailViewController.currentSalon = detailArray[indexPath.item]
        appointmentDetailViewController.currentStatus = status
        appointmentDetailViewController.currentAppointment = currentAppointment
        self.navigationController?.pushViewController(appointmentDetailViewController, animated: true)
    }
}

extension AppointmentsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell", for: indexPath) as! AppointmentsTableViewCell
        
        let appointment = detailArray[indexPath.item]
        let duration = appointment["duration"] ?? 0
        let email = appointment["emailid"] ?? ""
        let flexibility = appointment["flexibility"] ?? 0
        let hour = appointment["hour"] ?? 0
        let lat = appointment["lat"] ?? 0.0
        let lng = appointment["lng"] ?? 0.0
        let minute = appointment["minute"] ?? 0
        let originalPrice = appointment["originalprice"] ?? 0
        let price = appointment["price"] ?? 0
        let number = appointment["phonenoe"] ?? 0
        let seat = appointment["seat"] ?? 0
        let serviceName = appointment["service_name"] ?? ""
        let shopId = appointment["shopid"] ?? ""
        let shopName = appointment["shopname"] ?? ""
        let status = appointment["status"] ?? 0
        let userId = appointment["userid"] ?? ""
        let username = appointment["username"] ?? ""
        let fromSalon = appointment["fromSalon"] ?? false
        
        cell.appointmentAmountLabel.text = "₹ \(price as! Int)"
        cell.appointmentCentreLabel.text = shopName as? String
        cell.appointmentIdLabel.text = userId as? String
        cell.appointmentTitleLabel.text = serviceName as? String
        
        appointmentDetail["duration"] = duration
        appointmentDetail["email"] = email
        appointmentDetail["flexibility"] = flexibility
        appointmentDetail["hour"] = hour
        appointmentDetail["lat"] = lat
        appointmentDetail["lng"] = lng
        appointmentDetail["minute"] = minute
        appointmentDetail["originalprice"] = originalPrice
        appointmentDetail["price"] = price
        appointmentDetail["number"] = number
        appointmentDetail["seat"] = seat
        appointmentDetail["serviceName"] = serviceName
        appointmentDetail["shopId"] = shopId
        appointmentDetail["shopName"] = shopName
        appointmentDetail["status"] = status
        appointmentDetail["userId"] = userId
        appointmentDetail["username"] = username
        appointmentDetail["fromSalon"] = fromSalon
        
        let serviceStatus = status as! Int
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
        
        let bool = fromSalon as? Bool ?? false
        if bool {
            let salonColor = UIColor(displayP3Red: 255/255, green: 114/255, blue: 0, alpha: 0.7)
            
            let salonGradient = CAGradientLayer()
            salonGradient.colors = [Colors.clearColor,salonColor.withAlphaComponent(0.2).cgColor]
            salonGradient.frame = cell.bounds
            salonGradient.endPoint = CGPoint(x: 0.0, y: 0.5)
            salonGradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            
            if let layers = cell.layer.sublayers {
                if layers.count == 1 {
                    cell.layer.insertSublayer(salonGradient, at: 0)
                }
            }
            
            salonGradient.frame.size.width = cell.frame.width
            
        } else {
            let stylistColor = UIColor(displayP3Red: 255/255, green: 0/255, blue: 0, alpha: 0.7)
            let salonGradient = CAGradientLayer()
            salonGradient.colors = [Colors.clearColor,stylistColor.withAlphaComponent(0.2).cgColor]
            salonGradient.frame = cell.bounds
            salonGradient.endPoint = CGPoint(x: 0.0, y: 0.5)
            salonGradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            
            if let layers = cell.layer.sublayers {
                if layers.count == 1 {
                    cell.layer.insertSublayer(salonGradient, at: 0)
                }
            }
            salonGradient.frame.size.width = cell.frame.width
            
        }
        
        self.detailArray.append(appointmentDetail)
        let timeString = "\(hour):\(minute)"
        cell.dateLabel.text = timeString
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

