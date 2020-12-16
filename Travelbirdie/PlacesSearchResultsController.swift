//
//  PlacesSearchResultsController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 12/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlacesSearchResultsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var searchResults = [String]()
    
    @IBOutlet weak var searchController: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.searchController.becomeFirstResponder()
        self.searchController.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadDataWithArray(_ array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar,
        textDidChange searchText: String){
            
            // if a user deletes previous entry clear the former results and don't alert with an error
            if searchText.isEmpty {
                self.searchResults.removeAll()
                self.reloadDataWithArray(self.searchResults)
                return
            }
            
            self.view.alpha = 0.5
            self.activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            
        // As per Google spec https://developers.google.com/places/ios-sdk/autocomplete?hl=en#getting_place_predictions_programmatically
        let token = GMSAutocompleteSessionToken.init()
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
            let placesClient = GMSPlacesClient()
        placesClient.findAutocompletePredictions(fromQuery: searchText, filter: filter, sessionToken: token, callback: { (results, error) -> Void in
                self.searchResults.removeAll()
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                    DispatchQueue.main.async {
                        self.view.alpha = 1
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.stopAnimating()
                        // Error, e.g. the internet connection is offline
                        print("Error in PlacesSearchResultsController: \(String(describing: error?.localizedDescription))")
                        self.showAlertView(error?.localizedDescription)
                    }
                }
                
                if results == nil {
                    return
                }
                
                for result in results!{
                    if let result = (result as? GMSAutocompletePrediction){
                        self.searchResults.append(result.attributedFullText.string)
                    }
                }
                self.view.alpha = 1
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.stopAnimating()
                
                self.reloadDataWithArray(self.searchResults)
                
            })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath){
            
            let correctedAddress:String! = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: CharacterSet.symbols)
            
            SearchHelper.sharedInstance().getDestinationDetails(correctedAddress){(result, error) in
                
                if error == nil {
                    ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location] = self.searchResults[indexPath.row] as AnyObject
                    ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.latitude] = result!["lat"]
                    ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.longitude] = result!["lon"]
                    
                    print("Travelbirdie Location:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.location]!); Latitude:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.latitude]!) Longitude:\(ZilyoClient.sharedInstance().tempRequestParameters[ZilyoClient.Keys.longitude]!)")
                    self.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    self.showAlertView(SearchHelper.Constants.PleaseRetry)
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
