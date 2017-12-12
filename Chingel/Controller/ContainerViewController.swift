//
//  ContainerViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 02/12/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet weak var sideMenuLeadingConstraint: NSLayoutConstraint!
   
    var sideMenuOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()
       
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("toggleSideMenu"),
                                               object: nil)
    }
    
    
    @objc func toggleSideMenu() {
        if sideMenuOpen {
            sideMenuOpen = false
            sideMenuLeadingConstraint.constant = -300
        } else {
            sideMenuOpen = true
            sideMenuLeadingConstraint.constant = 0
        }
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if RestaurantDetailTableViewController.viewIsDark {
            return .lightContent
        }else {
            return .default
        }
    }
}
