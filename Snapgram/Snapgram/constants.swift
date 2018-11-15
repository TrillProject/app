//
//  constants.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/13/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

//let mainColor = UIColor(red: 185.0 / 255.0, green: 172.0 / 255.0, blue: 244.0 / 255.0, alpha: 1)
let mainColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
let mainFadedColor = UIColor(red: 199.0 / 255.0, green: 166.0 / 255.0, blue: 101.0 / 255.0, alpha: 1)
//let mainFadedColor = UIColor(red: 222.0 / 255.0, green: 216.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
let lightGrey = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1)
let mediumGrey = UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1)
let darkGrey = UIColor(red: 102.0 / 255.0, green: 102.0 / 255.0, blue: 102.0 / 255.0, alpha: 1)
let borderColor = UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1)
let redColor = UIColor(red: 255.0 / 255.0, green: 102.0 / 255.0, blue: 122.0 / 255.0, alpha: 1)
let separatorColor = UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1)
let highlightColor = UIColor(red: 157.0 / 255.0, green: 108.0 / 255.0, blue: 4.0 / 255.0, alpha: 1)


//let gradientColors = [#colorLiteral(red: 1, green: 0.4, blue: 0.4784313725, alpha: 1),#colorLiteral(red: 1, green: 0.4117647059, blue: 0.462745098, alpha: 1),#colorLiteral(red: 1, green: 0.4352941176, blue: 0.4196078431, alpha: 1),#colorLiteral(red: 1, green: 0.4784313725, blue: 0.3568627451, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0.5254901961, blue: 0.2823529412, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0.5764705882, blue: 0.2156862745, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0.631372549, blue: 0.1490196078, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0.6705882353, blue: 0.1137254902, alpha: 1),#colorLiteral(red: 1, green: 0.7215686275, blue: 0.1058823529, alpha: 1),#colorLiteral(red: 1, green: 0.7803921569, blue: 0.1058823529, alpha: 1),#colorLiteral(red: 1, green: 0.8352941176, blue: 0.1176470588, alpha: 1),#colorLiteral(red: 1, green: 0.8862745098, blue: 0.168627451, alpha: 1),#colorLiteral(red: 1, green: 0.9137254902, blue: 0.231372549, alpha: 1),#colorLiteral(red: 0.937254902, green: 0.9137254902, blue: 0.2862745098, alpha: 1),#colorLiteral(red: 0.8431372549, green: 0.9137254902, blue: 0.3647058824, alpha: 1),#colorLiteral(red: 0.7411764706, green: 0.9137254902, blue: 0.4470588235, alpha: 1),#colorLiteral(red: 0.6352941176, green: 0.9058823529, blue: 0.5294117647, alpha: 1),#colorLiteral(red: 0.5176470588, green: 0.8941176471, blue: 0.6196078431, alpha: 1),#colorLiteral(red: 0.4156862745, green: 0.8862745098, blue: 0.6980392157, alpha: 1),#colorLiteral(red: 0.3254901961, green: 0.8745098039, blue: 0.768627451, alpha: 1)]
let gradientColors = [#colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1),#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1),#colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1),#colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1),#colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1),#colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1),#colorLiteral(red: 0.7215686275, green: 0.7215686275, blue: 0.7215686275, alpha: 1),#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1),#colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1),#colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1),#colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1),#colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1),#colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1),#colorLiteral(red: 0.3764705882, green: 0.3764705882, blue: 0.3764705882, alpha: 1),#colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1),#colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1),#colorLiteral(red: 0.1882352941, green: 0.1882352941, blue: 0.1882352941, alpha: 1),#colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1),#colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.06274509804, alpha: 1),#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
let ratingWords = ["literally the worst", "avoid going here", "pretty bad", "mediocre", "decent", "worth a visit", "very good", "super awesome", "spectacular", "one of the best experiences of my life"]
