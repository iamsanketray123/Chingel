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
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var cuisines: UILabel!
    @IBOutlet weak var averageCost: UILabel!
    @IBOutlet weak var hasOnlineDelivery: UIImageView!
    @IBOutlet weak var isDeliveringNow: UIImageView!
    @IBOutlet weak var hasTableBooking: UIImageView!
    @IBOutlet weak var heartImage: UIImageView!

    
    var liked : Bool = false
    var heartImages = [UIImage]()
    var undoHeart = [UIImage]()
    var headerHeight: CGFloat = 220
    var headerView : UIView!
    var restaurant : Restaurant?
    var userLocation : CLLocation?
    let restaurantTitlelabel = UILabel()
    
    static var viewIsDark = true


    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        setupGradientView()
        
        updateCuisinesAndPricing()
        
        RestaurantsListViewController.locationChanged = false
        
        generateUberButton(userLocation : userLocation!, restaurantLocation : CLLocation(latitude: CLLocationDegrees(restaurant!.latitude)!, longitude: CLLocationDegrees(restaurant!.longitude)!), dropOffNickname: restaurant!.name)
        
        setupMap()
        
        restaurantName.text = restaurant?.name
        restaurantRating.text = restaurant?.rating
        restaurantRating.backgroundColor = hexStringToUIColor(hex: (restaurant?.ratingColor)!)
        restaurantRating.layer.cornerRadius = 3.0
        restaurantRating.layer.masksToBounds = true
        numberOfVotes.text = "Based on \(String(describing: restaurant!.votes)) reviews"
        restaurantAddress.text = restaurant?.address
        let url = URL(string: (restaurant?.imageURLString)!)
        restaurantImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground,.progressiveDownload])
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        headerView = table.tableHeaderView
        table.tableHeaderView = nil
        table.addSubview(headerView)
        
        table.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        table.contentOffset = CGPoint(x: 0, y: -headerHeight)
        
        heartImages = createImageArray(total: 24, imagePrefix: "heart")
        undoHeart = reverseImageArray(total: 24, imagePrefix: "heart")

        setupRestaurantLabel()
        
        updateHeaderView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(restaurant?.latitude,restaurant?.longitude,"🍱")
        if (UserDefaults.standard.object(forKey: "\(restaurant!.id)") as? Bool == true) {
            liked = true
            print("Restaurant has been added to favorites before this")
            heartImage.image = UIImage(named: "heart-23.png")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#C5170C")
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        UIApplication.shared.statusBarView?.backgroundColor = nil
        self.navigationController?.navigationBar.tintColor = .white
        makeViewDark()

    }

    

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getDirections(_ sender : Any) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=\(userLocation!.coordinate.latitude),\(userLocation!.coordinate.longitude)&daddr=\(restaurant!.latitude),\(restaurant!.longitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
        }else {
            Alert.showBasic(title: "Google Maps Not Found!", message: "Please install Google Maps to be able to use this feature to get directions to the Restaurant.", vc: self)
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
            restaurantTitlelabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: offset)
            makeViewLight()
            
        } else {
            self.navigationController?.navigationBar.tintColor = UIColor(hue: 1, saturation: offset, brightness: 1, alpha: 1)
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
            UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
            restaurantTitlelabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: offset)
            makeViewDark()
        }
    }
    
    fileprivate func setupGradientView() {
        let newLayer = CAGradientLayer()
        newLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        newLayer.frame = gradientView.frame
        
        gradientView.layer.addSublayer(newLayer)
    }
    fileprivate func setupRestaurantLabel() {
        restaurantTitlelabel.text = restaurant!.name
        restaurantTitlelabel.textColor = .clear
        restaurantTitlelabel.font = UIFont(name: "Avenir Next", size: 16)
        restaurantTitlelabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.navigationItem.titleView = restaurantTitlelabel
    }
    
    func updateCuisinesAndPricing() {
        cuisines.text = restaurant!.cuisines
        averageCost.text = "\(restaurant!.currency) \(restaurant!.costForTwo) for two (approx.)"
        
        restaurant!.hasOnlineDelivery == 1 ? (hasOnlineDelivery.image = UIImage(named: "available")) : (hasOnlineDelivery.image = UIImage(named: "unavailable"))
        restaurant!.isDeliveringNow == 1 ? (isDeliveringNow.image = UIImage(named: "available")) : (isDeliveringNow.image = UIImage(named: "unavailable"))
        restaurant!.hasTableBooking == 1 ? (hasTableBooking.image = UIImage(named: "available")) : (hasTableBooking.image = UIImage(named: "unavailable"))
        
    }
    
    func makeViewDark() {
        RestaurantDetailTableViewController.viewIsDark = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func makeViewLight() {
        RestaurantDetailTableViewController.viewIsDark = false
        setNeedsStatusBarAppearanceUpdate()
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
        button.frame = CGRect(x: 16, y: Int(directions.frame.origin.y + 298), width: Int(view.frame.width - 32), height: 50)
        
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

            if price.count > 0 {
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
    

    @IBAction func startAnimation(_ sender: UIButton) {
        
        if !liked {
            animateHeart(heartImages) { (image) in
                self.heartImage.image = image
                self.liked = true
                self.addRestaurantToFavorites(rest: self.restaurant!)
                DispatchQueue.main.async{
                    self.showToast(message : "Restaurant saved to Favorites")
                }
                print("complete")
            }
        }else if liked {
            print("need to animte back")
            animateHeart(undoHeart, completion: { (image) in
                self.heartImage.image = image
                self.liked = false
                self.deleteRestaurantFromFavorites(rest: self.restaurant!)
                DispatchQueue.main.async{
                self.showToast(message : "Restaurant removed from Favorites")
                }
            })
        }
    }
    
    
    func createImageArray (total : Int, imagePrefix : String) -> [UIImage] {
        var imageArray : [UIImage] = []
        for imageCount in 0..<total {
            let imageName = "\(imagePrefix)-\(imageCount).png"
            let image = UIImage(named: imageName)!
            imageArray.append(image)
        }
        return imageArray
    }
    func reverseImageArray(total: Int, imagePrefix: String) -> [UIImage] {
        var imageArray: [UIImage] = []
        for imageCount in (0..<total).reversed() {
            let imageName = "\(imagePrefix)-\(imageCount).png"
            let image = UIImage(named: imageName)!
            imageArray.append(image)
        }
        return imageArray
    }
    
    func animateHeart(_ imageArray : [UIImage],completion: @escaping (_ image : UIImage?)->Void) {
        
        heartImage.animationImages = imageArray
        heartImage.animationDuration = 1
        heartImage.animationRepeatCount = 1
        completion(imageArray.last!)
        heartImage.startAnimating()
        
    }
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 10, y: self.view.center.y, width: 355, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 20;
        toastLabel.clipsToBounds  =  true
        self.table.addSubview(toastLabel)
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

}
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if RestaurantDetailTableViewController.viewIsDark {
            return .lightContent
        }else {
            return .default
        }
    }
}

