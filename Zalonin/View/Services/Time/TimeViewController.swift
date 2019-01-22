//
//  TimeViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 07/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController {
    
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var statusCollectionView : UICollectionView!
    @IBOutlet weak var statusCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var timeCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var timeCollectionview : UICollectionView!
    @IBOutlet weak var nextButton : UIButton!
    
    let statusArray = ["Choose Date", "Choose Time", "Confirm Order", "Payment Option"]
    var timeArray : [String] = []
    var toString : String = ""
    var fromString : String = ""
    var currentTimeIndex : Int = -1
    var selectedDate : Date = Date()
    var totalDuration : Int = 0
    var selectedIndexes : [Int] = []
    var selectedTime : String = ""
    var salonName : String = ""
    var keyValue : String = ""
    var totalAmount : Int = 0
    var totalServicesString : String = ""
    
    var originalPrice : Int = 0
  
    
    var duration : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimeCollectionView()
        setupStatusCollectionView()
        setupNextButton()
        calculateTimeIntervals()
        
        for service in UserDetails.selectedServicesArray {
            let duration = service["duration"] as! Int
            totalDuration += duration
        }
        timeLabel.text = "\(totalDuration)"
    }
    
    func calculateIndexes () -> Int {
        var indexes = totalDuration / 15
        if totalDuration % 15 < 15 {
            indexes += 1
        }
        return indexes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
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

extension TimeViewController {
    //setup Status CollectionView
    func setupStatusCollectionView(){
        let width = self.view.frame.width/4
        let itemSize = CGSize(width: width, height: 50.0)
        statusCollectionViewFlowLayout.itemSize = itemSize
        statusCollectionViewFlowLayout.minimumLineSpacing = 0.0
        statusCollectionViewFlowLayout.minimumInteritemSpacing = 0.0
        statusCollectionView.backgroundColor = Colors.whiteColor
        statusCollectionView.dataSource = self
    }
    
    func setupNextButton(){
        nextButton.clipsToBounds = true
        nextButton.layer.borderColor = Colors.whiteColor.cgColor
        nextButton.layer.borderWidth = 2.0
    }
    
    func calculateTimeIntervals(){
        let startTimeString = fromString
        let endTimeString = toString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var dateString : String = startTimeString
        while dateString != endTimeString {
            let dateStringTime = dateFormatter.date(from: dateString)
            self.timeArray.append(dateString)
            let date = Calendar.current.date(byAdding: .minute, value: 15, to: dateStringTime!)
            
            dateString = dateFormatter.string(from: date!)
            
        }
        self.timeArray.append(endTimeString)
        self.timeCollectionview.reloadData()
    }
    
    @IBAction func nextButtonPressed(){
        if selectedIndexes.count > 0 {
            selectedTime = timeArray[selectedIndexes.first!]
            let confirmViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfirmViewController") as! ConfirmViewController
            confirmViewController.selectedTime = selectedTime
            confirmViewController.salonName = salonName
            confirmViewController.selectedDate = selectedDate
            confirmViewController.keyValue = keyValue
            confirmViewController.totalAmount = totalAmount
            confirmViewController.totalServicesString = totalServicesString
            confirmViewController.duration = totalDuration
            confirmViewController.originalPrice = originalPrice
            self.navigationController?.pushViewController(confirmViewController, animated: true)
        } else {
            self.showAlert(msg: "Please select a time slot")
        }
    }
}

extension TimeViewController {
    func setupTimeCollectionView(){
        timeCollectionview.backgroundColor = Colors.whiteColor
        let width = (self.view.frame.width - 60)/5
        let itemSize = CGSize(width: width, height: width)
        timeCollectionViewFlowLayout.itemSize = itemSize
        timeCollectionViewFlowLayout.minimumInteritemSpacing = 10.0
        timeCollectionViewFlowLayout.minimumLineSpacing = 10.0
        timeCollectionview.dataSource = self
        timeCollectionview.showsVerticalScrollIndicator = false
        timeCollectionview.delegate = self
        timeCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 10.0, 0)
    }
}

extension TimeViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == timeCollectionview {
            return self.timeArray.count
        } else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == timeCollectionview {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! TimeCollectionViewCell
            cell.backgroundColor = Colors.goldenColor
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let currentTimeString = dateFormatter.string(from: Date())
            let currentTime = dateFormatter.date(from: currentTimeString)
            
            let time = dateFormatter.date(from: timeArray[indexPath.item])
            
            let stringDateFormatter = DateFormatter()
            stringDateFormatter.dateFormat = "dd MM yyyy"
            let selectedDateString = stringDateFormatter.string(from: selectedDate)
            let currentDateString = stringDateFormatter.string(from: Date())
            
            
            if selectedDateString == currentDateString {
                if time! <= currentTime! {
                    cell.timeLabel.text = self.timeArray[indexPath.item]
                    cell.timeLabel.textColor = Colors.whiteColor
                    cell.backgroundColor = Colors.goldenColor
                } else {
                    if let index = selectedIndexes.index(of: indexPath.item) {
                        if index >= 0 {
                            cell.timeLabel.textColor = Colors.whiteColor
                            cell.backgroundColor = Colors.grayColor3
                        } else {
                            cell.timeLabel.textColor = Colors.blackColor
                            cell.backgroundColor = Colors.whiteColor
                            cell.layer.borderColor = Colors.blackColor.cgColor
                        }
                    }
                    else {
                        cell.timeLabel.textColor = Colors.blackColor
                        cell.backgroundColor = Colors.whiteColor
                        cell.layer.borderColor = Colors.blackColor.cgColor
                    }
                    
                    cell.timeLabel.text = self.timeArray[indexPath.item]
                    
                    cell.layer.borderWidth = 1.0
                }
            } else {
                if let index = selectedIndexes.index(of: indexPath.item) {
                    if index >= 0 {
                        cell.timeLabel.textColor = Colors.whiteColor
                        cell.backgroundColor = Colors.grayColor3
                    } else {
                        cell.timeLabel.textColor = Colors.blackColor
                        cell.backgroundColor = Colors.whiteColor
                        cell.layer.borderColor = Colors.blackColor.cgColor
                    }
                }
                else {
                    cell.timeLabel.textColor = Colors.blackColor
                    cell.backgroundColor = Colors.whiteColor
                    cell.layer.borderColor = Colors.blackColor.cgColor
                }
                
                cell.timeLabel.text = self.timeArray[indexPath.item]
                
                cell.layer.borderWidth = 1.0
                
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! TimeStatusCollectionViewCell
            if indexPath.item == 1 {
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

extension TimeViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentTimeIndex = calculateIndexes()
        let cell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
        if cell.backgroundColor != Colors.goldenColor {
            let selectIndex = indexPath.item
            selectedIndexes = []
            
            if selectIndex + currentTimeIndex <= timeArray.count {
                for i in 0..<currentTimeIndex {
                    let index = selectIndex + i
                    self.selectedIndexes.append(index)
                }
            }
            collectionView.reloadData()
        }
    }
}
