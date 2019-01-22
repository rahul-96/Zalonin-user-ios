//
//  FirebaseNetworkCalls.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 31/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreLocation

class FirebaseMethods {
    
    func getImageFromFirebase( _ completionHandler : @escaping(_ image : UIImage?, _  error : String?) -> Void){
        
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        let imageRef = storageRef.child("BOXOFFICESALON/IMAGE1.jpg")
        
        imageRef.getData(maxSize: 1 * 1024 * 014) { (data, error) in
            if error != nil {
                if data != nil {
                    let image = UIImage(data : data!)
                    completionHandler(image, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            } else {
                completionHandler(nil, error?.localizedDescription)
            }
        }
    }
    
    func cancelAppointment(appointment : [String : Any]){
        var currentAppointment = appointment
        currentAppointment["status"] = 6
        let id = currentAppointment["userid"] as! String
        let subId = String(id.prefix(6))
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        let path = "USER/\(UserDetails.userId)/REQUESTS/\(subId)/\(id)"
        
        ref.child(path).removeValue()
        ref.child(path).setValue(currentAppointment)
        
        let shopId = currentAppointment["shopid"] as! String
        let shopPath = "MERCHANT/\(shopId)/BOOKINGS/\(subId)/\(id)"
        
        ref.child(shopPath).removeValue()
        ref.child(shopPath).setValue(currentAppointment)
        
        ref.child(shopPath).updateChildValues(["status" : 6])
        ref.child(path).updateChildValues(["status" : 6])
    }
    
    
    func createNewUser(userId : String, username : String, userEmail : String, userNumber : String, userDate : String , completionHandler : @escaping (_ bool : Bool) -> Void){
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        
        let userDetailsDict = ["age": "",
                               "datejoined" : userDate,
                               "email" : userEmail,
                               "gender" : "",
                               "name" : username,
                               "phonenoe" : userNumber]
        
        let walletDetailsDict = ["points":0]
        
        let referDetailDict = ["references": 0 ,
                               "referred" : 1]
        
        var flag = 0
        
        ref.child("USER").observe(.value, with: { (snapshot) in
            let userArray = snapshot.children.allObjects as NSArray
            for user in userArray {
                let userSnapshot = user as! DataSnapshot
                let userKey = userSnapshot.key
                if userKey == userId {
                    flag = 1
                    UserDetails.userId = userId
                    UserDefaults.standard.set(userId, forKey: "user_id")
                    completionHandler(true)
                    return
                }
            }
            if flag == 0 {
                ref.child("USER").child(userId).child("REFER").setValue(referDetailDict)
                ref.child("USER").child(userId).child("WALLET").setValue(walletDetailsDict)
                ref.child("USER").child(userId).child("USERDETAILS").setValue(userDetailsDict)
                UserDefaults.standard.set(userId, forKey: "user_id")
                completionHandler(true)
            }
            UserDetails.userId = userId
        })
    }
    
    
    func fetchUserDetails(completionHandler : @escaping ( _ userName : String, _ userEmail : String,_ userGender : String,_ userNumber : String,_ references : String, _ request : Int, _ wallet : Int, _ birthDate : String) -> Void ){
        let id = UserDefaults.standard.value(forKey: "user_id")
        UserDetails.userId = id as! String
        
        let userId = UserDetails.userId
        var ref : DatabaseReference!
        ref = Database.database().reference()
        
        var requestCount = 0
        var wallet = 0
        
        ref.child("USER").child(userId).observe(.value, with: { (snapshot) in
            let referSnapshot = snapshot.childSnapshot(forPath: "REFER") as DataSnapshot
            let referValue = referSnapshot.value as! NSDictionary
            let references = referValue["references"] as! Int
            let referencesString = "\(references)"
            
            let userSnapshot = snapshot.childSnapshot(forPath: "USERDETAILS") as DataSnapshot
            let userValue = userSnapshot.value as! NSDictionary
            let userName = userValue["name"] as! String
            let userEmail = userValue["email"] as! String
            let userGender = userValue["gender"] as! String
            let userNumber = userValue["phonenoe"] as! String
            let birthDate = userValue["birth_date"] ?? ""
            
            let requestSnapshot = snapshot.childSnapshot(forPath: "REQUESTS") as DataSnapshot
            let requestArray = requestSnapshot.children.allObjects as NSArray
            for request in requestArray {
                let requestSubSnapshot = request as! DataSnapshot
                let requestSubArray = requestSubSnapshot.children.allObjects
                requestCount += requestSubArray.count
            }
            
            let walletSnapshot = snapshot.childSnapshot(forPath: "WALLET") as DataSnapshot
            let walletValue = walletSnapshot.value as! NSDictionary
            wallet = walletValue["points"] as! Int
            
            completionHandler(userName, userEmail, userGender, userNumber, referencesString, requestCount, wallet,birthDate as! String)
        })
    }
    
    func fetchAppointments(completionHandler : @escaping(_ detailArray : [[String: Any]]) -> Void){
        var reference : DatabaseReference!
        reference = Database.database().reference()
        let userId = UserDetails.userId
        
        var serviceArray : [[String : Any]] = []
        
        
        reference.child("USER").child(userId).child("REQUESTS").observeSingleEvent(of: .value) { (snapshot) in
            let requestArray = snapshot.children.allObjects as NSArray
            for request in requestArray {
                let requestSnapshot = request as! DataSnapshot
                let subrequestArray = requestSnapshot.children.allObjects as NSArray
                for subrequest in subrequestArray {
                    let subrequestSnapshot = subrequest as! DataSnapshot
                    if var subrequestValue = subrequestSnapshot.value as? [String : Any] {
                        subrequestValue["key"] = subrequestSnapshot.key
                        serviceArray.append(subrequestValue)
                    }
                }
            }
            
            completionHandler(serviceArray)
        }
        
    }
    
    func fetchAppointmentKeys(completionHandler : @escaping(_ detailArray : [String]) -> Void ) {
        var reference : DatabaseReference!
        reference = Database.database().reference()
        let userId = UserDetails.userId
        var serviceArray : [String] = []
        
        reference.child("USER").child(userId).child("REQUESTS").observe(.value, with: { (snapshot) in
            let requestArray = snapshot.children.allObjects as NSArray
            for request in requestArray {
                let requestSnapshot = request as! DataSnapshot
                let subrequestArray = requestSnapshot.children.allObjects as NSArray
                for subrequest in subrequestArray {
                    let subrequestSnapshot = subrequest as! DataSnapshot
                    let key = subrequestSnapshot.key
                    serviceArray.append(key)
                }
            }
            
            completionHandler(serviceArray)
        })
    }
    
    func saveUserDetails(name : String, mobileNumber : String, birthDate : String, gender : String){
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        let path = "USER/\(UserDetails.userId)/USERDETAILS"
        ref.child(path).observe(.value) { (snapshot) in
            if var value = snapshot.value as? [String : Any] {
                value["name"] = name
                value["gender"] = gender
                value["phonenoe"] = mobileNumber
                value["birth_date"] = birthDate
                
                ref.child(path).setValue(value)
            }
        }
    }
    
    func fetchSalon(_ shopId : String , completionHandler : @escaping (_ merchantDict : [String:AnyObject]) -> Void) {
        
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("MERCHANT").child(shopId).observeSingleEvent(of: .value) { (merchantSnapshot) in
            
            
            var merchantDict = [String : AnyObject]()
            let valueDetails = merchantSnapshot.childSnapshot(forPath: "SHOPDETAILS")
            if let value = valueDetails.value as? NSDictionary {
                let name = value["shopname"] as! String
                let number = value["phonenoe"] as! String
                
                merchantDict["name"] = name as AnyObject
                merchantDict["number"] = number as AnyObject
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
            completionHandler(merchantDict)
            
        }
    }
    
    func fetchChatUsers(completionHandler : @escaping ( _ usersArray : [String], _ nameArray : [String]) -> Void) {
        
        var userArray : [String] = []
        var nameArray : [String] = []
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("ZALONIN/CHAT_USER").observe(.value) { (snapshot) in
            let childArray = snapshot.children.allObjects as NSArray
            for child in childArray {
                let childSnapshot = child as! DataSnapshot
                let childString = childSnapshot.key
                userArray.append(childString)
            }
            
        }
        
        ref.child("ZALONIN/CHAT_PROFILE").observe(.value) { (snapshot) in
            let childArray = snapshot.children.allObjects as NSArray
            for child in childArray {
                let childSnapshot = child as! DataSnapshot
                if let childValue = childSnapshot.value as? NSDictionary {
                    let name = childValue["name"] as! String
                    nameArray.append(name)
                }
            }
            completionHandler(userArray,nameArray)

        }
    }
    
    func fetchStoreDetails(completionHandler : @escaping(_ data : [[String : Any]], _ size : [[String : Any]]) -> Void) {
        var ref : DatabaseReference
        ref = Database.database().reference()
        let childAddress = "ZALONIN/STORE/OTHERS"
        
        var dataDict : [[String : Any]] = []
        var sizeDict : [[String : Any]] = []
        
        ref.child(childAddress).observe(.value) { (snapshot) in
            let array = snapshot.children.allObjects as NSArray
            for store in array {
                let storeSnapshot = store as! DataSnapshot
                let detailSnapshot = storeSnapshot.childSnapshot(forPath: "DETAILS") 
                if var detailValue = detailSnapshot.value as? [String : Any] {
                    detailValue["category"] = "OTHERS"
                    dataDict.append(detailValue)
                }
                
                let sizeSnapshot = storeSnapshot.childSnapshot(forPath: "SIZE")
                if var sizeValue = sizeSnapshot.value as? [String : Any] {
                    sizeValue["category"] = "OTHERS"
                    sizeDict.append(sizeValue)
                }
            }
            completionHandler(dataDict,sizeDict)
        }
    }
    
    func fetchLikedProducts(completionHandler : @escaping(_ data : [[String : Any]]) -> Void) {
        let path = "USER/\(UserDetails.userId)/FAV"
        
        var dictArray : [[String : Any]] = []
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child(path).observe(.value) { (snapshot) in
            let array = snapshot.children.allObjects as NSArray
            for child in array {
                let childSnapshot = child as! DataSnapshot
                if let childValue = childSnapshot.value as? [String : Any] {
                    dictArray.append(childValue)
                }
            }
            completionHandler(dictArray)
        }
    }
    
    func createMessage(message : [String : Any], chatUser : String) {
        let userId = UserDefaults.standard.value(forKey: "user_id") as! String
        UserDetails.userId = userId
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        var childAddress = "USER/\(UserDetails.userId)/CHATS/\(chatUser)"
        
        let dateString = message["date"] as! String
        childAddress.append("/\(dateString)")
        
        ref.child(childAddress).setValue(message)
    }
    
    
    func fetchStylist(_ shopId : String , completionHandler : @escaping (_ merchantDict : [String:AnyObject]) -> Void) {
        
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("STYLIST").child(shopId).observeSingleEvent(of: .value) { (merchantSnapshot) in
            
            
            var merchantDict = [String : AnyObject]()
            let valueDetails = merchantSnapshot.childSnapshot(forPath: "STYLISTDETAIL")
            if let value = valueDetails.value as? NSDictionary {
                let name = value["name"] as! String
                let number = value["phonenoe"] as! String
                
                merchantDict["name"] = name as AnyObject
                merchantDict["number"] = number as AnyObject
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
            completionHandler(merchantDict)
            
        }
    }
    
    func fetchAdsCount(){
        var ref : DatabaseReference
        ref = Database.database().reference()
        ref.child("ZALONIN/ADS/ADS1").observeSingleEvent(of: .value) { (snapshot) in
            if let snapshotDict = snapshot.value as? NSDictionary {
                let value = snapshotDict["total"] as! Int
                UserDetails.ads1Count = value
            }
        }
        
        ref.child("ZALONIN/ADS/ADS2").observeSingleEvent(of: .value) { (snapshot) in
            if let snapshotDict = snapshot.value as? NSDictionary {
                let value = snapshotDict["total"] as! Int
                UserDetails.ads2Count = value
            }
        }
    }
    
    func removeProductFromCart(dict : [String : Any]) {
        var id = dict["id"] as! String
        var size = dict["size"] as! String
        size = size.uppercased()
        id += size
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        let cartPath = "USER/\(UserDetails.userId)/CART/\(id)"
        
        ref.child(cartPath).removeValue()
    }
    
    func moveProductToFav(dict : [String : Any]){
        removeProductFromCart(dict: dict)
        let id = dict["id"] as! String
        let favPath = "USER/\(UserDetails.userId)/FAV/\(id)"
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        ref.child(favPath).setValue(dict)
    }
    
    func addProductToCart(id: String, dict: [String : Any]){
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("USER/\(UserDetails.userId)/CART/\(id)").setValue(dict)
    }
    
    func saveAddress(dict : [String : Any]){
        let addressPath = "USER/\(UserDetails.userId)/ADDRESS"
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child(addressPath).childByAutoId().setValue(dict)
    }
    
    func placeStoreOrder(detailDict: [String : Any]){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddd"
        let date = Date()
        let pathSubString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyMMddHHmmss"
        let id = dateFormatter.string(from: date)
        
        var orderDict = detailDict
        orderDict["id"] = id
        
        let pathString = "ZALONIN/STORE_REQUEST/\(pathSubString)/\(id)"
        
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child(pathString).setValue(orderDict)
        
        let cartPath = "USER/\(UserDetails.userId)/CART"
        ref.child(cartPath).removeValue()
    }
    
    func fetchBlogs(completionHandler : @escaping(_ data : [[String : Any]]) -> Void){
        var ref : DatabaseReference
        var dictArray : [[String : Any]] = []
        
        ref = Database.database().reference()
        ref.child("ZALONIN/BLOGS").observeSingleEvent(of: .value) { (snapshot) in
            let snapshotArray = snapshot.children.allObjects as NSArray
            for snap in snapshotArray {
                
                let subSnapshot = snap as! DataSnapshot
                let detailSnapshot = subSnapshot.childSnapshot(forPath: "DETAILS") 
                if var detailDict = detailSnapshot.value as? [String : Any] {
                    let viewSnapshot = subSnapshot.childSnapshot(forPath: "VIEWS") 
                    if let viewDict = viewSnapshot.value as? [String : Any] {
                        let viewKeys = viewDict.keys.count
                        detailDict["views"] = viewKeys
                        dictArray.append(detailDict)

                    }
                }
            }
            completionHandler(dictArray)
        }
    }
    
    func likeProduct(id : String, dict : [String : Any]) {
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("USER/\(UserDetails.userId)/FAV/\(id)").setValue(dict)
    }
    
    func unlikeProduct(id : String) {
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("USER/\(UserDetails.userId)/FAV/\(id)").removeValue()
    }
    
    func fetchVlogs(completionHandler : @escaping(_ data : [[String : Any]]) -> Void){
        var ref : DatabaseReference
        var dictArray : [[String : Any]] = []
        
        ref = Database.database().reference()
        ref.child("ZALONIN/VLOGS").observeSingleEvent(of: .value) { (snapshot) in
            let snapshotArray = snapshot.children.allObjects as NSArray
            for snap in snapshotArray {
                
                let subSnapshot = snap as! DataSnapshot
                let detailSnapshot = subSnapshot.childSnapshot(forPath: "DETAILS")
                if var detailDict = detailSnapshot.value as? [String : Any] {
                    let viewSnapshot = subSnapshot.childSnapshot(forPath: "VIEWS")
                    if let viewDict = viewSnapshot.value as? [String : Any] {
                        let viewKeys = viewDict.keys.count
                        detailDict["views"] = viewKeys
                        dictArray.append(detailDict)
                        
                    }
                }
            }
            completionHandler(dictArray)
        }
    }
}
