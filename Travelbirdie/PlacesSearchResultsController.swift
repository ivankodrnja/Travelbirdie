//
//  PlacesSearchResultsController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 12/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import GoogleMaps


class PlacesSearchResultsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var searchResults = [String]()
    
    @IBOutlet weak var searchController: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.searchController.becomeFirstResponder()
        self.searchController.delegate = self
    }
    

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
            
            self.view.alpha = 0.5
            self.activityIndicator.startAnimating()
            
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
                self.view.alpha = 1
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.stopAnimating()
                
                self.reloadDataWithArray(self.searchResults)
            }
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.searchResults.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    

    func tableView(tableView: UITableView,
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
