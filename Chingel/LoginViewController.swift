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


class LoginViewController: UIViewController {
    
    @IBOutlet weak var signUp : UILabel!
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailIdTextField.delegate = self
        passwordTextField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.segueToSignUp))
        signUp.isUserInteractionEnabled = true
        signUp.addGestureRecognizer(gesture)
        
        
    }
    @IBAction func loginWithEmail(_ sender: Any) {
        loginUsingEmail()
    }
    @IBAction func loginWithFB(_ sender: Any) {
        loginUsingFacebook()
    }
    
    
    @objc func segueToSignUp () {
        performSegue(withIdentifier: "signUp", sender: self)
    }
    
    func loginUsingFacebook(){
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            if error != nil {
                print("FB Login failed")
                return
            }
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
                self.performSegue(withIdentifier: "RestaurantsList", sender: self)
            })
        }
    }
    
    func loginUsingEmail () {
        guard let email = emailIdTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                //handle error
                return
            }
            
            //success logging in
            UserDefaults.standard.set(user?.uid, forKey: "uid") // Saving the uid to Userdefaults
            
            self.performSegue(withIdentifier: "RestaurantsList", sender: self)
        }
    }
    
    
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
