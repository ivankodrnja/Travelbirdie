//
//  FavoritesViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 25/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var sharedContext: NSManagedObjectContext {
            return CoreDataStackManager.sharedInstance().managedObjectContext
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 350
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ZilyoClient.sharedInstance().apartmentDict.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "SearchResultViewCell"
        
        tableView.registerNib(UINib(nibName: "SearchResultViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as! SearchResultViewCell
        
        return cell
    }
}
