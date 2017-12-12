//
//  MKMapViewX.swift
//  Chingel
//
//  Created by Sanket  Ray on 24/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable
class MKMapViewX: MKMapView {
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }


}
