//
//  DateViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 04/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import FSCalendar

class DateViewController: UIViewController {

    @IBOutlet weak var cancelButton : UIButton!
    @IBOutlet weak var nextButton : UIButton!
    @IBOutlet weak var dateTitleLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var statusCollectionView : UICollectionView!
    @IBOutlet weak var statusCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var calendarView : FSCalendar!
    
    var toString : String = ""
    var fromString : String = ""
    let statusArray = ["Choose Date", "Choose Time", "Confirm Order", "Payment Option"]
    var selectedDate : Date = Date()
    var salonName : String = ""
    var keyValue : String = ""
    
    var originalPrice : Int = 0
  
    
    var currentAppointment = [String : Any]()
    var fromAppointment : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNextButton()
        statusCollectionView.dataSource = self
        
        let width = (self.view.frame.width)/4
        let itemSize = CGSize(width: width, height: 50)
        statusCollectionView.backgroundColor = Colors.whiteColor
        statusCollectionViewFlowLayout.itemSize = itemSize
        statusCollectionViewFlowLayout.minimumLineSpacing = 0.0
        statusCollectionViewFlowLayout.minimumInteritemSpacing = 0.0
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.today = nil
        
        calendarView.select(Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        self.dateLabel.text = dateFormatter.string(from: Date())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = "Checkout"
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = ""
        super.viewWillDisappear(animated)
    }
}

extension DateViewController {
    func setupNextButton(){
        nextButton.clipsToBounds = true
        nextButton.layer.borderColor = Colors.whiteColor.cgColor
        nextButton.layer.borderWidth = 2.0
    }
    
    @IBAction func nextButtonPressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        
        let date1 = dateFormatter.string(from: Date())
       
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        let date2 = dateFormatter.string(from: nextDate!)
        
        if dateLabel.text == date1 || dateLabel.text == date2 {
            let timeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TimeViewController") as! TimeViewController
            timeViewController.selectedDate = selectedDate
            timeViewController.fromString = fromString
            timeViewController.toString = toString
            timeViewController.salonName = salonName
            timeViewController.keyValue = keyValue
            timeViewController.totalAmount = currentAppointment["price"] as? Int ?? 0
            timeViewController.totalServicesString = currentAppointment["service_name"] as? String ?? ""
            timeViewController.originalPrice = originalPrice
        
            if fromAppointment {
                let duration  = currentAppointment["duration"] as! Int
                timeViewController.totalDuration = duration
            }
            
            self.navigationController?.pushViewController(timeViewController, animated: true)
        } else {
            self.showAlert(msg: "Booking only for today and tomorrow available")
        }
    }
    
    @IBAction func cancelButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
}

extension DateViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! StatusCollectionViewCell
        if indexPath.item == 0 {
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


extension DateViewController : FSCalendarDelegate , FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        self.dateLabel.text = dateFormatter.string(from: date)
        selectedDate = date
    }
}
