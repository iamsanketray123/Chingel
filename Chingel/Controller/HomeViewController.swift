//
//  HomeViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 17/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

//    OUTLETS
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yourFood: UILabel!
    @IBOutlet weak var yourRestaurant: UILabel!
    @IBOutlet weak var goButton: UIButtonX!
    @IBOutlet weak var letsGo: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImage.alpha = 0
        titleLabel.alpha = 0
        yourFood.alpha = 0
        yourRestaurant.alpha = 0
        goButton.alpha = 0
        letsGo.alpha = 0
        
        UserDefaults.standard.set(true, forKey: "firstLaunchComplete")
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1, animations: {
            self.backgroundImage.alpha = 1
        }) { (true) in
            self.animateTitle()
        }
    }

    func animateTitle () {
        UIView.animate(withDuration: 1, animations: {
            self.titleLabel.alpha = 1
        }) { (true) in
            self.animteFoodAndRestaurant()
        }
    }
    func animteFoodAndRestaurant() {
        UIView.animate(withDuration: 1, animations: {
            self.yourFood.alpha = 1
            self.yourRestaurant.alpha = 1
        }) { (true) in
            self.animateButtonAndLastLabel()
        }
    }
    func animateButtonAndLastLabel() {
        UIView.animate(withDuration: 1, animations: {
            self.goButton.alpha = 1
            self.letsGo.alpha = 1
        })
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}



















