//
//  SearchHelper.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 21/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation

class SearchHelper : NSObject {
    
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
        
        static let Location = "Location"
        static let NumberOfGuests = "Number of guests"
        static let CheckIn = "Check In"
        static let CheckOut = "Check Out"
        static let Count = 5
        static let SearchRentals = "SEARCH RENTALS"
    }
    
    
}