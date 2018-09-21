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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapImg: UIImageView!
    
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var favoritesLbl: UILabel!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var tagsSearchBar: UISearchBar!
    
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
    @IBOutlet weak var favoritesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionViewTopSpace: NSLayoutConstraint!
    
    var filterLocations = [String]()
    var filterTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        reviewOverlayLeadingSpace.constant = UIScreen.main.bounds.width / 2
        reviewOverlayTrailingSpace.constant = UIScreen.main.bounds.width / 2
        
    }
    
    // cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == locationCollectionView {
            return filterLocations.count
        } else {
            return filterTags.count
        }
    }
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == locationCollectionView {
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
    
    // clicked on tag
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == locationCollectionView {
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
