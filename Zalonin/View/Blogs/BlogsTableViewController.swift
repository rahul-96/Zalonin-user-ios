//
//  BlogsTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 20/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import SwiftWebVC
import YouTubePlayer

class BlogsTableViewController : UITableViewController {
    
    var dictArray : [[String : Any]] = []
    
    @IBOutlet weak var segmentController : UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView(){
        let nib = UINib(nibName: "BlogsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "blogsCell")
        tableView.separatorStyle = .none
        
        
        FirebaseMethods().fetchBlogs { (dict) in
            self.dictArray = dict
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Blogs"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blogsCell", for: indexPath) as! BlogsTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(displayP3Red: 62/255, green: 64/255, blue: 72/255, alpha: 1)
        
        let blog = dictArray[indexPath.item]
        let title = blog["head"] as! String
        let id = blog["id"] as! String
        let subTitle = blog["subtext"] as! String
        let viewCount = blog["views"] as! Int
        
        cell.subTitleLabel.text = subTitle
        cell.titeLabel.text = title
        
        
        let storage = Storage.storage(url: "gs://salon-ee42e.appspot.com")
        let storageRef = storage.reference()
        
        
        
        let subId = id.prefix(6)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let date = dateFormatter.date(from: String(subId))
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date!)
        
        cell.viewsCountLabel.text = "\(viewCount)"
        cell.messagesCountLabel.text = "\(0)"
        
        let childLocation = "BLOGS/\(id).jpg"
        let imageRef = storageRef.child(childLocation)
        
        if cell.blogImageView.image == UIImage(named  : "salon") {
            imageRef.downloadURL { (url, error) in
                if let _ = error {
                    cell.blogImageView.image = UIImage(named : "salon")
                }else {
                    cell.blogImageView.sd_setImage(with: url!, completed: nil)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentController.selectedSegmentIndex == 0 {
            let blog = dictArray[indexPath.item]
            let link = blog["link"] as! String
            let webVc = SwiftWebVC(urlString: link)
            self.navigationController?.pushViewController(webVc, animated: true)
        } else {
            let vlog = dictArray[indexPath.item]
            let link = vlog["link"] as! String
            let vlogsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VlogsViewController") as! VlogsViewController
            vlogsViewController.link = link
            self.navigationController?.pushViewController(vlogsViewController, animated: true)
        }
    }
    
    @IBAction func segmentControllerChanged(){
        if segmentController.selectedSegmentIndex == 0 {
            FirebaseMethods().fetchBlogs { (dict) in
                self.dictArray = dict
                self.tableView.reloadData()
            }
        } else {
            FirebaseMethods().fetchVlogs { (dict) in
                self.dictArray = dict
                self.tableView.reloadData()
            }
        }
    }
    
}
