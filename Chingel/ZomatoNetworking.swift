//
//  ZomatoNetworking.swift
//  Chingel
//
//  Created by Sanket  Ray on 21/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

func getListOfRestaurants(start: Int, lat: String, long: String, sort : String, order: String, completion : @escaping (_ restaurant: Restaurant?) -> Void) {
    print("Finding restaurants")
    RestaurantsListViewController.start += 20
    let request = NSMutableURLRequest(url: URL(string: "https://developers.zomato.com/api/v2.1/search?start=\(start)&lat=\(lat)&lon=\(long)&sort=\(sort)&order=\(order)")!)
    request.addValue("107aa037e7df67d13089a966c701acc0", forHTTPHeaderField: "user-key")
    
    
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        
        guard error == nil else{
            print("error while requesting data")
            return
        }
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("status code was other than 2xx")
            return
        }
        guard let data = data else {
            print("request for data failed")
            return
        }
        
        let parsedResult : [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        }catch {
            print("error parsing data")
            return
        }
        
        
        
        guard let nearbyRes = parsedResult["restaurants"] as? [AnyObject] else {
            print("Could not get restaurant list")
            return
        }
        //            Iterate over all the available restaurants for the location
        for res in nearbyRes {
            guard let rest = res["restaurant"] as? [String:AnyObject] else {
                print("Could not get restaurant")
                return
            }
            guard let r = rest["R"] as? [String:AnyObject] else {
                print("Could not get restaurant id")
                return
            }
            //                 1.  ResID
            guard let resID = r["res_id"] as? Int else {
                print("Could not get ID")
                return
            }
            //                2. Cuisines
            guard let cuisines = rest["cuisines"] as? String else {
                print("Could not get cuisines")
                return
            }
            
            guard let location = rest["location"] else {
                print("Could not get location")
                return
            }
            
            //               3. address
            guard let address = location["address"]as? String else {
                print("Adress Unavailable")
                return
            }
            //                4. locality
            guard let locality = location["locality"]as? String else {
                print("locality Unavailable")
                return
            }
            //                5. latitude
            guard let latitude = location["latitude"]as? String else {
                print("latitude Unavailable")
                return
            }
            
            //                6. longitude
            guard let longitude = location["longitude"]as? String else {
                print("longitude Unavailable")
                return
            }
            //                7. name
            guard let name = rest["name"] as? String else {
                print("Could not find name of restaurant")
                return
            }
            //                8. average cost for two
            guard let averageCostForTwo = rest["average_cost_for_two"] as? Int else {
                print("Could not find price")
                return
            }
            //                9. currency
            guard let currency = rest["currency"]as? String else {
                print("Currency unit not found")
                return
            }
            //                10. image
            guard let imageURLString = rest["featured_image"]  as? String else {
                print("Featured Image not found")
                return
            }
            
            guard let ratingDetails = rest["user_rating"] else {
                print("could not find ratings")
                return
            }
            //                11. aggregateRating
            guard let aggregateRating = ratingDetails["aggregate_rating"] as? String else {
                print("Can't find rating")
                return
            }
            
            //                12. ratingColor
            guard let ratingColor = ratingDetails["rating_color"] as? String else {
                print("Can't find ratingColor")
                return
            }
            //              13. ratingText
            guard let ratingText = ratingDetails["rating_text"] as? String else {
                print("Can't find ratingText")
                return
            }
            //                14. votes
            guard let votes = ratingDetails["votes"] as? String else {
                print("Can't find votes")
                return
            }
            
            let restaurant = Restaurant(id: resID, name: name, address: address, locality: locality, latitude: latitude, longitude: longitude, cuisines: cuisines, costForTwo: averageCostForTwo, currency: currency, rating: aggregateRating, ratingText: ratingText, ratingColor: ratingColor, votes: votes, imageURLString: imageURLString)
            
            completion(restaurant)
        }
    }
    task.resume()
}
//func getNumberOfRestaurants(start: Int, lat: String, long: String, sort : String, order: String,completion : @escaping (_ numberOfRestaurants : Int)->Void){
//    let request = NSMutableURLRequest(url: URL(string: "https://developers.zomato.com/api/v2.1/search?start=\(start)&lat=\(lat)&lon=\(long)&sort=\(sort)&order=\(order)")!)
//    request.addValue("107aa037e7df67d13089a966c701acc0", forHTTPHeaderField: "user-key")
//    
//    
//    let session = URLSession.shared
//    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
//        
//        guard error == nil else{
//            print("error while requesting data")
//            return
//        }
//        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//            print("status code was other than 2xx")
//            return
//        }
//        guard let data = data else {
//            print("request for data failed")
//            return
//        }
//        
//        let parsedResult : [String:AnyObject]!
//        do {
//            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//        }catch {
//            print("error parsing data")
//            return
//        }
//        guard let numberOfRestaurants = parsedResult["results_found"] as? Int else {
//            print("Could not get number of  restuaranst")
//            return
//        }
//        completion(numberOfRestaurants)
//    }
//    task.resume()
//}
//
