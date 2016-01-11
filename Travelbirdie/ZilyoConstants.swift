//
//  ZilyoConstants.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 22/11/15.
//  Copyright © 2015 Ivan Kodrnja. All rights reserved.
//

extension ZilyoClient {
    
    struct Constants {
        static let baseSecureUrl: String = "https://zilyo.p.mashape.com/"
        static let searchMethod = "search"
        static let countMethod = "count"
        static let idMethod = "id"
        static let ApplicationID = "5rLGHoSuYymsh6edZqeSBHwij58cp1BgjgbjsnxyNFFTrMEzb6"
    }
    
    struct Keys {
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let guests = "guests"
        static let checkIn = "stimestamp"
        static let checkOut = "etimestamp"
        
    }
    
    struct JSONResponseKeys {
        static let Result = "result"
        static let Price = "price"
        static let Provider = "provider"
        static let Amenities = "amenities"
        static let Attr = "attr"
        static let Id = "id"
        static let LatLng = "latLng"
        static let PriceRange = "priceRange"
        static let Photos = "photos"
        static let Location = "location"
        static let Availability = "availability"
        static let ItemStatus = "itemStatus"
        static let Reviews = "reviews"
    }
}
