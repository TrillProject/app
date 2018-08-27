//
//  postCell.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


class postCell: UITableViewCell {

    // header objects
    @IBOutlet weak var avaImg: UIButton!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var locationBtn: UIButton!
    
    // main picture
    @IBOutlet weak var picImg: UIImageView!
    
    // review
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    
    // buttons
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var suitcaseBtn: UIButton!
    
    // tags
    @IBOutlet weak var tag1View: UIView!
    @IBOutlet weak var tag1Btn: UIButton!
    @IBOutlet weak var tag2View: UIView!
    @IBOutlet weak var tag2Btn: UIButton!
    @IBOutlet weak var tag3View: UIView!
    @IBOutlet weak var tag3Btn: UIButton!
    
    // labels
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: KILabel!
    @IBOutlet weak var uuidLbl: UILabel!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var locationImgWidth: NSLayoutConstraint!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // clear like button & suitcase button title color
        likeBtn.setTitleColor(UIColor.clear, for: UIControlState())
        suitcaseBtn.setTitleColor(UIColor.clear, for: UIControlState())
        
        // double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(postCell.likeTap))
        likeTap.numberOfTapsRequired = 2
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
    }
    
    
    // double tap to like
    func likeTap() {
        
        // create large like gray heart
        let likePic = UIImageView(image: UIImage(named: "unlike.png"))
        likePic.frame.size.width = picImg.frame.size.width / 1.5
        likePic.frame.size.height = picImg.frame.size.width / 1.5
        likePic.center = picImg.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        // hide likePic with animation and transform to be smaller
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            likePic.alpha = 0
            likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) 
        
        // declare title of button
        let title = likeBtn.title(for: UIControlState())
        
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuidLbl.text
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("liked")
                    self.likeBtn.setTitle("like", for: UIControlState())
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
                    
                    // send notification if we liked to refresh TableView
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                    
                    
                    // send notification as like
                    if self.usernameLbl.text != PFUser.current()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        newsObj["to"] = self.usernameLbl.text
                        newsObj["owner"] = self.usernameLbl.text
                        newsObj["uuid"] = self.uuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj["firstname"] = PFUser.current()?.object(forKey: "firstname") as! String
                        newsObj["lastname"] = PFUser.current()?.object(forKey: "lastname") as! String
                        newsObj["private"] = PFUser.current()?.object(forKey: "private") as! Bool
                        
                        newsObj.saveEventually()
                    }
                    
                }
            })
            
        }
        
    }
    
    // clicked suitcase button
    @IBAction func suitcaseBtn_click(_ sender: UIButton) {
        
        // declare title of button
        let title = sender.title(for: UIControlState())
        
        // to add to suitcase
        if title == "notAdded" {
            let object = PFObject(className: "suitcase")
            object["user"] = PFUser.current()?.username
            object["location"] = locationLbl.text
            object["category"] = locationBtn.currentTitle
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("added to suitcase")
                    self.suitcaseBtn.setTitle("added", for: UIControlState())
                    self.suitcaseBtn.setBackgroundImage(UIImage(named: "suitcase3.png"), for: UIControlState())
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        // to remove from suitcase
        else {
            let query = PFQuery(className: "suitcase")
            query.whereKey("user", equalTo: PFUser.current()!.username!)
            query.whereKey("location", equalTo: locationLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                for object in objects! {
                    object.deleteInBackground(block: { (success, error) -> Void in
                        if success {
                            print("removed from suitcase")
                            self.suitcaseBtn.setTitle("notAdded", for: UIControlState())
                            self.suitcaseBtn.setBackgroundImage(UIImage(named: "suitcase4.png"), for: UIControlState())
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
            })
        }
    }
    
    // clicked like button
    @IBAction func likeBtn_click(_ sender: AnyObject) {
        
        // declare title of button
        let title = sender.title(for: UIControlState())
        
        // to like
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuidLbl.text
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("liked")
                    self.likeBtn.setTitle("like", for: UIControlState())
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
                    
                    // send notification if we liked to refresh TableView
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                    
                    // send notification as like
                    if self.usernameLbl.text != PFUser.current()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        newsObj["to"] = self.usernameLbl.text
                        newsObj["owner"] = self.usernameLbl.text
                        newsObj["uuid"] = self.uuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj["firstname"] = PFUser.current()?.object(forKey: "firstname") as! String
                        newsObj["lastname"] = PFUser.current()?.object(forKey: "lastname") as! String
                        newsObj["private"] = PFUser.current()?.object(forKey: "private") as! Bool
                        newsObj.saveEventually()
                    }
                }
            })
            
        // to dislike
        } else {
            
            // request existing likes of current user to show post
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: uuidLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                
                // find objects - likes
                for object in objects! {
                    
                    // delete found like(s)
                    object.deleteInBackground(block: { (success, error) -> Void in
                        if success {
                            print("disliked")
                            self.likeBtn.setTitle("unlike", for: UIControlState())
                            self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
                            
                            // send notification if we liked to refresh TableView
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                            
                            
                            // delete like notification
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usernameLbl.text!)
                            newsQuery.whereKey("uuid", equalTo: self.uuidLbl.text!)
                            newsQuery.whereKey("type", equalTo: "like")
                            newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })
                            
                            
                        }
                    })
                }
            })
            
        }
        
    }
    
    //set location button
    func selectLocationType(_ categoryType : String) {
        switch categoryType {
        case "country":
            selectLocationButton("country")
        case "city":
            selectLocationButton("city")
        case "restaurant":
            selectLocationButton("restaurant")
        case "nightlife":
            selectLocationButton("nightlife")
        case "arts":
            selectLocationButton("arts")
        case "shop":
            selectLocationButton("shop")
        case "hotel":
            selectLocationButton("hotel")
        default:
            selectLocationButton("transparent")
        }
    }
    
    func selectLocationButton(_ name : String) {
        if name == "arts" {
            locationImgWidth.constant = 29
        } else {
            locationImgWidth.constant = 22
        }
        locationBtn.setImage(UIImage(named: name), for: UIControlState())
    }
    
    // set post rating
    func setRating(_ rating : CGFloat) {
        reviewOverlayLeadingSpace.constant = rating * reviewBackground.frame.size.width
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
    
    // set tags
    func setTags(_ assignedTags : [String]) {
        let numberOfTags = assignedTags.count
        if 0 < numberOfTags {
            tag1Btn.setTitle(assignedTags[0].uppercased(), for: .normal)
            tag1View.isHidden = false
        } else {
            tag1View.isHidden = true
        }
        if 1 < numberOfTags {
            tag2Btn.setTitle(assignedTags[1].uppercased(), for: .normal)
            tag2View.isHidden = false
        } else {
            tag2View.isHidden = true
        }
        if 2 < numberOfTags {
            tag3Btn.setTitle(assignedTags[2].uppercased(), for: .normal)
            tag3View.isHidden = false
        } else {
            tag3View.isHidden = true
        }
    }
}
