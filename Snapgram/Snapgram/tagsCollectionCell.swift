//
//  tagsCollectionCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/5/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class tagsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var uuidLbl: UILabel!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var categoryImgWidth: NSLayoutConstraint!
}
