//
//  UIViewX.swift
//  Chingel
//
//  Created by Sanket  Ray on 06/12/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//
import UIKit

@IBDesignable class DesignView: UIView {
    
    
    @IBInspectable var cornerRadius : CGFloat = 3
    @IBInspectable var shadowColor : UIColor? = UIColor.black
    @IBInspectable var shadowOffSetWidth : Int = 2
    @IBInspectable var shadowOffSetHeight : Int = 2
    @IBInspectable var shadowOpacity : Float = 0.2
    
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffSetWidth, height: shadowOffSetHeight)
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = shadowOpacity
    }
    
    
    
}
