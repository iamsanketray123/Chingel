//
//  SideMenuTableViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 03/12/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import SideMenu
import StoreKit

class SideMenuTableViewController: UITableViewController {

    @IBOutlet weak var userImage: UIImageViewX!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        updateUserInfo { (imageUrlString, userName, userEmailID) in
            let url = URL(string : imageUrlString!)
            self.userImage.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveDownload], completed: nil)
            self.userName.text = userName
            self.userEmail.text = userEmailID
        }
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let tempImageView = UIImageView(image: UIImage(named: "wine"))
        tempImageView.frame = table.frame
        tempImageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = tempImageView

    }
    @IBAction func rateOnAppStore(_ sender : Any) {
            SKStoreReviewController.requestReview()
    }
    @IBAction func homeScreen(_ sender: Any) {
        dismiss(animated : true)
    }
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }catch {
            print("Error while logging out")
        }
        UserDefaults.standard.set(nil, forKey: "uid")
        
        dismiss(animated: true) {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            UIApplication.topViewController()?.present(controller, animated: true)
        }
//        The following code leads to the error "Application tried to present modally an active controller <Chingel.RestaurantsListViewController"

//        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
//        UIApplication.topViewController()?.present(controller, animated: true)
    }
    
    
    fileprivate func updateUserInfo(completion: @escaping (_ userImage : String?, _ userName: String?, _ userEmail: String?)->Void){
        let uid = UserDefaults.standard.object(forKey : "uid") as! String
        databaseReference.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:AnyObject] else {
                print("Could not get dictionary")
                return
            }
            completion((dict["pic"] as! String), (dict["username"] as! String), (dict["email"] as! String))

        }
    }
}








