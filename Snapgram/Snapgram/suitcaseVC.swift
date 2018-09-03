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

class suitcaseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
    var locations = [String]()
    var addresses = [String]()
    var dates = [Date?]()
    
    var locationArray = [String]()
    var addressArray = [String]()
    var dateArray = [Date?]()
    var categoryArray = [String]()
    var ratingArray = [CGFloat]()
    
    var followArray = [String]()
    
    // page size
    var page = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Suitcase"
        
        // pull to refresh
        refresher.addTarget(self, action: #selector(suitcaseVC.loadPlaces), for: UIControlEvents.valueChanged)
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

        loadPlaces(filterBy: selectedCategories)
    }
    
    // refreshing after recieved notification
    func refresh() {
        tableView.reloadData()
    }
    
    // load places
    func loadPlaces(filterBy categories : [String]) {
        
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
                    
                    // STEP 2. Get items in current user's suitcase
                    let suitcaseQuery = PFQuery(className: "suitcase")
                    suitcaseQuery.whereKey("user", equalTo: PFUser.current()!.username!)
//                    suitcaseQuery.limit = self.page
                    suitcaseQuery.addDescendingOrder("createdAt")
                    suitcaseQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.locations.removeAll(keepingCapacity: false)
                            self.addresses.removeAll(keepingCapacity: false)
                            self.dates.removeAll(keepingCapacity: false)
                            self.locationArray.removeAll(keepingCapacity: false)
                            self.addressArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.categoryArray.removeAll(keepingCapacity: false)
                            self.ratingArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                self.locations.append(object.object(forKey: "location") as! String)
                                self.addresses.append(object.object(forKey: "address") as! String)
                                self.dates.append(object.createdAt)
                            }
                            
                            // STEP 3. Get posts of items in suitcase by people current user follows
                            self.getPostData(forIndex: 0, filterBy: categories)
                            
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
    
    // Calculate place rating and category of items in suitcase from posts by people current user follows
    func getPostData(forIndex index : Int, filterBy categories : [String]) {
        
        var postRatingArray = [CGFloat]()
        var postCategoryArray = [String]()
        
        if index < locations.count {
            let query = PFQuery(className: "posts")
            query.whereKey("username", containedIn: self.followArray)
            query.whereKey("location", equalTo: locations[index])
            query.whereKey("address", equalTo: addresses[index])
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        
                        if object.object(forKey: "rating") != nil {
                            postRatingArray.append(object.object(forKey: "rating") as! CGFloat)
                        } else {
                            postRatingArray.append(0.0)
                        }
                        
                        if object.object(forKey: "category") != nil {
                            postCategoryArray.append(object.object(forKey: "category") as! String)
                        } else {
                            postCategoryArray.append("")
                        }
                    }
                    
                    let category = self.calculateCategory(postCategoryArray)
                    if selectedCategories.contains(category) {
                        self.locationArray.append(self.locations[index])
                        self.addressArray.append(self.addresses[index])
                        self.dateArray.append(self.dates[index])
                        self.categoryArray.append(category)
                        self.ratingArray.append(self.calculateAverageRating(postRatingArray))
                    }
                    
                    self.getPostData(forIndex: index + 1, filterBy: categories)
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            // reload tableView & end spinning of refresher
            self.tableView.reloadData()
//            self.refresher.endRefreshing()
        }
    }
    
    
    // scrolled down
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
//            loadMore()
//        }
//    }
    
    // pagination
    func loadMore() {
        
        if page <= locationArray.count {
            
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 3
            
            if PFUser.current() != nil {
                let suitcaseQuery = PFQuery(className: "suitcase")
                suitcaseQuery.whereKey("user", equalTo: PFUser.current()!.username!)
                suitcaseQuery.limit = self.page
                suitcaseQuery.addDescendingOrder("createdAt")
                suitcaseQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.locationArray.removeAll(keepingCapacity: false)
                        self.addressArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        self.categoryArray.removeAll(keepingCapacity: false)
                        self.ratingArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            
                            // add object to arrays if is in filtered categories
                            let category = self.calculateCategory(object["category"] as! [String])
                            if selectedCategories.contains(category) {
                                self.locationArray.append(object.object(forKey: "location") as! String)
                                self.addressArray.append(object.object(forKey: "address") as! String)
                                self.dateArray.append(object.createdAt)
                                self.categoryArray.append(category)
                                self.ratingArray.append(self.calculateAverageRating(object.object(forKey: "rating") as! [CGFloat]))
                            }
                        }
                        
                        // reload tableView & stop animating indicator
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
    }
    
    // clicked on category button
    @IBAction func categoryBtn_clicked(_ sender: UIButton) {
        
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
        loadPlaces(filterBy: selectedCategories)
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
