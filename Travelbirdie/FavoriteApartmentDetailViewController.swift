//
//  FavoriteApartmentDetailViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 27/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FavoriteApartmentDetailViewController: UITableViewController {
    
    var apartment : Apartment?
    // image array that will store urls for all apartment images
    var imageArray = [String]()
    // it will store the first image of the apartment, it will be set from the results view controller upon selecting a cell there
    var firstImage : UIImage!
    
    // check if images have been loaded in the images slider cell
    var loadImages : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        

        
        // make an array of urls of large apartment photos
        for anImage in (apartment?.photos)! {
            imageArray.append(anImage.path)
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
                
                cell.priceFromLabel.text = "$ \(apartment!.prices[0].nightly)+"
                
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
                cell.textLabel?.text = "Remove from Favorites"
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
                // labels cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelTableViewCell
                
                // make table cell separators stretch throught the screen width
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
                
                
                let bedroomsNumber = apartment!.attributes[0].bedrooms
                cell.bedroomCount?.text = "\(bedroomsNumber)"
                
                let bathroomsNumber = apartment!.attributes[0].bathrooms
                    cell.bathroomCount?.text = "\(bathroomsNumber)"
                
                let sleepsNumber = apartment!.attributes[0].occupancy
                cell.sleepsCount?.text = "\(sleepsNumber)"
                
                
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
                cell.textLabel?.text = apartment!.attributes[0].desc
                return cell
                // amentites labels cell
            default:
                cell.textLabel?.text = "Amenities (\(apartment!.amenities.count))"
                return cell
                
            }
            // third section contains the map
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapTableViewCell
            cell.mapView.mapType = .satellite
            
            let location = CLLocationCoordinate2D(latitude: apartment!.latitude, longitude: apartment!.longitude)
            
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
                let nightlyPrice = apartment!.prices[0].nightly
                cell.textLabel?.text = "Nightly"
                cell.detailTextLabel?.text = "$ \(nightlyPrice)"
    
                // weekend night price
            case 1:
                let weekendPrice = apartment!.prices[0].weekendNight
                cell.textLabel?.text = "Weekend night"
                cell.detailTextLabel?.text = "$ \(weekendPrice)"
            
            case 2:
                let weeklyPrice = apartment!.prices[0].weekly
                cell.textLabel?.text = "Weekly"
                cell.detailTextLabel?.text = "$ \(weeklyPrice)"

            default:
                let monthlyPrice = apartment!.prices[0].monthly
                cell.textLabel?.text = "Monthly"
                cell.detailTextLabel?.text = "$ \(monthlyPrice)"
                
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
                // delete apartment from the favorites list
                self.sharedContext.delete(apartment!)
                
                // save the apartment data
                CoreDataStackManager.sharedInstance().saveContext()
                
                self.navigationController?.popViewController(animated: true)
                
                // amentites labels cell
            case 2:
                return
                
            default:
                
                
                if Reachability.shared.isConnectedToNetwork() == true {
                    print("Internet connection OK")
                    let controller = storyboard!.instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
                    
                    // set description text in detail controller
                    controller.urlString = apartment?.providerUrl
                    
                    self.navigationController!.pushViewController(controller, animated: true)
                } else {
                    print("Internet connection FAILED")
                    self.showAlertView("Internet connection FAILED")
                }
                

            }
            
            // second section contains description and amenities
        case 1:
            
            switch(indexPath.row){
                // description
            case 0:
                
                let controller = storyboard!.instantiateViewController(withIdentifier: "DescriptionDetailViewController") as! DescriptionDetailViewController
                
                // set description text in detail controller
                controller.descriptionText = apartment!.attributes[0].desc
                // set title text in detail controller
                controller.titleText = "Description"
                
                self.navigationController!.pushViewController(controller, animated: true)
                
                // amentites labels cell
            default:
                let controller = storyboard!.instantiateViewController(withIdentifier: "DescriptionDetailViewController") as! DescriptionDetailViewController
                
                var amenitiesArray = String()
                for amenity in (apartment?.amenities)! {
                    let amenityText = amenity.list 
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

