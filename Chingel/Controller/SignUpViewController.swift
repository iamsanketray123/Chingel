//
//  SignUpViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 19/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import SVProgressHUD

class SignUpViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userImage: UIImageViewX!
    
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.delegate = self
        emailId.delegate = self
        password.delegate = self
    }
    @IBAction func uploadImage(_ sender: Any) {
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
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion : nil)
    }
    
    @IBAction func signUpWithEmail(_ sender: Any) {
        do {
            try signUpUsingEmail(completionForSignUp: { (uploadError,error, success) in
                if uploadError != nil {
                    Alert.showBasic(title: "Upload Error", message: "There was an error while uploading the image. Please try again", vc: self)
                }
                if error != nil {
                    Alert.showBasic(title: "Signup Error", message: "\(error!.localizedDescription)", vc: self)
                }
                self.performSegue(withIdentifier: "locationVC", sender: self)
            })
        }catch SignupError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out name, email and password fields", vc: self)
        }catch SignupError.invalidEmail {
            Alert.showBasic(title: "Invalid Email Format", message: "Please sure your email id is formatted correctly", vc: self)
        }catch SignupError.incorrectPasswordLength {
            Alert.showBasic(title: "Password Too Short", message: "Password should be a minimum of 6 characters", vc: self)
        }catch {
            Alert.showBasic(title: "Unable To Login", message: "There was an error while attempting to Signup", vc: self)
        }
    }
    @IBAction func singUpWithFB(_ sender: Any) {
        facebookSignUp()
    }
    
    func signUpUsingEmail(completionForSignUp: @escaping (_ uploadError: Error?, _ error : Error?, _ success: Bool?)->Void) throws {
        let name = self.name.text!
        let email = emailId.text!
        let password = self.password.text!
        
        if email.isEmpty || password.isEmpty || name.isEmpty {
            throw SignupError.incompleteForm
        }
        if !email.isValidEmail {
            throw SignupError.invalidEmail
        }
        if password.count < 6 {
            throw SignupError.incorrectPasswordLength
        }
        
        if reachability.connection != .none {               //Check for internet connection
            
            DispatchQueue.main.async{
                SVProgressHUD.show(withStatus: "Signing Up...")
                SVProgressHUD.setDefaultMaskType(.gradient)
            }
            
            if self.userImage.image != nil {
                let imageName = NSUUID().uuidString
                let storedImage = storageReference.child("profileImage").child(imageName)
                if let uploadData = UIImagePNGRepresentation(self.userImage.image!) {
                    
                    storedImage.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                        if error != nil {
                            print(error?.localizedDescription,"🍣")
                            completionForSignUp(error,nil,nil)
                            return
                        }
                        //                    Successfully uploaded image to Firebase Storage
                        storedImage.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                                return
                            }
                            
                            if let urlString = url?.absoluteString {
                                //                            Create User
                                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                                    if error != nil {
                                        //                                        print(error?.localizedDescription)
                                        DispatchQueue.main.async {
                                            SVProgressHUD.dismiss()
                                        }
                                        completionForSignUp(nil,error,nil)
                                        return
                                    }
                                    // registration successful
                                    guard let uid = user?.uid else {
                                        return
                                    }
                                    
                                    UserDefaults.standard.set(uid, forKey: "uid")
                                    
                                    let userReference = databaseReference.child("users").child(uid)
                                    let values = ["username":name,"email":email,"pic":urlString,"locationName":"","locationLatitude":"","locationLongitude":""]
                                    
                                    userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                                        if error != nil {
                                            print(error?.localizedDescription)
                                            return
                                        }
                                        // successfully saved user details
                                        print("Successfully created user")
                                        DispatchQueue.main.async{
                                            SVProgressHUD.dismiss()
                                        }
                                        completionForSignUp(nil,nil, true)
                                        //                                        self.performSegue(withIdentifier: "locationVC", sender: self)
                                    })
                                }
                            }
                        })
                    })
                }
            }
        } else {
            Alert.showBasic(title: "No Internet Connectivity", message: "Please check your internet connectivity and try again.", vc: self)
        }
    }
    
    func facebookSignUp() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            if error != nil {
                print("FB login failed",error!.localizedDescription)
                return
            }// login Success
            
            print(result?.token.tokenString)
            
            let accessToken = FBSDKAccessToken.current()
            
            guard let accessTokenString = accessToken?.tokenString else {
                return
            }
            
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                    print("Something went wrong with FB user", error?.localizedDescription)
                    return
                }
                print("Successfully logged in with user",Auth.auth().currentUser?.uid,"🍇")
                
                
                UserDefaults.standard.set((Auth.auth().currentUser?.uid)!, forKey: "uid")
                
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,email,picture.type(large)"]).start { (connection, result, error) in
                    guard error == nil else {
                        print("Found an error: \(error?.localizedDescription)")
                        return
                    }
                    guard let result = result as? [String: Any] else {
                        print("Error getting detail results of User")
                        return
                    }
                    guard let email = result["email"] as? String else {
                        print("Could not get email id")
                        return
                    }
                    guard let username = result["name"] as? String else {
                        print("Could not get username")
                        return
                    }
                    guard let picture = result["picture"] as? [String:Any] else {
                        print("Getting picture details")
                        return
                    }
                    guard let pictureData = picture["data"] as? [String:Any] else {
                        print("Error getting picture data")
                        return
                    }
                    guard let pictureURL = pictureData["url"] as? String else {
                        print("Error getting the picture URL")
                        return
                    }
                    self.saveUserInfoToFirebase(name: username, url: pictureURL, email: email, uid : (Auth.auth().currentUser?.uid)!)
                }
            })
        }
    }
    
    
    func saveUserInfoToFirebase(name : String, url : String, email: String, uid: String) {
        
        let userReference = databaseReference.child("users").child(uid)
        let values = ["username":name,"email":email,"pic":url,"locationName":"","locationLatitude":"","locationLongitude":""]
        userReference.updateChildValues(values) { (error, ref) in
            if error != nil {
                print("\(String(describing: error?.localizedDescription))")
                return
            }
            self.performSegue(withIdentifier: "locationVC", sender: self)
        }
    }

}

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImage.image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userImage.image = originalImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


