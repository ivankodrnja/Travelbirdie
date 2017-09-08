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
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location] = SearchHelper.Constants.Unknown as AnyObject
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.guests] = 1 as AnyObject
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn] = Date() as AnyObject
        // checkout is tomorrow
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut] = (Calendar.current as NSCalendar).date(
            byAdding: .day,
            value: 1,
            to: ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn] as! Date,
            options: [])! as AnyObject
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // make sure table cells have an updated content
        tableViewContainer.reloadData()
        
        self.tableViewContainer.alpha = 1.0
        self.backgroundImage.alpha = 1.0
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        self.datePickerContainerView.isHidden = true
        self.checkOutDatePickerContainerView.isHidden = true
        self.guestsPickerContainerView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "SearchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        // make table cell separators stretch throught the screen width, in Storyboard separator insets of the table view and the cell have also set to 0
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        // set static cells
        switch(indexPath.row){
        case 0:
            cell.textLabel?.text = SearchHelper.Constants.Location + ": " + (ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location] as! String)
            cell.imageView?.image = UIImage(named: "Pin")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 1:
            cell.textLabel?.text = SearchHelper.Constants.NumberOfGuests + ": " + String(describing: ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.guests]!)
            cell.imageView?.image = UIImage(named: "Guests")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 2:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let string = dateFormatter.string(from: ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn]! as! Date)
            
            cell.textLabel?.text = SearchHelper.Constants.CheckIn + ": " + string
            cell.imageView?.image = UIImage(named: "Calendar")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 3:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let string = dateFormatter.string(from: ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]! as! Date)
            
            cell.textLabel?.text = SearchHelper.Constants.CheckOut + ": " + string
            cell.imageView?.image = UIImage(named: "Calendar")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        case 4:
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.backgroundColor = UIColor.orange
            cell.textLabel?.textAlignment = .center
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.text = SearchHelper.Constants.SearchRentals
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
        default:
            break
        }
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return ParseClient.sharedInstance().studentsDict.count
        return SearchHelper.Constants.Count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch(indexPath.row){
            // select location
        case 0:
            
            let controller = storyboard!.instantiateViewController(withIdentifier: "PlacesSearchResultsController") as! PlacesSearchResultsController
            self.present(controller, animated: true, completion: nil)
            
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
        self.requestParameters[ZilyoClient.Keys.checkIn] = ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn]?.timeIntervalSince1970 as AnyObject
        self.requestParameters[ZilyoClient.Keys.checkOut] = ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]?.timeIntervalSince1970 as AnyObject
        self.requestParameters[ZilyoClient.Keys.page] = 1 as AnyObject
        
        // don't make a network request if destination isn't set
        if(self.requestParameters[ZilyoClient.Keys.latitude] == nil || self.requestParameters[ZilyoClient.Keys.longitude] == nil){
            self.showAlertView(SearchHelper.Constants.ChooseDestination)
        } else if (self.requestParameters[ZilyoClient.Keys.checkIn] as! TimeInterval > self.requestParameters[ZilyoClient.Keys.checkOut] as! TimeInterval) {
            // check if check in and check out dates are correct
            self.showAlertView("Check In must be before Check Out")
            
        } else if ((self.requestParameters[ZilyoClient.Keys.checkOut] as! TimeInterval) < (self.requestParameters[ZilyoClient.Keys.checkIn] as! TimeInterval)) {
            // check if check in and check out dates are correct
            self.showAlertView("Check Out must be after Check In")
            
        } else if (self.requestParameters[ZilyoClient.Keys.checkOut] as! TimeInterval == self.requestParameters[ZilyoClient.Keys.checkIn] as! TimeInterval) {
            // check if check in and check out dates are correct
            self.showAlertView("Check Out must be after Check In")
            
        } else {
            // let the user know something is going on under the hood
            self.tableViewContainer.alpha = 0.5
            self.backgroundImage.alpha = 0.5
            self.activityIndicator.startAnimating()
            
            let controller = storyboard!.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
            
            // prevent user from submiting twice
            self.searchTapped = true
            
            
            ZilyoClient.sharedInstance().getRentals(self.requestParameters[ZilyoClient.Keys.latitude]! as! Double, locationLon: self.requestParameters[ZilyoClient.Keys.longitude]! as! Double, guestsNumber: self.requestParameters[ZilyoClient.Keys.guests]! as! Int, checkIn: self.requestParameters[ZilyoClient.Keys.checkIn]! as! TimeInterval, checkOut: self.requestParameters[ZilyoClient.Keys.checkOut]! as! TimeInterval, page: 1){(result, error) in
                
                
                if error == nil {
                    //print(result)
                    controller.requestParameters = self.requestParameters
                    DispatchQueue.main.async {
                        
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
                    DispatchQueue.main.async {
                        self.searchTapped = false
                        self.tableViewContainer.alpha = 1.0
                        self.backgroundImage.alpha = 1.0
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.stopAnimating()
                        
                        print("Error in TravelbirdieSearchController: \(String(describing: error?.localizedDescription))")
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
        
        UIView.animate(withDuration: 0.4, animations: {
            
            // manage the appearance of the date picker
            self.datePickerContainerView.isHidden = false
            self.tabBarController?.tabBar.isHidden = true
            
            var frame: CGRect = self.datePickerContainerView.frame
            frame.origin.y = self.view.frame.size.height - frame.size.height
            self.datePickerContainerView.frame = frame
            self.dateSelectionPicker.minimumDate = Date()
            //self.dateSelectionPicker.minimumDate = (ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn]! as! NSDate)
            //self.dateSelectionPicker.maximumDate = (ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]! as! NSDate)
            
            self.dateSelectionPicker.isHidden = false
            
        })
        
    }
    
    @IBAction func dismissCheckInPicker(_ sender: AnyObject) {
        
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkIn] = self.dateSelectionPicker.date as AnyObject
        // make sure table cells have an updated content
        self.tableViewContainer.reloadData()
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.datePickerContainerView.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.maxY, width: self.view.frame.width, height: self.datePickerContainerView.frame.height)
            
        })
        //self.datePickerContainerView.hidden = true
    }
    
    func getCheckOutDate(){
        
        // put the date picker outside of the view
        var frame: CGRect = self.checkOutDatePickerContainerView.frame
        frame.origin.y = self.view.frame.size.height
        self.checkOutDatePickerContainerView.frame = frame
        
        UIView.animate(withDuration: 0.4, animations: {
            
            // manage the appearance of the date picker
            self.checkOutDatePickerContainerView.isHidden = false
            self.tabBarController?.tabBar.isHidden = true
            
            var frame: CGRect = self.checkOutDatePickerContainerView.frame
            frame.origin.y = self.view.frame.size.height - frame.size.height
            self.checkOutDatePickerContainerView.frame = frame
            //self.checkOutDateSelectionPicker.minimumDate = ((ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut]!) as! NSDate)
            
            self.checkOutDateSelectionPicker.isHidden = false
            
        })
        
    }
    
    @IBAction func dismissCheckOutPicker(_ sender: AnyObject) {
        
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.checkOut] = self.checkOutDateSelectionPicker.date as AnyObject
        // make sure table cells have an updated content
        self.tableViewContainer.reloadData()
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.checkOutDatePickerContainerView.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.maxY, width: self.view.frame.width, height: self.checkOutDatePickerContainerView.frame.height)
            
        })
        
    }
    
    
    func getNumberOfGuests(){
        
        // put the date picker outside of the view
        var frame: CGRect = self.guestsPickerContainerView.frame
        frame.origin.y = self.view.frame.size.height
        self.guestsPickerContainerView.frame = frame
        
        UIView.animate(withDuration: 0.4, animations: {
            
            // manage the appearance of the date picker
            self.guestsPickerContainerView.isHidden = false
            self.tabBarController?.tabBar.isHidden = true
            
            var frame: CGRect = self.guestsPickerContainerView.frame
            frame.origin.y = self.view.frame.size.height - frame.size.height
            self.guestsPickerContainerView.frame = frame
            
            
            self.guestsSelectionPicker.isHidden = false
            
        })
        
    }
    
    func dismissGuestsPicker() {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.guestsPickerContainerView.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.maxY, width: self.view.frame.width, height: self.guestsPickerContainerView.frame.height)
            
        })
        //        self.guestsPickerContainerView.hidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format:"%d", pickerDataSource[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.guests] = self.pickerDataSource[row] as AnyObject
        // make sure table cells have an updated content
        tableViewContainer.reloadData()
        self.dismissGuestsPicker()
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
