//
//  placeReviewCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/31/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class placeReviewCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIButton!
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var uuidLbl: UILabel!
    
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var commentLblTopSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // set post rating
    func setRating(_ rating : CGFloat) {
        reviewOverlayLeadingSpace.constant = rating * reviewBackground.frame.size.width
        Review.colorReview(rating, reviewBackground)
    }

}
