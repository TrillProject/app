//
//  friendCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 10/23/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class friendCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIButton!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        let checkImage = UIImage(named: "check")
        let tintedCheckImage = checkImage?.withRenderingMode(.alwaysTemplate)
        checkBtn.setImage(tintedCheckImage, for: .normal)
        checkBtn.tintColor = mainColor
    }

}
