//
//  UITextFieldX.swift
//  Chingel
//
//  Created by Sanket  Ray on 19/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

@IBDesignable
class UITextFieldX: UITextField {

    @IBInspectable var leftImage : UIImage? {
        didSet {
            updateLeftView()
        }
    }
    
    @IBInspectable var leftPadding : CGFloat = 0 {
        didSet {
            updateLeftView()
        }
    }
    
    func updateLeftView() {
        if let image = leftImage {
            leftViewMode = .always
            let imageView = UIImageView(frame : CGRect(x: leftPadding, y: 0, width: 27, height: 20))
            imageView.image = image
            
            let width = leftPadding + 25
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
            view.addSubview(imageView)
            
            leftView = view
            
        } else {
//            image is nil
            leftViewMode = .never
        }
    }


}












