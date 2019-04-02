//
//  postCategory.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/31/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

class PostCategory {
    
    class func selectImgType(_ categoryType : String, _ imgView : UIImageView!, _ imgConstraint : NSLayoutConstraint!, _ color: UIColor) {
        switch categoryType {
        case "country":
            imgView.image = UIImage(named: "country")!.withRenderingMode(.alwaysTemplate)
        case "city":
            imgView.image = UIImage(named: "city")!.withRenderingMode(.alwaysTemplate)
        case "restaurant":
            imgView.image = UIImage(named: "restaurant")!.withRenderingMode(.alwaysTemplate)
        case "nightlife":
            imgView.image = UIImage(named: "nightlife")!.withRenderingMode(.alwaysTemplate)
        case "arts":
            imgView.image = UIImage(named: "arts")!.withRenderingMode(.alwaysTemplate)
        case "shop":
            imgView.image = UIImage(named: "shop")!.withRenderingMode(.alwaysTemplate)
        case "hotel":
            imgView.image = UIImage(named: "hotel")!.withRenderingMode(.alwaysTemplate)
        default:
            imgView.image = UIImage(named: "transparent")!.withRenderingMode(.alwaysTemplate)
        }
        
        imgView.tintColor = color
        
        if categoryType == "arts" {
            imgConstraint.constant = 29
        } else {
            imgConstraint.constant = 22
        }
    }
    
    class func selectLocationBtnType(_ categoryType : String, _ btn : UIButton!, _ btnConstraint : NSLayoutConstraint!, _ color : UIColor) {
        switch categoryType {
        case "country":
            btn.setImage(UIImage(named: "country")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        case "city":
            btn.setImage(UIImage(named: "city")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        case "restaurant":
            btn.setImage(UIImage(named: "restaurant")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        case "nightlife":
            btn.setImage(UIImage(named: "nightlife")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        case "arts":
            btn.setImage(UIImage(named: "arts")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        case "shop":
            btn.setImage(UIImage(named: "shop")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        case "hotel":
            btn.setImage(UIImage(named: "hotel")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        default:
            btn.setImage(UIImage(named: "transparent")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        }
        
        btn.tintColor = color
        
        if categoryType == "arts" {
            btnConstraint.constant = 29
        } else {
            btnConstraint.constant = 22
        }
    }
}
