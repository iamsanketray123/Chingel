//
//  HelperMethods.swift
//  Chingel
//
//  Created by Sanket  Ray on 26/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

enum LoginError : Error {
    case incompleteForm
    case invalidEmail
    case incorrectPasswordLength
}
enum SignupError : Error {
    case incompleteForm
    case invalidEmail
    case incorrectPasswordLength
}

extension String {
    var isValidEmail : Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
}

class Alert {
    class func showBasic(title: String, message : String, vc : UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated : true)
    }
}
