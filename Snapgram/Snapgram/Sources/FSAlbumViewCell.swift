//
//  FSAlbumViewCell.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos

final class FSAlbumViewCell: UICollectionViewCell {
<<<<<<< HEAD
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkmarkImageView: UIImageView! {
        didSet {
            checkmarkImageView.isHidden = true
        }
    }
    
    var selectedLayer = CALayer()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
=======
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        
        didSet {
            
            self.imageView.image = image            
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
<<<<<<< HEAD
        
        isSelected = false
        selectedLayer.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor
=======
        self.isSelected = false
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    }
    
    override var isSelected : Bool {
        didSet {
<<<<<<< HEAD
            if selectedLayer.superlayer == self.layer {
                selectedLayer.removeFromSuperlayer()
                checkmarkImageView.isHidden = true
            }
            
            if isSelected {
                selectedLayer.frame = self.bounds
                layer.addSublayer(selectedLayer)
                checkmarkImageView.isHidden = false
            }
=======
            self.imageView.alpha = isSelected ? 0.5 : 1.0
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        }
    }
}
