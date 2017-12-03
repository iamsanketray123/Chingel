//
//  LocationViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 19/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class LocationViewController: UIViewController {
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(UserDefaults.standard.object(forKey: "uid"))
        
        
        
    }
    @IBAction func autoLocation(_ sender: Any) {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.stopUpdatingLocation()
    }
    
    @IBAction func manualSelection(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    //    Reverse Geocoding!
    
    func getAddressFromCoordinates(latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let location = CLLocation(latitude : latitude, longitude : longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            if ((placemarks?.count)! > 0) {
                let pm = placemarks![0] as! CLPlacemark
                
                self.updateLocationDetailsOfUser(locationName: pm.name!, locationLatitude: latitude, locationLongitude: longitude) {
                    self.performSegue(withIdentifier: "RestaurantsListNVC", sender: self)
                }
            }
        }
    }
    
    func updateLocationDetailsOfUser(locationName: String, locationLatitude: CLLocationDegrees, locationLongitude: CLLocationDegrees,completion : ()-> Void) {
        
        guard let uid = UserDefaults.standard.object(forKey : "uid") as? String else {
            print("UID not found")
            return
        }
        let latitude = "\(locationLatitude)"
        let longitude = "\(locationLongitude)"
        databaseReference.child("users").child(uid).updateChildValues(["locationName":locationName,"locationLatitude":latitude,"locationLongitude":longitude]) { (error, ref) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            print("Successfully updated location details")
        }
        completion()
    }
    
}

extension LocationViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("🥕",place.coordinate.latitude,place.coordinate.longitude,"🥕")
        
        //        update location details after selecting a place!
        updateLocationDetailsOfUser(locationName: place.name, locationLatitude: place.coordinate.latitude, locationLongitude: place.coordinate.longitude) {
            print("Location details updated to Firebase")
        }
        
        
        dismiss(animated: false) {
            self.performSegue(withIdentifier: "RestaurantsListNVC", sender: self)
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

extension LocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        getAddressFromCoordinates(latitude: latitude, longitude: longitude)
    }
}

