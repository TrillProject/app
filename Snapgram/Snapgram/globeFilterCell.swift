//
//  globeFilterCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 11/17/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class globeFilterCell: UITableViewCell {
    
    @IBOutlet weak var singleImg: UIImageView!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    
    @IBOutlet weak var tag1View: UIView!
    @IBOutlet weak var tag1Btn: UIButton!
    @IBOutlet weak var tag2View: UIView!
    @IBOutlet weak var tag2Btn: UIButton!
    @IBOutlet weak var tag3View: UIView!
    @IBOutlet weak var tag3Btn: UIButton!
    
    @IBOutlet weak var categoryIconWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
