//
//  postCategory.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/31/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

class PostCategory {
    
    class func selectImgType(_ categoryType : String, _ imgView : UIImageView!) {
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
    }
}
