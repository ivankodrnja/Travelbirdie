//
//  SearchHelper.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 21/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation

class SearchHelper : NSObject {
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    /* Shared Session */
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> SearchHelper {
        
        struct Singleton {
            static var sharedInstance = SearchHelper()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: Constants
    
    struct Constants {
        
        static let baseSecureUrl: String = "https://maps.googleapis.com/maps/api/geocode/json?sensor=false&address="
        static let ApplicationID = "AIzaSyCu-8E-ipkzCL_pnv_kZHMspFgf0qLaAWU"
        static let Location = "Destination"
        static let Unknown = "Unknown"
        static let NumberOfGuests = "Number of guests"
        static let CheckIn = "Check In"
        static let CheckOut = "Check Out"
        static let Count = 5
        static let SearchRentals = "SEARCH RENTALS"
        static let ChooseDestination = "Please choose a destination"
        static let PleaseRetry = "Please retry!"
        static let BookNow = "BOOK NOW"
    }
    
    func getDestinationDetails(_ correctedAddress : String, completionHandlerForDestinationDetails: @escaping (_ result: [String : AnyObject]?, _ error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // there is only one parameter
        
        
        
        /* 2. Build the URL */
        let urlString = SearchHelper.Constants.baseSecureUrl + correctedAddress
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
   
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDestinationDetails(nil, NSError(domain: "getDestinationDetails", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String:AnyObject]
                
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let dictionaryGeo = parsedResult["results"] {
                
                let dictionaryGeoResult = dictionaryGeo[0] as! [String:AnyObject]
                let geometry = dictionaryGeoResult["geometry"] as! [String:AnyObject]
    
                let location = geometry["location"]
                print(location!)
            }
            
            /* 6. Use the data! value(forKey:"geometry").value(forKey:"location").objectAtIndex(0)*/
            if let dictionaryGeo = parsedResult["results"] {
                
                let dictionaryGeoResult = dictionaryGeo[0] as! [String:AnyObject]
                let geometry = dictionaryGeoResult["geometry"] as! [String:AnyObject]
                
                let location = geometry["location"]
                
                if let lat = location?["lat"], let lon = location?["lng"] {
                    let resultDictionary = ["lat" : lat, "lon" : lon]
                    
                    completionHandlerForDestinationDetails(resultDictionary as [String : AnyObject], nil)
                }
                
 
                
                
            } else {
                completionHandlerForDestinationDetails(nil, NSError(domain: "Results from Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
            }
            
        }
        /* 7. Start the request */
        task.resume()
    }
}
