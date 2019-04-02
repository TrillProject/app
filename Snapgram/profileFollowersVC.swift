//
//  profileFollowersVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/18/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class profileFollowersVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var usernameHiddenLbl: UILabel!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // arrays to hold data received from servers
    var usernameArray = [String]()
    var firstnameArray = [String]()
    var avaArray = [PFFile]()
    
    // array showing who we follow or who follows us
    var followArray = [String]()
    
    var page = 18
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameHiddenLbl.text = user
        
        loadFollowers()
    }
    
    // loading followers
    func loadFollowers() {
        
        // STEP 1. Find in FOLLOW class people following User
        // find followers of user
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("following", equalTo: usernameHiddenLbl.text!)
        followQuery.whereKey("accepted", equalTo: true)
        followQuery.limit = self.page
        followQuery.addDescendingOrder("createdAt")
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.followArray.removeAll(keepingCapacity: false)
                
                // STEP 2. Hold received data
                // find related objects depending on query settings
                for object in objects! {
                    self.followArray.append(object.value(forKey: "follower") as! String)
                }
                
                // STEP 3. Find in USER class data of users following "User"
                // find users following user
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.firstnameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        
                        // find related objects in User class of Parse
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            if object.object(forKey: "firstname") != nil {
                                self.firstnameArray.append((object.object(forKey: "firstname") as! String).capitalized)
                            } else {
                                self.firstnameArray.append((object.object(forKey: "username") as! String).capitalized)
                            }
                            if object.object(forKey: "ava") == nil {
                                let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                                let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                                self.avaArray.append(avaFile!)
                            } else {
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            }
                            self.followersCollectionView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    
    // scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    
    // pagination
    func loadMore() {
        
        // if posts on the server are more than shown
        if page <= usernameArray.count {
            
            // increase page size to load +30 people
            page = page + 18
            
            // STEP 1. Find in FOLLOW class people following User
            // find followers of user
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("following", equalTo: usernameHiddenLbl.text!)
            followQuery.whereKey("accepted", equalTo: true)
            followQuery.limit = self.page
            followQuery.addDescendingOrder("createdAt")
            followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    // STEP 2. Hold received data
                    // find related objects depending on query settings
                    for object in objects! {
                        self.followArray.append(object.value(forKey: "follower") as! String)
                    }
                    
                    // STEP 3. Find in USER class data of users following "User"
                    // find users following user
                    let query = PFUser.query()
                    query?.whereKey("username", containedIn: self.followArray)
                    query?.addDescendingOrder("createdAt")
                    query?.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.firstnameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            // find related objects in User class of Parse
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                if object.object(forKey: "firstname") != nil {
                                    self.firstnameArray.append((object.object(forKey: "firstname") as! String).capitalized)
                                } else {
                                    self.firstnameArray.append((object.object(forKey: "username") as! String).capitalized)
                                }
                                if object.object(forKey: "ava") == nil {
                                    let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                                    let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                                    self.avaArray.append(avaFile!)
                                } else {
                                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                }
                                self.followersCollectionView.reloadData()
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }


    @IBOutlet weak var followersCollectionView: UICollectionView! {
        didSet {
            followersCollectionView.dataSource = self
            followersCollectionView.delegate = self
        }
    }
    
    
    // cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return firstnameArray.count
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //check orientation for cell size
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            // portrait
            return CGSize(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) + 20)
            
        } else {
            // landscape
            return CGSize(width: UIScreen.main.bounds.height / 3, height: (UIScreen.main.bounds.height / 3) + 20)
        }
    }
    
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Follower Cell", for: indexPath) as! followerCell
        
        // connect data from server to objects
        cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]
        cell.nameLbl.text = firstnameArray[(indexPath as NSIndexPath).row]
        avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.setBackgroundImage(UIImage(data: data!), for: .normal)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        cell.avaImg.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    @IBAction func avaImg_clicked(_ sender: UIButton) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = followersCollectionView.cellForItem(at: i) as! followerCell
        
        // if user tapped on himself go home, else go guest
        if cell.usernameLbl.text == PFUser.current()?.username {
            user = PFUser.current()!.username!
            let profile = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! profileVC
            self.navigationController?.pushViewController(profile, animated: true)
        } else {
            guestname.append(cell.usernameLbl.text!)
            user = cell.usernameLbl.text!
            let profileUser = self.storyboard?.instantiateViewController(withIdentifier: "profileUserVC") as! profileUserVC
            self.navigationController?.pushViewController(profileUser, animated: true)
        }
    }
    
}