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
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var locationTitleBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    
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
    @IBOutlet weak var suitcaseBtnLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var suitcaseBtnHeight: NSLayoutConstraint!
    
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
        
    }
    
    // clicked suitcase button
    @IBAction func suitcaseBtn_click(_ sender: UIButton) {
        
        // declare title of button
        let title = sender.title(for: UIControlState())
        
        // to add to suitcase
        if title == "notAdded" {
            
            let object = PFObject(className: "suitcase")
            object["user"] = PFUser.current()?.username
            object["location"] = self.locationTitleBtn.currentTitle!
            object["address"] = self.addressLbl.text!
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("added to suitcase")
                    
                    // send notification if we liked to refresh TableView
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "suitcase"), object: nil)
                    
                    self.suitcaseBtn.setTitle("added", for: UIControlState())
                    self.suitcaseBtn.setBackgroundImage(UIImage(named: "suitcase-fill1.png"), for: UIControlState())
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
            
        // to remove from suitcase
        else {
            let query = PFQuery(className: "suitcase")
            query.whereKey("user", equalTo: PFUser.current()!.username!)
            query.whereKey("location", equalTo: locationTitleBtn.currentTitle!)
            query.whereKey("address", equalTo: addressLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                for object in objects! {
                    object.deleteInBackground(block: { (success, error) -> Void in
                        if success {
                            print("removed from suitcase")
                            
                            // send notification if we liked to refresh TableView
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "suitcase"), object: nil)
                            
                            self.suitcaseBtn.setTitle("notAdded", for: UIControlState())
                            self.suitcaseBtn.setBackgroundImage(UIImage(named: "suitcase-outline1.png"), for: UIControlState())
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
                    self.likeBtn.setBackgroundImage(UIImage(named: "heart-fill.png"), for: UIControlState())
                    
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
                            self.likeBtn.setBackgroundImage(UIImage(named: "heart-outline.png"), for: UIControlState())
                            
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
    
    
    // set post rating
    func setRating(_ rating : CGFloat) {
        reviewOverlayLeadingSpace.constant = rating * reviewBackground.frame.size.width
        Review.colorReview(rating, reviewBackground)
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
    
    // DELETE post action
    class func deletePostData(_ uuid : String, _ isFavorite : Bool) {
        
        // STEP 1. Delete likes of post from server
        let likeQuery = PFQuery(className: "likes")
        likeQuery.whereKey("to", equalTo: uuid)
        likeQuery.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            }
        })
        
        // STEP 2. Delete comments of post from server
        let commentQuery = PFQuery(className: "comments")
        commentQuery.whereKey("to", equalTo: uuid)
        commentQuery.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            }
        })
        
        // STEP 3. Delete hashtags of post from server
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("to", equalTo: uuid)
        hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            }
        })
        
        // STEP 4. Delete tags to post from server
        let tagQuery = PFQuery(className: "postTags")
        tagQuery.whereKey("to", equalTo: uuid)
        tagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            }
        })
        
        // STEP 5. Delete post favorites from server
        if isFavorite {
            let favoriteQuery = PFQuery(className: "postFavorites")
            favoriteQuery.whereKey("to", equalTo: uuid)
            favoriteQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
        }
        
        // STEP 6. Delete news related to post from server
        let newsQuery = PFQuery(className: "news")
        newsQuery.whereKey("uuid", equalTo: uuid)
        newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            }
        })
    }
}
