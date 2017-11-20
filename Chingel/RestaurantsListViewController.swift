//
//  RestaurantsListViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 20/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

class RestaurantsListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print(UserDefaults.standard.object(forKey: "uid"))
    }

}
