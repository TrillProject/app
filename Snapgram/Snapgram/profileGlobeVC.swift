//
//  profileGlobeVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/18/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var filterCategories = [String]()

class profileGlobeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // value to hold keyboard frame size
    var keyboard = CGRect()
    var keyboardVisible = false
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapImg: UIImageView!
    
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var favoritesLbl: UILabel!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var tagsSearchBar: UISearchBar!
    
    @IBOutlet weak var favoritesCollectionView: UICollectionView! {
        didSet {
            favoritesCollectionView.delegate = self
            favoritesCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var favoritesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var favoritesCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var locationCollectionView: UICollectionView! {
        didSet {
            locationCollectionView.delegate = self
            locationCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var locationViewLayout: LeftAlignedCollectionViewFlowLayout!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView! {
        didSet {
            tagsCollectionView.delegate = self
            tagsCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var tagsCollectionViewLayout: LeftAlignedCollectionViewFlowLayout!
    
    @IBOutlet weak var reviewBackgroundImg: UIImageView!
    @IBOutlet weak var reviewOverlay: UIView!
    @IBOutlet var categoryBtns: [UIButton]!
    @IBOutlet weak var mapFavoritesSeparator: UIView!
    @IBOutlet weak var favoritesFilterSeparator: UIView!
    
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var reviewOverlayTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var locationCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationCollectionViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionViewTopSpace: NSLayoutConstraint!
    
    
    // arrays to hold server data
    var favoritesLocationArray = [String]()
    var favoritesAddressArray = [String]()
    var favoritesPicArray = [PFFile]()
    var favoritesCategoryArray = [String]()
    
    var filterLocations = [String]()
    var filterTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLbl.text = user
        
        locationViewLayout.estimatedItemSize = CGSize(width: 100.0, height: 30.0)
        tagsCollectionViewLayout.estimatedItemSize = CGSize(width: 100.0, height: 30.0)
        
        // tint category icons
        filterCategories.removeAll()
        for categoryBtn in categoryBtns {
            filterCategories.append(categoryBtn.restorationIdentifier!)
            tintIcons(categoryBtn)
        }
        
        locationCollectionViewHeight.constant = 0
        locationCollectionViewTopSpace.constant = 0
        tagsCollectionViewHeight.constant = 0
        tagsCollectionViewTopSpace.constant = 0
        
        // receive notification from postTagsVC when post is added
        NotificationCenter.default.addObserver(self, selector: #selector(globeVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        //check orientation for collection view height
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            // portrait
            favoritesCollectionViewHeight.constant = UIScreen.main.bounds.width / 2
            reviewOverlayLeadingSpace.constant = UIScreen.main.bounds.width / 2
            reviewOverlayTrailingSpace.constant = UIScreen.main.bounds.width / 2
        } else {
            // landscape
            favoritesCollectionViewHeight.constant = UIScreen.main.bounds.height / 2
            reviewOverlayLeadingSpace.constant = UIScreen.main.bounds.height / 2
            reviewOverlayTrailingSpace.constant = UIScreen.main.bounds.height / 2
        }
        
        locationSearchBar.returnKeyType = UIReturnKeyType.done
        tagsSearchBar.returnKeyType = UIReturnKeyType.done
        
        loadFavorites()
        
    }
    
    // reloading func with posts after received notification
    func uploaded(_ notification:Notification) {
        loadFavorites()
    }
    
    
    // FAVORITES
    
    func loadFavorites() {
            
        // STEP 1. Get favorites of user
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("username", equalTo: usernameLbl.text!)
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
    
    // clicked on collection cell
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
        } else {
            let cell = tagsCollectionView.cellForItem(at: indexPath) as! tagCell
            let indexOfTag = filterTags.index(of: cell.tagLbl.text!.lowercased())
            filterTags.remove(at: indexOfTag!)
            tagsCollectionView.reloadData()
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
}
