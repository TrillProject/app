//
//  followerCell.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/24/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class followerCell: UICollectionViewCell {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.main.bounds.width
        let cellSize = width / 3
        avaImg.frame = CGRect(x: 0.0, y: 0.0, width: cellSize / 1.5, height: cellSize / 1.5)
        nameLbl.frame = CGRect(x: 0.0, y: 0.0, width: cellSize, height: 20.0)
        
        avaImg.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY - 1)
        nameLbl.center = CGPoint(x: self.bounds.midX, y: self.bounds.size.height - 10)
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
    }

}
