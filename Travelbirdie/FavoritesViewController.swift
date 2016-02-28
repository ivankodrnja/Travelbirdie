//
//  FavoritesViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 25/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noFavoritesContainerView: UIView!
    
    // will serve for caching images
    var cache:NSCache!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // initialize cache
        self.cache = NSCache()
        // fetch results
        do {
            try fetchedResultsController.performFetch()
        
        } catch {
            print(error)
        }
        fetchedResultsController.delegate = self
        
    }

    override func viewWillAppear(animated: Bool) {

        // count the number of stored favorite apartments
        let sectionInfo = fetchedResultsController.sections![0]
        let numberOfObjects = sectionInfo.numberOfObjects
        // if there are favorite apartments show them
        if numberOfObjects > 0 {
            noFavoritesContainerView.hidden = true
            // otherwise show a message
        } else {
            noFavoritesContainerView.hidden = false
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Apartment")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 350
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        
        let apartment = fetchedResultsController.objectAtIndexPath(indexPath) as! Apartment
        
        let cellReuseIdentifier = "SearchResultViewCell"
        tableView.registerNib(UINib(nibName: "SearchResultViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as! SearchResultViewCell
        
        configureCell(cell, withApartment: apartment, atIndexPath: indexPath)
    
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("FavoriteApartmentDetailViewController") as! FavoriteApartmentDetailViewController
        
        let apartment = fetchedResultsController.objectAtIndexPath(indexPath) as! Apartment
        // set apartment object in the detail VC
        controller.apartment = apartment
        // set the first image to show in the detail VC
        
        if(self.cache.objectForKey(indexPath.row) != nil){
            controller.firstImage = (self.cache.objectForKey(indexPath.row) as? UIImage)!
        }
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                
                // Here we get the actor, then delete it from core data
                let apartment = fetchedResultsController.objectAtIndexPath(indexPath) as! Apartment
                sharedContext.deleteObject(apartment)
                CoreDataStackManager.sharedInstance().saveContext()
                
            default:
                break
            }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                // check for previously cached images at indexPath.row
                if(self.cache.objectForKey(newIndexPath!.row) != nil){
                    self.cache.removeObjectForKey((newIndexPath?.row)!)
                }
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    
                
            case .Delete:
                self.cache.removeObjectForKey((indexPath?.row)!)
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                self.cache.removeObjectForKey((indexPath?.row)!)
                self.cache.removeObjectForKey((newIndexPath?.row)!)
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! SearchResultViewCell
                let apartment = controller.objectAtIndexPath(indexPath!) as! Apartment
                self.configureCell(cell, withApartment: apartment, atIndexPath: indexPath!)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
    // MARK: - Configure Cell
    
    // This method is new. It contains the code that used to be in cellForRowAtIndexPath.
    // Refactoring it into its own method allow the logic to be reused in the fetch results
    // delegate methods
    
    func configureCell(cell: SearchResultViewCell, withApartment apartment: Apartment, atIndexPath indexPath: NSIndexPath) {
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        //***** set the apartment image *****//
        cell.apartmentImageView.clipsToBounds = true
        
        // default placeholder image
        cell.apartmentImageView.image = UIImage(named: "loadingImage")

        
        // first check if the image is cached
        if(self.cache.objectForKey(indexPath.row) != nil){
            print(indexPath.row)
            cell.apartmentImageView.image = self.cache.objectForKey(indexPath.row) as? UIImage
        } else {
            // if the image is not cached download it
            // get the first object in array of photos
            let photo = apartment.photos[0].path
            
            if photo != "" {
                
                // Start the task that will eventually download the image
                let task = ZilyoClient.sharedInstance().taskForImageWithSize(photo) { data, error in
                    
                    if let error = error {
                        print("Title download error: \(error.localizedDescription) url:\(photo)")
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.apartmentImageView.image = UIImage(named: "noImage")
                        }
                    }
                    
                    // no error ocurred, show the image
                    if let data = data {
                        // update the cell on the main thread
                        dispatch_async(dispatch_get_main_queue()) {
                            // check whether the cell is visible on screen before updating the image
                            if let updateCell : SearchResultViewCell = (self.tableView.cellForRowAtIndexPath(indexPath)) as? SearchResultViewCell{
                                
                                // create the image, show it and cache it
                                let image:UIImage!  = UIImage(data: data)
                                
                                if let secureImage = image {
                                    updateCell.apartmentImageView?.image = secureImage
                                    self.cache.setObject(secureImage, forKey: indexPath.row)
                                }
                                
                            }
                        }
                    }
                }
                
                // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
                cell.taskToCancelifCellIsReused = task
                
            }
            
        }
        //***** end of setting the apartment image *****//
        
        
        //***** set the apartment name or heading *****//
        cell.apartmentNameLabel.text = apartment.name
        
        //***** set the number of bedrooms *****//
        let bedroomsNumber = apartment.attributes[0].bedrooms
        cell.bedroomsNumberLabel.text = "\(bedroomsNumber)"
        
        //***** set the number of people that sleep *****//
        let sleepsNumber = apartment.attributes[0].occupancy
        cell.sleepsNumberLabel.text = "\(sleepsNumber)"
        
        //***** set the apartment location *****//
        cell.locationLabel.text = apartment.location
        
        
        //***** set the the daily price *****//
        let dailyPrice = apartment.prices[0].nightly
        cell.dailyPriceLabel.text = "\(dailyPrice)"
    }
    
}
