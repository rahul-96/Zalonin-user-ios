//
//  AppDelegate.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 08/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import GooglePlaces
import Reachability
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let gregorian = Calendar(identifier: .gregorian)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GMSPlacesClient.provideAPIKey("AIzaSyDaD8-puD638CQswWdNSZper8aLrfzT-c0")
        
        let firstOpen = UserDefaults.standard.value(forKey: "first_open") as? Bool
        
        if let _ = firstOpen {
            let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController") as! SidePanelViewController
            self.window?.rootViewController = sidePanelViewController
        } else {
            let splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
                self.window?.rootViewController = splashViewController
        }

        
        UIApplication.shared.statusBarStyle = .lightContent
       
        //userNotification Authorisation
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (accepted, error) in
            if !accepted {
                print("Notification Denied")
            }
            else {
                UNUserNotificationCenter.current().delegate = self
            }
        }
        
        return true
    }
    
    
    func scheduleNotifications(date : Date, message : String, id : String) {
        
        let date = date
        let previousDate = gregorian.date(byAdding: .minute, value: -30, to: date)
        var dayComponents = Calendar.current.dateComponents([.month,.day,.year], from: previousDate!)
        let timeComponents = Calendar.current.dateComponents([.hour , .minute], from: previousDate!)
        
        dayComponents.second = 0
        dayComponents.minute = timeComponents.minute
        dayComponents.hour = timeComponents.hour
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.sound = UNNotificationSound.default()
        
        content.subtitle = message
        
        let notif_identifier = id
        
        let request = UNNotificationRequest(identifier: notif_identifier, content: content, trigger: trigger)
        
        //schedule new notifications
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("Error occured during notification")
            } else {
                print("Notification created")
            }
        }
    }
    
    func scheduleBookingNotifications(date : Date, time : Int, id : String) {
        
        let date = date
        let previousDate = gregorian.date(byAdding: .minute, value: time, to: date)
        var dayComponents = Calendar.current.dateComponents([.month,.day,.year], from: previousDate!)
        let timeComponents = Calendar.current.dateComponents([.hour , .minute], from: previousDate!)
        
        dayComponents.second = 0
        dayComponents.minute = timeComponents.minute
        dayComponents.hour = timeComponents.hour
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Thank You"
        content.sound = UNNotificationSound.default()
        
        content.subtitle = "Please share your feedback with us"
        
        let notif_identifier = id
        
        let request = UNNotificationRequest(identifier: notif_identifier, content: content, trigger: trigger)
        
        //schedule new notifications
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("Error occured during notification")
            } else {
                print("Notification created")
            }
        }
    }
       
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
   
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        ReachabilityManager.shared.stopMonitoring()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
     ReachabilityManager.shared.startMonitoring()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

