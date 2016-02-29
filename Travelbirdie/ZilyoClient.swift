//
//  ZilyoClient.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 22/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation

class ZilyoClient: NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    /* Shared Session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    var apartmentDict : [ApartmentInformation] = [ApartmentInformation]()
    
    // dictionary that will temporarily hold request parameters
    var tempRequestParameters = [String : AnyObject]()

    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ZilyoClient {
        
        struct Singleton {
            static var sharedInstance = ZilyoClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    func getRentals(locationLat: Double, locationLon: Double, guestsNumber : Int = 1, checkIn : NSTimeInterval, checkOut : NSTimeInterval, page : Int = 1, completionHandler: (result: [ApartmentInformation]?, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let methodParameters = [ZilyoClient.Keys.latitude : locationLat, ZilyoClient.Keys.longitude : locationLon, ZilyoClient.Keys.guests : guestsNumber, ZilyoClient.Keys.checkIn : checkIn, ZilyoClient.Keys.checkOut : checkOut, ZilyoClient.Keys.page : page]
        

        
        /* 2. Build the URL */
        let urlString = ZilyoClient.Constants.baseSecureUrl + ZilyoClient.Constants.searchMethod + ZilyoClient.escapedParameters(methodParameters as! [String : AnyObject])
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue(ZilyoClient.Constants.ApplicationID, forHTTPHeaderField: "X-Mashape-Key")
        request.addValue("Accept", forHTTPHeaderField: "application/json")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                completionHandler(result: nil, error: error)
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
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
                
            /* 6. Use the data! */
            if let apartmentDictionary = parsedResult.valueForKey(ZilyoClient.JSONResponseKeys.Result) as? [[String:AnyObject]] {
                
               //print(apartmentDictionary)
                let apartments = ApartmentInformation.apartmentsFromResults(apartmentDictionary)
                completionHandler(result: apartments, error: nil)
                
            } else {
                completionHandler(result: nil, error: NSError(domain: "Results from Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
            }

        }
        /* 7. Start the request */
        task.resume()
    }
    
    
    
    // MARK: - All purpose task method for images
    
    func taskForImageWithSize(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: filePath)
        
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = ZilyoClient.errorForData(data, response: response, error: error)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    
    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            
            if let _ = parsedResult as? [String : AnyObject] {
                let userInfo = [NSLocalizedDescriptionKey : "There was an error"]
                return NSError(domain: "Zilyo Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }

}