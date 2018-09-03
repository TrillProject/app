//
//  suitcaseCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/2/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class suitcaseCell: UITableViewCell {
    
    @IBOutlet weak var underline: UIView!
    @IBOutlet weak var dot: UIView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var pinBtn: UIButton!
    
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    
    @IBOutlet weak var categoryIconWidth: NSLayoutConstraint!
    @IBOutlet weak var addressLblTopSpace: NSLayoutConstraint!
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // tint pin button
        let img = pinBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        pinBtn.setImage(img, for: .normal)
        pinBtn.tintColor = mainColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
