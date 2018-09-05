//
//  suitcaseVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/2/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var selectedCategories = [String]()

class suitcaseVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var categoryBtns: [UIButton]!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // arrays to hold server data
    var locationArray = [String]()
    var addressArray = [String]()
    var dateArray = [Date?]()
    var categoryArray = [String]()
    var ratingArray = [CGFloat]()
    
    var followArray = [String]()
    var postLocationArray = [String]()
    var postAddressArray = [String]()
    var postCategoryArray = [String]()
    var postRatingArray = [CGFloat]()
    
    // page size
    var page = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Suitcase"
        
        searchBar.delegate = self
        
        // pull to refresh
        refresher.addTarget(self, action: #selector(suitcaseVC.load), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        // indicator's x(horizontal) center
        indicator.center.x = tableView.center.x
        
        // receive notification from postsCell if post is added to suitcase, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(suitcaseVC.refresh), name: NSNotification.Name(rawValue: "suitcase"), object: nil)
        
        // tint category icons
        selectedCategories.removeAll()
        for categoryBtn in categoryBtns {
            selectedCategories.append(categoryBtn.restorationIdentifier!)
            tintIcons(categoryBtn)
        }

        loadPlaces(filterBy: selectedCategories, withLocation: "")
    }
    
    // refreshing after recieved notification
    func refresh() {
        tableView.reloadData()
    }
    
    func load() {
        loadPlaces(filterBy: selectedCategories, withLocation: searchBar.text!)
    }
    
    // load places
    func loadPlaces(filterBy categories : [String], withLocation location : String) {
        
        if PFUser.current() != nil {
            
            // STEP 1. Find people who current user follows
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
                    
                    // STEP 2. Get posts by people current user follows
                    let postQuery = PFQuery(className: "posts")
                    postQuery.whereKey("username", containedIn: self.followArray)
                    postQuery.findObjectsInBackground(block: { (postObjects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.postLocationArray.removeAll(keepingCapacity: false)
                            self.postAddressArray.removeAll(keepingCapacity: false)
                            self.postCategoryArray.removeAll(keepingCapacity: false)
                            self.postRatingArray.removeAll(keepingCapacity: false)
                            
                            // get data of posts
                            for postObject in postObjects! {
                                
                                if postObject.object(forKey: "location") != nil {
                                    self.postLocationArray.append(postObject.object(forKey: "location") as! String)
                                } else {
                                    self.postLocationArray.append("")
                                }
                                
                                if postObject.object(forKey: "address") != nil {
                                    self.postAddressArray.append(postObject.object(forKey: "address") as! String)
                                } else {
                                    self.postAddressArray.append("")
                                }
                                
                                if postObject.object(forKey: "category") != nil {
                                    self.postCategoryArray.append(postObject.object(forKey: "category") as! String)
                                } else {
                                    self.postCategoryArray.append("")
                                }
                                
                                if postObject.object(forKey: "rating") != nil {
                                    self.postRatingArray.append(postObject.object(forKey: "rating") as! CGFloat)
                                } else {
                                    self.postRatingArray.append(0.0)
                                }
                            }
                            
                            // STEP 3. Get items in current user's suitcase
                            let suitcaseQuery = PFQuery(className: "suitcase")
                            suitcaseQuery.whereKey("user", equalTo: PFUser.current()!.username!)
                            
                            if location != "" {
                                suitcaseQuery.whereKey("location", matchesRegex: "(?i)" + location)
                            }
                            
                            suitcaseQuery.limit = self.page
                            suitcaseQuery.addDescendingOrder("createdAt")
                            suitcaseQuery.findObjectsInBackground(block: { (suitcaseObjects, error) -> Void in
                                if error == nil {
                                    
                                    // clean up
                                    self.locationArray.removeAll(keepingCapacity: false)
                                    self.addressArray.removeAll(keepingCapacity: false)
                                    self.dateArray.removeAll(keepingCapacity: false)
                                    self.categoryArray.removeAll(keepingCapacity: false)
                                    self.ratingArray.removeAll(keepingCapacity: false)
                                    
                                    for suitcaseObject in suitcaseObjects! {
                                        
                                        var categories = [String]()
                                        var ratings = [CGFloat]()
                                        
                                        // loop through posts to find matching location and address
                                        for i in 0...self.postLocationArray.count - 1 {
                                            
                                            if self.postLocationArray[i] == (suitcaseObject.object(forKey: "location") as! String) && self.postAddressArray[i] == (suitcaseObject.object(forKey: "address") as! String) {
                                                
                                                categories.append(self.postCategoryArray[i])
                                                ratings.append(self.postRatingArray[i])
                                            }
                                        }
                                        
                                        // if no posts match the suitcase object, delete it
                                        if categories.isEmpty {
                                            suitcaseObject.deleteEventually()
                                            
                                        } else {
                                            // calculate average rating and category for suitcase item
                                            let category = self.calculateCategory(categories)
                                            if selectedCategories.contains(category) {
                                                self.locationArray.append(suitcaseObject.object(forKey: "location") as! String)
                                                self.addressArray.append(suitcaseObject.object(forKey: "address") as! String)
                                                self.dateArray.append(suitcaseObject.createdAt)
                                                self.categoryArray.append(category)
                                                self.ratingArray.append(self.calculateAverageRating(ratings))
                                            }
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
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    
    // scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    // pagination
    func loadMore() {
        
        if page <= locationArray.count {
            
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 10
            
            // filter
            loadPlaces(filterBy: selectedCategories, withLocation: searchBar.text!)
            
            // stop animating indicator
            self.indicator.stopAnimating()
        }
    }

    
    // clicked on category button
    @IBAction func categoryBtn_clicked(_ sender: UIButton) {
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // change tint of category button
        if sender.tintColor == mainColor {
            sender.tintColor = lightGrey
            selectedCategories.removeAll()
            for btn in categoryBtns {
                if btn.tintColor == mainColor {
                    selectedCategories.append(btn.restorationIdentifier!)
                }
            }
        } else {
            sender.tintColor = mainColor
            selectedCategories.append(sender.restorationIdentifier!)
        }
        
        // filter
        loadPlaces(filterBy: selectedCategories, withLocation: searchBar.text!)
    }
    
    // calculate average rating for place
    func calculateAverageRating(_ ratings : [CGFloat]) -> CGFloat {
        var total = CGFloat(0)
        for rating in ratings {
            total += rating
        }
        if ratings.count == 0 {
            return total
        } else {
            return (total / CGFloat(ratings.count))
        }
    }
    
    // calculate category of place
    func calculateCategory(_ categories : [String]) -> String {
        var counts = [String: Int]()
        categories.forEach { counts[$0] = (counts[$0] ?? 0) + 1 }
        if let (value, _) = counts.max(by: {$0.1 < $1.1}) {
            return value
        } else {
            return ""
        }
    }
    
    // TABLE VIEW
    //cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Suitcase Cell", for: indexPath) as! suitcaseCell
        
        // adjust line
        if (indexPath as NSIndexPath).row == locationArray.count - 1 {
            cell.line.isHidden = true
        } else {
            cell.line.isHidden = false
        }
        
        if (indexPath as NSIndexPath).row == 0 {
            cell.underline.isHidden = true
        } else {
            cell.underline.isHidden = false
        }
        
        cell.locationBtn.setTitle(locationArray[(indexPath as NSIndexPath).row], for: .normal)
        cell.dateLbl.text = dateArray[(indexPath as NSIndexPath).row]?.asString(style: .long)
        
        // set address
        cell.addressLbl.text = addressArray[(indexPath as NSIndexPath).row]
        if addressArray[(indexPath as NSIndexPath).row] == "" {
            cell.addressLblTopSpace.constant = 0
        } else {
            cell.addressLblTopSpace.constant = 10
        }
        
        // set category
        PostCategory.selectImgType(categoryArray[(indexPath as NSIndexPath).row], cell.categoryIcon, cell.categoryIconWidth)

        // set rating
        let rating = ratingArray[(indexPath as NSIndexPath).row]
        cell.reviewOverlayLeadingSpace.constant = rating * cell.reviewBackground.frame.size.width
        Review.colorReview(rating, cell.reviewBackground)
        
        // assign index
        cell.locationBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    
    // SEARCH BAR
    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        loadPlaces(filterBy: selectedCategories, withLocation: searchBar.text!)
        
        return true
    }
    
    // tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // show cancel button
        searchBar.showsCancelButton = true
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        // reload table view
        loadPlaces(filterBy: selectedCategories, withLocation: "")
    }
    
    
    // tint category icons
    func tintIcons(_ sender : UIButton) {
        let img = sender.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        sender.setImage(img, for: .normal)
        if sender.restorationIdentifier != nil && selectedCategories.contains(sender.restorationIdentifier!) {
            sender.tintColor = mainColor
        } else {
            sender.tintColor = lightGrey
        }
    }
    
    // clicked on location
    @IBAction func locationBtn_clicked(_ sender: UIButton) {
        
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: i) as! suitcaseCell
        
        placeTitle = cell.locationBtn.currentTitle!
        placeAddress = cell.addressLbl.text!
        placeCategory = categoryArray[(i as NSIndexPath).row]
        didSelectSelf = false
        
        let place = self.storyboard?.instantiateViewController(withIdentifier: "placeVC") as! placeVC
        self.navigationController?.pushViewController(place, animated: true)
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}
