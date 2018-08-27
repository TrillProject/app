//
//  profileVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/17/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var user = String()
var showDetails = String()

class profileVC: UIViewController {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var coverImg: UIImageView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var editBtn: UIButton!
    
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
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = (PFUser.current()?.object(forKey: "firstname") as? String)?.capitalized
        
        // receive notification from editProfileVC
        NotificationCenter.default.addObserver(self, selector: #selector(profileVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        //alignment
        let width = UIScreen.main.bounds.width
        let spacingVertical = CGFloat(20)
        let avaSize = CGFloat(100)
        let iconsY = avaSize + (spacingVertical * 2.75)
        let iconSize = CGFloat(26)
        let iconSpacing = (width - CGFloat(40 + iconSize * 5)) / 4
        
        avaImg.frame = CGRect(x: (width / 2) - (avaSize / 2), y: spacingVertical, width: avaSize, height: avaSize)
        coverImg.frame = CGRect(x: 0, y: 0, width: width, height: avaImg.frame.size.height + (spacingVertical * 2))
        
        feedImg.frame = CGRect(x: 20, y: iconsY, width: iconSize, height: iconSize)
        globeImg.frame = CGRect(x: feedImg.frame.origin.x + iconSpacing + iconSize, y: iconsY, width: iconSize, height: iconSize)
        followers.frame = CGRect(x: globeImg.frame.origin.x + iconSpacing + iconSize, y: iconsY - 8, width: iconSize, height: iconSize)
        following.frame = CGRect(x: followers.frame.origin.x + iconSpacing + iconSize, y: iconsY - 8, width: iconSize, height: iconSize)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 17)
        followingTitle.center = CGPoint(x: following.center.x, y: following.center.y + 17)
        editBtn.frame = CGRect(x: width - (iconSize + 20), y: iconsY, width: iconSize, height: iconSize)
        
        navBorder.frame = CGRect(x: 0, y: avaSize + iconSize + spacingVertical * 3.5, width: width, height: 1)
        navBorder.backgroundColor = borderColor
        
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
        
        let editImage = UIImage(named: "edit")
        let tintedEditImage = editImage?.withRenderingMode(.alwaysTemplate)
        editBtn.setBackgroundImage(tintedEditImage, for: .normal)
        editBtn.tintColor = lightGrey
        
        if PFUser.current() != nil {
        
            // STEP 1. Get user data
            if PFUser.current()?.object(forKey: "ava") == nil {
                self.avaImg.image = UIImage(named: "pp")
            } else {
                let avaQuery = PFUser.current()?.object(forKey: "ava") as! PFFile
                avaQuery.getDataInBackground { (data, error) -> Void in
                    self.avaImg.image = UIImage(data: data!)
                }
            }
            
            if PFUser.current()?.object(forKey: "cover") == nil {
                self.coverImg.image = UIImage(named: "transparent")
            } else {
                let coverFile = PFUser.current()?.object(forKey: "cover") as! PFFile
                coverFile.getDataInBackground(block: { (data, error) -> Void in
                    self.coverImg.image = UIImage(data: data!)
                })
            }
            
            // STEP 2. Count statistics
            // count total followers
            let userFollowers = PFQuery(className: "follow")
            userFollowers.whereKey("following", equalTo: PFUser.current()!.username!)
            userFollowers.whereKey("accepted", equalTo: true)
            userFollowers.countObjectsInBackground (block: { (count, error) -> Void in
                if error == nil {
                    self.followers.text = "\(count)"
                }
            })
            
            // count total followings
            let userFollowings = PFQuery(className: "follow")
            userFollowings.whereKey("follower", equalTo: PFUser.current()!.username!)
            userFollowings.whereKey("accepted", equalTo: true)
            userFollowings.countObjectsInBackground (block: { (count, error) -> Void in
                if error == nil {
                    self.following.text = "\(count)"
                }
            })
        } else {
            print("no current user")
        }
    }
    
    // reloading func after received notification
    func reload(_ notification:Notification) {
        self.navigationItem.title = (PFUser.current()?.object(forKey: "firstname") as? String)?.capitalized
        if PFUser.current()?.object(forKey: "ava") == nil {
            self.avaImg.image = UIImage(named: "pp")
        } else {
            let avaQuery = PFUser.current()?.object(forKey: "ava") as! PFFile
            avaQuery.getDataInBackground { (data, error) -> Void in
                self.avaImg.image = UIImage(data: data!)
            }
        }
        
        if PFUser.current()?.object(forKey: "cover") == nil {
            self.coverImg.image = UIImage(named: "transparent")
        } else {
            let coverFile = PFUser.current()?.object(forKey: "cover") as! PFFile
            coverFile.getDataInBackground(block: { (data, error) -> Void in
                self.coverImg.image = UIImage(data: data!)
            })
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
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
