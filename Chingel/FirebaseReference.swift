//
//  FirebaseReference.swift
//  Chingel
//
//  Created by Sanket  Ray on 19/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import Foundation
import Firebase

let databaseReference = Database.database().reference(fromURL: "https://friendlychat-19ed7.firebaseio.com/")
let storageReference = Storage.storage().reference(forURL: "gs://friendlychat-19ed7.appspot.com")
let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
