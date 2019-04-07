//
//  suitcaseVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/2/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class suitcaseVC: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var categoryBtns: [UIButton]!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    // arrays to hold server data
    var uuidArray = [String]()
    var locationArray = [String]()
    var addressArray = [String]()
    var picArray = [PFFile]()
    var categoryArray = [String]()
    
    var dateArray = [Date?]()
    var ratingArray = [CGFloat]()
    
    var followArray = [String]()
    var postLocationArray = [String]()
    var postAddressArray = [String]()
    var postCategoryArray = [String]()
    var postRatingArray = [CGFloat]()
    var postPicArray = [PFFile]()
    
    // page size
    var page = 10
    
    var selectedCategories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Suitcase"
        
        searchBar.delegate = self
        
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
        collectionView.reloadData()
    }
    
    func load() {
        loadPlaces(filterBy: selectedCategories, withLocation: searchBar.text!)
    }
    
    // load places
    func loadPlaces(filterBy categories : [String], withLocation location : String) {
        indicator.startAnimating()
        
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
                            self.postPicArray.removeAll(keepingCapacity: false)
                            self.postLocationArray.removeAll(keepingCapacity: false)
                            self.postAddressArray.removeAll(keepingCapacity: false)
                            self.postCategoryArray.removeAll(keepingCapacity: false)
                            self.postRatingArray.removeAll(keepingCapacity: false)
                            
                            // get data of posts
                            for postObject in postObjects! {
                                
                                self.postPicArray.append(postObject.object(forKey: "pic") as! PFFile)
                                
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
                                    self.picArray.removeAll(keepingCapacity: false)
                                    self.locationArray.removeAll(keepingCapacity: false)
                                    self.addressArray.removeAll(keepingCapacity: false)
                                    self.dateArray.removeAll(keepingCapacity: false)
                                    self.categoryArray.removeAll(keepingCapacity: false)
                                    self.ratingArray.removeAll(keepingCapacity: false)
                                    
                                    for suitcaseObject in suitcaseObjects! {
                                        
                                        var categories = [String]()
                                        var ratings = [CGFloat]()
                                        var pics = [PFFile]()
                                        
                                        // loop through posts to find matching location and address
                                        for i in 0...self.postLocationArray.count - 1 {
                                            
                                            if self.postLocationArray[i] == (suitcaseObject.object(forKey: "location") as! String) && self.postAddressArray[i] == (suitcaseObject.object(forKey: "address") as! String) {
                                                
                                                categories.append(self.postCategoryArray[i])
                                                ratings.append(self.postRatingArray[i])
                                                pics.append(self.postPicArray[i])
                                            }
                                        }
                                        
                                        // if no posts match the suitcase object, delete it
                                        if categories.isEmpty {
                                            suitcaseObject.deleteEventually()
                                            
                                        } else {
                                            // calculate average rating and category for suitcase item
                                            let category = self.calculateCategory(categories)
                                            if self.selectedCategories.contains(category) {
                                                self.locationArray.append(suitcaseObject.object(forKey: "location") as! String)
                                                self.addressArray.append(suitcaseObject.object(forKey: "address") as! String)
                                                self.dateArray.append(suitcaseObject.createdAt)
                                                self.categoryArray.append(category)
                                                self.ratingArray.append(self.calculateAverageRating(ratings))
                                                self.picArray.append(pics[0])
                                            }
                                        }
                                    }
                                    
                                    // reload collectionView
                                    self.collectionView.reloadData()
                                    DispatchQueue.main.async {
                                        self.indicator.stopAnimating()
                                        self.collectionView.isHidden = false
                                    }
                                    
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
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    // pagination
    func loadMore() {
        
        if page <= locationArray.count {
            
            // increase page size to load +10 posts
            page = page + 10
            
            // filter
            loadPlaces(filterBy: selectedCategories, withLocation: searchBar.text!)
        }
    }

    
    // clicked on category button
    @IBAction func categoryBtn_clicked(_ sender: UIButton) {
        
        self.collectionView.isHidden = true
        
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
    
    
    // COLLECTION VIEW
    
    // cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //check orientation for cell size
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            // portrait
            return CGSize(width: (UIScreen.main.bounds.width - 20) / 2, height: (UIScreen.main.bounds.width - 20) / 2)
            
        } else {
            // landscape
            return CGSize(width: (UIScreen.main.bounds.height - 20) / 2, height: (UIScreen.main.bounds.height - 20) / 2)
        }
    }
    
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Suitcase Collection Cell", for: indexPath) as! SuitcaseCollectionCell
        
        // set picture
        picArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // set location
        cell.locationLbl.text = locationArray[(indexPath as NSIndexPath).row].uppercased()
        
        // set address
        cell.addressLbl.text = addressArray[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    // selected cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SuitcaseCollectionCell
        
        placeTitle = locationArray[(indexPath as NSIndexPath).row]
        placeAddress = cell.addressLbl.text!
        placeCategory = categoryArray[(indexPath as NSIndexPath).row]
        didSelectSelf = false
        
        let place = self.storyboard?.instantiateViewController(withIdentifier: "placeVC") as! placeVC
        self.navigationController?.pushViewController(place, animated: true)
    }
    
    
    // SEARCH BAR
    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        self.collectionView.isHidden = true
        
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
        
        self.collectionView.isHidden = true
        
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
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}
