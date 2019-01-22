//
//  AskTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 25/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class AskTableViewController : UITableViewController {
    
    var askArray: [String] = []
    var nameArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.navigationItem.title = "ASK EXPERT"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "ASK EXPERT"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    func setupTableView(){
        let nib = UINib(nibName: "AskTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "askCell")
        tableView.tableFooterView = UIView()
        view.backgroundColor = Colors.grayColor3
        FirebaseMethods().fetchChatUsers { (userArray,nameArray) in
            self.askArray = userArray
            self.nameArray = nameArray
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return askArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "askCell", for: indexPath) as! AskTableViewCell
        let index = indexPath.item
        cell.setupAskTableViewCell(title: nameArray[index], imageNumber: (index%6) + 1)
        cell.backgroundColor = Colors.grayColor3
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        messageViewController.chatUser = askArray[indexPath.item]
        self.navigationController?.pushViewController(messageViewController, animated: true)
    }
}
