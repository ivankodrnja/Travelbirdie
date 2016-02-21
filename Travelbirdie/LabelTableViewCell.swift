//
//  LabelTableViewCell.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 20/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    @IBOutlet weak var bedroomCount: UILabel!
    @IBOutlet weak var bedroom: UILabel!
    @IBOutlet weak var bathroomCount: UILabel!
    @IBOutlet weak var bathroom: UILabel!
    @IBOutlet weak var sleepsCount: UILabel!
    @IBOutlet weak var sleeps: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
