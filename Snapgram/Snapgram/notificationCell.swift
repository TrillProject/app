//
//  notificationCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/23/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class notificationCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let img = followBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        followBtn.setImage(img, for: .normal)
        followBtn.tintColor = lightGrey
    }
}
