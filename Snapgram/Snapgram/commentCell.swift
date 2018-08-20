//
//  commentCell.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit


class commentCell: UITableViewCell {

    // UI objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var commentLbl: KILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0.01, bottom: 0.01, right: 0)
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
    }

}
