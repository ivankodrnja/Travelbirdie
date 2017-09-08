//
//  Price.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 25/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class Price : NSManagedObject {
    
    @NSManaged var nightly: Int
    @NSManaged var weekendNight: Int
    @NSManaged var weekly: Int
    @NSManaged var monthly: Int
    @NSManaged var apartment: Apartment?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Price", in: context)!
        
        super.init(entity: entity,insertInto: context)
        
        nightly = dictionary["nightly"] as! Int
        weekendNight = dictionary["weekend"] as! Int
        weekly = dictionary["weekly"] as! Int
        monthly = dictionary["monthly"] as! Int
    }
    
    
}
