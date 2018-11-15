//
//  placeVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/31/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var placeTitle : String?
var placeAddress : String?
var placeCategory : String?
var didSelectSelf : Bool?

class placeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var singleImg: UIImageView!
    
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var locationIconWidth: NSLayoutConstraint!
    
    // arrays to hold data received from servers
    var placeImgArray = [PFFile]()
    var usernameArray = [String]()
    var firstnameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var ratingArray = [CGFloat]()
    var commentArray = [String]()
    var uuidArray = [String]()
    
    var followArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.title = placeTitle!
        
        addressBtn.setTitle(placeAddress!, for: .normal)
        
        PostCategory.selectImgType(placeCategory!, locationIcon, locationIconWidth, mainColor)
        
        loadReviews()
    }
    
    func loadReviews() {
        
        // STEP 1. Find posts realted to people who we are following
        let followQuery = PFQuery(className: "follow")
        if PFUser.current() != nil {
            followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followQuery.whereKey("accepted", equalTo: true)
            followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }
                        
                    // STEP 2. Find posts made by people appended to followArray with location of placeTitle
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.whereKey("location", equalTo: self.navigationItem.title!)
                    query.whereKey("address", equalTo: self.addressBtn.currentTitle!)
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.placeImgArray.removeAll(keepingCapacity: false)
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.firstnameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.ratingArray.removeAll(keepingCapacity: false)
                            self.commentArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                
                                if object.object(forKey: "pic") != nil {
                                    self.placeImgArray.append(object.object(forKey: "pic") as! PFFile)
                                }
                                
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                
                                if object.object(forKey: "firstname") != nil {
                                    self.firstnameArray.append((object.object(forKey: "firstname") as! String).capitalized)
                                } else {
                                    self.firstnameArray.append(object.object(forKey: "username") as! String)
                                }
                                
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.dateArray.append(object.createdAt)
                                
                                if object.object(forKey: "rating") != nil {
                                    self.ratingArray.append(object.object(forKey: "rating") as! CGFloat)
                                } else {
                                    self.ratingArray.append(0.0)
                                }
                                
                                self.commentArray.append(object.object(forKey: "title") as! String)
                                self.uuidArray.append(object.object(forKey: "uuid") as! String)
                            }
                            
                            if self.usernameArray.count == 0 && didSelectSelf! {
                                
                                // clean up
                                self.placeImgArray.removeAll(keepingCapacity: false)
                                self.usernameArray.removeAll(keepingCapacity: false)
                                self.firstnameArray.removeAll(keepingCapacity: false)
                                self.avaArray.removeAll(keepingCapacity: false)
                                self.dateArray.removeAll(keepingCapacity: false)
                                self.ratingArray.removeAll(keepingCapacity: false)
                                self.commentArray.removeAll(keepingCapacity: false)
                                self.uuidArray.removeAll(keepingCapacity: false)
                                
                                let postQuery = PFQuery(className: "posts")
                                postQuery.whereKey("username", equalTo: PFUser.current()!.username!)
                                postQuery.whereKey("location", equalTo: self.navigationItem.title!)
                                postQuery.whereKey("address", equalTo: self.addressBtn.currentTitle!)
                                postQuery.addDescendingOrder("createdAt")
                                postQuery.findObjectsInBackground(block: { (postObjects, error) -> Void in
                                    if error == nil {
                                        
                                        // find related objects
                                        for postObject in postObjects! {
                                            
                                            self.usernameArray.append(PFUser.current()!.username!)
                                            self.firstnameArray.append((PFUser.current()?.object(forKey: "firstname") as! String).capitalized)
                                            self.avaArray.append(PFUser.current()?.object(forKey: "ava") as! PFFile)
                                            
                                            if postObject.object(forKey: "pic") != nil {
                                                self.placeImgArray.append(postObject.object(forKey: "pic") as! PFFile)
                                            }
                                            
                                            self.dateArray.append(postObject.createdAt)
                                            self.commentArray.append(postObject.object(forKey: "title") as! String)
                                            self.uuidArray.append(postObject.object(forKey: "uuid") as! String)
                                            
                                            if postObject.object(forKey: "rating") != nil {
                                                self.ratingArray.append(postObject.object(forKey: "rating") as! CGFloat)
                                            }
                                        }
                                        
                                        self.collectionView.reloadData()
                                        self.tableView.reloadData()
                                        
                                        self.setPicture(self.placeImgArray.count)
                                        self.setAverageRating(self.ratingArray)
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                            } else {
                                self.collectionView.reloadData()
                                self.tableView.reloadData()
                                
                                self.setPicture(self.placeImgArray.count)
                                self.setAverageRating(self.ratingArray)
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
    
    func setPicture(_ count : Int) {
        if count == 0 {
            collectionView.isHidden = true
            collectionViewHeight.constant = 0
            tableViewTopSpace.constant = 0
            singleImg.isHidden = true
        } else if count == 1 {
            collectionViewHeight.constant = 180
            tableViewTopSpace.constant = 20
            collectionView.isHidden = true
            singleImg.isHidden = false
            placeImgArray[0].getDataInBackground { (data, error) -> Void in
                self.singleImg.image = UIImage(data: data!)
            }
        } else {
            collectionViewHeight.constant = 180
            tableViewTopSpace.constant = 20
            collectionView.isHidden = false
            singleImg.isHidden = true
        }
    }
    
    func setAverageRating(_ ratings : [CGFloat]) {
        var total = CGFloat(0)
        for rating in ratings {
            total += rating
        }
        let rating = (ratings.count == 0 ? total : (total / CGFloat(ratings.count)))
        reviewOverlayLeadingSpace.constant = rating * reviewBackground.frame.size.width
        print("PLACEVC \(reviewBackground.frame.size.width)")
        Review.colorReview(rating, reviewBackground)
    }
    
    
    // collection view cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if placeImgArray.count <= 1 {
            return 0
        } else {
            return placeImgArray.count
        }
    }
    
    // collection view cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Place Img Cell", for: indexPath) as! placeImgCell
        
        // connect data from server to objects
        placeImgArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.placeImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    // table view cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // table view cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Place Review Cell", for: indexPath) as! placeReviewCell
        
        // connect data from server to objects
        cell.uuidLbl.text = uuidArray[(indexPath as NSIndexPath).row]
        cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]
        cell.usernameBtn.setTitle(firstnameArray[(indexPath as NSIndexPath).row], for: .normal)
        avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.setBackgroundImage(UIImage(data: data!), for: .normal)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // set date
        cell.dateLbl.text = dateArray[(indexPath as NSIndexPath).row]?.asString(style: .long)
        
        // set rating
        cell.setRating(ratingArray[(indexPath as NSIndexPath).row])
        
        // set comment
        cell.commentLbl.text = commentArray[(indexPath as NSIndexPath).row]
        
        if commentArray[(indexPath as NSIndexPath).row] == "" {
            cell.commentLblTopSpace.constant = 0
        } else {
            cell.commentLblTopSpace.constant = 15
        }

        cell.avaImg.layer.setValue(indexPath, forKey: "index")
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
        
    }
    
    // table cell selected - go to post
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        postuuid.append(uuidArray[(indexPath as NSIndexPath).row])
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
        
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // clicked on user - go to profile
    @IBAction func user_clicked(_ sender: UIButton) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! placeReviewCell
        
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
