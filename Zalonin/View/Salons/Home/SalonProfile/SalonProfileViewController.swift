//
//  SalonProfileTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 31/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

class SalonProfileViewController: UIViewController {
    
    var image : UIImage = UIImage()
    var profileText : String = ""
    var locationText : String = ""
    var number : String = ""
    var lat : CGFloat = 0.0
    var lng : CGFloat = 0.0
    var keyValue : String = ""
    var toString : String = ""
    var fromString : String = ""
    var salonDescription: String = ""
    var reviewArray : [[String: Any]] = []
    var imageArray : [URL] = []
    
    @IBOutlet weak var profileLabel : UILabel!
    @IBOutlet weak var locationLabel : UILabel!
    @IBOutlet weak var aboutLabel : UILabel!
    @IBOutlet weak var reviewButton : UIButton!
    @IBOutlet weak var locationButton : UIButton!
    @IBOutlet weak var phoneButton : UIButton!
    @IBOutlet weak var imageCollectionView : UICollectionView!
    @IBOutlet weak var imageCollectionViewFlowLayout : UICollectionViewFlowLayout!
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var bookButton : UIButton!
    @IBOutlet weak var descriptionLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let modifiedLocation = locationText.replacingOccurrences(of: "null", with: "")
        self.view.backgroundColor = Colors.grayColor3
        profileLabel.text = profileText
        locationLabel.text = modifiedLocation
        aboutLabel.text = "About " + profileText
        pageControl.numberOfPages = 4
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        descriptionLabel.text = description
        
        let itemSize = CGSize(width: self.view.frame.width, height: imageCollectionView.frame.height)
        imageCollectionViewFlowLayout.minimumLineSpacing = 0.0
        imageCollectionViewFlowLayout.minimumInteritemSpacing = 0.0
        imageCollectionViewFlowLayout.itemSize = itemSize
        
        if UserDetails.stylistSelected {
            bookButton.isHidden = true
        } else {
            bookButton.isHidden = false
        }
    }
    
    @IBAction func bookAppointmentPressed(){
        
        let servicesHomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServicesHomeViewController") as! ServicesHomeViewController
        servicesHomeViewController.salonName = profileText
        servicesHomeViewController.toString = toString
        servicesHomeViewController.fromString = fromString
        servicesHomeViewController.keyValue = keyValue
        self.navigationController?.pushViewController(servicesHomeViewController, animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDetails.salonSelected {
            self.navigationItem.title = "Salon Profile"
        } else {
            self.navigationItem.title = "Stylist Profile"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDetails.salonSelected {
            UserDetails.selectedServicesCount = 0
            UserDetails.selectedServicesArray = []
        }
    }
    
    @IBAction func phoneButtonTapped() {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func locationButtonTapped(){
        if UIApplication.shared.canOpenURL(URL(string : "comgooglemaps://")!) {
            let appUrlString = "comgooglemaps://?saddr=&daddr=\(lat),\(lng)&zoom=14&directionsmode=driving"
            UIApplication.shared.open(URL(string : appUrlString)!, options: [:], completionHandler: nil)
        } else {
            self.showAlert(msg: "No Location Available")
        }
    }
    
    @IBAction func reviewButtonTapped(){
        var ref : DatabaseReference
        ref = Database.database().reference()
        
        ref.child("MERCHANT").child(keyValue).child("REVIEW").observe(.value, with: { (snapshot) in
            let reviews = snapshot.children.allObjects as NSArray
            for review in reviews {
                let reviewSnapshot = review as! DataSnapshot
                let reviewValue = reviewSnapshot.value as! [String : Any]
                
                self.reviewArray.append(reviewValue)
            }
            
            let reviewTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReviewTableViewController") as! ReviewTableViewController
            
            reviewTableViewController.reviewArray = self.reviewArray
            self.navigationController?.pushViewController(reviewTableViewController, animated: true)
        })
    }
}

extension SalonProfileViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "salonProfileCell", for: indexPath) as! SalonProfileCollectionViewCell
        
        let salonImage = keyValue
        let imageLoc = "IMAGE\(indexPath.item + 1).jpg"
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        
        let childLocation = salonImage  + "/" + imageLoc
        let imageRef = storageRef.child(childLocation)
        
        if cell.salonProfileImageView?.image == UIImage(named : "salon") {
            imageRef.downloadURL { (url, error) in
                if error != nil {
                    print("image error")
                } else {
                    if url != nil {
                        let imageURL = url!
                        cell.salonProfileImageView?.sd_setImage(with: imageURL, completed: nil)
                    }
                }
            }
        }
        return cell
    }
}

extension SalonProfileViewController : UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = UIScreen.main.bounds.width
        let currentIndex = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentIndex
        
    }
}


