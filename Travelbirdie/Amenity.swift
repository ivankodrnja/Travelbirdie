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

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("Amenity", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        for amenity in dictionary[ZilyoClient.JSONResponseKeys.Amenities] as! [[String : AnyObject]] {
            let amenityText = amenity["text"] as! String
            list += "\(amenityText) "

        }

    }
    
    
}
