//
//  Apartment.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 25/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

 import UIKit
 // 1. Import CoreData
import CoreData

// 2. Make Apartment a subclass of NSManagedObject
class Apartment : NSManagedObject {
    
    // 3. We are promoting these four from simple properties, to Core Data attributes
    @NSManaged var id: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var amenities: [Amenity]
    @NSManaged var attributes: [Attribute]
    @NSManaged var photos: [Photo]
    @NSManaged var prices: [Price]
    
    // 4. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
     * 5. The two argument init method
     *
     * The Two argument Init method. The method has two goals:
     *  - insert the new Apartment into a Core Data Managed Object Context
     *  - initialze the Apartment's properties from a dictionary
     */
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Apartment" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("Apartment", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Apartment class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        id = dictionary[ZilyoClient.JSONResponseKeys.Id] as! String
        latitude = dictionary[ZilyoClient.JSONResponseKeys.LatLng]![0] as! Double
        longitude = dictionary[ZilyoClient.JSONResponseKeys.LatLng]![1] as! Double
    }
    

}


