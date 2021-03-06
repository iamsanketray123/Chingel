//
//  ChangeLocationViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 25/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import CoreData

class ChangeLocationViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    var recentLocations = [RecentLocations]()
    
    let manager = CLLocationManager()
    var latitude : CLLocationDegrees = 0.0
    var longitude : CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self

        table.layer.cornerRadius = 5
        table.layer.masksToBounds = true
        
        
//        fetch recent locations from database using CoreData
        fetchLocationsUsingCoreData()

    }

    
    @IBAction func dimiss(_ sender: Any) {
        RestaurantsListViewController.locationChanged = false
        dismiss(animated: true, completion : nil)
    }
    @IBAction func selectLocationManually(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func autoDetectLocation(_ sender: Any) {
        print("getting location")
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.stopUpdatingLocation()
    }
    func getAddress(completion: ()-> Void) {
        print("Running get address")
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            if error != nil {
                print("Error geocoding: \(error?.localizedDescription)")
                return
            }
            if ((placemarks?.count)! > 0) {
                let pm = placemarks![0]
                RestaurantsListViewController.navigationTitleButton.setTitle(pm.name, for: .normal)
                
//              save location to database using CoreData
                self.saveLocationUsingCoreData(name: pm.name!, latitude: self.latitude, longitude: self.longitude)
            }
        }
        completion()
    }

    func saveLocationUsingCoreData(name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "RecentLocations", into: managedContext) as! RecentLocations
        
        newLocation.locationName = name
        newLocation.locationLatitude = latitude
        newLocation.locationLongitude = longitude
        newLocation.creationDate = Date()
        do {
            try managedContext.save()
            print("🍷🍷🍷","New location saved to database","🍷🍷🍷")
        }catch {
            print("Error saving location to database")
        }
    }
    func fetchLocationsUsingCoreData() {
        let fetchRequest = NSFetchRequest<RecentLocations>(entityName : "RecentLocations")
        let sort = NSSortDescriptor(key: #keyPath(RecentLocations.creationDate), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            recentLocations = try managedContext.fetch(fetchRequest)
            print("Fetch successfull","🍵")
        }catch {
            print("Error fetching data from core data")
        }
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
extension ChangeLocationViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("🥕",place.coordinate.latitude,place.coordinate.longitude,"🥕")
        
        RestaurantsListViewController.locationLatitude = "\(place.coordinate.latitude)"
        RestaurantsListViewController.locationLongitude = "\(place.coordinate.longitude)"
        RestaurantsListViewController.navigationTitleButton.setTitle(place.name, for: .normal)
        RestaurantsListViewController.locationChanged = true
        
//      save location to database using CoreData
        saveLocationUsingCoreData(name: place.name,latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        dismiss(animated: false) {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
extension ChangeLocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationDetails = manager.location?.coordinate
        latitude = (locationDetails?.latitude)!
        longitude = (locationDetails?.longitude)!
        print(latitude,longitude)
        
        RestaurantsListViewController.locationLatitude = "\(latitude)"
        RestaurantsListViewController.locationLongitude = "\(longitude)"
        RestaurantsListViewController.locationChanged = true
        
        getAddress {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ChangeLocationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentLocations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let location = recentLocations[indexPath.row]
        cell.textLabel?.text = location.locationName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = recentLocations[indexPath.row]
        RestaurantsListViewController.navigationTitleButton.setTitle(location.locationName, for: .normal)
        RestaurantsListViewController.locationLatitude = "\(location.locationLatitude)"
        RestaurantsListViewController.locationLongitude = "\(location.locationLongitude)"
        RestaurantsListViewController.locationChanged = true

        dismiss(animated: true, completion: nil)
    }
}

