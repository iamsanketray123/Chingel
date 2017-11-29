//
//  RestaurantsListViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 20/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import CoreLocation
import SVProgressHUD
import FBSDKLoginKit

class RestaurantsListViewController: UIViewController {
    
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet var sortingList: UIView!
    
    var restaurants = [Restaurant]()
    var selectedRestaurant : Restaurant?
    
    static var start = 0
    static var navigationTitleButton = UIButton(type: .system)
    static var locationName = ""
    static var locationLatitude = ""
    static var locationLongitude = ""
    static var sort = "rating"
    static var order = "desc"
    static var locationChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        SVProgressHUD.show(withStatus: "Loading...")
        SVProgressHUD.setDefaultMaskType(.gradient)
        
        getLocationDataFromFirebase { (locationName, locationLatitude, locationLongitude) in
            RestaurantsListViewController.locationName = locationName!
            RestaurantsListViewController.locationLatitude =  locationLatitude!
            RestaurantsListViewController.locationLongitude = locationLongitude!
            print(RestaurantsListViewController.locationName,RestaurantsListViewController.locationLatitude,RestaurantsListViewController.locationLongitude,"🍕")
            
            self.createNavigationTitleButton(locationName : locationName!)
            
            RestaurantsListViewController.start = 0
            self.restaurants = [Restaurant]()
            self.table.reloadData()
            
            getListOfRestaurants(start: RestaurantsListViewController.start, lat: RestaurantsListViewController.locationLatitude, long: RestaurantsListViewController.locationLongitude, sort: RestaurantsListViewController.sort, order: RestaurantsListViewController.order, completion: { (restaurant) in
                
                self.restaurants.append(restaurant!)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.table.reloadData()
                }
                print(self.restaurants.count,"🍗")
                
            })
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if RestaurantsListViewController.locationChanged {
            SVProgressHUD.show(withStatus: "Loading...")
            SVProgressHUD.setDefaultMaskType(.gradient)
            
            print("🎾",RestaurantsListViewController.locationLatitude,RestaurantsListViewController.locationLongitude,"🎾")
            UIApplication.shared.statusBarView?.backgroundColor = nil
            
            RestaurantsListViewController.start = 0
            self.restaurants = [Restaurant]()
            table.reloadData()
            

            getListOfRestaurants(start: RestaurantsListViewController.start, lat: RestaurantsListViewController.locationLatitude, long: RestaurantsListViewController.locationLongitude, sort: RestaurantsListViewController.sort, order: RestaurantsListViewController.order, completion: { (restaurant) in
                
                
                self.restaurants.append(restaurant!)
                DispatchQueue.main.async {
                    self.table.reloadData()
                    SVProgressHUD.dismiss()
                }
                print(self.restaurants.count,"🍛")
                
            })
        }
        
    }
    
    //    This doesn't work even though all the superviews have user interaction enabled.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch : UITouch? = touches.first
        if touch?.view != sortingList {
            print("Touched outside sortinglist view")
            sortingList.isHidden = true
        }
    }
    
   @IBAction func logout() {
//        FBSDKLoginManager().logOut()
        try! Auth.auth().signOut()
        UserDefaults.standard.set(nil, forKey: "uid")
        let controller = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func searchAfterSorting(_ sender: Any) {
        //        print(restaurants.count)
        RestaurantsListViewController.start = 0
        self.restaurants = [Restaurant]()
        table.reloadData()
        
        getListOfRestaurants(start: RestaurantsListViewController.start, lat: RestaurantsListViewController.locationLatitude, long: RestaurantsListViewController.locationLongitude, sort: RestaurantsListViewController.sort, order: RestaurantsListViewController.order, completion: { (restaurant) in
            
            
            self.restaurants.append(restaurant!)
            DispatchQueue.main.async {
                self.table.reloadData()
                
            }
        })
        
    }
    
    @IBAction func sortByAction(_ sender: Any) {
        let centerX = (sortByButton.frame.origin.x + (sortByButton.frame.width/2))
        let centerY = (sortByButton.frame.height + (sortingList.frame.height/2))
        
        UIView.animate(withDuration: 0.2) {
            self.view.addSubview(self.sortingList)
            self.sortingList.center = CGPoint(x: centerX, y: centerY)
        }
    }
    
    @IBAction func sortingOptionTapped(_ sender: UIButton) {
        sortByButton.setTitle(sender.currentTitle, for: .normal)
        
        if sender.currentTitle! == "Rating High to Low" {
            RestaurantsListViewController.sort = "rating"
            RestaurantsListViewController.order = "desc"
        }
        else if sender.currentTitle! == "Price High to Low" {
            RestaurantsListViewController.sort = "cost"
            RestaurantsListViewController.order = "desc"
        }
        else if sender.currentTitle! == "Rating Low to High" {
            RestaurantsListViewController.sort = "rating"
            RestaurantsListViewController.order = "asc"
        }
        else if sender.currentTitle! == "Price Low to High" {
            RestaurantsListViewController.sort = "cost"
            RestaurantsListViewController.order = "asc"
        }
        
        UIView.animate(withDuration: 0.2) {
            self.sortingList.removeFromSuperview()
        }
    }
    
    
    
    
    func createNavigationTitleButton(locationName : String) {
        RestaurantsListViewController.navigationTitleButton.setImage(UIImage(named: "markerIcon"), for: .normal)
        RestaurantsListViewController.navigationTitleButton.setTitle(locationName, for: .normal)
        RestaurantsListViewController.navigationTitleButton.setTitleColor(UIColor.white, for: .normal)
        RestaurantsListViewController.navigationTitleButton.titleLabel?.font = UIFont(name: "Avenir Next", size: 16)
        RestaurantsListViewController.navigationTitleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        RestaurantsListViewController.navigationTitleButton.addTarget(self, action: #selector(self.selectLocation(button:)), for: .touchUpInside)
        
        self.navigationItem.titleView = RestaurantsListViewController.navigationTitleButton
    }
    
    @objc func selectLocation(button: UIButton) {
        performSegue(withIdentifier: "changeLocation", sender: self)
        
    }
    
    func getLocationDataFromFirebase (completion : @escaping (_ locationName: String?, _ locationLatitude : String?, _ locationLongitude : String?)-> Void) {
        
        let uid = UserDefaults.standard.object(forKey : "uid") as! String
        databaseReference.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:AnyObject] else {
                print("Could not get dictionary")
                return
            }
            
            completion(dict["locationName"] as! String, dict["locationLatitude"] as! String, dict["locationLongitude"] as! String)
            
            
        }
        
    }
    
}

extension RestaurantsListViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.img.image = nil
        let restaurant = restaurants[indexPath.row]
        //        cell.img.sd_setImage(with: nil, completed: nil)
        
        cell.backgroundCardView.backgroundColor = UIColor.white
        cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        cell.backgroundCardView.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = false
        cell.backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cell.backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.backgroundCardView.layer.shadowOpacity = 0.8
        
        
        if restaurant.ratingText == "Not rated" {
            cell.rating.text = "New"
        }
        else {
            cell.rating.text = restaurant.rating
        }
        
        cell.rating.backgroundColor = hexStringToUIColor(hex: restaurant.ratingColor)
        cell.rating.layer.cornerRadius = 3.0
        cell.rating.layer.masksToBounds = true
        cell.restaurantName.text = restaurant.name
        cell.restaurantLocality.text = restaurant.address
        
        let url = URL(string : restaurant.imageURLString!)
        cell.img.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveDownload])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRestaurant = restaurants[indexPath.row]
        tableView.deselectRow(at: indexPath, animated : true)
        performSegue(withIdentifier: "toDetailView", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            let destination = segue.destination as! RestaurantDetailTableViewController
            destination.restaurant = selectedRestaurant
            destination.userLocation = CLLocation(latitude: CLLocationDegrees(RestaurantsListViewController.locationLatitude)!, longitude: CLLocationDegrees(RestaurantsListViewController.locationLongitude)!)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //                DispatchQueue.main.async {
        //                    cell.alpha = 0
        //                    UIView.animate(withDuration: 0.5) {
        //                        cell.alpha = 1.0
        //                    }
        //                }
        let lastRestaurant = restaurants.count - 1
        if indexPath.row == lastRestaurant {
            
            getListOfRestaurants(start: RestaurantsListViewController.start, lat: RestaurantsListViewController.locationLatitude, long: RestaurantsListViewController.locationLongitude, sort: RestaurantsListViewController.sort, order: RestaurantsListViewController.order, completion: { (restaurant) in
                
                self.restaurants.append(restaurant!)
                DispatchQueue.main.async {
                    self.table.reloadData()
                    
                }
            })
        }
    }
}
