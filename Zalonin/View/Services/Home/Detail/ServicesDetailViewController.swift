//
//  ServicesDetailTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 10/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ServicesDetailViewController: UIViewController {
    
    @IBOutlet weak var proceedButton : UIButton!
    @IBOutlet weak var selectedItemsLabel : UILabel!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    
    var detailArray : [[String : Any]] = []
    var searchArray : [[String : Any]] = []
    var salonName : String = ""
    var fromString : String = ""
    var toString  : String = ""
    var keyValue : String = ""
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        searchArray = detailArray
        selectedItemsLabel.layer.borderColor = Colors.blackColor.cgColor
        selectedItemsLabel.layer.borderWidth = 2.0
        searchBar.delegate = self
        searchBar.tintColor = Colors.blackColor
        if UserDetails.salonSelected {
            tableView.allowsMultipleSelection = true
        } else {
            tableView.allowsMultipleSelection = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedItemsLabel.text = "\(UserDetails.selectedServicesCount) items selected"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDetails.salonSelected {
            self.navigationItem.title = "Salon Services"
        } else {
            self.navigationItem.title = "Stylist Services"
        }
        searchBar.placeholder = "Search Services"
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = ""
    }
    
    @IBAction func proceedButtonPressed(){
        
        if UserDetails.signedIn {
            if UserDetails.salonSelected {
                if UserDetails.selectedServicesCount > 0 {
                    let dateViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DateViewController") as! DateViewController
                    dateViewController.fromString = fromString
                    dateViewController.toString = toString
                    dateViewController.salonName = salonName
                    dateViewController.keyValue = keyValue
                    self.navigationController?.pushViewController(dateViewController, animated: true)
                } else {
                    self.showAlert(msg: "Please select atleast one service to proceed")
                }
                
            } else {
                if UserDetails.selectedServicesCount > 0 {
                    let salonViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SalonsViewController") as! SalonsViewController
                    
                    salonViewController.selectedIndex = selectedIndex
                    self.navigationController?.pushViewController(salonViewController, animated: true)
                } else {
                    self.showAlert(msg: "Please select atleast one service to proceed")
                }
            }
        } else {
            let signInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            self.present(signInViewController, animated: true, completion: nil)
        }
    }
}

extension ServicesDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ServicesDetailTableViewCell
        
        if toString != "" {
            let currentService = searchArray[indexPath.item]
            let name = currentService["name"]
            let priceInt = currentService["price"] as! Int
            let price = "₹ \(priceInt)"
            let newPriceInt = currentService["new"] as! Int
            let newPrice = "₹ \(newPriceInt)"
            cell.detailLabel.text = (name as! String)
            
            let attributedString = NSMutableAttributedString(string: price)
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
            
            cell.oldPriceLabel.attributedText = attributedString
            cell.newPriceLabel.text = newPrice
        } else {
            let currentService = searchArray[indexPath.item]
            let name = currentService["name"]
            
            cell.detailLabel.text = (name as! String)
            cell.oldPriceLabel.isHidden = true
            cell.newPriceLabel.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ServicesDetailTableViewCell
        cell.backgroundColor = Colors.grayColor1.withAlphaComponent(0.7)
        let service = searchArray[indexPath.item]
        if UserDetails.salonSelected {
            UserDetails.selectedServicesArray.append(service)
            UserDetails.selectedServicesCount += 1
        } else {
            UserDetails.selectedServicesArray = [service]
            UserDetails.selectedServicesCount = 1
        }
        selectedItemsLabel.text = "\(UserDetails.selectedServicesCount) items selected"
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ServicesDetailTableViewCell
        cell.backgroundColor = Colors.whiteColor
        let service = searchArray[indexPath.item]
        if UserDetails.salonSelected {
            UserDetails.selectedServicesArray = UserDetails.selectedServicesArray.filter({$0["name"] as! String != service["name"] as! String})
            UserDetails.selectedServicesCount -= 1
        } else {
            UserDetails.selectedServicesCount = 1
            UserDetails.selectedServicesArray = [service]
        }
        selectedItemsLabel.text = "\(UserDetails.selectedServicesCount) items selected"
    }
}

extension ServicesDetailViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            let searchText = searchBar.text?.lowercased()
            searchArray = []
            for service in detailArray {
                let name = service["name"] as! String
                
                if name.lowercased().range(of: searchText!) != nil {
                    searchArray.append(service)
                }
            }
            tableView.reloadData()
        } else {
            searchArray = detailArray
            tableView.reloadData()
        }
        searchBar.resignFirstResponder()
    }
}
