//
//  Attribute.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 25/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class Attribute : NSManagedObject {
    
    @NSManaged var bathrooms: Int
    @NSManaged var bedrooms: Int
    @NSManaged var occupancy: Int
    @NSManaged var desc: String
    @NSManaged var apartment: Apartment?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entity(forEntityName: "Attribute", in: context)!
    
        super.init(entity: entity,insertInto: context)
        
        bathrooms = dictionary["bedrooms"] as! Int
        bedrooms = dictionary["bathrooms"] as! Int
        occupancy = dictionary["occupancy"] as! Int
        desc = dictionary["description"] as! String
    }
    
    
}
