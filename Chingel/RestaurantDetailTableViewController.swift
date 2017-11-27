//
//  RestaurantDetailTableViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 21/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation
import UberRides
import MapKit

class RestaurantDetailTableViewController: UITableViewController, MKMapViewDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantRating: UILabel!
    @IBOutlet weak var numberOfVotes: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var directions: UIButtonX!
    
    var headerHeight: CGFloat = 220
    var headerView : UIView!
    var restaurant : Restaurant?
    var userLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateUberButton(userLocation : userLocation!, restaurantLocation : CLLocation(latitude: CLLocationDegrees(restaurant!.latitude)!, longitude: CLLocationDegrees(restaurant!.longitude)!), dropOffNickname: restaurant!.name)
        
        setupMap()
        
        restaurantName.text = restaurant?.name
        restaurantRating.text = restaurant?.rating
        restaurantRating.backgroundColor = hexStringToUIColor(hex: (restaurant?.ratingColor)!)
        restaurantRating.layer.cornerRadius = 3.0
        restaurantRating.layer.masksToBounds = true
        numberOfVotes.text = "Based on \(String(describing: restaurant!.votes)) reviews"
        restaurantAddress.text = restaurant?.address
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        headerView = table.tableHeaderView
        table.tableHeaderView = nil
        table.addSubview(headerView)
        
        table.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        table.contentOffset = CGPoint(x: 0, y: -headerHeight)
        
        let url = URL(string: (restaurant?.imageURLString)!)
        restaurantImage.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveDownload])

        
        updateHeaderView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(restaurant?.latitude,restaurant?.longitude,"🍱")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#C5170C")
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        UIApplication.shared.statusBarView?.backgroundColor = nil
        RestaurantsListViewController.navigationTitleButton.tintColor = .white

    }


    @IBAction func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getDirections(_ sender : Any) {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=\(userLocation!.coordinate.latitude),\(userLocation!.coordinate.longitude)&daddr=\(restaurant!.latitude),\(restaurant!.longitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
        }else {
            print("cant open google maps")
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateHeaderView()
        
        var offset = (scrollView.contentOffset.y+220) / 110
        if offset > 1 {
            offset = 1
            self.navigationController?.navigationBar.tintColor = UIColor(hue: 4, saturation: offset, brightness: 1, alpha: 1)
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
            UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
            
        } else {
            self.navigationController?.navigationBar.tintColor = UIColor(hue: 1, saturation: offset, brightness: 1, alpha: 1)
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
            UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
        }
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -headerHeight, width: table.bounds.width, height: headerHeight)
        if table.contentOffset.y < -headerHeight {
            headerRect.origin.y = table.contentOffset.y
            headerRect.size.height = -table.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    func setupMap() {

        print(restaurant?.latitude,restaurant?.longitude,"🍵")
        map.delegate = self
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(restaurant!.latitude)!, CLLocationDegrees(restaurant!.longitude)!)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = restaurant!.name
        map.addAnnotation(annotation)
    }
    
    
    func generateUberButton(userLocation : CLLocation, restaurantLocation : CLLocation, dropOffNickname : String){
        let button = RideRequestButton()
        view.addSubview(button)
        print("🍒",button.frame,"🍒")
        button.frame = CGRect(x: 16, y: Int(directions.frame.origin.y + 298), width: 343, height: 50)
        
        let ridesClient = RidesClient()
        let dropOffLocation = restaurantLocation
        let pickUpLocation = userLocation
        let builder = RideParametersBuilder()
        builder.pickupLocation = pickUpLocation
        builder.pickupNickname = "Current Location"
        builder.dropoffLocation = dropOffLocation
        builder.dropoffNickname = dropOffNickname

        var productID = ""
        ridesClient.fetchProducts(pickupLocation: pickUpLocation) { (product, response) in
            print(product.count,"🍚")
            if product.count > 0 {
                productID = product[0].productID
            } else {
                productID = ""
            }
            print("🥒\(productID)")
        }


        ridesClient.fetchPriceEstimates(pickupLocation: pickUpLocation, dropoffLocation: dropOffLocation) { (price, response) in

            if productID != "" {
                print(price[0].estimate,"🍚")
            }
        }

        ridesClient.fetchTimeEstimates(pickupLocation: pickUpLocation) { (time, response) in
            if productID != "" {
                print("🥕",time[0].estimate,"🥕")
            }
        }

        ridesClient.fetchRideRequestEstimate(parameters: builder.build()) { (rideEstimate, response) in
            builder.upfrontFare = rideEstimate?.fare
            print(rideEstimate,"🥗")
        }



        builder.productID = productID

        button.setContent()
        button.rideParameters = builder.build()
        button.loadRideInformation()
    }
    
}
