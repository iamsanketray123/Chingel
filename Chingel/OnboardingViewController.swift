//
//  OnboardingViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 17/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    

    @IBOutlet weak var onboardingView: OnboardingView!
    @IBOutlet weak var getStarted: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingView.dataSource = self
        onboardingView.delegate = self
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 1 {
            if getStarted.alpha == 1 {
                UIView.animate(withDuration: 0.1, animations: {
                    self.getStarted.alpha = 0
                })
            }
        }
    }
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2 {
            UIView.animate(withDuration: 0.3, animations: {
                self.getStarted.alpha = 1
            })
        }
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroundColorOne = UIColor(red: 217/255, green: 72/255, blue: 89/255, alpha: 1)
        let backgroundColorTwo = UIColor(red: 106/255, green: 166/255, blue: 211/255, alpha: 1)
        let backgroundColorThree = UIColor(red: 168/255, green: 200/255, blue: 78/255, alpha: 1)

        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        
        return [(#imageLiteral(resourceName: "dish"), "Find the Perfect Place", "Search from thousands of Restaurants and find the place, that suits your taste.", UIImage(),backgroundColorOne, UIColor.white, UIColor.white, titleFont, descriptionFont),
                
                (#imageLiteral(resourceName: "car"), "Ride with Uber", "After you have found the right palce, ride with Uber or get the directions to the place", UIImage(),backgroundColorTwo, UIColor.white, UIColor.white, titleFont, descriptionFont),
                
                (#imageLiteral(resourceName: "login"), "Register", "But first, you need to register with us :)", UIImage(),backgroundColorThree, UIColor.white, UIColor.white, titleFont, descriptionFont)][index]
        
    }
}
