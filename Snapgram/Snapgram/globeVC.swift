//
//  globeVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 10/11/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class globeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // value to hold keyboard frame size
    var keyboard = CGRect()
    var keyboardVisible = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapFavoritesSeparator: UIView!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var favoritesFilterSeparator: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var locationSearchBarActive: UISearchBar!
    @IBOutlet weak var tagsSearchBar: UISearchBar!
    @IBOutlet weak var tagsSearchBarActive: UISearchBar!
    
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var locationsTableView: UITableView! {
        didSet {
            locationsTableView.dataSource = self
            locationsTableView.delegate = self
        }
    }
    
    @IBOutlet weak var tagsTableView: UITableView! {
        didSet{
            tagsTableView.dataSource = self
            tagsTableView.delegate = self
        }
    }
    
    
    @IBOutlet weak var favoritesCollectionView: UICollectionView!{
        didSet{
            favoritesCollectionView.dataSource = self
            favoritesCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var favoritesCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var favoritesCollectionViewFlowLayout: LeftAlignedCollectionViewFlowLayout!
    
    @IBOutlet weak var locationCollectionView: UICollectionView!{
        didSet{
            locationCollectionView.dataSource = self
            locationCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var locationCollectionViewLayout: LeftAlignedCollectionViewFlowLayout!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!{
        didSet{
            tagsCollectionView.dataSource = self
            tagsCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var tagsCollectionViewLayout: LeftAlignedCollectionViewFlowLayout!
    
    
    @IBOutlet weak var reviewContainerView: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    @IBOutlet weak var reviewBackgroundImg: UIImageView!
    @IBOutlet var categoryBtns: [UIButton]!
    
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var reviewOverlayTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var locationCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationCollectionViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionViewTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var filterTableView: UITableView! {
        didSet{
            filterTableView.dataSource = self
            filterTableView.delegate = self
        }
    }
    @IBOutlet weak var filterTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var filterTableViewOverlay: UIView!
    @IBOutlet weak var filterIndicatorView: UIView!
    @IBOutlet weak var filterIndicator: UIActivityIndicatorView!
    
    
    // arrays to hold server data
    var favoritesLocationArray = [String]()
    var favoritesAddressArray = [String]()
    var favoritesPicArray = [PFFile]()
    var favoritesCategoryArray = [String]()
    
    var followArray = [String]()
    
    var filterLocations = [String]()
    var filterTags = [String]()
    
    var filterRatingStart = CGFloat(0.0)
    var filterRatingEnd = CGFloat(1.0)
    
    // table view data
    var tagsArray = [String]()
    var countArray = [Int]()
    
    var locationsArray = [String]()
    var locationsCountArray = [Int]()
    
    var filterCategories = [String]()
    
    var sortedPicImgArray = [PFFile]()
    var sortedLocationArray = [String]()
    var sortedAddressArray = [String]()
    var sortedCategoryArray = [String]()
    var sortedPlaceTagsArray = [[String]]()
    var sortedRatingArray = [CGFloat]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Explore Network"
        
        locationCollectionViewLayout.estimatedItemSize = CGSize(width: 100.0, height: 26.0)
        tagsCollectionViewLayout.estimatedItemSize = CGSize(width: 100.0, height: 26.0)
        
        // tint category icons
        filterCategories.removeAll()
        for categoryBtn in categoryBtns {
            filterCategories.append(categoryBtn.restorationIdentifier!)
            tintIcons(categoryBtn)
        }
        
//        locationCollectionViewHeight.constant = 0
        locationCollectionViewTopSpace.constant = 0
//        tagsCollectionViewHeight.constant = 0
        tagsCollectionViewTopSpace.constant = 0
        
        // receive notification from postTagsVC when post is added
        NotificationCenter.default.addObserver(self, selector: #selector(globeVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        // receive notification from profileUserVC
        NotificationCenter.default.addObserver(self, selector: #selector(globeVC.reloadFriends(_:)), name: NSNotification.Name(rawValue: "followingUserChanged"), object: nil)
        
        //check orientation for collection view height
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            // portrait
            favoritesCollectionViewHeight.constant = UIScreen.main.bounds.width / 2
//            reviewOverlayLeadingSpace.constant = UIScreen.main.bounds.width / 2
//            reviewOverlayTrailingSpace.constant = UIScreen.main.bounds.width / 2
            
        } else {
            // landscape
            favoritesCollectionViewHeight.constant = UIScreen.main.bounds.height / 2
//            reviewOverlayLeadingSpace.constant = UIScreen.main.bounds.height / 2
//            reviewOverlayTrailingSpace.constant = UIScreen.main.bounds.height / 2
        }
        
        locationSearchBar.delegate = self
        locationSearchBarActive.delegate = self
        tagsSearchBar.delegate = self
        tagsSearchBarActive.delegate = self
        locationSearchBar.returnKeyType = UIReturnKeyType.done
        locationSearchBarActive.returnKeyType = UIReturnKeyType.done
        tagsSearchBar.returnKeyType = UIReturnKeyType.done
        tagsSearchBarActive.returnKeyType = UIReturnKeyType.done
        
        // rating pan gesture
        let ratingPan = UIPanGestureRecognizer(target: self, action: #selector(globeVC.handleRatingPan(_:)))
        reviewContainerView.addGestureRecognizer(ratingPan)
        
//        reviewOverlayLeadingSpace.constant = UIScreen.main.bounds.width

        searchContainer.isHidden = true
        tagsSearchBarActive.isHidden = true
        tagsTableView.isHidden = true
        locationSearchBarActive.isHidden = true
        locationsTableView.isHidden = true
        
        locationsTableView.tableFooterView = UIView()
        locationsTableView.separatorInset = UIEdgeInsets.zero
        
        tagsTableView.tableFooterView = UIView()
        tagsTableView.separatorInset = UIEdgeInsets.zero
        
        filterTableView.tableFooterView = UIView()
        filterTableView.separatorInset = UIEdgeInsets.zero
        
        self.filterTableView.isScrollEnabled = false
        self.scrollView.bounces = false
        self.filterTableView.bounces = true
        
        filterIndicatorView.isHidden = true
        filterTableViewOverlay.isHidden = false
        
        getFriends()
        
        loadFavorites()
    }
    
    // scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            filterTableView.isScrollEnabled = (self.scrollView.contentOffset.y >= 200)
        } else if scrollView == self.filterTableView {
            self.filterTableView.isScrollEnabled = (filterTableView.contentOffset.y > 0)
        }
    }
    
    
    func getFriends() {
        
        let followQuery = PFQuery(className: "follow")
        if PFUser.current() != nil {
            followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followQuery.whereKey("accepted", equalTo: true)
            followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    filterFriends.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        filterFriends.append(object.object(forKey: "following") as! String)
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    // reload after following user changed
    func reloadFriends(_ notification:Notification) {
        getFriends()
    }
    
    
    // reloading func with posts after received notification
    func uploaded(_ notification:Notification) {
        loadFavorites()
    }
    
    
    // filter rating
    func handleRatingPan(_ sender : UIPanGestureRecognizer) {
        
        let reviewWidth = UIScreen.main.bounds.width
        
        switch sender.state {
        case .began:
            break
        case .changed:
            let location = sender.location(in: self.reviewContainerView).x
            reviewOverlayTrailingSpace.constant = reviewWidth - location
        case .ended:
            filterRatingStart = (reviewWidth - reviewOverlayTrailingSpace.constant) / reviewWidth
        default:
            break
        }
    }
    
    
    // FAVORITES
    
    func loadFavorites() {
        
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
                    
                    // STEP 2. Get favorites of people current user follows
                    let postQuery = PFQuery(className: "posts")
                    postQuery.whereKey("username", containedIn: self.followArray)
                    postQuery.findObjectsInBackground(block: { (favoriteObjects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.favoritesPicArray.removeAll(keepingCapacity: false)
                            self.favoritesLocationArray.removeAll(keepingCapacity: false)
                            self.favoritesAddressArray.removeAll(keepingCapacity: false)
                            self.favoritesCategoryArray.removeAll(keepingCapacity: false)
                            
                            // get data of posts
                            for favoriteObject in favoriteObjects! {
                                
                                // only select posts which are favorite
                                if favoriteObject.object(forKey: "favorite") != nil &&  (favoriteObject.object(forKey: "favorite") as! Bool) == true {
                                    
                                    self.favoritesPicArray.append(favoriteObject.object(forKey: "pic") as! PFFile)
                                    
                                    if favoriteObject.object(forKey: "location") != nil {
                                        self.favoritesLocationArray.append(favoriteObject.object(forKey: "location") as! String)
                                    } else {
                                        self.favoritesLocationArray.append("")
                                    }
                                    
                                    if favoriteObject.object(forKey: "address") != nil {
                                        self.favoritesAddressArray.append(favoriteObject.object(forKey: "address") as! String)
                                    } else {
                                        self.favoritesAddressArray.append("")
                                    }
                                    
                                    if favoriteObject.object(forKey: "category") != nil {
                                        self.favoritesCategoryArray.append(favoriteObject.object(forKey: "category") as! String)
                                    } else {
                                        self.favoritesCategoryArray.append("")
                                    }
                                }
                            }
                            
                            // reload collectionView
                            self.favoritesCollectionView.reloadData()
                            
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
    
    
    // COLLECTION VIEW
    
    // cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == favoritesCollectionView {
            return favoritesPicArray.count
        } else if collectionView == locationCollectionView {
            return filterLocations.count
        } else {
            return filterTags.count
        }
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == favoritesCollectionView {
            //check orientation for cell size
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                // portrait
                return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                
            } else {
                // landscape
                return CGSize(width: UIScreen.main.bounds.height - 20 / 2, height: UIScreen.main.bounds.height - 20 / 2)
            }
        } else {
            return collectionView.frame.size
        }
    }
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == favoritesCollectionView {
        
            // define cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Favorite Cell", for: indexPath) as! favoritesCell
            
            // set picture
            favoritesPicArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.picImg.image = UIImage(data: data!)
                } else {
                    print(error!.localizedDescription)
                }
            }
            
            // set location
            cell.locationLbl.text = favoritesLocationArray[(indexPath as NSIndexPath).row].uppercased()
            
            return cell
            
        } else if collectionView == locationCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! tagCell
            cell.tagLbl.text = filterLocations[(indexPath as NSIndexPath).row].uppercased()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! tagCell
            cell.tagLbl.text = filterTags[(indexPath as NSIndexPath).row].uppercased()
            return cell
        }
    }
    
    // selected cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == favoritesCollectionView {
            placeTitle = favoritesLocationArray[(indexPath as NSIndexPath).row]
            placeAddress = favoritesAddressArray[(indexPath as NSIndexPath).row]
            placeCategory = favoritesCategoryArray[(indexPath as NSIndexPath).row]
            didSelectSelf = false
            
            let place = self.storyboard?.instantiateViewController(withIdentifier: "placeVC") as! placeVC
            self.navigationController?.pushViewController(place, animated: true)
            
        } else if collectionView == locationCollectionView {
            let cell = locationCollectionView.cellForItem(at: indexPath) as! tagCell
            let indexOfTag = filterLocations.index(of: cell.tagLbl.text!.lowercased())
            filterLocations.remove(at: indexOfTag!)
            locationCollectionView.reloadData()
            self.locationCollectionView.layoutIfNeeded()
            self.locationCollectionViewHeight.constant = self.locationCollectionView.contentSize.height
        } else {
            let cell = tagsCollectionView.cellForItem(at: indexPath) as! tagCell
            let indexOfTag = filterTags.index(of: cell.tagLbl.text!.lowercased())
            filterTags.remove(at: indexOfTag!)
            tagsCollectionView.reloadData()
            self.tagsCollectionView.layoutIfNeeded()
            self.tagsCollectionViewHeight.constant = self.tagsCollectionView.contentSize.height
        }
    }
    
    // tint category icons
    func tintIcons(_ sender : UIButton) {
        let img = sender.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        sender.setImage(img, for: .normal)
        if sender.restorationIdentifier != nil && filterCategories.contains(sender.restorationIdentifier!) {
            sender.tintColor = mainColor
        } else {
            sender.tintColor = lightGrey
        }
    }
    
    @IBAction func categoryBtn_clicked(_ sender: UIButton) {
        // dismiss keyboard
        locationSearchBar.resignFirstResponder()
        tagsSearchBar.resignFirstResponder()
        
        // change tint of category button
        if sender.tintColor == mainColor {
            sender.tintColor = lightGrey
            filterCategories.removeAll()
            for btn in categoryBtns {
                if btn.tintColor == mainColor {
                    filterCategories.append(btn.restorationIdentifier!)
                }
            }
        } else {
            sender.tintColor = mainColor
            filterCategories.append(sender.restorationIdentifier!)
        }
    }
    
    @IBAction func filterFriendsBtn_clicked(_ sender: UIButton) {
        let friends = self.storyboard?.instantiateViewController(withIdentifier: "filterFriendsVC") as! filterFriendsVC
        self.navigationController?.pushViewController(friends, animated: true)
    }
    
    // func to hide keyboard
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    // func when keyboard is shown
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // define keyboard frame size
        keyboard = (((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            // TO DO
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardVisible = false
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            // TO DO
        })
    }
    
    
    // SEARCH
    
    // tapped on the  search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if searchBar == tagsSearchBar {
            tagsSearchBar.resignFirstResponder()
            tagsSearchBarActive.isHidden = false
            tagsSearchBarActive.becomeFirstResponder()
            searchContainer.isHidden = false
            tagsTableView.isHidden = false
            
            // show cancel button
            tagsSearchBarActive.showsCancelButton = true
            
            loadTags()
            
        } else if searchBar == locationSearchBar {
            
            locationSearchBar.resignFirstResponder()
            locationSearchBarActive.isHidden = false
            locationSearchBarActive.becomeFirstResponder()
            searchContainer.isHidden = false
            locationsTableView.isHidden = false
            
            // show cancel button
            locationSearchBarActive.showsCancelButton = true
            
            loadLocations()
            
        } else if searchBar == tagsSearchBarActive {
            tagsSearchBarActive.becomeFirstResponder()
            searchContainer.isHidden = false
            tagsTableView.isHidden = false
            
            // show cancel button
            tagsSearchBarActive.showsCancelButton = true
            
            loadTags()
            
        } else if searchBar == locationSearchBarActive {
            locationSearchBarActive.becomeFirstResponder()
            searchContainer.isHidden = false
            locationsTableView.isHidden = false
            
            // show cancel button
            locationSearchBarActive.showsCancelButton = true
            
            loadLocations()
        }
    }
    
    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if searchBar == tagsSearchBarActive {
            loadTags()
        } else if searchBar == locationSearchBarActive {
            loadLocations()
        }
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            if searchBar == tagsSearchBarActive {
                loadTags()
            } else if searchBar == locationSearchBarActive {
                loadLocations()
            }
        }
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        searchContainer.isHidden = true
        tagsTableView.isHidden = true
        locationsTableView.isHidden = true
        locationSearchBarActive.isHidden = true
        tagsSearchBarActive.isHidden = true
    }
    
    
    // TABLE VIEW
    
    // table view cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tagsTableView {
            return tagsArray.count
            
        } else if tableView == locationsTableView {
                
            return locationsArray.count
            
//        } else if tableView == filterTableView {
        } else {
            return sortedPicImgArray.count
        }
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tagsTableView {
        
            // define cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Tags Table Cell", for: indexPath) as! tagsTableCell
            
            cell.tagLbl.text = tagsArray[(indexPath as NSIndexPath).row]
            if countArray[(indexPath as NSIndexPath).row] == 1 {
                cell.countLbl.text = "\(countArray[(indexPath as NSIndexPath).row]) post"
            } else {
                cell.countLbl.text = "\(countArray[(indexPath as NSIndexPath).row]) posts"
            }
            
            return cell
        
        } else if tableView == locationsTableView {
            
            // define cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! tagsTableCell
            
            cell.tagLbl.text = locationsArray[(indexPath as NSIndexPath).row]
            if locationsCountArray[(indexPath as NSIndexPath).row] == 1 {
                cell.countLbl.text = "\(locationsCountArray[(indexPath as NSIndexPath).row]) post"
            } else {
                cell.countLbl.text = "\(locationsCountArray[(indexPath as NSIndexPath).row]) posts"
            }
            
            return cell
            
//        } else if tableView == filterTableView {
        } else{
            
            // define cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "globeFilterCell", for: indexPath) as! globeFilterCell
            
            sortedPicImgArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                cell.singleImg.image = UIImage(data: data!)
            }
            
            PostCategory.selectImgType(sortedCategoryArray[(indexPath as NSIndexPath).row], cell.categoryIcon, cell.categoryIconWidth, mainColor)
            
            cell.locationBtn.setTitle(sortedLocationArray[(indexPath as NSIndexPath).row], for: .normal)
            
            cell.addressLbl.text = sortedAddressArray[(indexPath as NSIndexPath).row]
            
            // set rating
            cell.reviewOverlayLeadingSpace.constant = sortedRatingArray[(indexPath as NSIndexPath).row] * UIScreen.main.bounds.width
            Review.colorReview(sortedRatingArray[(indexPath as NSIndexPath).row], cell.reviewBackground)
            
            // set tags
            let assignedTags = sortedPlaceTagsArray[(indexPath as NSIndexPath).row]
            let numberOfTags = assignedTags.count
            if 0 < numberOfTags {
                cell.tag1Btn.setTitle(assignedTags[0].uppercased(), for: .normal)
                cell.tag1View.isHidden = false
            } else {
                cell.tag1View.isHidden = true
            }
            if 1 < numberOfTags {
                cell.tag2Btn.setTitle(assignedTags[1].uppercased(), for: .normal)
                cell.tag2View.isHidden = false
            } else {
                cell.tag2View.isHidden = true
            }
            if 2 < numberOfTags {
                cell.tag3Btn.setTitle(assignedTags[2].uppercased(), for: .normal)
                cell.tag3View.isHidden = false
            } else {
                cell.tag3View.isHidden = true
            }
            
            // assign index
            cell.locationBtn.layer.setValue(indexPath, forKey: "index")
            
            return cell
        }
    }
    
    // selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tagsTableView {
            
            // dismiss keyboard
            tagsSearchBarActive.resignFirstResponder()
            
            // hide cancel button
            tagsSearchBarActive.showsCancelButton = false
            
            // reset text
            tagsSearchBarActive.text = ""
            
            tagsSearchBarActive.isHidden = true
            self.searchContainer.isHidden = true
            self.tagsTableView.isHidden = true
            
            filterTags.append(tagsArray[(indexPath as NSIndexPath).row])
            tagsCollectionView.reloadData()
            self.tagsCollectionView.layoutIfNeeded()
            self.tagsCollectionViewHeight.constant = self.tagsCollectionView.contentSize.height
            self.tagsCollectionViewTopSpace.constant = 15
        
        } else if tableView == locationsTableView {
            
            // dismiss keyboard
            locationSearchBarActive.resignFirstResponder()
            
            // hide cancel button
            locationSearchBarActive.showsCancelButton = false
            
            // reset text
            locationSearchBarActive.text = ""
            
            locationSearchBarActive.isHidden = true
            self.searchContainer.isHidden = true
            self.locationsTableView.isHidden = true
            
            filterLocations.append(locationsArray[(indexPath as NSIndexPath).row])
            locationCollectionView.reloadData()
            self.locationCollectionView.layoutIfNeeded()
            self.locationCollectionViewHeight.constant = self.tagsCollectionView.contentSize.height
            self.locationCollectionViewTopSpace.constant = 15
            
        }
    }
    
    
    // load tags
    func loadTags() {
                    
        // STEP 1. Find tags made by people appended to filterFriends
        let tagQuery = PFQuery(className: "postTags")
        tagQuery.whereKey("by", containedIn: filterFriends)
        tagQuery.whereKey("tag", notContainedIn: filterTags)
        if self.tagsSearchBarActive.text! != "" {
            tagQuery.whereKey("tag", hasPrefix: self.tagsSearchBarActive.text!.lowercased())
        }
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
                self.tagsTableView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    
    // load locations
    func loadLocations() {
        
        // STEP 1. Find posts made by people appended to filterFriends
        let query = PFQuery(className: "posts")
        query.whereKey("username", containedIn: filterFriends)
        query.whereKey("country", notContainedIn: filterLocations)
        query.whereKey("city", notContainedIn: filterLocations)
        query.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.locationsArray.removeAll(keepingCapacity: false)
                self.locationsCountArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    let country = object.object(forKey: "country")
                    let city = object.object(forKey: "city")
                    
                    if country != nil && city != nil {
                    
                        if (self.locationSearchBarActive.text! == "") ||  (self.locationSearchBarActive.text! != "" && (country as! String).hasPrefix(self.locationSearchBarActive.text!)) {
                        
                            if !self.locationsArray.contains(country as! String) {
                                self.locationsArray.append(country as! String)
                                self.locationsCountArray.append(1)
                            } else {
                                let index = self.locationsArray.index(of: country as! String)!
                                self.locationsCountArray[index] = self.locationsCountArray[index] + 1
                            }
                        }
                        
                        if (self.locationSearchBarActive.text! == "") ||  (self.locationSearchBarActive.text! != "" && (city as! String).hasPrefix(self.locationSearchBarActive.text!)) {
                            
                            if !self.locationsArray.contains(city as! String) {
                                self.locationsArray.append(city as! String)
                                self.locationsCountArray.append(1)
                            } else {
                                let index = self.locationsArray.index(of: city as! String)!
                                self.locationsCountArray[index] = self.locationsCountArray[index] + 1
                            }
                        }
                    }
                }
                
                // reload table view
                self.locationsTableView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // filter
    func loadPlaces() {
        
        filterIndicator.startAnimating()
        filterIndicatorView.isHidden = false
        filterTableViewOverlay.isHidden = false
        
        // STEP 1. Find posts made by people appended to filterFriends
        let query = PFQuery(className: "posts")
        query.whereKey("username", containedIn: filterFriends)
        query.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                
                // local arrays
                var picImgArray = [PFFile]()
                var locationArray = [String]()
                var addressArray = [String]()
                var countryArray = [String]()
                var cityArray = [String]()
                var categoryArray = [[String]]()
                var placeTagsArray = [[String]]()
                var ratingArray = [[CGFloat]]()
                
                var filteredPicImgArray = [PFFile]()
                var filteredLocationArray = [String]()
                var filteredAddressArray = [String]()
                var filteredCategoryArray = [String]()
                var filteredPlaceTagsArray = [[String]]()
                var filteredRatingArray = [CGFloat]()
                
                // clean up
                self.sortedPicImgArray.removeAll(keepingCapacity: false)
                self.sortedLocationArray.removeAll(keepingCapacity: false)
                self.sortedAddressArray.removeAll(keepingCapacity: false)
                self.sortedCategoryArray.removeAll(keepingCapacity: false)
                self.sortedRatingArray.removeAll(keepingCapacity: false)
                self.sortedPlaceTagsArray.removeAll(keepingCapacity: false)
                
                
                for object in objects! {
                    
                    let picImg = object.object(forKey: "pic")
                    let location = object.object(forKey: "location")
                    let address = object.object(forKey: "address")
                    let country = object.object(forKey: "country")
                    let city = object.object(forKey: "city")
                    let category = object.object(forKey: "category")
                    let rating = object.object(forKey: "rating")
                    let tags = object.object(forKey: "tags")
                    
                    if picImg != nil && location != nil && address != nil && country != nil && city != nil && category != nil && rating != nil && tags != nil {
                        
                        if !addressArray.contains(address as! String) {
                            
                            picImgArray.append(picImg as! PFFile)
                            addressArray.append(address as! String)
                            countryArray.append(country as! String)
                            cityArray.append(city as! String)
                            locationArray.append(location as! String)
                            categoryArray.append([category as! String])
                            ratingArray.append([rating as! CGFloat])
                            placeTagsArray.append(tags as! [String])
                            
                        } else {
                            
                            let index = addressArray.index(of: address as! String)!
                            categoryArray[index].append(category as! String)
                            ratingArray[index].append(rating as! CGFloat)
                            for tag in (tags as! [String]) {
                                placeTagsArray[index].append(tag)
                            }
                            
                        }
                    }
                }
                
                for i in 0..<categoryArray.count {
                    
                    var locationPresent = false
                    if self.filterLocations.count == 0 {
                        locationPresent = true
                    } else {
                        if self.filterLocations.contains(countryArray[i]) || self.filterLocations.contains(cityArray[i]) {
                            locationPresent = true
                        }
                    }
                    
                    var categoryPresent = false
                    var presentCategory = ""
                    for category in categoryArray[i] {
                        if self.filterCategories.contains(category) {
                            categoryPresent = true
                            presentCategory = category
                        }
                    }
                    
                    let rating = self.getAverageRating(ratingArray[i])
                    var ratingIncluded = false
                    if rating >= self.filterRatingStart && rating <= self.filterRatingEnd {
                        ratingIncluded = true
                    }
                    
                    var tagIncluded = false
                    if self.filterTags.count == 0 {
                        tagIncluded = true
                    } else {
                        for tag in placeTagsArray[i] {
                            if self.filterTags.contains(tag) {
                                tagIncluded = true
                            }
                        }
                    }
                    
                    if locationPresent && categoryPresent && ratingIncluded && tagIncluded {
                        filteredPicImgArray.append(picImgArray[i])
                        filteredLocationArray.append(locationArray[i])
                        filteredAddressArray.append(addressArray[i])
                        filteredCategoryArray.append(presentCategory)
                        filteredPlaceTagsArray.append(placeTagsArray[i])
                        filteredRatingArray.append(rating)
                    }
                }
                
                // Sort filteredRatingArray along with its offsets
                // and then extract the offsets using map
                let offsets = filteredRatingArray.enumerated().sorted { $0.element > $1.element }.map { $0.offset }
                
                // Use map on the array of ordered offsets to order the other arrays
                self.sortedRatingArray = offsets.map { filteredRatingArray[$0] }
                self.sortedPicImgArray = offsets.map { filteredPicImgArray[$0] }
                self.sortedLocationArray = offsets.map { filteredLocationArray[$0] }
                self.sortedAddressArray = offsets.map { filteredAddressArray[$0] }
                self.sortedCategoryArray = offsets.map { filteredCategoryArray[$0] }
                self.sortedPlaceTagsArray = offsets.map { filteredPlaceTagsArray[$0] }
 
                self.filterTableView.reloadData()
                
                DispatchQueue.main.async {
                    self.filterTableViewHeight.constant = CGFloat(self.sortedPicImgArray.count * 380)
//                    let o1 = self.mapView.frame.size.height + 2
//                    let o2 = self.favoritesView.frame.size.height
//                    let o3 = self.filterTableView.frame.origin.y
//                    
//                    var offset = o1 + o2 + o3
//                    if self.filterTableViewHeight.constant < UIScreen.main.bounds.height {
//                        offset = offset + self.filterTableViewHeight.constant - UIScreen.main.bounds.height
//                    }
                    
                    self.filterIndicatorView.isHidden = true
                    self.filterIndicator.stopAnimating()
                    self.filterTableViewOverlay.isHidden = true
                    
//                    self.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                }
                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func getAverageRating(_ ratings : [CGFloat]) -> CGFloat {
        var total = CGFloat(0)
        for rating in ratings {
            total += rating
        }
        let rating = (ratings.count == 0 ? total : (total / CGFloat(ratings.count)))
        return rating
    }
    
    // filter places
    @IBAction func filterBtn_clicked(_ sender: UIButton) {
        loadPlaces()
    }
    
    // click location button in filter cell, go to place VC
    @IBAction func locationBtn_clicked(_ sender: UIButton) {
        
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = filterTableView.cellForRow(at: i) as! globeFilterCell
        
        placeTitle = cell.locationBtn.currentTitle!
        placeAddress = cell.addressLbl.text!
        placeCategory = sortedCategoryArray[(i as NSIndexPath).row]
        didSelectSelf = false
        
        let place = self.storyboard?.instantiateViewController(withIdentifier: "placeVC") as! placeVC
        self.navigationController?.pushViewController(place, animated: true)
    }
}


