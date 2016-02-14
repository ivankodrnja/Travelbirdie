//
//  SearchHelper.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 21/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation

class SearchHelper : NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    /* Shared Session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
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
    }
    
    func getDestinationDetails(correctedAddress : String, completionHandler: (result: [String : AnyObject]?, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // there is only one parameter
        
        
        
        /* 2. Build the URL */
        let urlString = SearchHelper.Constants.baseSecureUrl + correctedAddress
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
   
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                //completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let dictionary = parsedResult.valueForKey("results")?.valueForKey("geometry")?.valueForKey("location")?.objectAtIndex(0) {
                
                let lat = dictionary["lat"] as! Double
                let lon = dictionary["lng"] as! Double
                
                let resultDictionary = ["lat" : lat, "lon" : lon]
                
                completionHandler(result: resultDictionary, error: nil)
                
            } else {
                completionHandler(result: nil, error: NSError(domain: "Results from Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
            }
            
        }
        /* 7. Start the request */
        task.resume()
    }
}