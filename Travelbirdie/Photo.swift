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
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!

        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        path = dictionary[ZilyoClient.JSONResponseKeys.Photos]!["large"] as! String
        
    }
    
    var image: UIImage? {
        
        get {
            return ZilyoClient.Caches.imageCache.imageWithIdentifier(path)
        }
        
        set {
            ZilyoClient.Caches.imageCache.storeImage(newValue, withIdentifier: path)
        }
    }
}