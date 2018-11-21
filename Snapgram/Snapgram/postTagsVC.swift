//
//  postTagsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/10/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var selectedImg : UIImage?
var postLocation : String?
var postAddress : String?
var postCountry : String?
var postCity : String?
var postComment : String?
var selectedCategory : String?
var selectedTags = [String]()
var customTags = [String]()
var postRating : CGFloat?
var isPostFavorite = false

let tags = ["lobortis", "nam", "fermentum", "fusce", "dictum", "aman", "eu", "placerat", "suscipt", "neque", "imperdiet", "dabibus", "risus", "laoreet", "urna", "convallius", "quisque", "iaculis", "mattis"]


class postTagsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // value to hold keyboard frame size
    var keyboard = CGRect()
    var keyboardVisible = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView! {
        didSet {
            tagsCollectionView.dataSource = self
            tagsCollectionView.delegate = self
        }
    }
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var customTagsCollectionView: UICollectionView! {
        didSet {
            customTagsCollectionView.dataSource = self
            customTagsCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var customTagsLayout: LeftAlignedCollectionViewFlowLayout!
    
    @IBOutlet weak var addTagTxt: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addTagTxtBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var customTagsCollectionViewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var customTagsCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Post"
        
        layout.estimatedItemSize = CGSize(width: 100.0, height: 30.0)
        customTagsLayout.estimatedItemSize = CGSize(width: 100.0, height: 30.0)
        
        let addImg = addBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        addBtn.setImage(addImg, for: .normal)
        addBtn.tintColor = mainColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.addTagTxt.frame.height))
        addTagTxt.leftView = paddingView
        addTagTxt.leftViewMode = UITextFieldViewMode.always
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(postTagsVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postTagsVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(postTagsVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.backgroundView.isUserInteractionEnabled = true
        self.backgroundView.addGestureRecognizer(hideTap)
        
        // to connect with apple/google maps
        postAddress = "122 North 5th Street, Brooklyn, NY 11211"
        postCountry = "USA"
        postCity = "New York"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tagsCollectionViewHeight.constant = tagsCollectionView.contentSize.height
    }

    // cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return tags.count
        } else {
            return customTags.count
        }
    }
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // define cell
        if collectionView == tagsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag Cell", for: indexPath) as! tagCell
            cell.tagLbl.text = tags[(indexPath as NSIndexPath).row].uppercased()
            if selectedTags.contains(cell.tagLbl.text!.lowercased()) {
                cell.backgroundColor = highlightColor
            } else {
                cell.backgroundColor = lightGrey
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! tagCell
            cell.tagLbl.text = customTags[(indexPath as NSIndexPath).row].uppercased()
            cell.backgroundColor = highlightColor
            return cell
        }
    }
    
    // clicked on tag
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tagsCollectionView {
            let cell = tagsCollectionView.cellForItem(at: indexPath) as! tagCell
            if cell.backgroundColor == lightGrey {
                cell.backgroundColor = highlightColor
                selectedTags.append(cell.tagLbl.text!.lowercased())
            } else {
                cell.backgroundColor = lightGrey
                let indexOfTag = selectedTags.index(of: cell.tagLbl.text!.lowercased())
                selectedTags.remove(at: indexOfTag!)
            }
        } else {
            let cell = customTagsCollectionView.cellForItem(at: indexPath) as! tagCell
            let indexOfTag = customTags.index(of: cell.tagLbl.text!.lowercased())
            customTags.remove(at: indexOfTag!)
            customTagsCollectionView.reloadData()
        }
    }
    
    @IBAction func addBtn_clicked(_ sender: UIButton) {
        if !addTagTxt.text!.isEmpty {
            if !customTags.contains(addTagTxt.text!.lowercased()) && !tags.contains(addTagTxt.text!.lowercased()) {
                customTags.append(addTagTxt.text!.lowercased())
                customTagsCollectionView.reloadData()
                self.customTagsCollectionView.layoutIfNeeded()
                self.customTagsCollectionViewHeight.constant = self.customTagsCollectionView.contentSize.height
                self.addTagTxt.text = nil
            }
        }
    }
    
    // add post
    @IBAction func publishBtn_clicked(_ sender: UIBarButtonItem) {
        
         //dissmiss keyboard
        self.view.endEditing(true)
        
        // send data to server to "posts" class in Parse
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()!.username
        if PFUser.current()?.object(forKey: "firstname") != nil {
            object["firstname"] = PFUser.current()?.object(forKey: "firstname") as? String
        } else {
            object["firstname"] = PFUser.current()!.username
        }
        object["ava"] = PFUser.current()!.value(forKey: "ava") as! PFFile
        
        let uuid = UUID().uuidString
        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"
        
        if postComment == nil {
            object["title"] = ""
        } else {
            object["title"] = postComment!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        // send pic to server after converting to FILE and compression
        if selectedImg != nil {
            let imageData = UIImageJPEGRepresentation(selectedImg!, 0.5)
            let imageFile = PFFile(name: "post.jpg", data: imageData!)
            object["pic"] = imageFile
        }
        
        let objTags = selectedTags + customTags
        
        object["location"] = postLocation
        object["address"] = postAddress
        object["country"] = postCountry
        object["city"] = postCity
        object["category"] = selectedCategory
        object["tags"] = objTags
        object["rating"] = postRating
        object["favorite"] = isPostFavorite
        
        // send favorite to server
        if isPostFavorite {
            let favoriteObj = PFObject(className: "postFavorites")
            favoriteObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
            favoriteObj["by"] = PFUser.current()?.username
            favoriteObj.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("added to favorites")
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        // send tags to server
        for tag in objTags {
            let tagObj = PFObject(className: "postTags")
            tagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
            tagObj["by"] = PFUser.current()?.username
            tagObj["tag"] = tag
            tagObj.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("tag \(tag) created")
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        // send #hashtag to server
        if postComment != nil {
            let words:[String] = postComment!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
            // define tagged word
            for var word in words {
                
                // save #hasthag in server
                if word.hasPrefix("#") {
                    
                    // cut symbol
                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                    word = word.trimmingCharacters(in: CharacterSet.symbols)
                    
                    let hashtagObj = PFObject(className: "hashtags")
                    hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
                    hashtagObj["by"] = PFUser.current()?.username
                    hashtagObj["hashtag"] = word.lowercased()
                    hashtagObj["comment"] = postComment
                    hashtagObj.saveInBackground(block: { (success, error) -> Void in
                        if success {
                            print("hashtag \(word) created")
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
            }
        }
        
        // finally save information
        object.saveInBackground (block: { (success, error) -> Void in
            if error == nil {
                
                // send notification with name "uploaded"
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                
                // switch to another ViewController at 0 index of tabbar
                self.dismiss(animated: true, completion: {
                    
                })
            }
        })
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
            self.customTagsCollectionViewBottomSpace.constant = self.customTagsCollectionViewBottomSpace.constant + self.keyboard.height
            if self.addTagTxt.isFirstResponder && !self.keyboardVisible{
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentSize.height + self.keyboard.height - self.scrollView.bounds.size.height ), animated: true)
                self.keyboardVisible = true
            }
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardVisible = false

        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.customTagsCollectionViewBottomSpace.constant = self.customTagsCollectionViewBottomSpace.constant - self.keyboard.height
        })
    }
    
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
