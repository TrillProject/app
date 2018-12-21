//
//  locationCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/16/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class locationCell: UITableViewCell {

    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
