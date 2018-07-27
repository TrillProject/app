//
//  profileUserVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/18/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var guestname = [String]()

class profileUserVC: UIViewController {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var coverImg: UIImageView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var feedImg: UIImageView!
    @IBOutlet weak var globeImg: UIImageView!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingTitle: UILabel!
    
    @IBOutlet weak var navBorder: UIView!
    
    @IBOutlet weak var feedView: UIView!
    @IBOutlet weak var globeView: UIView!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    @IBOutlet weak var lockImg: UIImageView!
    @IBOutlet weak var privateLbl: UILabel!
    
    private var isPrivate = false
    private var isFollowing = false
    private var firstname = String()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //alignment
        let width = UIScreen.main.bounds.width
        let spacingVertical = CGFloat(20)
        let avaSize = CGFloat(100)
        let iconsY = avaSize + (spacingVertical * 2.75)
        let iconSize = CGFloat(26)
        let iconSpacing = (width - CGFloat(40 + iconSize * 5)) / 4
        let lockSize = CGFloat(60)
        
        avaImg.frame = CGRect(x: (width / 2) - (avaSize / 2), y: spacingVertical, width: avaSize, height: avaSize)
        coverImg.frame = CGRect(x: 0, y: 0, width: width, height: avaImg.frame.size.height + (spacingVertical * 2))
        
        feedImg.frame = CGRect(x: 20, y: iconsY, width: iconSize, height: iconSize)
        globeImg.frame = CGRect(x: feedImg.frame.origin.x + iconSpacing + iconSize, y: iconsY, width: iconSize, height: iconSize)
        followers.frame = CGRect(x: globeImg.frame.origin.x + iconSpacing + iconSize, y: iconsY - 8, width: iconSize, height: iconSize)
        following.frame = CGRect(x: followers.frame.origin.x + iconSpacing + iconSize, y: iconsY - 8, width: iconSize, height: iconSize)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 17)
        followingTitle.center = CGPoint(x: following.center.x, y: following.center.y + 17)
        followBtn.frame = CGRect(x: width - (iconSize + 20), y: iconsY, width: iconSize, height: iconSize)
        
        navBorder.frame = CGRect(x: 0, y: avaSize + iconSize + spacingVertical * 3.5, width: width, height: 1)
        navBorder.backgroundColor = borderColor
        
        lockImg.frame = CGRect(x: 50, y: navBorder.frame.origin.y + 150, width: lockSize, height: lockSize)
        privateLbl.frame = CGRect(x: lockSize + lockImg.frame.origin.x + 30, y: lockImg.frame.origin.y, width: width - 130 - lockSize, height: lockSize)
        
        segmentControl.frame = CGRect(x: CGFloat(0), y: iconsY, width: width - (iconSize + 20), height: iconSize)
        segmentControl.tintColor = UIColor.clear
        segmentControl.setWidth(iconSpacing + iconSize, forSegmentAt: 0)
        segmentControl.setWidth(iconSpacing + iconSize, forSegmentAt: 1)
        segmentControl.setWidth(iconSpacing + iconSize, forSegmentAt: 2)
        segmentControl.setWidth(iconSpacing + iconSize, forSegmentAt: 3)
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        // icon colors
        feedImg.image = feedImg.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        feedImg.tintColor = darkGrey
        
        globeImg.image = globeImg.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        globeImg.tintColor = lightGrey
        
        let followImg = followBtn.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
        followBtn.setBackgroundImage(followImg, for: .normal)
        followBtn.tintColor = lightGrey
        
        // STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last!)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    // call alert
                    let alert = UIAlertController(title: "\(guestname.last!.uppercased())", message: "is not existing", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                
                // find related to user information
                for object in objects! {
                    
                    if object.object(forKey: "firstname") != nil {
                        self.navigationItem.title = (object.object(forKey: "firstname") as? String)?.capitalized
                        self.firstname = ((object.object(forKey: "firstname") as? String)?.capitalized)!
                    } else {
                        self.navigationItem.title = guestname.last!
                        self.firstname = guestname.last!
                    }
                    
                    // get profile picture
                    if object.object(forKey: "ava") != nil {
                        let avaFile : PFFile = (object.object(forKey: "ava") as? PFFile)!
                        avaFile.getDataInBackground(block: { (data, error) -> Void in
                            self.avaImg.image = UIImage(data: data!)
                        })
                    } else {
                        self.avaImg.image = UIImage(named: "pp")
                    }
                    
                    // get cover photo
                    if object.object(forKey: "cover") == nil {
                        self.coverImg.image = UIImage(named: "transparent")
                    } else {
                        let coverFile = (object.object(forKey: "cover") as? PFFile)!
                        coverFile.getDataInBackground(block: { (data, error) -> Void in
                            self.coverImg.image = UIImage(data: data!)
                        })
                    }
                    
                    // check if profile is private
                    if object.object(forKey: "private") != nil,  (object.object(forKey: "private") as? Bool) == true {
                        self.isPrivate = true
                    } else {
                    }
                    
                    // check if following
                    let followingQuery = PFQuery(className: "follow")
                    followingQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
                    followingQuery.whereKey("following", equalTo: guestname.last!)
                    followingQuery.countObjectsInBackground (block: { (count, error) -> Void in
                        if error == nil {
                            if count == 0 {
                            } else {
                                self.isFollowing = true
                            }
                            self.displayViewForPrivate(private: self.isPrivate, following: self.isFollowing, name : self.firstname)
                        } else {
                            print(error?.localizedDescription ?? "error")
                        }
                    })
                }
            } else {
                print(error?.localizedDescription ?? "error")
            }
        })
        
        // STEP 2. Show does current user follow guest or do not
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count == 0 {
                    self.followBtn.tintColor = lightGrey
                } else {
                    self.followBtn.tintColor = mainColor
                }
            } else {
                print(error?.localizedDescription ?? "error")
            }
        })
        
        // STEP 3. Count statistics
        // count followers
        let userFollowers = PFQuery(className: "follow")
        userFollowers.whereKey("following", equalTo: guestname.last!)
        userFollowers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                self.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? "error")
            }
        })
        
        // count followings
        let userFollowings = PFQuery(className: "follow")
        userFollowings.whereKey("follower", equalTo: guestname.last!)
        userFollowings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                self.following.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? "error")
            }
        })
    }
    
    // clicked follow button
    @IBAction func clicked_followBtn(_ sender: UIButton) {
        
        // to follow
        if self.followBtn.tintColor == lightGrey {
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = guestname.last!
            if !self.isPrivate {
                // to follow if profile is not private
                object["requested"] = false
                object["accepted"] = true
            } else {
                // to request to follow if profile is private
                object["requested"] = true
                object["accepted"] = false
            }
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    if !self.isPrivate {
                        self.followBtn.tintColor = mainColor
                    } else {
                        self.followBtn.tintColor = mainFadedColor
                    }
                        
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
                    print(error?.localizedDescription ?? "error")
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
                            if success {
                                self.followBtn.tintColor = lightGrey
                                
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
                                print(error?.localizedDescription ?? "error")
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription ?? "error")
                }
            })
        }
    }
    
    // display view for private profile
    func displayViewForPrivate(private isPrivate : Bool, following isFollowing : Bool, name firstname : String) {
        if isPrivate, isFollowing == false {
            lockImg.isHidden = false
            privateLbl.text = "\(firstname)'s profile is private.\nSend a request to follow."
            privateLbl.isHidden = false
            feedView.isHidden = true
            globeView.isHidden = true
            followersView.isHidden = true
            followingView.isHidden = true
            feedImg.tintColor = darkGrey
            globeImg.tintColor = lightGrey
            followers.textColor = lightGrey
            followersTitle.textColor = lightGrey
            following.textColor = lightGrey
            followingTitle.textColor = lightGrey
        } else if isFollowing || !isPrivate {
            lockImg.isHidden = true
            privateLbl.isHidden = true
            feedView.isHidden = false
            globeView.isHidden = true
            followersView.isHidden = true
            followingView.isHidden = true
            feedImg.tintColor = darkGrey
            globeImg.tintColor = lightGrey
            followers.textColor = lightGrey
            followersTitle.textColor = lightGrey
            following.textColor = lightGrey
            followingTitle.textColor = lightGrey
        }
    }
    
    
    //navigation between profile views
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        if isFollowing || !isPrivate {
            switch segmentControl.selectedSegmentIndex {
            case 0:
                // feed
                feedView.isHidden = false
                globeView.isHidden = true
                followersView.isHidden = true
                followingView.isHidden = true
                feedImg.tintColor = darkGrey
                globeImg.tintColor = lightGrey
                followers.textColor = lightGrey
                followersTitle.textColor = lightGrey
                following.textColor = lightGrey
                followingTitle.textColor = lightGrey
            case 1:
                // globe
                feedView.isHidden = true
                globeView.isHidden = false
                followersView.isHidden = true
                followingView.isHidden = true
                feedImg.tintColor = lightGrey
                globeImg.tintColor = darkGrey
                followers.textColor = lightGrey
                followersTitle.textColor = lightGrey
                following.textColor = lightGrey
                followingTitle.textColor = lightGrey
            case 2:
                // followers
                feedView.isHidden = true
                globeView.isHidden = true
                followersView.isHidden = false
                followingView.isHidden = true
                feedImg.tintColor = lightGrey
                globeImg.tintColor = lightGrey
                followers.textColor = darkGrey
                followersTitle.textColor = darkGrey
                following.textColor = lightGrey
                followingTitle.textColor = lightGrey
            case 3:
                // following
                feedView.isHidden = true
                globeView.isHidden = true
                followersView.isHidden = true
                followingView.isHidden = false
                feedImg.tintColor = lightGrey
                globeImg.tintColor = lightGrey
                followers.textColor = lightGrey
                followersTitle.textColor = lightGrey
                following.textColor = darkGrey
                followingTitle.textColor = darkGrey
            default:
                // feed
                feedView.isHidden = false
                globeView.isHidden = true
                followersView.isHidden = true
                followingView.isHidden = true
                feedImg.tintColor = darkGrey
                globeImg.tintColor = lightGrey
                followers.textColor = lightGrey
                followersTitle.textColor = lightGrey
                following.textColor = lightGrey
                followingTitle.textColor = lightGrey
            }
        }
    }
    
}
