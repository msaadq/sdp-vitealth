//
//  FoodDetailsTableViewCell.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/22/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit

class FoodDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var brand: UILabel!
    @IBOutlet weak var calories: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
