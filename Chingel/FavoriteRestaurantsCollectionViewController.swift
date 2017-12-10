//
//  FavoriteRestaurantsCollectionViewController.swift
//  Chingel
//
//  Created by Sanket  Ray on 06/12/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import CoreLocation

class FavoriteRestaurantsCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {

    @IBOutlet var collection: UICollectionView!
    @IBOutlet weak var trash: UIBarButtonItem!
    
    
    var editingEnabled = false
    var index = [IndexPath]()
    var selectedRestaurant : FavoriteRestaurants?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemWidth = UIScreen.main.bounds.width/2 - 1
        let idemHeight = UIScreen.main.bounds.height/2.75 - 2
        let layout = UICollectionViewFlowLayout()
        //        layout.sectionInset = UIEdgeInsetsMake(5,0,5,0)
        layout.itemSize = CGSize(width: itemWidth, height: idemHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        collection.collectionViewLayout = layout
        
        do {
            try self.fetchedResultsController.performFetch()
        }catch{
            print("An error occured while fetching favorite restaurants")
        }
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1
        
        longPressGesture.delegate = self
        self.collection.addGestureRecognizer(longPressGesture)
        
    }
    
    
    @IBAction func deleteFavoriteRestaurants(_ sender: Any) {
        
        for restaurantIndex in index {
            let restaurant = fetchedResultsController.object(at: restaurantIndex)
            UserDefaults.standard.set(nil, forKey: "\(restaurant.id)")
            managedContext.delete(restaurant)
            do{
                try managedContext.save()
            }catch {
                print("Error while saving")
            }
        }
        index = [IndexPath]()
        trash.isEnabled = false
        collection.allowsMultipleSelection = false
        editingEnabled = false
    }
    
    
    
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            print("Hello")
            editingEnabled = true
            trash.isEnabled = true
            collection.allowsMultipleSelection = true
            let touchPoint = longPressGestureRecognizer.location(in: self.view)

            if let indexPath = collection.indexPathForItem(at: touchPoint) {
                index.append(indexPath)
                print(index)
                let cell = collectionView?.cellForItem(at: indexPath)
                cell?.backgroundColor = .gray
                cell?.alpha = 0.5
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! FavoriteRestaurantDetailTableViewController
        destination.restaurant = selectedRestaurant
        destination.userLocation = CLLocation(latitude: CLLocationDegrees(RestaurantsListViewController.locationLatitude)!, longitude: CLLocationDegrees(RestaurantsListViewController.locationLongitude)!)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if (cell?.isSelected)! && !editingEnabled {
            collectionView.deselectItem(at: indexPath, animated : true)
            print(index)
            selectedRestaurant = fetchedResultsController.object(at: indexPath)
        }
        if !editingEnabled {
            performSegue(withIdentifier: "FavoriteRestaurantDetail", sender: self)
        }
        if editingEnabled {
            cell?.backgroundColor = .gray
            cell?.alpha = 0.5
            index = collectionView.indexPathsForSelectedItems!
            print(index.count)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let ind = collectionView.indexPathsForSelectedItems {
            index = ind
        }
        print(index,"🍈")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .clear
        cell?.alpha = 1

        if editingEnabled && index.count == 0 {
            print(index,"🥕")
            trash.isEnabled = false
            collection.allowsMultipleSelection = false
            editingEnabled = false
            print("This is working")
            
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<FavoriteRestaurants> in
        let fetchRequest = NSFetchRequest<FavoriteRestaurants>(entityName : "FavoriteRestaurants")
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let favoriteRestaurant = fetchedResultsController.object(at: indexPath)
        
        cell.name.text = favoriteRestaurant.name
        cell.rating.text = favoriteRestaurant.rating
        cell.rating.backgroundColor = hexStringToUIColor(hex: "\(favoriteRestaurant.ratingColor!)")
        
        let url = URL(string : favoriteRestaurant.imageURLString!)
        cell.image.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveDownload])
        
        return cell
    }

}


extension FavoriteRestaurantsCollectionViewController : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath{
                self.collection.insertItems(at: [insertIndexPath])
            }
        case .delete:
            if let deleteIndexpath = indexPath{
                self.collection.deleteItems(at: [deleteIndexpath])
            }
        case .move:
            if let deleteIndexPath = indexPath {
                self.collection.deleteItems(at: [deleteIndexPath])
            }
            if let insertIndexPath = newIndexPath {
                self.collection.insertItems(at: [insertIndexPath])
            }
        default:
            print()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.collection.insertSections(sectionIndexSet as IndexSet)
        case .delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.collection.deleteSections(sectionIndexSet as IndexSet)
        default:
            print("Nothing")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collection.numberOfItems(inSection: 0)
    }
}
