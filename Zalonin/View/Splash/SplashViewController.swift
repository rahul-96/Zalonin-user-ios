//
//  SplashViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 26/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout : UICollectionViewFlowLayout!
    
    let imageArray = ["Zalonin-User-App-Screen-1","Zalonin-User-App-Screen-2","Zalonin-User-App-Screen-3","Zalonin-User-App-Screen-4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStartedButton.isHidden = true
        getStartedButton.clipsToBounds = true
        getStartedButton.layer.cornerRadius = 20
        UIApplication.shared.statusBarStyle = .lightContent
        self.view.backgroundColor = Colors.grayColor3
        self.collectionView.backgroundColor = Colors.grayColor3
        setupCollectionView()
    }
    
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let itemSize = view.frame.size
        collectionViewFlowLayout.itemSize = itemSize
        collectionViewFlowLayout.minimumLineSpacing = 0.0
        collectionViewFlowLayout.minimumInteritemSpacing = 0.0
    }
    
    @IBAction func closeButtonPressed(sender : UIButton){
        presentOnboardingViewController()
    }
    
    @IBAction func getStartedButton(sender : UIButton){
        presentOnboardingViewController()
    }
    
    func presentOnboardingViewController(){
        let sidePanelViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SidePanelViewController") as! SidePanelViewController
        self.present(sidePanelViewController, animated: true, completion: nil)
    }
}

extension SplashViewController : UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = UIScreen.main.bounds.width
        let currentIndex = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentIndex
        
        if currentIndex == 3  {
            getStartedButton.isHidden  = false
        } else {
            getStartedButton.isHidden = true
        }
    }
}

extension SplashViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "splashCell", for: indexPath) as! SplashCollectionViewCell
        cell.imageView.image = UIImage(named : imageArray[indexPath.item])
        return cell
    }
}
