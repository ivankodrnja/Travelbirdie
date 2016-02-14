//
//  PlacesSearchResultsController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 12/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import GoogleMaps


class PlacesSearchResultsController: UITableViewController, UISearchBarDelegate {

    var searchResults = [String]()
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        // Uncomment the following line to preserve selection between presentations
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
       self.searchController = UISearchController(searchResultsController: nil)
       self.searchController.searchBar.delegate = self
       self.searchController.dimsBackgroundDuringPresentation = false
       //self.searchController.searchBar.sizeToFit()
       self.tableView.tableHeaderView = self.searchController.searchBar
       self.searchController.searchBar.becomeFirstResponder()
        
    }
    /*
    override func viewDidAppear(animated: Bool) {
        self.searchController.searchBar.becomeFirstResponder()
        
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadDataWithArray(array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar,
        textDidChange searchText: String){
            
            let placesClient = GMSPlacesClient()
            placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:NSError?) -> Void in
                self.searchResults.removeAll()
                if results == nil {
                    return
                }
                for result in results!{
                    if let result = result as? GMSAutocompletePrediction{
                        self.searchResults.append(result.attributedFullText.string)
                    }
                }
                self.reloadDataWithArray(self.searchResults)
            }
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.searchResults.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    

    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath){

            let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
            
            SearchHelper.sharedInstance().getDestinationDetails(correctedAddress){(result, error) in
                
                if error == nil {
                    ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location] = self.searchResults[indexPath.row]
                    ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.latitude] = result!["lat"]
                    ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.longitude] = result!["lon"]
                    
                    print("Travelbirdie Location:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location]!); Latitude:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.latitude]!) Longitude:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.longitude]!)")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    self.showAlertView(SearchHelper.Constants.PleaseRetry)
                }

            }
            
            
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
