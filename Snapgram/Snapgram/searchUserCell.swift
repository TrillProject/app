//
//  searchUserCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/8/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class searchUserCell: UITableViewCell {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        
        // tint follow button
        let img = followBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        followBtn.setImage(img, for: .normal)
        followBtn.tintColor = lightGrey
    }

}
