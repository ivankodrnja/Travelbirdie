//
//  ImageSliderCell.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 22/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class ImageSliderCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var priceFromLabel: UILabel!
    @IBAction func addApartmentToFavorites(_ sender: AnyObject) {
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}
