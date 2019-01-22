//
//  HomeTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 22/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseDatabase
import MapKit
import Kingfisher

class HomeTableViewController: UITableViewController {
    
    @IBOutlet weak var headerCollectionView : UICollectionView!
    @IBOutlet weak var headerCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var searchBar : UISearchBar!
    
    //    let bannerArray = ["banner-1", "banner-2"]
    var firebaseImage : UIImage = UIImage()
    var salonArray : [[String : Any]] = []
    var searchArray : [[String : Any]] = []
    var imageArray : [[String]] = []
   
    var priceString : String = "price"
    var maleStylistArray : [[String : Any]] = []
    
    var selectedIndex : Int = 0
    var selectedService : String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDetails.salonSelected {
            self.navigationItem.title = "Salons"
        }else {
            self.navigationItem.title = "Stylist"
        }
    }
    
    override func viewDidLoad() {
        setupView()
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "Search Salons"
        searchBar.tintColor = Colors.whiteColor
        if UserDetails.salonSelected {
            UserDetails.selectedServicesCount = 0
            UserDetails.selectedServicesArray = []
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDetails.salonSelected {
            UserDetails.selectedServicesCount = 0
            UserDetails.selectedServicesArray = []
        }
        
        if salonArray.count > 0 {
            self.searchArray = []
            
            if UserDetails.salonSelected {
                for salon in self.salonArray {
                    if let distance = salon["distance"] as? Double {
                        if distance <= UserDetails.distanceFilter {
                            self.searchArray.append(salon)
                        }
                    }
                }
            } else {
                for salon in self.salonArray {
                    if let distance = salon["distance"] as? Double {
                        if distance <= UserDetails.stylistDistanceFilter {
                            self.searchArray.append(salon)
                        }
                    }
                }
            }
            
            if UserDetails.resetFilters == true {
                UserDetails.distanceFilter = 5.0
                UserDetails.sortByIndex = -1
                UserDetails.costByIndex = -1
                UserDetails.resetFilters = false
            } else if UserDetails.rated == true {
                searchArray = searchArray.filter({
                    let rating = $0["rating"] as! CGFloat
                    return rating > 3.5
                })
                
            } else if UserDetails.openNow == true {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                searchArray = searchArray.filter({
                    let fromString = $0["from"] as! String
                    let toString = $0["to"] as! String
                    
                    let from = dateFormatter.date(from: fromString)
                    let to = dateFormatter.date(from: toString)
                    
                    let currentTimeString = dateFormatter.string(from: Date())
                    let currentTime = dateFormatter.date(from: currentTimeString)
                    
                    if currentTime! >= from! && currentTime! <= to! {
                        return true
                    } else {
                        return false
                    }
                })
            }
            
            
            if UserDetails.sortByIndex == 0 {
                self.searchArray.sort(by: { (s1, s2) -> Bool in
                    let distance1 = s1["distance"] as! Double
                    let distance2 = s2["distance"] as! Double
                    return distance1 < distance2
                })
            } else if UserDetails.sortByIndex == 1 {
                self.searchArray.sort(by: { (s1, s2) -> Bool in
                    let rating1 = s1["rating"] as! CGFloat
                    let rating2 = s2["rating"] as! CGFloat
                    return rating1 > rating2
                })
            } else if UserDetails.sortByIndex == 2 {
                self.searchArray.sort(by: { (s1, s2) -> Bool in
                    let price1 = s1[priceString] as! CGFloat
                    let price2 = s2[priceString] as! CGFloat
                    
                    
                    return price1 < price2
                })
            } else if UserDetails.sortByIndex == 3 {
                self.searchArray.sort(by: { (s1, s2) -> Bool in
                    let price1 = s1["users"] as! Int
                    let price2 = s2["users"] as! Int
                    return price1 < price2
                })
            }
            
            
            var tempArray : [[String : Any]] = []
            
            if UserDetails.costByIndex == 0 {
                for salon in searchArray {
                    if let price = salon[priceString] as? CGFloat {
                        if price >= 0.0 && price < 500.0 {
                            tempArray.append(salon)
                        }
                    }
                }
                searchArray = tempArray
            } else if UserDetails.costByIndex == 1 {
                for salon in searchArray {
                    if let price = salon[priceString] as? CGFloat {
                        if price >= 500.0 && price < 1000.0 {
                            tempArray.append(salon)
                        }
                    }
                }
                searchArray = tempArray
            } else if UserDetails.costByIndex == 2 {
                for salon in searchArray {
                    if let price = salon[priceString] as? CGFloat {
                        if price >= 1000.0 && price < 2000.0 {
                            tempArray.append(salon)
                        }
                    }
                }
                searchArray = tempArray
            } else if UserDetails.costByIndex == 3{
                for salon in searchArray {
                    if let price = salon[priceString] as? CGFloat {
                        if price >= 2000.0  {
                            tempArray.append(salon)
                        }
                    }
                }
                searchArray = tempArray
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    func setupView(){
        
        let activityView : UIActivityIndicatorView = UIActivityIndicatorView()
        activityView.activityIndicatorViewStyle = .whiteLarge
        activityView.center.y = view.center.y
        activityView.center.x = self.view.frame.width/2 - 10
        activityView.frame.size = CGSize(width: 20, height: 20)
        activityView.isHidden = true
        self.view.addSubview(activityView)
        
        tableView.backgroundColor = Colors.grayColor2
        tableView.tableFooterView?.backgroundColor = Colors.grayColor2
        setupTableView()
        setupCollectionView()
        var ref : DatabaseReference!
        ref = Database.database().reference()
        
        activityView.startAnimating()
        activityView.isHidden = false
        
        if UserDetails.salonSelected {
            ref.child("MERCHANT").observeSingleEvent(of: .value) { (snapshot) in
                let merchants = snapshot.children.allObjects as NSArray
                for merchant in merchants {
                    let merchantSnapshot = merchant as! DataSnapshot
                    
                    var merchantDict = [String : AnyObject]()
                    
                    
                    let valueDetails = merchantSnapshot.childSnapshot(forPath: "SHOPDETAILS")
                    if let value = valueDetails.value as? NSDictionary {
                        let name = value["shopname"] as! String
                        let number = value["phonenoe"] as! String
                        let description = value["description"] ?? ""
                        
                        merchantDict["name"] = name as AnyObject
                        merchantDict["number"] = number as AnyObject
                        merchantDict["description"] = description as AnyObject
                    }
                    
                    let locationDetails = merchantSnapshot.childSnapshot(forPath: "LOCATION")
                    if let location = locationDetails.value as? NSDictionary {
                        let name = location["address"] as! String
                        let longitude = location["lng"] as! CGFloat
                        let latitude = location["lat"] as! CGFloat
                        
                        merchantDict["lat"] = latitude as AnyObject
                        merchantDict["address"] = name as AnyObject
                        merchantDict["lng"] = longitude as AnyObject
                        
                        
                        let loc1 = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                        let loc2 = CLLocation(latitude: UserDetails.userLocation.latitude, longitude: UserDetails.userLocation.longitude)
                        
                        let distance = (loc1.distance(from: loc2))/1000
                        
                        merchantDict["distance"] = distance as AnyObject
                        
                    }
                    
                    let ratingDetails = merchantSnapshot.childSnapshot(forPath: "RATING")
                    if let ratingValue = ratingDetails.value as? NSDictionary {
                        let stars = ratingValue["stars"] as! Int
                        let users = ratingValue["users"] as! Int
                        let rating : CGFloat = CGFloat(stars/users)
                        merchantDict["rating"] = rating as AnyObject
                        merchantDict["users"] = users as AnyObject
                    } else {
                        merchantDict["rating"] = 5.0 as AnyObject
                        merchantDict["users"] = 0 as AnyObject
                    }
                    
                    let priceDetails = merchantSnapshot.childSnapshot(forPath: "AVGPRICE")
                    if let priceValue = priceDetails.value as? NSDictionary {
                        let services = priceValue["nservices"] as! Int
                        let totalPrice = priceValue["totalprice"] as! Int
                        let price = CGFloat(totalPrice/services)
                        merchantDict["price"] = price as AnyObject
                    }
                    
                    
                    let timeDetails = merchantSnapshot.childSnapshot(forPath: "TIMINGS")
                    if let timeValue = timeDetails.value as? NSDictionary {
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
                        
                        merchantDict["from"] = fromString as AnyObject
                        merchantDict["to"] = toString as AnyObject
                    }
                    
                    
                    merchantDict["image"] = merchantSnapshot.key as AnyObject
                    self.salonArray.append(merchantDict)
                }
                activityView.stopAnimating()
                activityView.isHidden = true
                
                
                for salon in self.salonArray {
                    if (salon["distance"] as? Double) != nil {
                        let distance = salon["distance"] as! Double
                        if distance <= 5 {
                            self.searchArray.append(salon)
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
        } else {
            ref.child("STYLIST").observe(.value, with: { (snapshot) in
                let merchants = snapshot.children.allObjects as NSArray
                for merchant in merchants {
                    var merchantDict : [String : Any] = [String : Any]()
                    let merchantSnapshot = merchant as! DataSnapshot
                    
                    let details = merchantSnapshot.childSnapshot(forPath: "STYLISTDETAIL")
                    
                    if let detailsValue = details.value as? NSDictionary{
                        let email = detailsValue["email"] ?? ""
                        let name = detailsValue["name"] ?? ""
                        let number = detailsValue["number"] ?? ""
                        let description = detailsValue["description"] ?? ""
                        
                        
                        merchantDict["email"] = email as! String
                        merchantDict["name"] = name as! String
                        merchantDict["number"] = number as! String
                        merchantDict["id"] = merchantSnapshot.key
                        merchantDict["description"] = description
                    }
                    
                    
                    let discount = merchantSnapshot.childSnapshot(forPath: "DISCOUNT")
                    
                    if let discountValue = discount.value as? NSDictionary{
                        let discount = discountValue["discount"] ?? 0
                        let zaloninDiscount = discountValue["zalonindiscount"] ?? 0
                        
                        merchantDict["discount"] = discount as! Int
                        merchantDict["zaloninDiscount"] = zaloninDiscount as! Int
                    }
                    
                    let services = merchantSnapshot.childSnapshot(forPath: "SERVICES")
                    let femaleServices = services.childSnapshot(forPath: "FEMALE")
                    let maleServices = services.childSnapshot(forPath: "MALE")
                    
                    var femaleStylistArray : [[String : Any]] = []
                    var maleStylistArray : [[String : Any]] = []
                    
                    let  femaleSnapArray = femaleServices.children.allObjects as NSArray
                    for femaleService in femaleSnapArray {
                        let femaleSnapshot = femaleService as! DataSnapshot
                        let femaleArray = femaleSnapshot.children.allObjects as NSArray
                        for femaleSubService in femaleArray {
                            let femaleSubSnapshot = femaleSubService as! DataSnapshot
                            let femaleSubValue = femaleSubSnapshot.value as! NSDictionary
                            let duration = femaleSubValue["duration"] ?? 0
                            let name = femaleSubValue["name"] ?? ""
                            let price = femaleSubValue["price"] ?? 0
                            
                            var femaleDict = [String : Any]()
                            femaleDict["duration"] = duration
                            femaleDict["name"] = name
                            femaleDict["price"] = price
                            femaleStylistArray.append(femaleDict)
                        }
                    }
                    
                    merchantDict["females"] = femaleStylistArray
                    
                    
                    let  maleSnapArray = maleServices.children.allObjects as NSArray
                    for maleService in maleSnapArray {
                        let maleSnapshot = maleService as! DataSnapshot
                        let maleArray = maleSnapshot.children.allObjects as NSArray
                        for maleSubService in maleArray {
                            let maleSubSnapshot = maleSubService as! DataSnapshot
                            let maleSubValue = maleSubSnapshot.value as! NSDictionary
                            let duration = maleSubValue["duration"] ?? 0
                            let name = maleSubValue["name"] ?? ""
                            let price = maleSubValue["price"] ?? 0
                            
                            var maleDict = [String : Any]()
                            maleDict["duration"] = duration
                            maleDict["name"] = name
                            maleDict["price"] = price
                            maleStylistArray.append(maleDict)
                        }
                    }
                    
                    merchantDict["males"] = maleStylistArray
                    
                    
                    let locationDetails = merchantSnapshot.childSnapshot(forPath: "LOCATION")
                    
                    if let location = locationDetails.value as? NSDictionary {
                        let name = location["address"] as! String
                        let longitude = location["lng"] as! CGFloat
                        let latitude = location["lat"] as! CGFloat
                        
                        merchantDict["lat"] = latitude as AnyObject
                        merchantDict["address"] = name as AnyObject
                        merchantDict["lng"] = longitude as AnyObject
                        
                        
                        let loc1 = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                        let loc2 = CLLocation(latitude: UserDetails.userLocation.latitude, longitude: UserDetails.userLocation.longitude)
                        
                        let distance = (loc1.distance(from: loc2))/1000
                        
                        merchantDict["distance"] = distance as AnyObject
                        
                    }
                    
                    let ratingDetails = merchantSnapshot.childSnapshot(forPath: "RATING")
                    if let ratingValue = ratingDetails.value as? NSDictionary {
                        let stars = ratingValue["stars"] as! Int
                        let users = ratingValue["users"] as! Int
                        let rating : CGFloat = CGFloat(stars/users)
                        merchantDict["rating"] = rating as AnyObject
                        merchantDict["users"] = users as AnyObject
                    } else {
                        merchantDict["rating"] = 5.0 as AnyObject
                        merchantDict["users"] = 0 as AnyObject
                    }
                    
                    let priceDetails = merchantSnapshot.childSnapshot(forPath: "AVGPRICE")
                    if let priceValue = priceDetails.value as? NSDictionary {
                        let services = priceValue["nservices"] as! Int
                        let totalPrice = priceValue["totalprice"] as! Int
                        let price = CGFloat(totalPrice/services)
                        merchantDict["price"] = price as AnyObject
                    }
                    
                    
                    let timeDetails = merchantSnapshot.childSnapshot(forPath: "TIMINGS")
                    if let timeValue = timeDetails.value as? NSDictionary {
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
                        
                        merchantDict["from"] = fromString as AnyObject
                        merchantDict["to"] = toString as AnyObject
                    }
                    
                    
                    merchantDict["image"] = merchantSnapshot.key as AnyObject
                    self.salonArray.append(merchantDict)
                }
                activityView.stopAnimating()
                activityView.isHidden = true
                
                let service = UserDetails.selectedServicesArray.first
                let name = service!["name"] as! String
                self.selectedService = name
                
                if self.selectedIndex == 0 {
                    for salon in self.salonArray {
                        let femaleStylistArray = salon["females"] as! [[String : Any]]
                        for female in femaleStylistArray {
                            let name = female["name"] as! String
                            if name.lowercased() == self.selectedService.lowercased() {
                                self.searchArray.append(salon)
                            }
                        }
                    }
                    self.tableView.reloadData()
                    
                } else {
                    for salon in self.salonArray {
                        let maleStylistArray = salon["males"] as! [[String : Any]]
                        for male in maleStylistArray {
                            let name = male["name"] as! String
                            if name.lowercased() == self.selectedService.lowercased() {
                                self.searchArray.append(salon)
                            }
                        }
                    }
                    self.tableView.reloadData()
                    
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        let salonNib = UINib(nibName: "SalonTableViewCell", bundle: nil)
        tableView.separatorStyle = .none
        tableView.register(salonNib, forCellReuseIdentifier: "salonCell")
        tableView.clipsToBounds = true
        tableView.tableHeaderView?.backgroundColor = Colors.grayColor3
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let salonCell = tableView.dequeueReusableCell(withIdentifier: "salonCell", for: indexPath) as! SalonTableViewCell
        salonCell.selectionStyle = .none
        salonCell.backgroundColor = UIColor.darkGray
        
        let salon = searchArray[indexPath.item]
        let salonName = salon["name"] as! String
        let rating = salon["rating"] as! CGFloat
        
        salonCell.salonLabel.text = salonName.uppercased()
        let address = salon["address"] ?? ""
        var addressString : String = ""
        let subStrings = (address as! String).split(separator: ",")
        if subStrings.count > 3 {
            addressString = subStrings[2] + ", " + subStrings[3]
        }
        
        salonCell.locationLabel.text = String(addressString)
        salonCell.ratingLabel.text = String("\(rating)".prefix(3))
        
        if let salonImage = salon["image"] as? String {
            let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
            let storageRef = storage.reference()
            
            let childLocation = salonImage + "/IMAGE1.jpg"
            let imageRef = storageRef.child(childLocation)
            
            
            imageRef.downloadURL { (url, error) in
                if error != nil {
                    print("image error")
                } else {
                    let imageURL = url!
                    
                    salonCell.salonImageView.image = UIImage(named : "salon")
                    
                    
                    DispatchQueue.global().async {
                        do {
                            let data = try Data(contentsOf: imageURL)
                            let image = UIImage(data : data)
                            if image != nil {
                                DispatchQueue.main.async {
                                    salonCell.salonImageView.image = image
                                }
                            }
                        } catch {
                            
                        }
                    }
                    
                }
            }
        }
        let distance = salon["distance"] as? Double
        if distance != nil {
            salonCell.distanceLabel.text = String("\(distance!)".prefix(4)) + " KM"
        } else {
            salonCell.distanceLabel.text = ""
        }
        
        if UserDetails.stylistSelected {
            var priceInt : Int = 0
            var serviceOldPrice : Int = 0
            
            
            if self.selectedIndex == 0 {
                let femaleStylistArray = salon["females"] as! [[String : Any]]
                
                let femaleService = femaleStylistArray.first
                priceInt = femaleService!["price"] as! Int
                let discount = salon["discount"] as! Int
                serviceOldPrice = ((100 - discount) * priceInt)/100
                
                let price = "₹ \(priceInt)"
                
                let attributedString = NSMutableAttributedString(string: price)
                attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
                
                salonCell.oldPriceLabel.attributedText = attributedString
                salonCell.newPriceLabel.text = "₹ \(serviceOldPrice)"
            } else {
                let maleStylistArray = salon["males"] as! [[String : Any]]
                
                let maleService = maleStylistArray.first
                priceInt = maleService!["price"] as! Int
                let discount = salon["discount"] as! Int
                serviceOldPrice = ((100 - discount) * priceInt)/100
                
                let price = "₹ \(priceInt)"
                
                let attributedString = NSMutableAttributedString(string: price)
                attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
                
                salonCell.oldPriceLabel.attributedText = attributedString
                salonCell.newPriceLabel.text = "₹ \(serviceOldPrice)"
            }
        }
        
        salonCell.bookNowButton.tag = indexPath.item
        salonCell.bookNowButton.addTarget(self, action: #selector(bookNowTapped), for: .touchUpInside)
        return salonCell
    }
    
    
    
    @objc func viewTapped(tag : Int){
        
        let cell = tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as! SalonTableViewCell
        let salonProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SalonProfileViewController") as! SalonProfileViewController
        
        let salon = self.searchArray[tag]
        
        if let lat = salon["lat"] as? CGFloat {
            salonProfileViewController.lat = lat
        }
        
        if let lng = salon["lng"] as? CGFloat {
            salonProfileViewController.lng = lng
        }
        
        let description = salon["description"] as! String
        let salonImage = salon["image"] as! String
        let number = salon["number"] as! String
        let address = salon["address"] ?? ""
        let name = salon["name"] as! String
        let fromString = salon["from"] as! String
        let toString = salon["to"] as! String
        
        salonProfileViewController.toString = toString
        salonProfileViewController.fromString = fromString
        salonProfileViewController.salonDescription = description
        salonProfileViewController.keyValue = salonImage
        salonProfileViewController.number = number
        
        salonProfileViewController.locationText = address as! String
        salonProfileViewController.profileText = name
        
        self.navigationController?.pushViewController(salonProfileViewController, animated: true)
    }
    
    @objc func bookNowTapped(sender : UIButton){
        
        let tag = sender.tag
        
        if UserDetails.salonSelected {
            let salon = self.searchArray[tag]
            let image = salon["image"] as! String
            let fromString = salon["from"] as! String
            let toString = salon["to"] as! String
            let name = salon["name"] as! String
            
            
            let servicesHomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesHomeViewController") as! ServicesHomeViewController
            servicesHomeViewController.keyValue = image
            servicesHomeViewController.fromString = fromString
            servicesHomeViewController.toString = toString
            servicesHomeViewController.salonName = name
            self.navigationController?.pushViewController(servicesHomeViewController, animated: true)
        } else {
            
            let stylist = self.searchArray[tag]
            let fromString = stylist["from"] as! String
            let toString = stylist["to"] as! String
            let name = stylist["name"] as! String
            let keyValue = stylist["id"] as! String
            
            let dateViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DateViewController") as! DateViewController
            
            var priceInt : Int = 0
            var serviceOldPrice : Int = 0
            var duration : Int = 0
            
            
            if selectedIndex == 0 {
                let femaleStylistArray = stylist["females"] as! [[String : Any]]
                
                let femaleService = femaleStylistArray.first
                priceInt = femaleService!["price"] as! Int
                let discount = stylist["discount"] as! Int
                duration = femaleService!["duration"] as! Int
                serviceOldPrice = ((100 - discount) * priceInt)/100
            } else {
                let maleStylistArray = stylist["males"] as! [[String : Any]]
                
                let maleService = maleStylistArray.first
                priceInt = maleService!["price"] as! Int
                let discount = stylist["discount"] as! Int
                duration = maleService!["duration"] as! Int
                
                serviceOldPrice = ((100 - discount) * priceInt)/100
            }
            
            
            var service = UserDetails.selectedServicesArray.first
            UserDetails.selectedServicesArray = []
            
            service!["duration"] = duration
            service!["new"] =  priceInt
            service!["price"] = serviceOldPrice
            
            UserDetails.selectedServicesArray = [service!]
            
            dateViewController.fromString = fromString
            dateViewController.toString = toString
            dateViewController.salonName = name
            dateViewController.keyValue = keyValue
            self.navigationController?.pushViewController(dateViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewTapped(tag: indexPath.item)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
    
}

//MARK: CollectionView
extension HomeTableViewController {
    func setupCollectionView(){
        
        let width : CGFloat = UIScreen.main.bounds.width
        let itemSize : CGSize = CGSize(width: width, height: 150)
        headerCollectionViewFlowLayout.itemSize = itemSize
        headerCollectionViewFlowLayout.minimumLineSpacing = 0.0
        headerCollectionViewFlowLayout.minimumInteritemSpacing = 0.0
        headerCollectionView.isPagingEnabled = true
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        headerCollectionView.backgroundColor = UIColor.gray
    }
}

extension HomeTableViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //todo
    }
}

extension HomeTableViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserDetails.ads1Count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let headerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as! HomeCollectionViewCell
        
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        
        let childLocation = "ADS1/IMAGE\(indexPath.item + 1).jpg"
        let imageRef = storageRef.child(childLocation)
        
        if headerCollectionViewCell.salonImageView.image == UIImage(named : "salon") {
            imageRef.downloadURL { (url, error) in
                if error == nil {
                    headerCollectionViewCell.salonImageView.sd_setImage(with: url, completed: nil)
                } else {
                    headerCollectionViewCell.salonImageView.image = UIImage(named : "salon")
                }
            }
        }
        
        return headerCollectionViewCell
    }
}

extension HomeTableViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchArray = []
        if searchBar.text == "" {
            searchArray = salonArray
            tableView.reloadData()
        } else {
            let searchText = searchBar.text?.lowercased()
            for service in salonArray {
                let name = service["name"] as? String ?? ""
                if name.lowercased().range(of: searchText!) != nil {
                    self.searchArray.append(service)
                }
            }
            self.tableView.reloadData()
        }
        self.searchBar.resignFirstResponder()
    }
}
