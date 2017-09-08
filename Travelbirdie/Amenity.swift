//
//  Amenity.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 25/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//
import UIKit
import CoreData

class Amenity : NSManagedObject {

    @NSManaged var list: String
    @NSManaged var apartment: Apartment?

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entity(forEntityName: "Amenity", in: context)!
        super.init(entity: entity,insertInto: context)
        
        /*
        for amenity in dictionary[ZilyoClient.JSONResponseKeys.Amenities] as! [[String : AnyObject]] {
            let amenityText = amenity["text"] as! String
            list += "\(amenityText) "

        }
        */
        list = dictionary["text"] as! String
    }
    
    
}
