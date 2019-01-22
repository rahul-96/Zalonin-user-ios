//
//  LoginOnboardingViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 13/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import SWRevealViewController
import UserNotifications

class LoginOnboardingViewController: UIViewController {
    
    @IBOutlet weak var sideMenuButton : UIBarButtonItem!
    @IBOutlet weak var scrollView : UIScrollView!
    
    
    override func viewDidLoad() {
        
        UserDefaults.standard.set(true, forKey: "first_open")
        
        FirebaseMethods().fetchAdsCount()
        super.viewDidLoad()
       
        
        let signedIn = UserDefaults.standard.value(forKey: "signedIn") as? Bool
        if signedIn != nil {
            UserDetails.signedIn = signedIn!
            if signedIn! {
                let userId = UserDefaults.standard.value(forKey: "user_id") as! String
                UserDetails.userId = userId
                
                FirebaseMethods().fetchUserDetails { (userName, userEmail, userGender, userNumber, references, requestCount, wallet, birthDate) in
                    UserDetails.userName = userName
                    UserDetails.userEmail = userEmail
                    UserDetails.userGender = userGender
                    UserDetails.userNumber = userNumber
                    UserDetails.references = references
                    UserDetails.userBirthDate = birthDate
                    
                }
            }
        }
        
        setupNavigationBar()
        setupMenuButton()
        setupNotifications()
        setupRateView()
    }
    
    func setupNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmss"
        let delegate = UIApplication.shared.delegate as! AppDelegate

        if UserDetails.signedIn {
            //setup notifications if the user is signed in
            FirebaseMethods().fetchAppointmentKeys { (detailArray) in
                for appointment in detailArray {
                    
                    let date = dateFormatter.date(from: appointment)
                    delegate.scheduleNotifications(date: date!, message: "Your Appointment is due in 30 minutes", id: appointment)
                }
            }
            
            FirebaseMethods().fetchAppointments { (appointments) in
                for appointment in appointments {
                    let dateId = appointment["userid"] as? String
                    if let dateString = dateId {
                        let date = dateFormatter.date(from: dateString)
                    
                        let duration = appointment["duration"] as! Int
                        delegate.scheduleBookingNotifications(date: date!, time: duration, id: dateString)
                    }
                }
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (notifications) in
            for notification in notifications {
                print(notification.trigger)
            }
        })
    }
    
    func setupRateView(){
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScrollView()
    }
    
    func setupMenuButton(){
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(self.revealViewController().revealToggle(_:))
            self.revealViewController().rearViewRevealWidth = 260
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @objc func salonButtonTapped(){
        let salonViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SalonsViewController") as! SalonsViewController
        self.navigationController?.pushViewController(salonViewController, animated: true)
        UserDetails.salonSelected = true
        UserDetails.stylistSelected = false
    }
    
    @objc func exploreButtonTapped(){
        let blogsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlogsTableViewController") as! BlogsTableViewController
        self.navigationController?.pushViewController(blogsTableViewController, animated: true)
    }
    
    @objc func askButtonTapped(){
        if UserDetails.signedIn {
            let askTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AskTableViewController") as! AskTableViewController
            self.navigationController?.pushViewController(askTableViewController, animated: true)
        } else {
            let signInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            self.present(signInViewController, animated: true, completion: nil)
        }
    }
    
    @objc func stylistButtonTapped(){
        let servicesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesHomeViewController") as! ServicesHomeViewController
        self.navigationController?.pushViewController(servicesViewController, animated: true)
        UserDetails.salonSelected = false
        UserDetails.stylistSelected = true
    }
    
    
    
    @objc func storeButtonPressed(){
        
//        if UserDetails.signedIn {
//            let storeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreViewController") as! StoreViewController
//            self.navigationController?.pushViewController(storeViewController, animated: true)
//        } else {
//            let signInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//            self.present(signInViewController, animated: true, completion: nil)
//        }
        
        let comingSoonViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ComingSoonViewController") as! ComingSoonViewController
        self.navigationController?.pushViewController(comingSoonViewController, animated: true)
      
    }
    
    func setupScrollView(){
        scrollView.contentSize.height = 0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize.width = self.view.frame.width
        scrollView.backgroundColor = Colors.grayColor3
        
        let bookNowView = Bundle.main.loadNibNamed("BookNowView", owner: self, options: nil)?.first as! BookNowView
        
        bookNowView.frame.origin = CGPoint(x: 10, y: 10)
        bookNowView.frame.size = CGSize(width: self.view.frame.width - 20, height: 250)
        bookNowView.clipsToBounds = true
        bookNowView.backgroundColor = Colors.clearColor
        self.scrollView.addSubview(bookNowView)
        self.scrollView.contentSize.height += 260
        
        bookNowView.salonsButton.addTarget(self, action: #selector(salonButtonTapped), for: .touchUpInside)
        bookNowView.stylistButton.addTarget(self, action: #selector(stylistButtonTapped), for: .touchUpInside)
        
        let exploreView = Bundle.main.loadNibNamed("ExploreView", owner: self, options: nil)?.first as! ExploreView
        exploreView.frame.origin = CGPoint(x : 10, y: self.scrollView.contentSize.height + 10)
        exploreView.frame.size = CGSize(width: self.view.frame.width - 20, height: 250)
        exploreView.clipsToBounds = true
        exploreView.backgroundColor = Colors.clearColor
        self.scrollView.addSubview(exploreView)
        self.scrollView.contentSize.height += 260
        exploreView.exploreButton.addTarget(self, action: #selector(exploreButtonTapped), for: .touchUpInside)
        
        exploreView.askButton.addTarget(self, action: #selector(askButtonTapped), for: .touchUpInside)
        
        let storeView = Bundle.main.loadNibNamed("StoreView", owner: self, options: nil)?.first as! StoreView
        storeView.frame.origin = CGPoint(x: 10, y: scrollView.contentSize.height + 10)
        storeView.frame.size = CGSize(width: self.view.frame.width - 20, height: 200)
        storeView.clipsToBounds = true
        storeView.storeButton.addTarget(self, action : #selector(storeButtonPressed), for: .touchUpInside)
        storeView.backgroundColor = Colors.clearColor
        self.scrollView.addSubview(storeView)
        self.scrollView.contentSize.height += 220
        
    }
}
