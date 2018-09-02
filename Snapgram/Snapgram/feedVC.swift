//
//  feedVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//
import UIKit
import Parse


class feedVC: UITableViewController {

    // UI objects
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var titleArray = [String]()
    var uuidArray = [String]()
    var categoryArray = [String]()
    var locationArray = [String]()
    var addressArray = [String]()
    var favoriteArray = [Bool]()
    var tagsArray = [[String]]()
    var ratingArray = [CGFloat]()
    
    var followArray = [String]()
    
    // page size
    var page = 10
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "TRILL"
        
        // pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        // receive notification from postsCell if picture is liked, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        // indicator's x(horizontal) center
        indicator.center.x = tableView.center.x
        
        // receive notification from postTagsVC
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        // calling function to load posts
        loadPosts()
    }
    
    
    // refreshing function after like
    func refresh() {
        tableView.reloadData()
    }
    
    
    // reloading func with posts after received notification
    func uploaded(_ notification:Notification) {
        loadPosts()
    }
    
    
    // load posts
    func loadPosts() {
        
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
                
                    // append current user to see own posts in feed
                    self.followArray.append(PFUser.current()!.username!)
                
                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                        
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
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
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.dateArray.append(object.createdAt)
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
                            self.tableView.reloadData()
                            self.refresher.endRefreshing()
                        
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
    
    
    // scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            
            // STEP 1. Find posts realted to people who we are following
            let followQuery = PFQuery(className: "follow")
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
                    
                    // append current user to see own posts in feed
                    self.followArray.append(PFUser.current()!.username!)
                    
                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
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
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.dateArray.append(object.createdAt)
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
                            
                            // reload tableView & stop animating indicator
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
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


    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuidArray.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        
        // connect objects with our information from arrays
        let infoQuery = PFQuery(className: "_User")
        let username = usernameArray[(indexPath as NSIndexPath).row]
        infoQuery.whereKey("username", equalTo: username)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                if objects!.isEmpty {
                    self.alert("Not Found", message: "\(username.capitalized) does not exist")
                }
                for object in objects! {
                    if object.object(forKey: "firstname") != nil {
                        cell.usernameBtn.setTitle((object.object(forKey: "firstname") as? String)?.capitalized, for: UIControlState())
                    } else {
                        cell.usernameBtn.setTitle(username, for: UIControlState())
                    }
                }
            }
        })
        
        cell.usernameLbl.text = username
        cell.uuidLbl.text = uuidArray[(indexPath as NSIndexPath).row]
        cell.titleLbl.text = titleArray[(indexPath as NSIndexPath).row]

        // place profile picture
        avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            cell.avaImg.setBackgroundImage(UIImage(data: data!), for: .normal) 
        }
        
        // place post picture
        picArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // set location button
        if favoriteArray[(indexPath as NSIndexPath).row] == true {
            cell.locationImgWidth.constant = 22
            cell.locationBtn.setImage(UIImage(named: "like2"), for: .normal)
        } else {
            cell.selectLocationType(categoryArray[(indexPath as NSIndexPath).row])
        }
        
        // set location
        cell.locationTitleBtn.setTitle(locationArray[(indexPath as NSIndexPath).row], for: .normal)
        
        // set address
        cell.addressLbl.text = addressArray[(indexPath as NSIndexPath).row]
        
        // set rating
        cell.setRating(ratingArray[(indexPath as NSIndexPath).row])
        
        // manipulate suitcase button depending on if it is added to user's suitcase
        let didAdd = PFQuery(className: "suitcase")
        didAdd.whereKey("user", equalTo: PFUser.current()!.username!)
        didAdd.whereKey("location", equalTo: cell.locationTitleBtn.currentTitle!)
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
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
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
        cell.avaImg.layer.setValue(indexPath, forKey: "index")
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
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
    
    
    // clicked username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
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
    
    
    // clicked comment button
    @IBAction func commentBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameLbl.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    
    // clicked more button
//    @IBAction func moreBtn_click(_ sender: AnyObject) {
//        
//        // call index of button
//        let i = sender.layer.value(forKey: "index") as! IndexPath
//        
//        // call cell to call further cell date
//        let cell = tableView.cellForRow(at: i) as! postCell
//        
//        
//        // DELET ACTION
//        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) -> Void in
//            
//            // STEP 1. Delete row from tableView
//            self.usernameArray.remove(at: (i as NSIndexPath).row)
//            self.avaArray.remove(at: (i as NSIndexPath).row)
//            self.dateArray.remove(at: (i as NSIndexPath).row)
//            self.picArray.remove(at: (i as NSIndexPath).row)
//            self.titleArray.remove(at: (i as NSIndexPath).row)
//            self.uuidArray.remove(at: (i as NSIndexPath).row)
//            self.categoryArray.remove(at: (i as NSIndexPath).row)
//            
//            // STEP 2. Delete post from server
//            let postQuery = PFQuery(className: "posts")
//            postQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
//            postQuery.findObjectsInBackground(block: { (objects, error) -> Void in
//                if error == nil {
//                    for object in objects! {
//                        object.deleteInBackground(block: { (success, error) -> Void in
//                            if success {
//                                
//                                // send notification to rootViewController to update shown posts
//                                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
//                                
//                                // push back
//                                self.navigationController?.popViewController(animated: true)
//                            } else {
//                                print(error!.localizedDescription)
//                            }
//                        })
//                    }
//                } else {
//                    print(error!.localizedDescription)
//                }
//            })
//            
//            // STEP 2. Delete likes of post from server
//            let likeQuery = PFQuery(className: "likes")
//            likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
//            likeQuery.findObjectsInBackground(block: { (objects, error) -> Void in
//                if error == nil {
//                    for object in objects! {
//                        object.deleteEventually()
//                    }
//                }
//            })
//            
//            // STEP 3. Delete comments of post from server
//            let commentQuery = PFQuery(className: "comments")
//            commentQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
//            commentQuery.findObjectsInBackground(block: { (objects, error) -> Void in
//                if error == nil {
//                    for object in objects! {
//                        object.deleteEventually()
//                    }
//                }
//            })
//            
//            // STEP 4. Delete hashtags of post from server
//            let hashtagQuery = PFQuery(className: "hashtags")
//            hashtagQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
//            hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
//                if error == nil {
//                    for object in objects! {
//                        object.deleteEventually()
//                    }
//                }
//            })
//        }
//        
//        
//        // COMPLAIN ACTION
//        let complain = UIAlertAction(title: "Complain", style: .default) { (UIAlertAction) -> Void in
//            
//            // send complain to server
//            let complainObj = PFObject(className: "complain")
//            complainObj["by"] = PFUser.current()?.username
//            complainObj["to"] = cell.uuidLbl.text
//            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
//            complainObj.saveInBackground(block: { (success, error) -> Void in
//                if success {
//                    self.alert("Complain has been made successfully", message: "Thank You! We will consider your complain")
//                } else {
//                    self.alert("ERROR", message: error!.localizedDescription)
//                }
//            })
//        }
//        
//        // CANCEL ACTION
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        
//        // create menu controller
//        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
//        
//        
//        // if post belongs to user, he can delete post, else he can't
//        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
//            menu.addAction(delete)
//            menu.addAction(cancel)
//        } else {
//            menu.addAction(complain)
//            menu.addAction(cancel)
//        }
//        
//        // show menu
//        self.present(menu, animated: true, completion: nil)
//    }
    
    @IBAction func locationTitleBtn_clicked(_ sender: UIButton) {
        
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: i) as! postCell
        
        placeTitle = cell.locationTitleBtn.currentTitle!
        placeAddress = cell.addressLbl.text!
        placeCategory = categoryArray[(i as NSIndexPath).row]
        placeUser = cell.usernameLbl.text!
        
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
    
    @IBAction func clicked_search(_ sender: UIBarButtonItem) {
        let users = self.storyboard?.instantiateViewController(withIdentifier: "usersVC") as! usersVC
        self.navigationController?.pushViewController(users, animated: true)
    }
}
