//
//  TravelbirdieSearchViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 18/10/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit

class TravelbirdieSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    //checkin date picker
    @IBOutlet weak var datePickerContainerView: UIView!
    @IBOutlet weak var dateSelectionPicker: UIDatePicker!
    //checkout date picker
    @IBOutlet weak var checkOutDatePickerContainerView: UIView!
    @IBOutlet weak var checkOutDateSelectionPicker: UIDatePicker!
    
    // guests picker
    @IBOutlet weak var guestsPickerContainerView: UIView!
    @IBOutlet weak var guestsSelectionPicker: UIPickerView!
    
    var pickerDataSource = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var tableViewContainer: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // variable thata will use to enable / disable search row in the column
    var searchTapped : Bool = false
    
    // dictionary that will hold request parameters
    var requestParameters = [String : AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set default values for the search query
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location] = SearchHelper.Constants.Unknown
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.guests] = 1
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn] = NSDate()
        // checkout is tomorrow
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut] = NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: 1,
            toDate: ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn] as! NSDate,
            options: [])!
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillAppear(animated: Bool) {
        // make sure table cells have an updated content
        tableViewContainer.reloadData()
        
        self.tableViewContainer.alpha = 1.0
        self.backgroundImage.alpha = 1.0
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        self.datePickerContainerView.hidden = true
        self.checkOutDatePickerContainerView.hidden = true
        self.guestsPickerContainerView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "SearchCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as UITableViewCell
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        // set static cells
        switch(indexPath.row){
        case 0:
            cell.textLabel?.text = SearchHelper.Constants.Location + ": " + (ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location] as! String)
            cell.imageView?.image = UIImage(named: "Pin")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 1:
            cell.textLabel?.text = SearchHelper.Constants.NumberOfGuests + ": " + String(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.guests]!)
            cell.imageView?.image = UIImage(named: "Guests")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 2:
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let string = dateFormatter.stringFromDate(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn]! as! NSDate)
            
            cell.textLabel?.text = SearchHelper.Constants.CheckIn + ": " + string
            cell.imageView?.image = UIImage(named: "Calendar")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 3:
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let string = dateFormatter.stringFromDate(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]! as! NSDate)
            
            cell.textLabel?.text = SearchHelper.Constants.CheckOut + ": " + string
            cell.imageView?.image = UIImage(named: "Calendar")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 4:
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.backgroundColor = UIColor.orangeColor()
            cell.textLabel?.textAlignment = .Center
            cell.textLabel!.font = UIFont.boldSystemFontOfSize(20)
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = SearchHelper.Constants.SearchRentals
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
        default:
            break
        }
        
        return cell
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return ParseClient.sharedInstance().studentsDict.count
        return SearchHelper.Constants.Count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch(indexPath.row){
            // select location
        case 0:
            
            let controller = storyboard!.instantiateViewControllerWithIdentifier("PlacesSearchResultsController") as! PlacesSearchResultsController
            self.presentViewController(controller, animated: true, completion: nil)
            
            /*
            let placesSearchController = PlacesSearchResultsController()
            self.presentViewController(placesSearchController, animated: true, completion: nil)
            */
            // select number of guests
        case 1:
            if(searchTapped){
                return
            } else {
                self.getNumberOfGuests()
                
                
            }
            // select check in date
        case 2:
            if(searchTapped){
                return
            } else {
                self.getCheckInDate()
                
                
            }
            
            // select check out date
        case 3:
            if(searchTapped){
                return
            } else {
                self.getCheckOutDate()
                
            }
            
            
        case 4:
            // if the user already tapped search rentals
            if(searchTapped){
                return
            } else {
                self.searchRentals()
            }
            
            
        default:
            break
        }
        
    }
    
    
    // MARK: - Helper functions
    
    
    func searchRentals() {
        
        self.requestParameters[ZilyoClient.Keys.latitude] = ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.latitude]
        
        self.requestParameters[ZilyoClient.Keys.longitude] = ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.longitude]
        self.requestParameters[ZilyoClient.Keys.guests] = ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.guests]
        self.requestParameters[ZilyoClient.Keys.checkIn] = ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn]?.timeIntervalSince1970
        self.requestParameters[ZilyoClient.Keys.checkOut] = ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]?.timeIntervalSince1970
        self.requestParameters[ZilyoClient.Keys.page] = 1
        
        // don't make a network request if destination isn't set
        if(self.requestParameters[ZilyoClient.Keys.latitude] == nil || self.requestParameters[ZilyoClient.Keys.longitude] == nil){
            self.showAlertView(SearchHelper.Constants.ChooseDestination)
        } else if (self.requestParameters[ZilyoClient.Keys.checkIn] as! NSTimeInterval > self.requestParameters[ZilyoClient.Keys.checkOut] as! NSTimeInterval) {
            // check if check in and check out dates are correct
            self.showAlertView("Check In must be before Check Out")
            
        } else if ((self.requestParameters[ZilyoClient.Keys.checkOut] as! NSTimeInterval) < (self.requestParameters[ZilyoClient.Keys.checkIn] as! NSTimeInterval)) {
            // check if check in and check out dates are correct
            self.showAlertView("Check Out must be after Check In")
            
        } else if (self.requestParameters[ZilyoClient.Keys.checkOut] as! NSTimeInterval == self.requestParameters[ZilyoClient.Keys.checkIn] as! NSTimeInterval) {
            // check if check in and check out dates are correct
            self.showAlertView("Check Out must be after Check In")
            
        } else {
            // let the user know something is going on under the hood
            self.tableViewContainer.alpha = 0.5
            self.backgroundImage.alpha = 0.5
            self.activityIndicator.startAnimating()
            
            let controller = storyboard!.instantiateViewControllerWithIdentifier("ResultsViewController") as! ResultsViewController
            
            // prevent user from submiting twice
            self.searchTapped = true
            
            
            ZilyoClient.sharedInstance().getRentals(self.requestParameters[ZilyoClient.Keys.latitude]! as! Double, locationLon: self.requestParameters[ZilyoClient.Keys.longitude]! as! Double, guestsNumber: self.requestParameters[ZilyoClient.Keys.guests]! as! Int, checkIn: self.requestParameters[ZilyoClient.Keys.checkIn]! as! NSTimeInterval, checkOut: self.requestParameters[ZilyoClient.Keys.checkOut]! as! NSTimeInterval, page: 1){(result, error) in
                
                
                if error == nil {
                    //print(result)
                    controller.requestParameters = self.requestParameters
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if result?.count == 0 {
                            self.showAlertView("No rentals found, please refine your search!")
                            self.searchTapped = false
                            
                            self.tableViewContainer.alpha = 1.0
                            self.backgroundImage.alpha = 1.0
                            self.activityIndicator.hidesWhenStopped = true
                            self.activityIndicator.stopAnimating()
                            
                        } else {
                            
                            ZilyoClient.sharedInstance().apartmentDict = result!
                            self.navigationController!.pushViewController(controller, animated: true)
                            // search row is enabled again
                            self.searchTapped = false
                        }
                    }
                } else {
                    // Inform user on the main thread about errors, e.g. the internet connection is offline
                    dispatch_async(dispatch_get_main_queue()) {
                        self.searchTapped = false
                        self.tableViewContainer.alpha = 1.0
                        self.backgroundImage.alpha = 1.0
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.stopAnimating()
                        
                        print("Error in TravelbirdieSearchController: \(error?.localizedDescription)")
                        self.showAlertView(error?.localizedDescription)
                    }
                }
            }
            
        }
    }
    
    func getCheckInDate(){
        
        // put the date picker outside of the view
        var frame: CGRect = self.datePickerContainerView.frame
        frame.origin.y = self.view.frame.size.height
        self.datePickerContainerView.frame = frame
        
        UIView.animateWithDuration(0.4, animations: {
            
            // manage the appearance of the date picker
            self.datePickerContainerView.hidden = false
            self.tabBarController?.tabBar.hidden = true
            
            var frame: CGRect = self.datePickerContainerView.frame
            frame.origin.y = self.view.frame.size.height - frame.size.height
            self.datePickerContainerView.frame = frame
            self.dateSelectionPicker.minimumDate = NSDate()
            //self.dateSelectionPicker.minimumDate = (ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn]! as! NSDate)
            //self.dateSelectionPicker.maximumDate = (ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]! as! NSDate)
            
            self.dateSelectionPicker.hidden = false
            
        })
        
    }
    
    @IBAction func dismissCheckInPicker(sender: AnyObject) {
        
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn] = self.dateSelectionPicker.date
        // make sure table cells have an updated content
        self.tableViewContainer.reloadData()
        
        UIView.animateWithDuration(0.4, animations: {
            
            self.datePickerContainerView.frame = CGRectMake(self.view.frame.minX, self.view.frame.maxY, self.view.frame.width, self.datePickerContainerView.frame.height)
            
        })
        //self.datePickerContainerView.hidden = true
    }
    
    func getCheckOutDate(){
        
        // put the date picker outside of the view
        var frame: CGRect = self.checkOutDatePickerContainerView.frame
        frame.origin.y = self.view.frame.size.height
        self.checkOutDatePickerContainerView.frame = frame
        
        UIView.animateWithDuration(0.4, animations: {
            
            // manage the appearance of the date picker
            self.checkOutDatePickerContainerView.hidden = false
            self.tabBarController?.tabBar.hidden = true
            
            var frame: CGRect = self.checkOutDatePickerContainerView.frame
            frame.origin.y = self.view.frame.size.height - frame.size.height
            self.checkOutDatePickerContainerView.frame = frame
            //self.checkOutDateSelectionPicker.minimumDate = ((ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]!) as! NSDate)
            
            self.checkOutDateSelectionPicker.hidden = false
            
        })
        
    }
    
    @IBAction func dismissCheckOutPicker(sender: AnyObject) {
        
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut] = self.checkOutDateSelectionPicker.date
        // make sure table cells have an updated content
        self.tableViewContainer.reloadData()
        
        UIView.animateWithDuration(0.4, animations: {
            
            self.checkOutDatePickerContainerView.frame = CGRectMake(self.view.frame.minX, self.view.frame.maxY, self.view.frame.width, self.checkOutDatePickerContainerView.frame.height)
            
        })
        
    }
    
    
    func getNumberOfGuests(){
        
        // put the date picker outside of the view
        var frame: CGRect = self.guestsPickerContainerView.frame
        frame.origin.y = self.view.frame.size.height
        self.guestsPickerContainerView.frame = frame
        
        UIView.animateWithDuration(0.4, animations: {
            
            // manage the appearance of the date picker
            self.guestsPickerContainerView.hidden = false
            self.tabBarController?.tabBar.hidden = true
            
            var frame: CGRect = self.guestsPickerContainerView.frame
            frame.origin.y = self.view.frame.size.height - frame.size.height
            self.guestsPickerContainerView.frame = frame
            
            
            self.guestsSelectionPicker.hidden = false
            
        })
        
    }
    
    func dismissGuestsPicker() {
        
        UIView.animateWithDuration(0.4, animations: {
            
            self.guestsPickerContainerView.frame = CGRectMake(self.view.frame.minX, self.view.frame.maxY, self.view.frame.width, self.guestsPickerContainerView.frame.height)
            
        })
        //        self.guestsPickerContainerView.hidden = true
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format:"%d", pickerDataSource[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.guests] = self.pickerDataSource[row]
        // make sure table cells have an updated content
        tableViewContainer.reloadData()
        self.dismissGuestsPicker()
    }
    
    // MARK: - Helpers
    
    func showAlertView(errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true){
            
        }
        
    }
}