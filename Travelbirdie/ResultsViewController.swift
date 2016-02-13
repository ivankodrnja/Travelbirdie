//
//  ResultsViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 22/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    

    var requestParameters = [String : AnyObject]()
    
    // handle auto downoad of subsequent apartments
    var populatingApartments = false
    // next page to show is 2
    var currentPage = 2
    
    // we will use these two count variables to check the last page of results, when these two variables match, we won't make additional network calls as this means we've hit the last page of results
    var currentCountOfApartments : Int!
    var totalCountOfApartments : Int!
    
    override func viewDidLoad() {

    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
    }
    
    // MARK: - Table delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        /* Get cell type */
        let cellReuseIdentifier = "SearchResultViewCell"
        
        tableView.registerNib(UINib(nibName: "SearchResultViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as! SearchResultViewCell


        
        let apartment = ZilyoClient.sharedInstance().apartmentDict[indexPath.row]
        
        //***** set the apartment image *****//
        cell.apartmentImageView.clipsToBounds = true
        
        // default placeholder image
        cell.apartmentImageView.image = UIImage(named: "noImage")
        
        // get the first object in array of photos
        var photo = apartment.photos![0]
        // get the large image from the first object in photos array
        let largePhotoUrl = photo ["large"]
        
        if let titleImageUrl = largePhotoUrl {
           
            // Start the task that will eventually download the image
            let task = ZilyoClient.sharedInstance().taskForImageWithSize(titleImageUrl as! String) { data, error in
                
                if let error = error {
                    print("Title download error: \(error.localizedDescription)")
                    dispatch_async(dispatch_get_main_queue()) {
                    // show placeholder image
                    cell.apartmentImageView.image = UIImage(named: "noImage")
                    }
                }
                
                if let data = data {
                    // Create the image
                    let image = UIImage(data: data)
                    
                    // update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.apartmentImageView.image = image
                    }
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            cell.taskToCancelifCellIsReused = task
            
        } else {
            cell.apartmentImageView.image = UIImage(named: "noImage")
        }
        //***** end of setting the apartment image *****//
        
        
        //***** set the apartment name or heading *****//
        cell.apartmentNameLabel.text = apartment.attr!["heading"] as? String
        
        //***** set the number of bedrooms *****//
        let bedroomsNumber = apartment.attr!["bedrooms"] as? Int
        cell.bedroomsNumberLabel.text = "\(bedroomsNumber!)"
        
        //***** set the number of people that sleep *****//
        let sleepsNumber = apartment.attr!["occupancy"] as? Int
        cell.sleepsNumberLabel.text = "\(sleepsNumber!)"
        
        //***** set the apartment location *****//
        cell.locationLabel.text = apartment.location!["city"] as? String
        
        //***** set the number of people that sleep *****//
        let dailyPrice = apartment.price!["nightly"] as? Int
        cell.dailyPriceLabel.text = "\(dailyPrice!)"
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 350
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ZilyoClient.sharedInstance().apartmentDict.count

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 { // Loads more apartments once the user has scrolled 80% of the view
            searchRentals()
            
        }

        
    }
    
    func searchRentals() {
        // Loads apartments in the "currentPage" and uses "populatingApartments" as a flag to avoid loading the next page while you are still loading the current page
        if populatingApartments {
            return
        }
        if let ttlCountOfApartments = self.totalCountOfApartments {
            if (currentCountOfApartments == ttlCountOfApartments){
                return
            }
            
        }
        
        populatingApartments = true

        
        ZilyoClient.sharedInstance().getRentals(self.requestParameters[ZilyoClient.Keys.latitude]! as! Double, locationLon: self.requestParameters[ZilyoClient.Keys.longitude] as! Double, guestsNumber: self.requestParameters[ZilyoClient.Keys.guests]! as! Int, checkIn: self.requestParameters[ZilyoClient.Keys.checkIn]! as! NSTimeInterval, checkOut: self.requestParameters[ZilyoClient.Keys.checkOut]! as! NSTimeInterval, page: self.currentPage){(result, error) in
            
            
            if error == nil {
                // Store the current number of apartments before adding any new batch
                self.currentCountOfApartments = ZilyoClient.sharedInstance().apartmentDict.count
                print("currentCountOfApartments count:\(self.currentCountOfApartments)\n")
                
                print("Current page:\(self.currentPage)\n")
                ZilyoClient.sharedInstance().apartmentDict += result!
                
                self.totalCountOfApartments = ZilyoClient.sharedInstance().apartmentDict.count 
                print("totalCountOfApartments count:\(self.totalCountOfApartments)\n")

                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.populatingApartments = false
                    self.tableView.reloadData()
                    
                    self.currentPage++
                }
            }

            
        }

    }
}
