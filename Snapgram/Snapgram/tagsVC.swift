//
//  tagsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/5/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var currentTag : String?

class tagsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
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
    
    // arrays for server data
    var followArray = [String]()
    
    // collection view data
    var uuidArray = [String]()
    var usernameArray = [String]()
    var picArray = [PFFile]()
    var ratingArray = [CGFloat]()
    var categoryArray = [String]()
    var locationArray = [String]()
    var addressArray = [String]()
    
    // table view data
    var tagsArray = [String]()
    var countArray = [Int]()
    
    var page = 12
    var tagsPage = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = currentTag!
        
        tableView.isHidden = true
        collectionView.isHidden = false
        
        searchBar.delegate = self
        
        loadCells()
    }
    
    
    // COLLECTION VIEW
    
    // load collection view cells
    func loadCells() {
        
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
                    
                    // append current user to see own posts
                    self.followArray.append(PFUser.current()!.username!)
                    
                    // STEP 2. Find tags made by people appended to followArray with the correct tag name
                    let tagQuery = PFQuery(className: "postTags")
                    tagQuery.whereKey("by", containedIn: self.followArray)
                    tagQuery.whereKey("tag", equalTo: self.navigationItem.title!)
                    tagQuery.limit = self.page
                    tagQuery.addDescendingOrder("createdAt")
                    tagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                self.uuidArray.append(object.object(forKey: "to") as! String)
                            }
                            
                            // STEP 3. Get the post for each tag object
                            let postQuery = PFQuery(className: "posts")
                            postQuery.whereKey("uuid", containedIn: self.uuidArray)
                            postQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                if error == nil {
                                    
                                    // clean up
                                    self.usernameArray.removeAll(keepingCapacity: false)
                                    self.picArray.removeAll(keepingCapacity: false)
                                    self.ratingArray.removeAll(keepingCapacity: false)
                                    self.categoryArray.removeAll(keepingCapacity: false)
                                    self.locationArray.removeAll(keepingCapacity: false)
                                    self.addressArray.removeAll(keepingCapacity: false)
                                    
                                    for object in objects! {
                                        self.usernameArray.append(object.object(forKey: "username") as! String)
                                        self.picArray.append(object.object(forKey: "pic") as! PFFile)
                                        self.ratingArray.append(object.object(forKey: "rating") as! CGFloat)
                                        
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
                                    }
                                    
                                    // reload collectionView
                                    self.collectionView.reloadData()
                                    
                                } else {
                                    print(error!.localizedDescription)
                                }
                            })
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        
        // scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            
            if scrollView == collectionView {
                self.loadMore()
            } else {
                self.loadMoreTags()
            }
        }
    }
    
    // pagination
    func loadMore() {
        
        // if posts on the server are more than shown
        if page <= uuidArray.count {
            
            // increase page size to load +12 posts
            page = page + 12
            
            loadCells()
        }
    }
    
    // cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uuidArray.count
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //check orientation for cell size
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            // portrait
            return CGSize(width: UIScreen.main.bounds.width / 2, height: (UIScreen.main.bounds.width / 2) + 60)

        } else {
            // landscape
            return CGSize(width: UIScreen.main.bounds.height / 2, height: (UIScreen.main.bounds.height / 2) + 60)
        }
    }
    
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tags Collection Cell", for: indexPath) as! tagsCollectionCell
        
        // connect data from server to objects
        cell.uuidLbl.text = uuidArray[(indexPath as NSIndexPath).row]
        cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]
        
        // set picture
        picArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // set rating
        cell.reviewOverlayLeadingSpace.constant = ratingArray[(indexPath as NSIndexPath).row] * cell.reviewBackground.frame.size.width
        Review.colorReview(ratingArray[(indexPath as NSIndexPath).row], cell.reviewBackground)
        
        // set category
        PostCategory.selectImgType(categoryArray[(indexPath as NSIndexPath).row], cell.categoryImg, cell.categoryImgWidth, mediumGrey)
        
        // set location
        cell.locationBtn.setTitle(locationArray[(indexPath as NSIndexPath).row], for: .normal)
        
        // set address
        cell.addressLbl.text = addressArray[(indexPath as NSIndexPath).row]
        
        // assign index
        cell.locationBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    // selected cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // go to post
        postuuid.append(uuidArray[(indexPath as NSIndexPath).row])
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    // selected location
    @IBAction func locationBtn_clicked(_ sender: UIButton) {
        
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = collectionView.cellForItem(at: i) as! tagsCollectionCell
        
        placeTitle = cell.locationBtn.currentTitle!
        placeAddress = cell.addressLbl.text!
        placeCategory = categoryArray[(i as NSIndexPath).row]
        didSelectSelf = (cell.usernameLbl.text! == PFUser.current()!.username! ? true : false)
        
        let place = self.storyboard?.instantiateViewController(withIdentifier: "placeVC") as! placeVC
        self.navigationController?.pushViewController(place, animated: true)
    }
    
    
    // TABLE VIEW
    
    // load tags
    func loadTags() {
        
        // STEP 1. Get people current user is following
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
                    
                    // append current user to see own tags
                    self.followArray.append(PFUser.current()!.username!)
                    
                    // STEP 2. Find tags made by people appended to followArray
                    let tagQuery = PFQuery(className: "postTags")
                    tagQuery.whereKey("by", containedIn: self.followArray)
                    if self.searchBar.text! != "" {
                        tagQuery.whereKey("tag", hasPrefix: self.searchBar.text!.lowercased())
                    }
//                    tagQuery.limit = self.tagsPage
                    tagQuery.addDescendingOrder("createdAt")
                    tagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.tagsArray.removeAll(keepingCapacity: false)
                            self.countArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                
                                if !self.tagsArray.contains(object.object(forKey: "tag") as! String) {
                                    self.tagsArray.append(object.object(forKey: "tag") as! String)
                                    self.countArray.append(1)
                                } else {
                                    let index = self.tagsArray.index(of: object.object(forKey: "tag") as! String)!
                                    self.countArray[index] = self.countArray[index] + 1
                                }
                            }
                            
                            // reload table view
                            self.tableView.reloadData()
                            
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
    
    // pagination
    func loadMoreTags() {
        
        // if posts on the server are more than shown
        if tagsPage <= tagsArray.count {
            
            // increase page size to load +12 posts
            tagsPage = tagsPage + 20
            
            loadTags()
        }
    }
    
    // table view cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsArray.count
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tags Table Cell", for: indexPath) as! tagsTableCell
        
        cell.tagLbl.text = tagsArray[(indexPath as NSIndexPath).row]
        if countArray[(indexPath as NSIndexPath).row] == 1 {
            cell.countLbl.text = "\(countArray[(indexPath as NSIndexPath).row]) post"
        } else {
            cell.countLbl.text = "\(countArray[(indexPath as NSIndexPath).row]) posts"
        }
        
        return cell
    }
    
    // selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.navigationItem.title = tagsArray[(indexPath as NSIndexPath).row].lowercased()
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        loadCells()
        
        tableView.isHidden = true
        collectionView.isHidden = false
    }
    
    
    // SEARCH BAR
    
    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        loadTags()
        
        return true
    }
    
    // tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // show cancel button
        searchBar.showsCancelButton = true
        
        collectionView.isHidden = true
        tableView.isHidden = false
        
        loadTags()
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        tableView.isHidden = true
        collectionView.isHidden = false
    }
    
    
    // back button clicked
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
