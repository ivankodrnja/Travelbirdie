//
//  ApartmentInformation.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 30/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

struct ApartmentInformation {

    var price: [String : AnyObject]?
    var provider: [String : AnyObject]?
    var amenities: [[String : AnyObject]]?
    var attr: [String : AnyObject]?
    var id: String?
    var latLng: [Double]?
    var priceRange: [[String : AnyObject]]?
    var photos: [[String : AnyObject]]?
    var location: [String : AnyObject]?
    var availability: [[String : AnyObject]]?
    var itemStatus: String?
    var reviews: [[String : AnyObject]]?
    
    /* Construct a StudentInformation from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        price = dictionary[ZilyoClient.JSONResponseKeys.Price] as? [String : AnyObject]
        provider = dictionary[ZilyoClient.JSONResponseKeys.Provider] as? [String : AnyObject]
        amenities = dictionary[ZilyoClient.JSONResponseKeys.Amenities] as? [[String : AnyObject]]
        attr = dictionary[ZilyoClient.JSONResponseKeys.Attr] as? [String : AnyObject]
        id = dictionary[ZilyoClient.JSONResponseKeys.Id] as? String
        latLng = dictionary[ZilyoClient.JSONResponseKeys.LatLng] as? [Double]
        priceRange = dictionary[ZilyoClient.JSONResponseKeys.PriceRange] as? [[String : AnyObject]]
        photos = dictionary[ZilyoClient.JSONResponseKeys.Photos] as? [[String : AnyObject]]
        location = dictionary[ZilyoClient.JSONResponseKeys.Location] as? [String : AnyObject]
        availability = dictionary[ZilyoClient.JSONResponseKeys.Availability] as? [[String : AnyObject]]
        itemStatus = dictionary[ZilyoClient.JSONResponseKeys.ItemStatus] as? String
        reviews = dictionary[ZilyoClient.JSONResponseKeys.Reviews] as? [[String : AnyObject]]
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of ApartmentInformation objects */
    static func apartmentsFromResults(_ results: [[String : AnyObject]]) -> [ApartmentInformation] {
        var apartments = [ApartmentInformation]()
        
        for result in results {
            apartments.append(ApartmentInformation(dictionary: result))
        }
        
        return apartments
    }
    
    
}
