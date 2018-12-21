//
//  searchLocationCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/9/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class searchLocationCell: UITableViewCell {

    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var pinBtn: UIButton!
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    
    @IBOutlet weak var tagView1: UIView!
    @IBOutlet weak var tagView2: UIView!
    @IBOutlet weak var tagView3: UIView!
    @IBOutlet weak var tag1: UIButton!
    @IBOutlet weak var tag2: UIButton!
    @IBOutlet weak var tag3: UIButton!
    
    @IBOutlet weak var categoryIconWidth: NSLayoutConstraint!
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
