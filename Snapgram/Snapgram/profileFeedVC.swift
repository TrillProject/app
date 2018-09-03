//
//  profileFeedVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/18/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class profileFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var usernameHiddenLbl: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // arrays to hold server data
    var picArray = [PFFile]()
    var titleArray = [String]()
    var uuidArray = [String]()
    var categoryArray = [String]()
    var locationArray = [String]()
    var addressArray = [String]()
    var favoriteArray = [Bool]()
    var tagsArray = [[String]]()
    var ratingArray = [CGFloat]()
    
    // page size
    var page = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameHiddenLbl.text = user
        
        // pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControlEvents.valueChanged)
        feedTableView.addSubview(refresher)
        
        // receive notification from postsCell if picture is liked, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(profileFeedVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        // indicator's x(horizontal) center
        indicator.center.x = feedTableView.center.x
        
        // receive notification from uploadVC
        NotificationCenter.default.addObserver(self, selector: #selector(profileFeedVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        // calling function to load posts
        loadPosts()
        
    }
    
    // refreshing function after like to update degit
    func refresh() {
        feedTableView.reloadData()
    }
    
    // reloading func with posts after received notification
    func uploaded(_ notification:Notification) {
        loadPosts()
    }
    
    // load posts
    func loadPosts() {
        
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: usernameHiddenLbl.text!)
        query.limit = self.page
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.picArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.categoryArray.removeAll(keepingCapacity: false)
                self.locationArray.removeAll(keepingCapacity: false)
                self.addressArray.removeAll(keepingCapacity: false)
                self.favoriteArray.removeAll(keepingCapacity: false)
                self.tagsArray.removeAll(keepingCapacity: false)
                self.ratingArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.picArray.append(object.object(forKey: "pic") as! PFFile)
                    self.titleArray.append(object.object(forKey: "title") as! String)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    
                    if object.object(forKey: "category") != nil {
                        self.categoryArray.append(object.object(forKey: "category") as! String)
                    } else {
                        self.categoryArray.append("")
                    }
                    
                    if object.object(forKey: "location") != nil {
                        self.locationArray.append(object.object(forKey: "location") as! String)
                    } else {
                        self.locationArray.append("")
                    }
                    
                    if object.object(forKey: "address") != nil {
                        self.addressArray.append(object.object(forKey: "address") as! String)
                    } else {
                        self.addressArray.append("")
                    }
                    
                    if object.object(forKey: "favorite") != nil {
                        self.favoriteArray.append(object.object(forKey: "favorite") as! Bool)
                    } else {
                        self.favoriteArray.append(false)
                    }
                    
                    if object.object(forKey: "tags") != nil {
                        self.tagsArray.append(object.object(forKey: "tags") as! [String])
                    } else {
                        self.tagsArray.append([])
                    }
                    
                    if object.object(forKey: "rating") != nil {
                        self.ratingArray.append(object.object(forKey: "rating") as! CGFloat)
                    } else {
                        self.ratingArray.append(0.0)
                    }
                }
                
                // reload tableView & end spinning of refresher
                self.feedTableView.reloadData()
                self.refresher.endRefreshing()
                
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
        if page <= uuidArray.count {
            
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 10
            
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: usernameHiddenLbl.text!)
            query.limit = self.page
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.titleArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.categoryArray.removeAll(keepingCapacity: false)
                    self.locationArray.removeAll(keepingCapacity: false)
                    self.addressArray.removeAll(keepingCapacity: false)
                    self.favoriteArray.removeAll(keepingCapacity: false)
                    self.tagsArray.removeAll(keepingCapacity: false)
                    self.ratingArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.picArray.append(object.object(forKey: "pic") as! PFFile)
                        self.titleArray.append(object.object(forKey: "title") as! String)
                        self.uuidArray.append(object.object(forKey: "uuid") as! String)
                        
                        if object.object(forKey: "category") != nil {
                            self.categoryArray.append(object.object(forKey: "category") as! String)
                        } else {
                            self.categoryArray.append("")
                        }
                        
                        if object.object(forKey: "location") != nil {
                            self.locationArray.append(object.object(forKey: "location") as! String)
                        } else {
                            self.locationArray.append("")
                        }
                        
                        if object.object(forKey: "address") != nil {
                            self.addressArray.append(object.object(forKey: "address") as! String)
                        } else {
                            self.addressArray.append("")
                        }
                        
                        if object.object(forKey: "favorite") != nil {
                            self.favoriteArray.append(object.object(forKey: "favorite") as! Bool)
                        } else {
                            self.favoriteArray.append(false)
                        }
                        
                        if object.object(forKey: "tags") != nil {
                            self.tagsArray.append(object.object(forKey: "tags") as! [String])
                        } else {
                            self.tagsArray.append([])
                        }
                        
                        if object.object(forKey: "rating") != nil {
                            self.ratingArray.append(object.object(forKey: "rating") as! CGFloat)
                        } else {
                            self.ratingArray.append(0.0)
                        }
                    }
                    
                    // reload tableView & end spinning of refresher
                    self.feedTableView.reloadData()
                    self.refresher.endRefreshing()
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    
    @IBOutlet weak var feedTableView: UITableView! {
        didSet {
            feedTableView.dataSource = self
            feedTableView.delegate = self
        }
    }
    
    //cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "Post Cell", for: indexPath) as! postCell
        
        // connect objects with our information
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: usernameHiddenLbl.text!)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                if objects!.isEmpty {
                    self.alert("Not Found", message: "\(self.usernameHiddenLbl.text!.capitalized) does not exist")
                }
                for object in objects! {
                    if object.object(forKey: "firstname") != nil {
                        cell.usernameBtn.setTitle((object.object(forKey: "firstname") as? String)?.capitalized, for: UIControlState())
                    } else {
                        cell.usernameBtn.setTitle(self.usernameHiddenLbl.text!, for: UIControlState())
                    }
                    
                    if object.object(forKey: "ava") != nil {
                        let avaFile : PFFile = (object.object(forKey: "ava") as? PFFile)!
                        avaFile.getDataInBackground(block: { (data, error) -> Void in
                            cell.avaImg.setBackgroundImage(UIImage(data: data!), for: .normal)
                        })
                    } else {
                        cell.avaImg.setBackgroundImage(UIImage(named: "pp"), for: .normal)
                    }
                }
            }
        })
        
        cell.usernameLbl.text = usernameHiddenLbl.text!
        cell.uuidLbl.text = uuidArray[(indexPath as NSIndexPath).row]
        cell.titleLbl.text = titleArray[(indexPath as NSIndexPath).row]
        
        // place post picture
        picArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // set location button
        if favoriteArray[(indexPath as NSIndexPath).row] == true {
            cell.locationBtn.setImage(UIImage(named: "like2"), for: UIControlState())
            cell.locationImgWidth.constant = 22
        } else {
            PostCategory.selectLocationBtnType(categoryArray[(indexPath as NSIndexPath).row], cell.locationBtn, cell.locationImgWidth)
        }
        
        // set location
        cell.locationTitleBtn.setTitle(locationArray[(indexPath as NSIndexPath).row], for: .normal)
        
        // set address
        cell.addressLbl.text = addressArray[(indexPath as NSIndexPath).row]
        
        // set rating
        cell.setRating(ratingArray[(indexPath as NSIndexPath).row])
        
        // manipulate suitcase button depending on if it is added to user's suitcase
        let didAdd = PFQuery(className: "suitcase")
        didAdd.whereKey("user", equalTo: usernameHiddenLbl.text!)
        didAdd.whereKey("location", equalTo: cell.locationTitleBtn.currentTitle!)
        didAdd.whereKey("addess", equalTo: cell.addressLbl.text!)
        didAdd.countObjectsInBackground { (count, error) -> Void in
            if count == 0 {
                cell.suitcaseBtn.setTitle("notAdded", for: UIControlState())
                cell.suitcaseBtn.setBackgroundImage(UIImage(named: "suitcase4.png"), for: UIControlState())
            } else {
                cell.suitcaseBtn.setTitle("added", for: UIControlState())
                cell.suitcaseBtn.setBackgroundImage(UIImage(named: "suitcase3.png"), for: UIControlState())
            }
        }
        
        // manipulate like button depending on did user like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: usernameHiddenLbl.text!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackground { (count, error) -> Void in
            // if no any likes are found, else found likes
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
            } else {
                cell.likeBtn.setTitle("like", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
            }
        }
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackground { (count, error) -> Void in
            if count == 1 {
                cell.likeLbl.text = "\(count) like"
            } else {
                cell.likeLbl.text = "\(count) likes"
            }
        }
        
        // set tags
        cell.setTags(tagsArray[(indexPath as NSIndexPath).row])
        
        // assign index
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.locationTitleBtn.layer.setValue(indexPath, forKey: "index")
        
        // @mention is tapped
        cell.titleLbl.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            // if tapped on @currentUser go home, else go guest
            if mention.lowercased() == PFUser.current()?.username {
                user = PFUser.current()!.username!
                let profile = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! profileVC
                self.navigationController?.pushViewController(profile, animated: true)
            } else {
                guestname.append(mention.lowercased())
                user = mention.lowercased()
                let profileUser = self.storyboard?.instantiateViewController(withIdentifier: "profileUserVC") as! profileUserVC
                self.navigationController?.pushViewController(profileUser, animated: true)
            }
        }
        
        // #hashtag is tapped
        cell.titleLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        
        return cell
    }
    
    @IBAction func commentBtn_clicked(_ sender: UIButton) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = feedTableView.cellForRow(at: i) as! postCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameLbl.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    
    @IBAction func locationTitleBtn_clicked(_ sender: UIButton) {
        
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = feedTableView.cellForRow(at: i) as! postCell
        
        placeTitle = cell.locationTitleBtn.currentTitle!
        placeAddress = cell.addressLbl.text!
        placeCategory = categoryArray[(i as NSIndexPath).row]
        didSelectSelf = (cell.usernameLbl.text! == PFUser.current()!.username! ? true : false)
        
        let place = self.storyboard?.instantiateViewController(withIdentifier: "placeVC") as! placeVC
        self.navigationController?.pushViewController(place, animated: true)
    }
    
    // alert action
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
