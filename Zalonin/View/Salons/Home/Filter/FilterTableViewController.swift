//
//  FilterTableViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 11/04/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class FilterTableViewController: UITableViewController {
    
    let headerArray = ["Quick Filters", "Distance", "Sort By", "Average Cost"]
    let sortArray =  ["Distance", "Rating", "Cost", "Popularity"]
    let costArray = ["0-500", "500-1000", "1000-2000", "2000+"]
    let sortImageArray = ["location-1", "rating", "rupee", "popularity"]
    
    @IBOutlet weak var resetFilterButton : UIButton!
    @IBOutlet weak var ratedFilterButton : UIButton!
    @IBOutlet weak var openNowButton : UIButton!
    @IBOutlet weak var distanceLabel : UILabel!
    
    @IBOutlet weak var sortCollectionView : UICollectionView!
    @IBOutlet weak var sortCollectionViewFlowLayout : UICollectionViewFlowLayout!
    
    @IBOutlet weak var priceCollectionView : UICollectionView!
    @IBOutlet weak var priceCollectionViewFlowLayout : UICollectionViewFlowLayout!
    
    @IBOutlet weak var horizontalSlider : UISlider!
    
    var selectedSortCell = -1
    var selectedCostCell = -1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        horizontalSlider.value = Float(UserDetails.distanceFilter)
        let distance = Int(UserDetails.distanceFilter)
        distanceLabel.text = "\(distance)"
        selectedSortCell = UserDetails.sortByIndex
        selectedCostCell = UserDetails.costByIndex
    }
    
    @IBOutlet weak var averageCollectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSortCollectionView()
        setupPriceCollectionView()
        let applyButton : UIBarButtonItem = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(applyButtonTapped))        
        self.navigationItem.rightBarButtonItem = applyButton
    }
    
    @objc func applyButtonTapped(){
        UserDetails.distanceFilter = Double(horizontalSlider.value)
        UserDetails.sortByIndex = selectedSortCell
        UserDetails.costByIndex = selectedCostCell
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupPriceCollectionView(){
        priceCollectionView.dataSource = self
        priceCollectionView.delegate = self
        priceCollectionView.backgroundColor = Colors.grayColor3
        let width = self.view.frame.width/4
        let itemSize = CGSize(width: width, height: 75)
        priceCollectionViewFlowLayout.itemSize = itemSize
        priceCollectionViewFlowLayout.minimumLineSpacing = 0
        priceCollectionViewFlowLayout.minimumInteritemSpacing = 0
    }
    
    func setupSortCollectionView(){
        sortCollectionView.dataSource = self
        sortCollectionView.delegate = self
        sortCollectionView.backgroundColor = Colors.grayColor3
        let width = self.view.frame.width/4
        let itemSize = CGSize(width: width, height: 75)
        sortCollectionViewFlowLayout.itemSize = itemSize
        sortCollectionViewFlowLayout.minimumLineSpacing = 0
        sortCollectionViewFlowLayout.minimumInteritemSpacing = 0
        
        if UserDetails.rated == true {
            selectButton(button: ratedFilterButton)
        }
        if UserDetails.openNow == true {
            selectButton(button: openNowButton)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Colors.grayColor2
        let label = UILabel(frame: CGRect(x: 15, y: 10, width: self.view.frame.width - 30, height: 20))
        label.textColor = Colors.whiteColor
        label.text = headerArray[section]
        headerView.addSubview(label)
        return headerView
    }
    
    func selectButton(button : UIButton) {
        button.setImage(UIImage(named : "on"), for: .normal)
    }
    
    func unselectButton(button : UIButton) {
        button.imageView?.image = UIImage(named : "off")
        button.setImage(UIImage(named : "off"), for: .normal)
    }
    
    @IBAction func resetFilterButtonPressed(){
        selectButton(button: resetFilterButton)
        unselectButton(button: ratedFilterButton)
        unselectButton(button: openNowButton)
        UserDetails.resetFilters = true
        UserDetails.openNow = false
        UserDetails.rated = false
    }
    
    @IBAction func ratedButtonPressed(){
        unselectButton(button: resetFilterButton)
        selectButton(button: ratedFilterButton)
        unselectButton(button: openNowButton)
        UserDetails.rated = true
        UserDetails.openNow = false
        UserDetails.resetFilters = false
    }
    
    @IBAction func openNowButtonPressed(){
        unselectButton(button: resetFilterButton)
        unselectButton(button: ratedFilterButton)
        selectButton(button: openNowButton)
        UserDetails.openNow = true
        UserDetails.rated = false
        UserDetails.resetFilters = false
    }
    
    @IBAction func sliderValueChanged(){
        distanceLabel.text = "\(Int(horizontalSlider.value))"
    }
}

extension FilterTableViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sortCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sortCell", for: indexPath) as! FilterCollectionViewCell
            cell.filterLabel.text = sortArray[indexPath.item]
            cell.filterImageView.image = UIImage(named : sortImageArray[indexPath.item])
            if indexPath.item == selectedSortCell {
                cell.filterImageView.alpha = 1.0
                cell.filterLabel.alpha = 1.0
            }
            else {
                cell.filterLabel.alpha = 0.4
                cell.filterImageView.alpha = 0.4
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceCell", for: indexPath) as! FilterPriceCollectionViewCell
            cell.filterLabel.text = costArray[indexPath.item]
            if indexPath.item == selectedCostCell {
                cell.filterPriceImageView.alpha = 1.0
                cell.filterLabel.alpha = 1.0
            }
            else {
                cell.filterLabel.alpha = 0.4
                cell.filterPriceImageView.alpha = 0.4
            }
            return cell
        }
    }
}

extension FilterTableViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sortCollectionView {
            selectedSortCell = indexPath.item
            collectionView.reloadData()
        } else {
            selectedCostCell = indexPath.item
            collectionView.reloadData()
        }
    }
}
