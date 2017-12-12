//
//  UpdateProfileViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 07/12/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import SDWebImage
import GooglePlaces
import CoreLocation
import Firebase
import SVProgressHUD

class UpdateProfileViewController: UIViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageViewX!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userLocation: UILabel!
    
    static var newLocationName : String?
    static var newLocationLatitude : CLLocationDegrees?
    static var newLocationLongitude : CLLocationDegrees?
    
    let manager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInfo { (imageUrlString, userName, userEmailID, userLocationName, userLocationLatitude, userLocationLongitude) in
            let url = URL(string : imageUrlString!)
            self.profileImage.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveDownload], completed: nil)
            self.headerImage.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveDownload], completed: nil)
            self.userName.text = userName
            self.name.text = userName
            self.userLocation.text = userLocationName
            UpdateProfileViewController.newLocationName = userLocationName
            UpdateProfileViewController.newLocationLatitude = CLLocationDegrees(userLocationLatitude!)
            UpdateProfileViewController.newLocationLongitude = CLLocationDegrees(userLocationLongitude!)
        }
        userName.delegate = self

    }
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nameTextField(_ sender: Any) {
        name.text = userName.text
    }
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera Not Available")
            }
            
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    @IBAction func selectLocationManually(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func autoDetectLocation(_ sender: Any) {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.stopUpdatingLocation()
    }
    @IBAction func saveChanges(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Saving Changes...")
        SVProgressHUD.setDefaultMaskType(.gradient)
        updateChanges() { (success) in
            if success! {
                SVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func updateChanges(completion: @escaping (_ success : Bool?)-> Void) {

        if profileImage.image != nil {
            let imageName = NSUUID().uuidString
            let storedImage = storageReference.child("profileImage").child(imageName)
            if let uploadData = UIImagePNGRepresentation(profileImage.image!){
                storedImage.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
                    //                    Successfully uploaded image to firebase storage
                    storedImage.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                            return
                        }
                        guard let urlString = url?.absoluteString else {
                            print("could not get url string")
                            return
                        }
                        let uid = UserDefaults.standard.object(forKey: "uid")
                        databaseReference.child("users").child(uid as! String).updateChildValues(["pic": urlString, "locationName": UpdateProfileViewController.newLocationName! , "locationLatitude": "\(UpdateProfileViewController.newLocationLatitude!)" , "locationLongitude": "\(UpdateProfileViewController.newLocationLongitude!)","username": self.userName.text!]) { (error, ref) in
                            if error != nil {
                                print(error?.localizedDescription)
                                return
                            }
                            print("Successfully updated user details")
                            completion(true)
                        }
                    })
                })
            }
        }
    }
    func getAddressFromCoordinates(latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let location = CLLocation(latitude : latitude, longitude : longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            if ((placemarks?.count)! > 0) {
                let pm = placemarks![0] as! CLPlacemark
                
                UpdateProfileViewController.newLocationName = pm.name!
                UpdateProfileViewController.newLocationLatitude = latitude
                UpdateProfileViewController.newLocationLongitude = longitude
                
                self.userLocation.text = pm.name!
            print(UpdateProfileViewController.newLocationName,UpdateProfileViewController.newLocationLatitude,UpdateProfileViewController.newLocationLongitude,"🥥")
            }
        }
    }
    
    func updateUserInfo(completion: @escaping (_ userImage : String?, _ userName: String?, _ userEmail: String?, _ userLocationName: String?, _ userLocationLatitude: String?, _ userLocationLongitude : String?)->Void){
        let uid = UserDefaults.standard.object(forKey : "uid") as! String
        databaseReference.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:AnyObject] else {
                print("Could not get dictionary")
                return
            }
            completion((dict["pic"] as! String), (dict["username"] as! String), (dict["email"] as! String), (dict["locationName"] as! String),(dict["locationLatitude"] as! String), (dict["locationLongitude"] as! String))
            
        }
    }
    
}
extension UpdateProfileViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
}
extension UpdateProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImage.image = editedImage
            self.headerImage.image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.image = originalImage
            self.headerImage.image = originalImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension UpdateProfileViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        getAddressFromCoordinates(latitude: latitude, longitude: longitude)
    }
}
extension UpdateProfileViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("🥕",place.coordinate.latitude,place.coordinate.longitude,"🥕")
        
//  update new location details
        UpdateProfileViewController.newLocationName = place.name
        UpdateProfileViewController.newLocationLatitude = place.coordinate.latitude
        UpdateProfileViewController.newLocationLongitude = place.coordinate.longitude
        userLocation.text = place.name
        print(UpdateProfileViewController.newLocationName,UpdateProfileViewController.newLocationLatitude,UpdateProfileViewController.newLocationLongitude,"🌽")
        
        dismiss(animated: true)
        
        
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
