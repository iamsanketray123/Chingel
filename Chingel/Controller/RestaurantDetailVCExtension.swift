//
//  RestaurantDetailVCExtension.swift
//  Chingel
//
//  Created by Sanket  Ray on 04/12/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import Foundation
import CoreData

extension RestaurantDetailTableViewController {
    func addRestaurantToFavorites(rest: Restaurant) {
        let newRestaurant = NSEntityDescription.insertNewObject(forEntityName: "FavoriteRestaurants", into: managedContext) as! FavoriteRestaurants
        print(managedContext.persistentStoreCoordinator.debugDescription,"📩")

        UserDefaults.standard.set(true, forKey: "\(rest.id)")
        
        newRestaurant.creationDate = Date()
        newRestaurant.id = Int32(rest.id)
        newRestaurant.name = rest.name
        newRestaurant.address = rest.address
        newRestaurant.locality = rest.locality
        newRestaurant.latitude = Double(rest.latitude)!
        newRestaurant.longitude = Double(rest.longitude)!
        newRestaurant.cuisines = rest.cuisines
        newRestaurant.costForTwo = Int32(rest.costForTwo)
        newRestaurant.currency = rest.currency
        newRestaurant.rating = rest.rating
        newRestaurant.ratingText = rest.ratingText
        newRestaurant.ratingColor = rest.ratingColor
        newRestaurant.votes = rest.votes
        newRestaurant.imageURLString = rest.imageURLString
        newRestaurant.hasOnlineDelivery = Int32(rest.hasOnlineDelivery)
        newRestaurant.isDeliveringNow = Int32(rest.isDeliveringNow)
        newRestaurant.hasTableBooking = Int32(rest.hasTableBooking)
        
        do {
            try managedContext.save()
            print("Restaurant added to core data")
        }catch {
            print("Error saving restaurant to core data")
        }
        
    }
    func deleteRestaurantFromFavorites(rest : Restaurant) {
        UserDefaults.standard.set(false, forKey: "\(rest.id)")

        var restaurantToDelete : FavoriteRestaurants?
        let fetchRequest = NSFetchRequest<FavoriteRestaurants>(entityName: "FavoriteRestaurants")
        fetchRequest.predicate = NSPredicate(format: "id == \(rest.id)")
        do {
             let rest = try managedContext.fetch(fetchRequest)
             restaurantToDelete = rest[0]
             print("found restaurant to delete")
        }catch {
            print("Error getting restaurants from database")
        }
        managedContext.delete(restaurantToDelete!)
        do {
            try managedContext.save()
        }catch {
            print("Error saving after deleting restaurant")
        }
    }
}








