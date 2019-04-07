//
//  mentionCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/19/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class mentionCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
    }
}
