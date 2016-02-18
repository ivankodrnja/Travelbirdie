//
//  DetailViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 15/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceFromLabel: UILabel!
    @IBOutlet weak var bedroomText: UIButton!
    
    
    var accommodationId : String?
    
    var apartment : ApartmentInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // workaround for putting scroll view under the navigation bar
        let navBarHeight = self.navigationController?.navigationBar.frame.height
        let statusHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        self.scrollView.contentInset = UIEdgeInsets(top: -navBarHeight! - statusHeight, left: 0, bottom: 0, right: 0)
        
        //self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.title = apartment!.attr!["heading"] as? String
        
        
        // get the first object in array of photos
        var photo = apartment!.photos![0]
        // get the large image from the first object in photos array
        let largePhotoUrl = photo ["large"]
        
        if let titleImageUrl = largePhotoUrl {
            
            // Start the task that will eventually download the image
            _ = ZilyoClient.sharedInstance().taskForImageWithSize(titleImageUrl as! String) { data, error in
                
                // default placeholder image
                self.imageView.image = UIImage(named: "noImage")
                
                if let error = error {
                    print("Title download error: \(error.localizedDescription)")
                    dispatch_async(dispatch_get_main_queue()) {
                        // show placeholder image
                        self.imageView.image = UIImage(named: "noImage")
                    }
                }
                
                if let data = data {
                    // Create the image
                    let image = UIImage(data: data)
                    
                    // update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.imageView.image = image
                        
                    }
                }
            }
            
            
            // set bedroom text
            self.bedroomText.layer.borderColor = UIColor.blackColor().CGColor
            self.bedroomText.layer.borderWidth = 2
            self.bedroomText.backgroundColor = UIColor.yellowColor()
            //***** set the number of bedrooms *****//
            let bedroomsNumber = apartment!.attr!["bedrooms"] as? Int
            self.bedroomText.titleLabel?.text = "\(bedroomsNumber!)"
        }
        
        //***** set the the daily price *****//
        let dailyPrice = apartment!.price!["nightly"] as? Int
        priceFromLabel.text = "$ \(dailyPrice!)+"
        
    }
    

    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.navigationBarHidden = false
        //self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.alpha = 0.7
        self.navigationController?.navigationBar.translucent = true
    }
 
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.alpha = 0.8
        self.navigationController?.navigationBar.translucent = true
       // self.navigationController?.hidesBarsOnSwipe = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
