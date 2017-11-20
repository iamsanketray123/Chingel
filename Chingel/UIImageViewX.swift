//
//  UIImageViewX.swift
//  Chingel
//
//  Created by Sanket  Ray on 19/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

@IBDesignable
class UIImageViewX: UIImageView {

    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

}
