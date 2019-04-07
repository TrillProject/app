//
//  review.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/31/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

class Review {
    class func colorReview(_ rating : CGFloat, _ reviewBackground : UIView!) {
        if rating <= 0.05 {
            reviewBackground.backgroundColor = gradientColors[0]
        } else if rating <= 0.1 {
            reviewBackground.backgroundColor = gradientColors[1]
        } else if rating <= 0.15 {
            reviewBackground.backgroundColor = gradientColors[2]
        } else if rating <= 0.2 {
            reviewBackground.backgroundColor = gradientColors[3]
        } else if rating <= 0.25 {
            reviewBackground.backgroundColor = gradientColors[4]
        } else if rating <= 0.3 {
            reviewBackground.backgroundColor = gradientColors[5]
        } else if rating <= 0.35 {
            reviewBackground.backgroundColor = gradientColors[6]
        } else if rating <= 0.4 {
            reviewBackground.backgroundColor = gradientColors[7]
        } else if rating <= 0.45 {
            reviewBackground.backgroundColor = gradientColors[8]
        } else if rating <= 0.5 {
            reviewBackground.backgroundColor = gradientColors[9]
        } else if rating <= 0.55 {
            reviewBackground.backgroundColor = gradientColors[10]
        } else if rating <= 0.6 {
            reviewBackground.backgroundColor = gradientColors[11]
        } else if rating <= 0.65 {
            reviewBackground.backgroundColor = gradientColors[12]
        } else if rating <= 0.7 {
            reviewBackground.backgroundColor = gradientColors[13]
        } else if rating <= 0.75 {
            reviewBackground.backgroundColor = gradientColors[14]
        } else if rating <= 0.8 {
            reviewBackground.backgroundColor = gradientColors[15]
        } else if rating <= 0.85 {
            reviewBackground.backgroundColor = gradientColors[16]
        } else if rating <= 0.9 {
            reviewBackground.backgroundColor = gradientColors[17]
        } else if rating <= 0.95 {
            reviewBackground.backgroundColor = gradientColors[18]
        } else {
            reviewBackground.backgroundColor = gradientColors[19]
        }
    }
}
