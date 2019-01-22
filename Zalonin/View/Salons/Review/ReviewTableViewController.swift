//
//  ReviewTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 11/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class ReviewTableViewController: UITableViewController {

    var reviewArray : [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Reviews"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = ""
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        
        let review = reviewArray[indexPath.item]
        cell.nameLabel.text = review["name"] as? String
        cell.reviewLabel.text = review["review"] as? String
        
        let rating = review["rating"] as! CGFloat
        cell.ratingLabel.text = "\(rating)"
        
        let date = Double(review["date"] as! String)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        let reviewDate = Date(timeIntervalSince1970: date!)
        let reviewDateString = dateFormatter.string(from: reviewDate)
        
        let name = review["name"] as! String
        let firstLetter = String(describing : name.uppercased().first!)
        
        cell.alphabeticalLabel.text = firstLetter
        
        cell.dateLabel.text = reviewDateString
        return cell
    }
}
