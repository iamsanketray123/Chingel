//
//  LoginViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 18/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SVProgressHUD


class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailIdTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    @IBAction func segueToSignUp (_ sender : Any) {
        performSegue(withIdentifier: "SignupVC", sender: self)
    }
    @IBAction func loginWithEmail(_ sender: Any) {
        do{
            try loginUsingEmail() { (error, success) in
                if error != nil {
                    Alert.showBasic(title: "Invalid Password", message: "Entered password is invalid. Please check again!", vc: self)
                }
                self.performSegue(withIdentifier: "RestaurantsListNVC", sender: self)
            }
        }catch LoginError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out both email and password fields", vc: self)
        }catch LoginError.invalidEmail {
            Alert.showBasic(title: "Invalid Email Format", message: "Please sure your email id is formatted correctly", vc: self)
        }catch LoginError.incorrectPasswordLength {
            Alert.showBasic(title: "Password Too Short", message: "Password should be a minimum of 6 characters", vc: self)
        }catch {
            Alert.showBasic(title: "Unable To Login", message: "There was an error while attempting to Login", vc: self)
        }
    }
    @IBAction func loginWithFB(_ sender: Any) {
        loginUsingFacebook { (accountExists) in
            if accountExists {
                self.performSegue(withIdentifier: "RestaurantsListNVC", sender: self)
            }else {
                Alert.showBasic(title: "User Not Found", message: "You don't have an account with us yet. Please click on the \"Signup Button\" to register. Thank You!", vc: self)
            }
        }
    }
    func loginUsingEmail(completion: @escaping (_ err: Error?, _ success : Bool?)->Void)throws {
        let email = emailIdTextField.text!
        let password = passwordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            throw LoginError.incompleteForm
        }
        if !email.isValidEmail {
            throw LoginError.invalidEmail
        }
        if password.count < 6 {
            throw LoginError.incorrectPasswordLength
        }
        SVProgressHUD.show(withStatus: "Logging In...")
        SVProgressHUD.setDefaultMaskType(.gradient)
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                //handle error
                SVProgressHUD.dismiss()
                completion(error!, nil)
                return
            }
            
            //success logging in
            UserDefaults.standard.set(user?.uid, forKey: "uid") // Saving the uid to Userdefaults
            SVProgressHUD.dismiss()
            completion(nil,true)
        }
    }
    
    
    
    func loginUsingFacebook(completion : @escaping (_ accountExists : Bool)-> Void){
        FBSDKLoginManager().logOut()
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            if error != nil {
                print("FB Login failed",error!.localizedDescription)
                return
            }
            //            login Success
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,email,picture.type(large)"]).start { (connection, result, error) in
                print("This got executed...")
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
                //                Find out if an email id has been registered or not.
                databaseReference.child("users").queryOrdered(byChild: "email").queryStarting(atValue: email).queryEnding(atValue: email+"\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.childrenCount,"🍶")
                    //                  snapshot.childrenCount == 0, Account has not been created yet.
                    if snapshot.childrenCount == 0 {
                        completion ( false)
                    }
                    print("Executed")
                    
                    //                     if snapshot.childrenCount is > 0, an account has been created already.
                    if snapshot.childrenCount > 0{
                        let accessToken = FBSDKAccessToken.current()
                        guard let accessTokenString = accessToken?.tokenString else {
                            print("Could not get string from accessToken")
                            return
                        }
                        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                        
                        Auth.auth().signIn(with: credentials, completion: { (user, error) in
                            if error != nil {
                                print("Something went wrong with FB user",error?.localizedDescription)
                                return
                            }
                            UserDefaults.standard.set((Auth.auth().currentUser?.uid)!, forKey: "uid")
                            //                successfully logged in
                            
                            completion(true)
                        })
                    }  
                })
            }
        }
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
