//
//  SideMenuTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 13/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import Reachability

class SideMenuTableViewController: UITableViewController {
    
    
    @IBOutlet weak var UserImageView : UIImageView!
    
    
    let menuTitleArray : [String] = ["Profile",
                                     "My Appointments",
                                     "Refer a Friend",
                                     "Contact Us",
                                     "About Us",
                                     "Terms and Conditions",
                                     "Privacy Policy",
                                     "Logout"]
    
    let titleArray : [String] = ["Sign In",
                                 "Contact Us",
                                 "About Us",
                                 "Terms and Conditions",
                                 "Privacy Policy"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationController = self.revealViewController().frontViewController as! UINavigationController
        let loginViewController = navigationController.viewControllers.first as! LoginOnboardingViewController
        loginViewController.scrollView.isUserInteractionEnabled = false
        
        
        if UserDetails.signedIn {
            if UserDetails.userGender.lowercased() == "female" {
                UserImageView.image = UIImage(named : "female")
            } else {
                UserImageView.image = UIImage(named : "Male")
            }
        } else {
            UserImageView.image = UIImage(named : "salon")
        }
        
        UserImageView.clipsToBounds = true
        UserImageView.layer.cornerRadius = 60
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationController = self.revealViewController().frontViewController as! UINavigationController
        let loginViewController = navigationController.viewControllers.first as! LoginOnboardingViewController
        loginViewController.scrollView.isUserInteractionEnabled = true
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDetails.signedIn {
            return menuTitleArray.count
        } else {
            return titleArray.count
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath) as! SidePanelTableViewCell
        
        
        if UserDetails.signedIn {
            cell.sidePanelLabel.text = menuTitleArray[indexPath.item]
            cell.sidePanelImageView.image = UIImage(named : menuTitleArray[indexPath.item])
        } else {
            cell.sidePanelLabel.text = titleArray[indexPath.item]
            cell.sidePanelImageView.image = UIImage(named : titleArray[indexPath.item])
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let frontNavigationController = self.revealViewController().frontViewController as! UINavigationController
        
        
        if UserDetails.signedIn {
            
            switch indexPath.item {
            case 0:
                //Profile
                let profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                self.revealViewController().revealToggle(animated: true)
                frontNavigationController.pushViewController(profileViewController, animated: true)
                break
            case 1:
                //My Appointments
                let appointmentsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppointmentsViewController") as! AppointmentsViewController
                self.revealViewController().revealToggle(animated: true)
                frontNavigationController.pushViewController(appointmentsViewController, animated: true)
                break
            case 2:
                let referViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReferViewController") as! ReferViewController
                self.revealViewController().revealToggle(animated: true)
                frontNavigationController.pushViewController(referViewController, animated: true)
                break
            case 3:
                let contactViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
                self.revealViewController().revealToggle(animated: true)
                frontNavigationController.pushViewController(contactViewController, animated: true)
                break
            case 4:
                let url = URL(string : Constants.aboutUs)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                break
            case 5:
                let url = URL(string : Constants.tnc)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                break
            case 6:
                let url = URL(string : Constants.privacyPolicy)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                break
            case 7:
                let alertController = UIAlertController(title: "Zalonin", message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (action) in
                    
                    
                    self.revealViewController().revealToggle(animated: true)
                    UserDefaults.standard.removeObject(forKey: "user_id")
                    UserDetails.signedIn = false
                    UserDefaults.standard.set(false, forKey: "signedIn")
                    self.tableView.reloadData()
                    
                    GIDSignIn.sharedInstance().signOut()
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        self.showAlert(msg: "Couldn't sign out user")
                    }
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(logoutAction)
                self.present(alertController, animated: true, completion: nil)
                break
            default:
                break
            }
        }
        else {
            switch indexPath.item {
            case 0:
                //Profile
                let signInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.revealViewController().revealToggle(animated: true)
                self.present(signInViewController, animated: true, completion: nil)
                break
            case 1:
                let contactViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
                self.revealViewController().revealToggle(animated: true)
                frontNavigationController.pushViewController(contactViewController, animated: true)
                break
            case 2:
                let url = URL(string : Constants.aboutUs)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                break
            case 3:
                let url = URL(string : Constants.tnc)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                break
            case 4:
                let url = URL(string : Constants.privacyPolicy)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                break
            default:
                break
            }
        }
    }
}

