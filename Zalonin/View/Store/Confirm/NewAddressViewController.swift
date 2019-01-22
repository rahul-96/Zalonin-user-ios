//
//  NewAddressViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 22/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import CoreLocation

class NewAddressViewController: UIViewController {
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var locationLabel : UILabel!
    @IBOutlet weak var nextButton : UIButton!
    @IBOutlet weak var searchBar : UISearchBar!
    
    var resultsViewController : GMSAutocompleteResultsViewController?
    var searchController : UISearchController?
    var resultView : UITextView?
    let locationManager = CLLocationManager()
    var selectedIndex : Int = 0
    
    func makeButtonsRound(button : UIButton){
        let height = button.frame.height
        button.layer.cornerRadius = height/2
        button.clipsToBounds = true
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = Colors.blackColor
        
        let gmsFilter = GMSAutocompleteFilter()
        gmsFilter.country = "IN"
        resultsViewController?.autocompleteFilter = gmsFilter
    }
    
    func setupLocationManager(){
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            self.locationManager.delegate = self
        }
    }
    
    @IBAction func nextButtonPressed(){
        var detailDict = [String : Any]()
        detailDict["address"] = locationLabel.text
        detailDict["lat"] = UserDetails.userLocation.latitude
        detailDict["lng"] = UserDetails.userLocation.longitude
        FirebaseMethods().saveAddress(dict: detailDict)
        self.navigationController?.popViewController(animated: true)
    }
}

//View Life Cycle
extension NewAddressViewController {
    override func viewDidLoad() {
        setupLocationManager()
        searchBar.delegate = self
        searchBar.placeholder = "Search Location"
        self.locationLabel.text = "Fetching Location ..."
        
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .denied, .restricted:
                self.showAlert(msg: "Please enable location services for Zalonin to work")
                self.nextButton.isHidden = true
                break
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        }
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "New Address"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
}

extension NewAddressViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autoCompleteViewController = GMSAutocompleteViewController()
        autoCompleteViewController.delegate = self
        self.present(autoCompleteViewController, animated: true, completion: nil)
    }
}

extension NewAddressViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.locationManager.delegate = nil
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            UserDetails.userLocation = center
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemark, error) in
                if error == nil {
                    let firstLocation = placemark?.first
                    let locality = firstLocation?.locality ?? ""
                    let sublocality = firstLocation?.subLocality ?? ""
                    let name = firstLocation?.name ?? ""
                    self.locationLabel.text =  name + ", " + sublocality + ", " + locality
                    
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
}

extension NewAddressViewController : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let address = place.formattedAddress
        self.locationLabel.text = address
        let coordinates = place.coordinate
        let mapPin = MKPointAnnotation()
        mapPin.coordinate = coordinates
        
        UserDetails.userLocation = coordinates
        self.mapView.addAnnotation(mapPin)
        
        let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        viewController.dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
