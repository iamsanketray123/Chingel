//
//  SideMenuTableViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 03/12/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import SDWebImage

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
