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
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // arrays to hold server data
    var picArray = [PFFile]()
    var titleArray = [String]()
    var uuidArray = [String]()
    var categoryArray = [String]()
    
    // page size
    var page = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        query.whereKey("username", equalTo: user)
        query.limit = self.page
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.picArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.categoryArray.removeAll(keepingCapacity: false)
                
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
            query.whereKey("username", equalTo: user)
            query.limit = self.page
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.titleArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.categoryArray.removeAll(keepingCapacity: false)
                    
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
        infoQuery.whereKey("username", equalTo: user)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                if objects!.isEmpty {
                    self.alert("Not Found", message: "\(user.capitalized) does not exist")
                }
                for object in objects! {
                    if object.object(forKey: "firstname") != nil {
                        cell.usernameBtn.setTitle((object.object(forKey: "firstname") as? String)?.capitalized, for: UIControlState())
                    } else {
                        cell.usernameBtn.setTitle(user, for: UIControlState())
                    }
                    
                    if object.object(forKey: "ava") != nil {
                        let avaFile : PFFile = (object.object(forKey: "ava") as? PFFile)!
                        avaFile.getDataInBackground(block: { (data, error) -> Void in
                            cell.avaImg.image = UIImage(data: data!)
                        })
                    } else {
                        cell.avaImg.image = UIImage(named: "pp")
                    }
                }
            }
        })
        
        cell.uuidLbl.text = uuidArray[(indexPath as NSIndexPath).row]
        cell.titleLbl.text = titleArray[(indexPath as NSIndexPath).row]
        
        // place post picture
        picArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // set location button
        switch categoryArray[(indexPath as NSIndexPath).row] {
        case "country":
            cell.locationBtn.setTitle("country", for: UIControlState())
            cell.locationBtn.setBackgroundImage(UIImage(named: "country.png"), for: UIControlState())
        case "city":
            cell.locationBtn.setTitle("city", for: UIControlState())
            cell.locationBtn.setBackgroundImage(UIImage(named: "city.png"), for: UIControlState())
        default:
            cell.locationBtn.setTitle("", for: UIControlState())
            cell.locationBtn.setBackgroundImage(UIImage(named: "transparent.png"), for: UIControlState())
        }
        
        // manipulate suitcase button depending on if it is added to user's suitcase
        let didAdd = PFQuery(className: "suitcase")
        didAdd.whereKey("user", equalTo: user)
        didAdd.whereKey("location", equalTo: cell.locationLbl.text!)
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
        didLike.whereKey("by", equalTo: user)
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
        
        // asign index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        
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
    
    @IBAction func usernameBtn_clicked(_ sender: UIButton) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = feedTableView.cellForRow(at: i) as! postCell
        
        // if user tapped on himself go home, else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            user = PFUser.current()!.username!
            let profile = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! profileVC
            self.navigationController?.pushViewController(profile, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            user = cell.usernameBtn.titleLabel!.text!
            let profileUser = self.storyboard?.instantiateViewController(withIdentifier: "profileUserVC") as! profileUserVC
            self.navigationController?.pushViewController(profileUser, animated: true)
        }
    }
    
    @IBAction func commentBtn_clicked(_ sender: UIButton) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = feedTableView.cellForRow(at: i) as! postCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    // go to post
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // alert action
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
