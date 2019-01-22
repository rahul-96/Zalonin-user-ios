//
//  ServicesHomeViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 03/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ServicesHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var segmentController  : UISegmentedControl!
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var headerCollectionView : UICollectionView!
    @IBOutlet weak var headerCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var selectedItemsLabel : UILabel!
    
    let bannerArray = ["app banner-3", "app banner-4"]
    var keyValue : String = ""
    var discountValue : Int = 0
    var femaleServicesArray : [String] = []
    var maleServicesArray : [String] = []
    var detailArray : [[String : Any]] = []
    var searchArray : [String] = []
    var fromString : String = ""
    var toString : String = ""
    var salonName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSegmentController()
        setupSearchBar()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        
        selectedItemsLabel.layer.borderColor = Colors.blackColor.cgColor
        selectedItemsLabel.layer.borderWidth = 2.0
        
        //fetch firebase data
        
        var ref : DatabaseReference!
        ref = Database.database().reference()
        
        if keyValue != "" {
            
            
            fetchDiscount()
            
            ref.child("MERCHANT").child(keyValue).observeSingleEvent(of: .value) { (snapshot) in
                let serviceDetails = snapshot.childSnapshot(forPath: "SERVICES")
                let femaleServices = serviceDetails.childSnapshot(forPath: "FEMALE")
                if let femaleDict = femaleServices.value as? NSDictionary {
                    for key in femaleDict.allKeys {
                        if let keyString = key as? String {
                            self.femaleServicesArray.append(keyString)
                        }
                    }
                    self.searchArray = self.femaleServicesArray
                    self.tableView.reloadData()
                }
                
                let maleServices = serviceDetails.childSnapshot(forPath: "MALE")
                if let maleDict = maleServices.value as? NSDictionary {
                    for key in maleDict.allKeys {
                        if let keyString = key as? String {
                            self.maleServicesArray.append(keyString)
                        }
                    }
                }
            }
        } else {
            ref.child("ZALONIN/CATEGORY").observe(.value, with: { (snapshot) in
                
                let femaleSnapshot = snapshot.childSnapshot(forPath: "FEMALE")
                let femaleServices = femaleSnapshot.children.allObjects as NSArray
                for service in femaleServices {
                    let serviceSnapshot = service as! DataSnapshot
                    let key = serviceSnapshot.key
                    self.femaleServicesArray.append(key)
                }
                self.searchArray = self.femaleServicesArray
                self.tableView.reloadData()
                
                let maleSnapshot = snapshot.childSnapshot(forPath: "MALE")
                let maleServices = maleSnapshot.children.allObjects as NSArray
                for service in maleServices {
                    let serviceSnapshot = service as! DataSnapshot
                    let key = serviceSnapshot.key
                    self.maleServicesArray.append(key)
                }
            })
        }
        
        searchBar.tintColor = Colors.blackColor
    }
    
    func fetchDiscount(){
        var ref : DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("MERCHANT").child(keyValue).child("DISCOUNT").observe(.value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let discount = value["discount"] as! Int
            self.discountValue = discount
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDetails.salonSelected {
            self.navigationItem.title = "Salon Services"
        } else {
            self.navigationItem.title = "Stylist Services"
        }
        self.detailArray = []
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = ""
        self.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedItemsLabel.text = "\(UserDetails.selectedServicesCount) items selected"
    }
}

extension ServicesHomeViewController  {
    func setupCollectionView(){
        let width : CGFloat = UIScreen.main.bounds.width - 10
        let itemSize : CGSize = CGSize(width: width, height: 150)
        headerCollectionViewFlowLayout.itemSize = itemSize
        headerCollectionViewFlowLayout.minimumLineSpacing = 0.0
        headerCollectionViewFlowLayout.minimumInteritemSpacing = 0.0
        headerCollectionView.isPagingEnabled = true
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        headerCollectionView.backgroundColor = UIColor.gray
    }
    
    func setupSegmentController() {
        let segmentFont = UIFont.boldSystemFont(ofSize: 15)
        segmentController.setTitleTextAttributes([NSAttributedStringKey.font : segmentFont], for: .normal)
        segmentController.tintColor = Colors.grayColor3
    }
    
    func setupSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = "Search Services"
    }
    
    @IBAction func segmentControllerChanged(){
        if segmentController.selectedSegmentIndex == 0 {
            self.searchArray = femaleServicesArray
        } else {
            self.searchArray = maleServicesArray
        }
        self.tableView.reloadData()
        
    }
    
    @IBAction func proceedButtonPressed(){
        if UserDetails.salonSelected {
            if UserDetails.selectedServicesCount == 0 {
                self.showAlert(msg: "Please select one of the services to proceed!")
            } else {
                let dateViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DateViewController") as! DateViewController
                dateViewController.fromString = fromString
                dateViewController.toString = toString
                dateViewController.salonName = salonName
                self.navigationController?.pushViewController(dateViewController, animated: true)
            }
        } else {
            if UserDetails.selectedServicesCount > 0 {
                let salonViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SalonsViewController") as! SalonsViewController
                
                salonViewController.selectedIndex = segmentController.selectedSegmentIndex
                self.navigationController?.pushViewController(salonViewController, animated: true)
            } else {
                self.showAlert(msg: "Please select atleast one service to proceed")
            }
        }
    }
}

extension ServicesHomeViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ServicesHomeViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserDetails.ads2Count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let headerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as! ServicesCollectionViewCell
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        
        let childLocation = "ADS2/IMAGE\(indexPath.item + 1).jpg"
        let imageRef = storageRef.child(childLocation)
        
        if headerCollectionViewCell.servicesImageView.image == UIImage(named : "salon") {
            imageRef.downloadURL { (url, error) in
                if error == nil {
                    headerCollectionViewCell.servicesImageView.sd_setImage(with: url, completed: nil)
                } else {
                    headerCollectionViewCell.servicesImageView.image = UIImage(named : "salon")
                }
            }
        }
        return headerCollectionViewCell
    }
}

extension ServicesHomeViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! ServicesTableViewCell
        cell.selectionStyle = .none
        cell.serviceLabel.text = self.searchArray[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var ref : DatabaseReference!
        ref = Database.database().reference()
        
        if segmentController.selectedSegmentIndex == 0 {
            
            if keyValue != "" {
                let currentService = self.femaleServicesArray[indexPath.item]
                ref.child("MERCHANT").child(keyValue).child("SERVICES/FEMALE").child(currentService).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let objects = snapshot.children.allObjects as? [DataSnapshot] {
                        if objects.count > 0 {
                            
                            for children in objects {
                                let serviceValue = children.value as! NSDictionary
                                let serviceName = serviceValue["name"] as! String
                                let servicePrice = serviceValue["price"] as! Int
                                let serviceDuration = serviceValue["duration"] as! Int
                                let serviceOldPrice = ((100 - self.discountValue) * servicePrice)/100
                                
                                let detailDict : [String: Any] = [
                                    "name" : serviceName ,
                                    "price" : servicePrice,
                                    "duration" : serviceDuration,
                                    "new" : serviceOldPrice
                                ]
                                self.detailArray.append(detailDict)
                            }
                            
                            let serviceDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesDetailViewController") as! ServicesDetailViewController
                            serviceDetailViewController.fromString = self.fromString
                            serviceDetailViewController.toString = self.toString
                            serviceDetailViewController.salonName = self.salonName
                            serviceDetailViewController.detailArray = self.detailArray
                            serviceDetailViewController.keyValue = self.keyValue
                            serviceDetailViewController.selectedIndex = self.segmentController.selectedSegmentIndex
                            self.navigationController?.pushViewController(serviceDetailViewController, animated: true)
                        }
                    }
                })
            } else {
                let currentService = self.femaleServicesArray[indexPath.item]
                ref.child("ZALONIN/CATEGORY/FEMALE").child(currentService).child("SERVICES").observe(.value, with: { (snapshot) in
                    let servicesArray = snapshot.children.allObjects as NSArray
                    if servicesArray.count > 0 {
                        
                        for service in servicesArray {
                            let serviceSnapshot = service as! DataSnapshot
                            if let serviceValue = serviceSnapshot.value as? NSDictionary {
                                if let name = serviceValue["name"] as? String {
                                    var detailDict = [String : Any]()
                                    detailDict["name"] = name
                                    self.detailArray.append(detailDict)
                                }
                            }
                        }
                        
                        let serviceDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesDetailViewController") as! ServicesDetailViewController
                        serviceDetailViewController.fromString = self.fromString
                        serviceDetailViewController.salonName = self.salonName
                        serviceDetailViewController.toString = self.toString
                        serviceDetailViewController.detailArray = self.detailArray
                        serviceDetailViewController.keyValue = self.keyValue
                        serviceDetailViewController.selectedIndex = self.segmentController.selectedSegmentIndex
                        
                        self.navigationController?.pushViewController(serviceDetailViewController, animated: true)
                    }
                })
            }
        } else {
            if keyValue != "" {
                let currentService = self.maleServicesArray[indexPath.item]
                ref.child("MERCHANT").child(keyValue).child("SERVICES/MALE").child(currentService).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let objects = snapshot.children.allObjects as? [DataSnapshot] {
                        if objects.count > 0 {
                            
                            for children in objects {
                                let serviceValue = children.value as! NSDictionary
                                let serviceName = serviceValue["name"] as! String
                                let servicePrice = serviceValue["price"] as! Int
                                let serviceDuration = serviceValue["duration"] as! Int
                                let serviceOldPrice = ((100 - self.discountValue) * servicePrice)/100
                                
                                let detailDict  : [String : Any] = [
                                    "name" : serviceName ,
                                    "price" : servicePrice,
                                    "duration" : serviceDuration,
                                    "new" :  serviceOldPrice
                                ]
                                self.detailArray.append(detailDict)
                            }
                            
                            let serviceDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesDetailViewController") as! ServicesDetailViewController
                            
                            serviceDetailViewController.selectedIndex = self.segmentController.selectedSegmentIndex
                            serviceDetailViewController.keyValue = self.keyValue
                            serviceDetailViewController.fromString = self.fromString
                            serviceDetailViewController.toString = self.toString
                            serviceDetailViewController.detailArray = self.detailArray
                            self.navigationController?.pushViewController(serviceDetailViewController, animated: true)
                        }
                    }
                })
            } else {
                let currentService = self.femaleServicesArray[indexPath.item]
                ref.child("ZALONIN/CATEGORY/MALE").child(currentService).child("SERVICES").observe(.value, with: { (snapshot) in
                    let servicesArray = snapshot.children.allObjects as NSArray
                    if servicesArray.count > 0 {
                        
                        for service in servicesArray {
                            let serviceSnapshot = service as! DataSnapshot
                            if let serviceValue = serviceSnapshot.value as? NSDictionary {
                                if let name = serviceValue["name"] as? String {
                                    var detailDict = [String : Any]()
                                    detailDict["name"] = name
                                    self.detailArray.append(detailDict)
                                }
                            }
                        }
                        
                        let serviceDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesDetailViewController") as! ServicesDetailViewController
                        serviceDetailViewController.selectedIndex = self.segmentController.selectedSegmentIndex
                        serviceDetailViewController.fromString = self.fromString
                        serviceDetailViewController.salonName = self.salonName
                        serviceDetailViewController.toString = self.toString
                        serviceDetailViewController.detailArray = self.detailArray
                        serviceDetailViewController.keyValue = self.keyValue
                        self.navigationController?.pushViewController(serviceDetailViewController, animated: true)
                    }
                })
            }
        }
    }
}

extension ServicesHomeViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBar.resignFirstResponder()
            if segmentController.selectedSegmentIndex == 0 {
                searchArray = femaleServicesArray
                tableView.reloadData()
            } else {
                searchArray = maleServicesArray
                tableView.reloadData()
            }
        } else {
            searchArray = []
            let searchText = searchBar.text?.lowercased()
            if segmentController.selectedSegmentIndex == 0 {
                for service in femaleServicesArray {
                    if service.lowercased().range(of: searchText!) != nil {
                        searchArray.append(service)
                    }
                }
            } else {
                for service in maleServicesArray {
                    if service.lowercased().range(of: searchText!) != nil {
                        searchArray.append(service)
                    }
                }
            }
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
}

