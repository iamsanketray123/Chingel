//
//  Restaurant.swift
//  Chingel
//
//  Created by Sanket  Ray on 21/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit


struct Restaurant {
    
    let id : Int
    let name : String
    let address : String
    let locality : String
    let latitude : String
    let longitude : String
    let cuisines : String
    let costForTwo : Int
    let currency : String
    let rating : String
    let ratingText : String
    let ratingColor : String
    let votes : String
    let imageURLString : String?
    
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
