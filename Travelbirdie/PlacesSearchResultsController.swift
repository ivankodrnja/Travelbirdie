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
    var resultsArray = [String]()
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
       self.searchController = UISearchController(searchResultsController: nil)
       self.searchController.searchBar.delegate = self
       //self.searchController.searchBar.sizeToFit()
       tableView.tableHeaderView = self.searchController.searchBar
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
            
            let placesClient = GMSPlacesClient()
            placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:NSError?) -> Void in
                self.searchResults.removeAll()////////////
                if results == nil {
                    return
                }
                for result in results!{
                    if let result = result as? GMSAutocompletePrediction{
                        self.searchResults.append(result.attributedFullText.string)///////////
                    }
                }
                self.reloadDataWithArray(self.searchResults)////////
            }
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
            // 1
            // 2
            let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
            let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false")
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
                // 3
                do {
                    if data != nil{
                        let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as!  NSDictionary
                        
                        let lat = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lat")?.objectAtIndex(0) as! Double
                        let lon = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lng")?.objectAtIndex(0) as! Double
                        // 4
                        print("Latitude:\(lat); Longitude:\(lon)")
                        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location] = self.searchResults[indexPath.row]
                        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.latitude] = lat
                        ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.longitude] = lon
                        print("Travelbirdie Location:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location]!); Latitude:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.latitude]!) Longitude:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.longitude]!)")
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }catch {
                    print("Error")
                }
            }
            // 5
            task.resume()
    }
    

}
