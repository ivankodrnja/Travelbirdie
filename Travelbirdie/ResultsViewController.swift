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
    
    // will serve for caching images
    var cache:NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        // initialize cache
        self.cache = NSCache()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
    }
    
    
    
    // MARK: - Table delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "SearchResultViewCell"
        
        tableView.register(UINib(nibName: "SearchResultViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! SearchResultViewCell
        
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        
        let apartment = ZilyoClient.sharedInstance().apartmentDict[indexPath.row]
        
        //***** set the apartment image *****//
        cell.apartmentImageView.clipsToBounds = true
        
        // default placeholder image
        cell.apartmentImageView.image = UIImage(named: "loadingImage")
        
        // first check if the image is cached
        if(self.cache.object(forKey: indexPath.row as AnyObject) != nil){
            cell.apartmentImageView.image = self.cache.object(forKey: indexPath.row as AnyObject) as? UIImage
        } else {
            // if the image is not cached download it
            // get the first object in array of photos
            var photo = apartment.photos![0]
            // get the large image from the first object in photos array
            let largePhotoUrl = photo["large"]
            
            if let titleImageUrl = largePhotoUrl {
                
                // Start the task that will eventually download the image
                let task = ZilyoClient.sharedInstance().taskForImageWithSize(titleImageUrl as! String) { data, error in
                    
                    if let error = error {
                        print("Title download error: \(error.localizedDescription) url:\(titleImageUrl)")
                        DispatchQueue.main.async {
                            cell.apartmentImageView.image = UIImage(named: "noImage")
                        }
                    }
                    
                    // no error ocurred, show the image
                    if let data = data {
                        // update the cell on the main thread
                        DispatchQueue.main.async {
                            // check whether the cell is visible on screen before updating the image
                            if let updateCell : SearchResultViewCell = (tableView.cellForRow(at: indexPath)) as? SearchResultViewCell{
                                
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
        cell.apartmentNameLabel.text = apartment.attr!["heading"] as? String
        
        //***** set the number of bedrooms *****//
        let bedroomsNumber = apartment.attr!["bedrooms"] as? Int
        cell.bedroomsNumberLabel.text = "\(bedroomsNumber!)"
        
        //***** set the number of people that sleep *****//
        let sleepsNumber = apartment.attr!["occupancy"] as? Int
        cell.sleepsNumberLabel.text = "\(sleepsNumber!)"
        
        //***** set the apartment location *****//
        cell.locationLabel.text = apartment.location!["city"] as? String
        
        //***** set the the daily price *****//
        let dailyPrice = apartment.price!["nightly"] as? Int
        cell.dailyPriceLabel.text = "\(dailyPrice!)"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ZilyoClient.sharedInstance().apartmentDict.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "ApartmentDetailViewController") as! ApartmentDetailTableViewController
        
        let apartment = ZilyoClient.sharedInstance().apartmentDict[indexPath.row]
        // set apartment object in the detail VC
        controller.apartment = apartment
        // set the first image to show in the detail VC
        if(self.cache.object(forKey: indexPath.row as AnyObject) != nil){
            controller.firstImage = (self.cache.object(forKey: indexPath.row as AnyObject) as? UIImage)!
        }
        
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    /* MAKE SPACING BETWEEN THE CELLS
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.contentView.backgroundColor = UIColor.clearColor()
    
    let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width, (self.view.frame.size.height) - 20))
    
    whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
    whiteRoundedView.layer.masksToBounds = false
    whiteRoundedView.layer.cornerRadius = 2.0
    whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
    whiteRoundedView.layer.shadowOpacity = 0.2
    
    cell.contentView.addSubview(whiteRoundedView)
    cell.contentView.sendSubviewToBack(whiteRoundedView)
    }
    */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
        
        ZilyoClient.sharedInstance().getRentals(self.requestParameters[ZilyoClient.Keys.latitude]! as! Double, locationLon: self.requestParameters[ZilyoClient.Keys.longitude] as! Double, guestsNumber: self.requestParameters[ZilyoClient.Keys.guests]! as! Int, checkIn: self.requestParameters[ZilyoClient.Keys.checkIn]! as! TimeInterval, checkOut: self.requestParameters[ZilyoClient.Keys.checkOut]! as! TimeInterval, page: self.currentPage){(result, error) in
            
            if error == nil {
                // Store the current number of apartments before adding any new batch
                self.currentCountOfApartments = ZilyoClient.sharedInstance().apartmentDict.count
                print("currentCountOfApartments count:\(self.currentCountOfApartments)\n")
                
                print("Current page:\(self.currentPage)\n")
                ZilyoClient.sharedInstance().apartmentDict += result!
                
                self.totalCountOfApartments = ZilyoClient.sharedInstance().apartmentDict.count
                print("totalCountOfApartments count:\(self.totalCountOfApartments)\n")
                
                DispatchQueue.main.async {
                    
                    self.populatingApartments = false
                    self.tableView.reloadData()
                    
                    self.currentPage+=1
                }
            } else {
                DispatchQueue.main.async {
                    // Error, e.g. the internet connection is offline
                    print("Error in ResultsViewController: \(String(describing: error?.localizedDescription))")
                    self.showAlertView(error?.localizedDescription)
                }
            }
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
