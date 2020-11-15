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
    var cache:NSCache<AnyObject, AnyObject>!
    
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

    override func viewWillAppear(_ animated: Bool) {

        // count the number of stored favorite apartments
        let sectionInfo = fetchedResultsController.sections![0]
        let numberOfObjects = sectionInfo.numberOfObjects
        // if there are favorite apartments show them
        if numberOfObjects > 0 {
            noFavoritesContainerView.isHidden = true
            // otherwise show a message
        } else {
            noFavoritesContainerView.isHidden = false
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<Apartment> = {
        
        let fetchRequest = NSFetchRequest<Apartment>(entityName: "Apartment")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Get cell type */
        
        let apartment = fetchedResultsController.object(at: indexPath) 
        
        let cellReuseIdentifier = "SearchResultViewCell"
        tableView.register(UINib(nibName: "SearchResultViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! SearchResultViewCell
        
        configureCell(cell, withApartment: apartment, atIndexPath: indexPath)
    
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "FavoriteApartmentDetailViewController") as! FavoriteApartmentDetailViewController
        
        let apartment = fetchedResultsController.object(at: indexPath) 
        // set apartment object in the detail VC
        controller.apartment = apartment
        // set the first image to show in the detail VC
        
        if(self.cache.object(forKey: indexPath.row as AnyObject) != nil){
            controller.firstImage = (self.cache.object(forKey: indexPath.row as AnyObject) as? UIImage)!
        }
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
            
            switch (editingStyle) {
            case .delete:
                
                // Here we get the actor, then delete it from core data
                let apartment = fetchedResultsController.object(at: indexPath) 
                sharedContext.delete(apartment)
                CoreDataStackManager.sharedInstance().saveContext()
                
            default:
                break
            }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
            
            switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                
            default:
                return
            }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            
            switch type {
            case .insert:
                // check for previously cached images at indexPath.row
                if(self.cache.object(forKey: newIndexPath!.row as AnyObject) != nil){
                    self.cache.removeObject(forKey: (newIndexPath?.row)! as AnyObject)
                }
                tableView.insertRows(at: [newIndexPath!], with: .fade)
    
                
            case .delete:
                self.cache.removeObject(forKey: (indexPath?.row)! as AnyObject)
                tableView.deleteRows(at: [indexPath!], with: .fade)
                
            case .update:
                self.cache.removeObject(forKey: (indexPath?.row)! as AnyObject)
                self.cache.removeObject(forKey: (newIndexPath?.row)! as AnyObject)
                let cell = tableView.cellForRow(at: indexPath!) as! SearchResultViewCell
                let apartment = controller.object(at: indexPath!) as! Apartment
                self.configureCell(cell, withApartment: apartment, atIndexPath: indexPath!)
                
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                
            }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    
    // MARK: - Configure Cell
    
    // This method is new. It contains the code that used to be in cellForRowAtIndexPath.
    // Refactoring it into its own method allow the logic to be reused in the fetch results
    // delegate methods
    
    func configureCell(_ cell: SearchResultViewCell, withApartment apartment: Apartment, atIndexPath indexPath: IndexPath) {
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        //***** set the apartment image *****//
        cell.apartmentImageView.clipsToBounds = true
        
        // default placeholder image
        cell.apartmentImageView.image = UIImage(named: "loadingImage")

        
        // first check if the image is cached
        if(self.cache.object(forKey: indexPath.row as AnyObject) != nil){
            print(indexPath.row)
            cell.apartmentImageView.image = self.cache.object(forKey: indexPath.row as AnyObject) as? UIImage
        } else {
            // if the image is not cached download it
            // get the first object in array of photos
            let photo = apartment.photos[0].path
            
            if photo != "" {
                
                // Start the task that will eventually download the image
                let task = ZilyoClient.sharedInstance().taskForImageWithSize(photo) { data, error in
                    
                    if let error = error {
                        print("Title download error: \(error.localizedDescription) url:\(photo)")
                        DispatchQueue.main.async {
                            cell.apartmentImageView.image = UIImage(named: "noImage")
                        }
                    }
                    
                    // no error ocurred, show the image
                    if let data = data {
                        // update the cell on the main thread
                        DispatchQueue.main.async {
                            // check whether the cell is visible on screen before updating the image
                            if let updateCell : SearchResultViewCell = (self.tableView.cellForRow(at: indexPath)) as? SearchResultViewCell{
                                
                                // create the image, show it and cache it
                                let image:UIImage!  = UIImage(data: data)
                                
                                if let secureImage = image {
                                    updateCell.apartmentImageView?.image = secureImage
                                    self.cache.setObject(secureImage, forKey: indexPath.row as AnyObject)
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
