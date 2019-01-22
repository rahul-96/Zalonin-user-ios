//
//  UserDetails.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 09/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct UserDetails {
    static var userId : String = ""
    static var references : String = ""
    static var userName : String = ""
    static var userEmail : String = ""
    static var userNumber : String = ""
    static var moneySpent : String = ""
    static var requestSent : String = ""
    static var signedIn : Bool = false
    static var userLocation  = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    static var userBirthDate : String = ""
    static var userGender : String = ""
    
    static var distanceFilter : Double = 5.0
    static var stylistDistanceFilter : Double = 50.0
    static var sortByIndex : Int = -1
    static var costByIndex : Int = -1
    
    static var selectedServicesArray : [[String : Any]] = []
    static var selectedServicesCount = 0
    
    static var resetFilters : Bool = false
    static var rated : Bool = false
    static var openNow : Bool = false
    
    static var salonSelected : Bool = false
    static var stylistSelected : Bool = false
    
    static var ads1Count : Int = 0
    static var ads2Count : Int = 1
}
