//
//  Photo.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 25/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class Photo : NSManagedObject {
    
    @NSManaged var path: String
    @NSManaged var apartment: Apartment?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Photo", in: context)!

        super.init(entity: entity,insertInto: context)
        
        path = dictionary["large"] as! String
        
    }
    
}
