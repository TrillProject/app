//
//  postCategory.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/31/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

class PostCategory {
    
    class func selectImgType(_ categoryType : String, _ imgView : UIImageView!, _ imgConstraint : NSLayoutConstraint!) {
        switch categoryType {
        case "country":
            imgView.image = UIImage(named: "country")
        case "city":
            imgView.image = UIImage(named: "city")
        case "restaurant":
            imgView.image = UIImage(named: "restaurant")
        case "nightlife":
            imgView.image = UIImage(named: "nightlife")
        case "arts":
            imgView.image = UIImage(named: "arts")
        case "shop":
            imgView.image = UIImage(named: "shop")
        case "hotel":
            imgView.image = UIImage(named: "hotel")
        default:
            imgView.image = UIImage(named: "transparent")
        }
        
        if categoryType == "arts" {
            imgConstraint.constant = 29
        } else {
            imgConstraint.constant = 22
        }
    }
    
    class func selectLocationBtnType(_ categoryType : String, _ btn : UIButton!, _ btnConstraint : NSLayoutConstraint!) {
        switch categoryType {
        case "country":
            btn.setImage(UIImage(named: "country"), for: UIControlState())
        case "city":
            btn.setImage(UIImage(named: "city"), for: UIControlState())
        case "restaurant":
            btn.setImage(UIImage(named: "restaurant"), for: UIControlState())
        case "nightlife":
            btn.setImage(UIImage(named: "nightlife"), for: UIControlState())
        case "arts":
            btn.setImage(UIImage(named: "arts"), for: UIControlState())
        case "shop":
            btn.setImage(UIImage(named: "shop"), for: UIControlState())
        case "hotel":
            btn.setImage(UIImage(named: "hotel"), for: UIControlState())
        default:
            btn.setImage(UIImage(named: "transparent"), for: UIControlState())
        }
        
        if categoryType == "arts" {
            btnConstraint.constant = 29
        } else {
            btnConstraint.constant = 22
        }
    }
}
