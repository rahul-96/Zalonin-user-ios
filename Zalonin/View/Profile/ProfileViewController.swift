//
//  ProfileViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 22/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var phoneNumberLabel : UILabel!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var nameAlphabetLabel : UILabel!
    @IBOutlet weak var requestLabel : UILabel!
    @IBOutlet weak var moneySpentLabel : UILabel!
    @IBOutlet weak var referencesLabel : UILabel!
    @IBOutlet weak var enterReferralButton : UIButton!
    @IBOutlet weak var walletLabel : UILabel!
    @IBOutlet weak var tableView : UITableView!
    
    func makeLabelRound(label : UILabel){
        let width = label.frame.width
        label.layer.cornerRadius = width/2
        label.clipsToBounds = true
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1.5
        setupLabels()
        
        tableView.frame.size.height = 800
        addBarButton()
    }
    
    func addBarButton(){
        let editBarButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonPressed))
        self.navigationItem.rightBarButtonItem = editBarButton
    }
    
    @objc func editButtonPressed(){
        let userDetailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserDetailTableViewController") as! UserDetailTableViewController
        self.navigationController?.pushViewController(userDetailTableViewController, animated: true)
    }
    
    func setupLabels(){
        nameLabel.text = ""
        phoneNumberLabel.text = ""
        userNameLabel.text = ""
        nameAlphabetLabel.text = ""
        requestLabel.text = ""
        moneySpentLabel.text = ""
        referencesLabel.text = ""
        walletLabel.text = ""
    }
    
    func fetchUserDetails(){
        if UserDetails.userEmail != "" {
            self.nameLabel.text = UserDetails.userId
            self.phoneNumberLabel.text = UserDetails.userNumber
            self.userNameLabel.text = UserDetails.userName
            self.requestLabel.text = "0"
            self.moneySpentLabel.text = "0"
            self.walletLabel.text = "0"
            self.referencesLabel.text = UserDetails.references
            let firstLetter = String(describing: UserDetails.userName.first!)
            self.nameAlphabetLabel.text = firstLetter
        } else {
            FirebaseMethods().fetchUserDetails { (userName, userEmail, userGender, userNumber, references, requestCount, wallet, birthDate) in
                UserDetails.userNumber = userNumber
                UserDetails.userEmail = userEmail
                UserDetails.userName = userName
                UserDetails.references = references
                UserDetails.userBirthDate = birthDate
                
                self.nameLabel.text = UserDetails.userId
                self.phoneNumberLabel.text = userNumber
                self.userNameLabel.text = userName
                self.requestLabel.text = "\(requestCount)"
                self.moneySpentLabel.text = "0"
                self.referencesLabel.text = references
                self.walletLabel.text = "\(wallet)"
                let firstLetter = String(describing: userName.first!)
                self.nameAlphabetLabel.text = firstLetter
            }
        }
    }
}

//View Life Cycle
extension ProfileViewController {
    override func viewDidLoad() {
        makeLabelRound(label: nameAlphabetLabel)
        makeLabelRound(label: requestLabel)
        makeLabelRound(label: moneySpentLabel)
        makeLabelRound(label: referencesLabel)
        makeLabelRound(label: walletLabel)
        
        fetchUserDetails()
        self.navigationItem.title = "Profile"
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationItem.title = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Profile"
    }
}
