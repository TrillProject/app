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
    
    @IBOutlet weak var usernameHiddenLbl: UILabel!
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
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
    
    @IBOutlet weak var feedView: UIView!
    @IBOutlet weak var globeView: UIView!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    @IBOutlet weak var privateView: UIView!
    @IBOutlet weak var lockImg: UIImageView!
    @IBOutlet weak var privateLbl: UILabel!
    
    private var isPrivate = false
    private var isFollowing = false
    private var pendingRequest = false
    private var firstname = String()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = ""
        usernameHiddenLbl.text = guestname.last!
        
        // receive notification from notificationVC
        NotificationCenter.default.addObserver(self, selector: #selector(profileUserVC.followingChanged(_:)), name: NSNotification.Name(rawValue: "followingChanged"), object: nil)
        
        // icon colors
        feedImg.image = feedImg.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        feedImg.tintColor = .black
        
        globeImg.image = globeImg.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        globeImg.tintColor = lightGrey
        
        let followImg = followBtn.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
        followBtn.setBackgroundImage(followImg, for: .normal)
        followBtn.tintColor = lightGrey
        
        // STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo:  usernameHiddenLbl.text!)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    // call alert
                    let alert = UIAlertController(title: "Not Found", message: "\(self.usernameHiddenLbl.text!.capitalized) does not exist", preferredStyle: UIAlertControllerStyle.alert)
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
                        self.navigationItem.title = self.usernameHiddenLbl.text!
                        self.firstname = self.usernameHiddenLbl.text!
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
                        self.isPrivate = false
                    }
                    
                    // check if following
                    self.checkIfFollowing()
                }
            } else {
                print(error!.localizedDescription)
            }
        })
        
        // STEP 2. Count statistics
        // count followers
        let userFollowers = PFQuery(className: "follow")
        userFollowers.whereKey("following", equalTo: usernameHiddenLbl.text!)
        userFollowers.whereKey("accepted", equalTo: true)
        userFollowers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                self.followers.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        })
        
        // count followings
        let userFollowings = PFQuery(className: "follow")
        userFollowings.whereKey("follower", equalTo: usernameHiddenLbl.text!)
        userFollowings.whereKey("accepted", equalTo: true)
        userFollowings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                self.following.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func checkIfFollowing() {
        let followingQuery = PFQuery(className: "follow")
        followingQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followingQuery.whereKey("following", equalTo: usernameHiddenLbl.text!)
        followingQuery.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count == 0 {
                    self.followBtn.tintColor = lightGrey
                    self.pendingRequest = false
                    self.displayViewForPrivate(private: self.isPrivate, following: self.isFollowing, name: self.firstname, pending: self.pendingRequest)
                } else {
                    followingQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            for object in objects! {
                                if object.object(forKey: "accepted") as! Bool == true {
                                    self.followBtn.tintColor = mainColor
                                    self.isFollowing = true
                                    self.pendingRequest = false
                                } else {
                                    //self.followBtn.tintColor = mainFadedColor
                                    self.followBtn.tintColor = darkGrey
                                    self.isFollowing = false
                                    self.pendingRequest = true
                                }
                                self.displayViewForPrivate(private: self.isPrivate, following: self.isFollowing, name: self.firstname, pending: self.pendingRequest)
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // clicked follow button
    @IBAction func clicked_followBtn(_ sender: UIButton) {
        
        // to follow
        if self.followBtn.tintColor == lightGrey {
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = usernameHiddenLbl.text!
            if !self.isPrivate {
                // to follow if profile is not private
                object["accepted"] = true
            } else {
                // to request to follow if profile is private
                object["accepted"] = false
            }
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    if !self.isPrivate {
                        self.followBtn.tintColor = mainColor
                        
                        // send notification to update feed
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                        
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
                        newsObj["to"] = self.usernameHiddenLbl.text!
                        newsObj["owner"] = ""
                        newsObj["uuid"] = ""
                        newsObj["type"] = "follow"
                        newsObj["checked"] = "no"
                        newsObj["firstname"] = PFUser.current()?.object(forKey: "firstname") as! String
                        newsObj["lastname"] = PFUser.current()?.object(forKey: "lastname") as! String
                        newsObj["private"] = PFUser.current()?.object(forKey: "private") as! Bool
                        newsObj.saveEventually()
                        
                        // send notification to refresh notificationsVC
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "followingUserChanged"), object: nil)
                        
                    } else {
                        //self.followBtn.tintColor = mainFadedColor
                        self.followBtn.tintColor = darkGrey
                        self.privateLbl.text = "Follow request sent."
                        
                        // send request notification
                        let requestObj = PFObject(className: "request")
                        requestObj["by"] = PFUser.current()?.username
                        if PFUser.current()?.object(forKey: "ava") != nil {
                            requestObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        } else {
                            let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                            let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                            requestObj["ava"] = avaFile!
                        }
                        requestObj["to"] = self.usernameHiddenLbl.text!
                        requestObj["checked"] = "no"
                        requestObj["firstname"] = PFUser.current()?.object(forKey: "firstname") as! String
                        requestObj["lastname"] = PFUser.current()?.object(forKey: "lastname") as! String
                        
                        requestObj.saveEventually()
                        
                        // send notification to refresh notificationsVC
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "followingUserChanged"), object: nil)
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        // unfollow
        } else if self.followBtn.tintColor == mainColor {
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: usernameHiddenLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                self.followBtn.tintColor = lightGrey
                                
                                // delete follow notifications
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: self.usernameHiddenLbl.text!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                                let followAcceptedQuery = PFQuery(className: "news")
                                followAcceptedQuery.whereKey("by", equalTo: self.usernameHiddenLbl.text!)
                                followAcceptedQuery.whereKey("to", equalTo: PFUser.current()!.username!)
                                followAcceptedQuery.whereKey("type", equalTo: "follow accepted")
                                followAcceptedQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                                // send notification to refresh notificationsVC
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "followingUserChanged"), object: nil)
                                
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                    // send notification to update feed
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        // delete follow request notification
        } else if self.followBtn.tintColor == darkGrey {
            
            // delete follow request
            let requestQuery = PFQuery(className: "request")
            requestQuery.whereKey("by", equalTo: PFUser.current()!.username!)
            requestQuery.whereKey("to", equalTo: usernameHiddenLbl.text!)
            requestQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    self.followBtn.tintColor = lightGrey
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // delete follow relationship
            let followerQuery = PFQuery(className: "follow")
            followerQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followerQuery.whereKey("following", equalTo: usernameHiddenLbl.text!)
            followerQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // send notification to refresh notificationsVC
            NotificationCenter.default.post(name: Notification.Name(rawValue: "followingUserChanged"), object: nil)
            
            // update view
            privateLbl.text = "\(firstname)'s profile is private.\nSend a request to follow."
        }
    }
    
    // display view for private profile
    func displayViewForPrivate(private isPrivate : Bool, following isFollowing : Bool, name firstname : String, pending pendingRequest : Bool) {
        if isPrivate && !isFollowing && !pendingRequest {
            privateLbl.text = "\(firstname)'s profile is private.\nSend a request to follow."
            privateView.isHidden = false
            feedView.isHidden = true
            globeView.isHidden = true
            followersView.isHidden = true
            followingView.isHidden = true
            feedImg.tintColor = .black
            globeImg.tintColor = lightGrey
            followers.textColor = lightGrey
            followersTitle.textColor = lightGrey
            following.textColor = lightGrey
            followingTitle.textColor = lightGrey
        } else if isPrivate && !isFollowing && pendingRequest {
            privateLbl.text = "Follow request sent."
            privateView.isHidden = false
            feedView.isHidden = true
            globeView.isHidden = true
            followersView.isHidden = true
            followingView.isHidden = true
            feedImg.tintColor = .black
            globeImg.tintColor = lightGrey
            followers.textColor = lightGrey
            followersTitle.textColor = lightGrey
            following.textColor = lightGrey
            followingTitle.textColor = lightGrey
        } else if isFollowing || !isPrivate {
            privateView.isHidden = true
            feedView.isHidden = false
            globeView.isHidden = true
            followersView.isHidden = true
            followingView.isHidden = true
            feedImg.tintColor = .black
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
                feedImg.tintColor = .black
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
                globeImg.tintColor = .black
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
                followers.textColor = .black
                followersTitle.textColor = .black
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
                following.textColor = .black
                followingTitle.textColor = .black
            default:
                // feed
                feedView.isHidden = false
                globeView.isHidden = true
                followersView.isHidden = true
                followingView.isHidden = true
                feedImg.tintColor = .black
                globeImg.tintColor = lightGrey
                followers.textColor = lightGrey
                followersTitle.textColor = lightGrey
                following.textColor = lightGrey
                followingTitle.textColor = lightGrey
            }
        }
    }
    
    // change following button color after received notification
    func followingChanged(_ notification:Notification) {
        checkIfFollowing()
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
