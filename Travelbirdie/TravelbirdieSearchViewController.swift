//
//  TravelbirdieSearchViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 18/10/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit

class TravelbirdieSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var dateSelectionPicker: UIDatePicker!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var datePickerContainerView: UIView!
    @IBOutlet weak var tableViewContainer: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // it will be used in UIDatePicker
    var checkInDate : NSDate = NSDate()
    var checkOutDate : NSDate?
    
    // variable thata will use to enable / disable search row in the column
    var searchTapped : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkOutDate = NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: 1,
            toDate: self.checkInDate,
            options: [])!
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableViewContainer.alpha = 1.0
        self.backgroundImage.alpha = 1.0
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
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
        
        // set static cells
        switch(indexPath.row){
        case 0:
            cell.textLabel?.text = SearchHelper.Constants.Location
            cell.imageView?.image = UIImage(named: "Pin")
            
        case 1:
            cell.textLabel?.text = SearchHelper.Constants.NumberOfGuests
            cell.imageView?.image = UIImage(named: "Pin")
            
        case 2:
            cell.textLabel?.text = SearchHelper.Constants.CheckIn
            cell.imageView?.image = UIImage(named: "Pin")
            
        case 3:
            cell.textLabel?.text = SearchHelper.Constants.CheckOut
            cell.imageView?.image = UIImage(named: "Pin")
            
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
            break
        // select number of guests
        case 1:
            break
        // select check in date
        case 2:
            if(searchTapped){
                return
            } else {
                self.getDate("checkInDate")
            
 
            }
            
        // select check out date
        case 3:
            if(searchTapped){
                return
            } else {
                self.getDate("checkOutDate")

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
        
        // let the user know something is going on under the hood
        self.tableViewContainer.alpha = 0.5
        self.backgroundImage.alpha = 0.5
        self.activityIndicator.startAnimating()
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ResultsViewController") as! ResultsViewController
        
        // prevent user from submiting twice
        self.searchTapped = true
        
        
        
        let locationLat = 45.3400805
        let locationLon = 14.3096924
        
        let date = NSDate().timeIntervalSince1970
        
        print(date)
        
        let checkIn = date
        let checkOut = date + 86400
        
        ZilyoClient.sharedInstance().getRentals(locationLat, locationLon: locationLon, checkIn: checkIn, checkOut: checkOut){(result, error) in
            
            
            if error == nil {
                //print(result)
                dispatch_async(dispatch_get_main_queue()) {
                    
                    //controller.result = result!
                    ZilyoClient.sharedInstance().apartmentDict = result!
                    self.navigationController!.pushViewController(controller, animated: true)
                    // search row is enabled again
                    self.searchTapped = false
                }
            }

            
        }
    }
    
    func getDate(type: String){
        
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

            self.dateSelectionPicker.hidden = false
            
            
            // date picker behavior depending on the type
            if(type=="checkInDate"){
                self.dateSelectionPicker.minimumDate = self.checkInDate
                self.dateSelectionPicker.addTarget(self, action: "recognizecheckInDate:", forControlEvents: UIControlEvents.AllEvents)
                
            } else if (type=="checkOutDate"){
                self.dateSelectionPicker.minimumDate = self.checkOutDate
                self.dateSelectionPicker.addTarget(self, action: "recognizecheckOutDate:", forControlEvents: UIControlEvents.AllEvents)
            }
            

            
      
            
        })
        
    }
    
    @IBAction func dismissPicker(sender: AnyObject) {
        UIView.animateWithDuration(0.4, animations: {
           
            self.datePickerContainerView.frame = CGRectMake(self.view.frame.minX, self.view.frame.maxY, self.view.frame.width, self.datePickerContainerView.frame.height)
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yyyy"

            //print (dateFormatter.stringFromDate(self.dateSelectionPicker.date))
            print("CheckIn:\(self.checkInDate)")
            print("CheckOut:\(self.checkOutDate!)")
            
        })
        
    }
    
    func recognizecheckInDate(sender: UIDatePicker) {
        self.checkInDate = sender.date
    }
    
    func recognizecheckOutDate(sender: UIDatePicker) {
        self.checkOutDate = sender.date
    }

}