//
//  followerCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/24/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class followerCell: UICollectionViewCell {
    
    
    @IBOutlet weak var avaImg: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // check orientation for avaImg corner radius
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            // portrait
            avaImg.layer.cornerRadius = ((UIScreen.main.bounds.width / 3) - 40) / 2
            
            
        } else {
            // landscape
            avaImg.layer.cornerRadius = ((UIScreen.main.bounds.height / 3) - 40) / 2
        }
    }

}
