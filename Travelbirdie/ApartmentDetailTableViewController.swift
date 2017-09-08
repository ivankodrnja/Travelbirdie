//
//  ApartmentDetailTableViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 20/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ApartmentDetailTableViewController: UITableViewController {

    var apartment : ApartmentInformation?
    // image array that will store urls for all apartment images
    var imageArray = [String]()
    // it will store the first image of the apartment, it will be set from the results view controller upon selecting a cell there
    var firstImage : UIImage!
    
    // check if images have been loaded in the images slider cell
    var loadImages : Bool = true
    
    // it will store list of favorite apartments
    var favoriteApartments : [Apartment]?
    
    // will serve to check if it is already in the favorites list
    var isFavorite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // make an array of urls of large apartment photos
        for anImage in apartment!.photos! {
            let largeImageUrl = anImage["large"] as! String
            imageArray.append(largeImageUrl)
        }
        
        favoriteApartments = checkIsFavorite()
        
        if favoriteApartments?.count > 0 {
            isFavorite = true
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
    
    func checkIsFavorite() -> [Apartment] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Apartment")
        fetchRequest.predicate = NSPredicate(format: "id == %@", (apartment?.id)!)
        do {
            return try sharedContext.fetch(fetchRequest) as! [Apartment]
        } catch let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [Apartment]()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // different sections have different number of rows
        switch(section){
        case 0:
            return 4 // image slider, add to favorites, labels cell and book cell
        case 1:
           return 2 // description and amenities
        case 2:
            return 1 // map cell
        default:
            return 4 // rental rates : nightly, weekend night, weekly, monthly
        }
        
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // different sections have different number of rows
        switch(section){
        case 1:
            return "Description" // description and amenities
        case 2:
            return "Map" // map cell
        case 3:
            return "Rental Rates" // rental rates : nightly, weekend night, weekly, monthly
        default:
            return ""
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // cell type depends on section and a row inside the section
        switch(indexPath.section){
        // first section contains image slider, labels cell and book cell
        case 0:
            
            switch(indexPath.row){
            // image slider
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSliderCell", for: indexPath) as! ImageSliderCell
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
                
                if let nightlyPrice = apartment!.price!["nightly"] as? Int {
                    cell.priceFromLabel.text = "$ \(nightlyPrice)+"
                }

                // load images only the first time cell appears
                if loadImages {
                    var urlCount = 0
                    // cache downloaded images and use Auk image slideshow library from https://github.com/evgenyneu/Auk
                    Moa.settings.cache.requestCachePolicy = .returnCacheDataElseLoad
                    for imageUrl in imageArray {
                        urlCount += 1
                        cell.scrollView.auk.settings.placeholderImage = UIImage(named: "loadingImage")
                        cell.scrollView.auk.settings.errorImage = UIImage(named: "noImage")
                        if urlCount == 1 {
                            
                            if let firstImage = self.firstImage {
                                cell.scrollView.auk.show(image: firstImage)
                            }
                            continue
                        }
                        cell.scrollView.auk.show(url: imageUrl)
                    }
                    loadImages = false
                }
                
                return cell
            // add to favorites
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath)
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.backgroundColor = UIColor.gray
                cell.textLabel?.textAlignment = .center
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
                cell.textLabel?.textColor = UIColor.white
                if isFavorite {
                    cell.textLabel?.text = "Added to Favorites"
                } else {
                    cell.textLabel?.text = "Add to Favorites"
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
            // labels cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelTableViewCell

                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero

                
                if let bedroomsNumber = apartment!.attr!["bedrooms"] as? Int {
                    cell.bedroomCount?.text = "\(bedroomsNumber)"
                }
                if let bathroomsNumber = apartment!.attr!["bathrooms"] as? Int {
                    cell.bathroomCount?.text = "\(bathroomsNumber)"
                }
                
                if let sleepsNumber = apartment!.attr!["occupancy"] as? Int {
                    cell.sleepsCount?.text = "\(sleepsNumber)"
                }
                
                return cell
                
            // booking cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) 
                
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.backgroundColor = UIColor.orange
                cell.textLabel?.textAlignment = .center
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
                cell.textLabel?.textColor = UIColor.white
                cell.textLabel?.text = SearchHelper.Constants.BookNow
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                
                return cell
                
            }
        // second section contains description and amenities
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            // make table cell separators stretch throught the screen width
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            
            switch(indexPath.row){
            // description
            case 0:
                cell.textLabel?.text = apartment!.attr!["description"] as? String
                return cell
            // amentites labels cell
            default:
                cell.textLabel?.text = "Amenities (\(apartment!.amenities!.count))"
                return cell

            }
        // third section contains the map
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapTableViewCell
            cell.mapView.mapType = .satellite
            
            let location = CLLocationCoordinate2D(latitude: apartment!.latLng![0], longitude: apartment!.latLng![1])
            
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegion(center: location, span: span)
            
            cell.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            
            cell.mapView.addAnnotation(annotation)

            return cell
        
        // fourth section contains the rental rates: nightly, weekend night, weekly, monthly
        default:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "RentalRatesCell")
            cell.detailTextLabel?.textColor = UIColor.black
            cell.selectionStyle = .none
            // make table cell separators stretch throught the screen width
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            
            // each of 4 rows shows different price type
            switch(indexPath.row){
            // nightly or daily price
            case 0:
                if let nightlyPrice = apartment!.price!["nightly"] as? Int {
                    cell.textLabel?.text = "Nightly"
                    cell.detailTextLabel?.text = "$ \(nightlyPrice)"
                }
            // weekend night price
            case 1:
                if let weekendPrice = apartment!.price!["weekend"] as? Int {
                    cell.textLabel?.text = "Weekend night"
                    cell.detailTextLabel?.text = "$ \(weekendPrice)"
                }
            case 2:
                if let weeklyPrice = apartment!.price!["weekly"] as? Int {
                    cell.textLabel?.text = "Weekly"
                    cell.detailTextLabel?.text = "$ \(weeklyPrice)"
                }
            default:
                if let monthlyPrice = apartment!.price!["monthly"] as? Int {
                    cell.textLabel?.text = "Monthly"
                    cell.detailTextLabel?.text = "$ \(monthlyPrice)"
                }
                
            }
            return cell

        }
        
        
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
        // first section contains image slider, labels cell and book cell
        case 0:
            switch(indexPath.row){
                // image slider
            case 0:
                return
                // add to favorites
            case 1:
                // save to favorites list using Core Data only if already isn't added to favorites list
                if !isFavorite {
                    // prepare a dictionary to save as an Apartment object
                    let aptDict: [String : AnyObject] = [ZilyoClient.JSONResponseKeys.Id : (self.apartment?.id)! as AnyObject, ZilyoClient.JSONResponseKeys.LatLng : (self.apartment?.latLng)! as AnyObject, ZilyoClient.JSONResponseKeys.Location : (self.apartment?.location)! as AnyObject, ZilyoClient.JSONResponseKeys.Attr : (self.apartment?.attr)! as AnyObject, ZilyoClient.JSONResponseKeys.Provider : (self.apartment?.provider)! as AnyObject]
                    let apt = Apartment(dictionary: aptDict, context: self.sharedContext)
                    
                    // add amenities
                    for amenity in apartment!.amenities! {
                        let anAmenity = Amenity(dictionary: amenity, context: self.sharedContext)
                        anAmenity.apartment = apt
                    }
                    
                    
                    // add prices
                    let pricesDict = apartment?.price
                    let price = Price(dictionary: pricesDict!, context: self.sharedContext)
                    price.apartment = apt
                    
                    // add attributes
                    let attributesDict = apartment?.attr
                    let attribute = Attribute(dictionary: attributesDict!, context: self.sharedContext)
                    attribute.apartment = apt
                    
                    // add photo urls
                    for anImage in apartment!.photos! {
                        let photo = Photo(dictionary: anImage, context: self.sharedContext)
                        photo.apartment = apt
                    }
                    
                    // save the apartment data
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    isFavorite = true
                    tableView.reloadData()
                }
                
                
                
                // booking labels cell
            case 2:
                return
                
            default:
                
                if Reachability.shared.isConnectedToNetwork() == true {
                    print("Internet connection OK")
                    let controller = storyboard!.instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
                    
                    // set description text in detail controller
                    controller.urlString = apartment!.provider!["url"] as? String
                    self.navigationController!.pushViewController(controller, animated: true)
                } else {
                    print("Internet connection not present")
                    self.showAlertView("Internet connection not present")
                }
                
                
            }
        
            // second section contains description and amenities
        case 1:
            
            switch(indexPath.row){
            // description
            case 0:

                let controller = storyboard!.instantiateViewController(withIdentifier: "DescriptionDetailViewController") as! DescriptionDetailViewController
                
                // set description text in detail controller
                controller.descriptionText = apartment!.attr!["description"] as? String
                // set title text in detail controller
                controller.titleText = "Description"
                
                self.navigationController!.pushViewController(controller, animated: true)
                
            // amentites labels cell
            default:
                let controller = storyboard!.instantiateViewController(withIdentifier: "DescriptionDetailViewController") as! DescriptionDetailViewController
                
                var amenitiesArray = String()
                for amenity in apartment!.amenities! {
                    let amenityText = amenity["text"] as! String
                    amenitiesArray += "\(amenityText) "
                }
                
                // set description text in detail controller
                controller.descriptionText = amenitiesArray
                // set title text in detail controller
                controller.titleText = "Amenities"
                
                self.navigationController!.pushViewController(controller, animated: true)
                
            }
            
        default:
            return
        }
    }

    
    // MARK: - Helpers
    
    func showAlertView(_ errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true){
            
        }
        
    }
    
}
