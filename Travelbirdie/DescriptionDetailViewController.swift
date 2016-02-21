//
//  DescriptionDetailViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 21/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class DescriptionDetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var descriptionText: String!
    var titleText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let title = self.titleText{
        navigationItem.title = title
        }
        
        if let text = self.descriptionText{
            self.textView.text = text
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
