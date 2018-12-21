//
//  headerView.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


class headerView: UICollectionReusableView {
    
    // UI objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var coverImg: UIImageView!
    
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    
    @IBOutlet weak var editOrFollowBtn: UIButton!
    
    @IBOutlet weak var feedBtn: UIImageView!
    @IBOutlet weak var globeBtn: UIImageView!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.main.bounds.width
        let spacingVertical = CGFloat(20)
        let avaSize = CGFloat(100)
        
        avaImg.frame = CGRect(x: (width / 2) - (avaSize / 2), y: spacingVertical, width: avaSize, height: avaSize)
        coverImg.frame = CGRect(x: 0, y: 0, width: width, height: avaImg.frame.size.height + (spacingVertical * 2))
        
        let iconsY = avaImg.frame.origin.y + avaImg.frame.size.height + (spacingVertical * 1.75)
        let iconSize = 28
        let iconSpacing = (width - CGFloat(40 + iconSize * 5)) / 4
        
        feedBtn.frame = CGRect(x: 20, y: Int(iconsY), width: iconSize, height: iconSize)
        globeBtn.frame = CGRect(x: Int(feedBtn.frame.origin.x + iconSpacing) + Int(iconSize), y: Int(iconsY), width: iconSize, height: iconSize)
        followers.frame = CGRect(x: Int(globeBtn.frame.origin.x + iconSpacing) + Int(iconSize), y: Int(iconsY - 7), width: 50, height: 30)
        followings.frame = CGRect(x: Int(followers.frame.origin.x + iconSpacing) + Int(iconSize), y: Int(iconsY - 7), width: 50, height: 30)
        editOrFollowBtn.frame = CGRect(x: Int(followings.frame.origin.x + iconSpacing) + Int(iconSize), y: Int(iconsY), width: iconSize, height: iconSize)
        
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 17)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 17)
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
    }
    
    // clicked follow button from GuestVC
    @IBAction func followBtn_clicked(_ sender: AnyObject) {
        
        let followingImage = UIImage(named: "check")
        let followingTintedImage = followingImage?.withRenderingMode(.alwaysTemplate)
        let notFollowingTintedImage = followingImage?.withRenderingMode(.alwaysTemplate)
        
        // to follow
        if self.editOrFollowBtn.tintColor == lightGrey {
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = guestname.last!
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.editOrFollowBtn.setBackgroundImage(followingTintedImage, for: .normal)
                    self.editOrFollowBtn.tintColor = mainColor
                    
                    // send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    if PFUser.current()?.object(forKey: "ava") != nil {
                        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    } else {
                        let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                        newsObj["ava"] = avaFile!
                    }
                    newsObj["to"] = guestname.last
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                    
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            // unfollow
        } else {
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: guestname.last!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success { self.editOrFollowBtn.setBackgroundImage(notFollowingTintedImage, for: .normal)
                                self.editOrFollowBtn.tintColor = lightGrey
                                
                                // delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: guestname.last!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                            } else {
                                print(error?.localizedDescription)
                            }
                        })
                    }
                    
                } else {
                    print(error?.localizedDescription)
                }
            })
            
        }
        
    }
   
}
