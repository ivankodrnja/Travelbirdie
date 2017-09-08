//
//  ZilyoClient.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 22/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation

class ZilyoClient: NSObject {
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    /* Shared Session */
    var session: URLSession
    
    override init() {
        session = URLSession.shared
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
    
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    
    func getRentals(_ locationLat: Double, locationLon: Double, guestsNumber : Int = 1, checkIn : TimeInterval, checkOut : TimeInterval, page : Int = 1, completionHandlerForGetRentals: @escaping (_ result: [ApartmentInformation]?, _ error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let methodParameters = [ZilyoClient.Keys.latitude : locationLat, ZilyoClient.Keys.longitude : locationLon, ZilyoClient.Keys.guests : guestsNumber, ZilyoClient.Keys.checkIn : checkIn, ZilyoClient.Keys.checkOut : checkOut, ZilyoClient.Keys.page : page] as [String : Any]
        

        
        /* 2. Build the URL */
        let urlString = ZilyoClient.Constants.baseSecureUrl + ZilyoClient.Constants.searchMethod + ZilyoClient.escapedParameters(methodParameters as [String : AnyObject])
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
        request.addValue(ZilyoClient.Constants.ApplicationID, forHTTPHeaderField: "X-Mashape-Key")
        request.addValue("Accept", forHTTPHeaderField: "application/json")
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest)  { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetRentals(nil, NSError(domain: "getRentals", code: 1, userInfo: userInfo))
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
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                print(parsedResult)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
                
            /* 6. Use the data! */
            if let apartmentDictionary = parsedResult[ZilyoClient.JSONResponseKeys.Result] as? [[String:AnyObject]] {
                
               //print(apartmentDictionary)
                let apartments = ApartmentInformation.apartmentsFromResults(apartmentDictionary)
                completionHandlerForGetRentals(apartments, nil)
                
            } else {
                completionHandlerForGetRentals(nil,  NSError(domain: "Results from Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
            }

        }
        /* 7. Start the request */
        task.resume()
    }
    
    
    
    // MARK: - All purpose task method for images
    
    func taskForImageWithSize(_ filePath: String, completionHandlerForImageWithSize: @escaping (_ imageData: Data?, _ error: NSError?) ->  Void) -> URLSessionTask {
        
        let url = URL(string: filePath)
        
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, downloadError) in
            
            if let error = downloadError {
                let newError = ZilyoClient.errorForData(data, response: response, error: error as NSError)
                completionHandlerForImageWithSize(nil, newError)
            } else {
                completionHandlerForImageWithSize(data, nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    
    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error
    
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            
            if let _ = parsedResult as? [String : AnyObject] {
                let userInfo = [NSLocalizedDescriptionKey : "There was an error"]
                return NSError(domain: "Zilyo Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }

}
