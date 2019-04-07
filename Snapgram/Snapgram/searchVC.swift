//
//  searchVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/8/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class searchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    @IBOutlet weak var hiddenView: UIView!


    @IBOutlet weak var peopleBtn: UIButton!
    @IBOutlet weak var placeBtn: UIButton!

    @IBOutlet weak var searchBar: UISearchBar!

    // people outlets

    @IBOutlet weak var peopleTableView: UITableView! {
        didSet {
            peopleTableView.delegate = self
            peopleTableView.dataSource = self
        }
    }

    // place outlets

    @IBOutlet weak var placeTableView: UITableView! {
        didSet {
            placeTableView.delegate = self
            placeTableView.dataSource = self
        }
    }

    @IBOutlet weak var placeScrollView: UIScrollView!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var reviewBackground: UIView!
    @IBOutlet weak var reviewOverlay: UIView!
    @IBOutlet weak var singleImg: UIImageView!

    @IBOutlet weak var placeCollectionView: UICollectionView! {
        didSet {
            placeCollectionView.delegate = self
            placeCollectionView.dataSource = self
        }
    }

    @IBOutlet weak var placeReviewTableView: UITableView! {
        didSet {
            placeReviewTableView.delegate = self
            placeReviewTableView.dataSource = self
        }
    }

    @IBOutlet weak var placeReviewTableHeight: NSLayoutConstraint!
    @IBOutlet weak var categoryIconWidth: NSLayoutConstraint!
    @IBOutlet weak var reviewOverlayLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var placeCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var placeReviewTableViewTopSpace: NSLayoutConstraint!

    @IBOutlet weak var placeScrollViewIndicatorContainer: UIView!
    @IBOutlet weak var placeScrollViewIndicator: UIActivityIndicatorView!
    @IBOutlet weak var peopleTableViewIndicatorContainer: UIView!
    @IBOutlet weak var peopleTableViewIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placeTableViewIndicatorContainer: UIView!
    @IBOutlet weak var placeTableViewIndicator: UIActivityIndicatorView!

    // arrays to hold data from server
    // people
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var firstnameArray = [String]()
    var lastnameArray = [String]()
    var privateArray = [Bool]()
    // 0 = not following, 1 = pending, 2 = following
    var followTypeArray = [Int]()
    var acceptedArray = [String]()
    var pendingArray = [String]()

    // place
    var locationArray = [String]()
    var addressArray = [String]()
    var categoryArray = [[String]]()
    var usersArray = [[String]]()
    var followArray = [String]()

    var placeImgArray = [PFFile]()
    var placeUsernameArray = [String]()
    var placeFirstnameArray = [String]()
    var placeAvaArray = [PFFile]()
    var placeDateArray = [Date?]()
    var placeRatingArray = [CGFloat]()
    var placeCommentArray = [String]()
    var placeUuidArray = [String]()


    // pagination
    var pagePeople = 20
    var pagePlaces = 30

    var placeSelected = false


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Search"

        searchBar.delegate = self

        showView()
        loadUsers()
    }

    // display the people search view
    func showView() {

        peopleBtn.setTitleColor(mainColor, for: .normal)
        placeBtn.setTitleColor(mediumGrey, for: .normal)

        peopleTableView.tableFooterView = UIView()
        peopleTableView.isHidden = false

        placeTableView.tableFooterView = UIView()
        placeTableView.isHidden = true

        placeReviewTableView.tableFooterView = UIView()
        placeScrollView.isHidden = true

        self.placeReviewTableView.isScrollEnabled = false
        self.placeScrollView.bounces = false
        self.placeReviewTableView.bounces = true

        placeScrollViewIndicatorContainer.isHidden = true
        peopleTableViewIndicatorContainer.isHidden = true
        placeTableViewIndicatorContainer.isHidden = true
    }


    // PEOPLE SEARCH

    func loadUsers() {

        peopleTableView.isHidden = true
        peopleTableViewIndicatorContainer.isHidden = false
        peopleTableViewIndicator.startAnimating()

        // STEP 1. Get all people current user follows and check if they are accepted or pending
        let followingQuery = PFQuery(className: "follow")
        followingQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followingQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {

                // clean up
                self.acceptedArray.removeAll(keepingCapacity: false)
                self.pendingArray.removeAll(keepingCapacity: false)

                for object in objects! {

                    if object.object(forKey: "accepted") as! Bool {
                        self.acceptedArray.append(object.object(forKey: "following") as! String)
                    } else {
                        self.pendingArray.append(object.object(forKey: "following") as! String)
                    }
                }

                // STEP 2. Get users that match search
                let userQuery = PFQuery(className: "_User")
                userQuery.whereKey("username", notEqualTo: PFUser.current()!.username!)
                userQuery.addDescendingOrder("createdAt")
                userQuery.limit = self.pagePeople

                userQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                    if error == nil {

                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.firstnameArray.removeAll(keepingCapacity: false)
                        self.lastnameArray.removeAll(keepingCapacity: false)
                        self.privateArray.removeAll(keepingCapacity: false)
                        self.followTypeArray.removeAll(keepingCapacity: false)

                        // find related objects
                        for object in objects! {

                            var addUser = false

                            if self.searchBar.text == "" {
                                addUser = true
                            } else {

                                let fname = object.object(forKey: "firstname")
                                let lname = object.object(forKey: "lastname")

                                if fname != nil {
                                    if (fname as! String).lowercased().starts(with: self.searchBar.text!.lowercased()) {
                                        addUser = true
                                    }
                                }

                                if lname != nil {
                                    if (lname as! String).lowercased().starts(with: self.searchBar.text!.lowercased()) {
                                        addUser = true
                                    }
                                }

                                if (fname != nil && lname != nil) {
                                    let fullname = ((fname as! String) + " " + (lname as! String)).lowercased()
                                    if fullname.starts(with: self.searchBar.text!.lowercased()) {
                                        addUser = true
                                    }
                                }
                            }

                            if addUser {
                                self.usernameArray.append(object.object(forKey: "username") as! String)

                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)

                                if object.object(forKey: "firstname") != nil {
                                    self.firstnameArray.append(object.object(forKey: "firstname") as! String)
                                } else {
                                    self.firstnameArray.append(object.object(forKey: "username") as! String)
                                }

                                if object.object(forKey: "lastname") != nil {
                                    self.lastnameArray.append(object.object(forKey: "lastname") as! String)
                                } else {
                                    self.lastnameArray.append("")
                                }

                                if object.object(forKey: "private") != nil {
                                    self.privateArray.append(object.object(forKey: "private") as! Bool)
                                } else {
                                    self.privateArray.append(false)
                                }

                                if self.acceptedArray.contains((object.object(forKey: "username") as! String)) {
                                    self.followTypeArray.append(2)
                                } else if self.pendingArray.contains((object.object(forKey: "username") as! String)) {
                                    self.followTypeArray.append(1)
                                } else {
                                    self.followTypeArray.append(0)
                                }
                            }
                        }

                        // reload table view
                        self.peopleTableView.reloadData()

                        DispatchQueue.main.async {
                            self.peopleTableView.isHidden = false
                            self.peopleTableViewIndicatorContainer.isHidden = false
                            self.peopleTableViewIndicator.stopAnimating()
                        }

                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
    }

    // pagination
    func loadMoreUsers() {

        if pagePeople <= usernameArray.count {

            pagePeople = pagePeople + 20

            loadUsers()
        }
    }

    // clicked follow button
    @IBAction func followBtn_clicked(_ sender: UIButton) {

        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath

        // call cell to call further cell data
        let cell = peopleTableView.cellForRow(at: i) as! searchUserCell

        if sender.tintColor == highlightColor {
            // unfollow
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: cell.usernameLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {

                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                sender.tintColor = lightGrey

                                // send notification to update profileUserVC
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "followingChanged"), object: nil)

                                // delete follow notifications
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: cell.usernameLbl.text!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })

                                let followAcceptedQuery = PFQuery(className: "news")
                                followAcceptedQuery.whereKey("by", equalTo: cell.usernameLbl.text!)
                                followAcceptedQuery.whereKey("to", equalTo: PFUser.current()!.username!)
                                followAcceptedQuery.whereKey("type", equalTo: "follow accepted")
                                followAcceptedQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }

                    // send notification to update feed
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)

                } else {
                    print(error!.localizedDescription)
                }
            })

        } else if sender.tintColor == lightGrey {
            // follow
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = cell.usernameLbl.text!

            if privateArray[(i as NSIndexPath).row] == false {
                // to follow if profile is not private
                object["accepted"] = true
            } else {
                // to request to follow if profile is private
                object["accepted"] = false
            }
            object.saveInBackground(block: { (success, error) -> Void in
                if success {

                    // send notification to update profileUserVC
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "followingChanged"), object: nil)

                    if self.privateArray[(i as NSIndexPath).row] == false {
                        sender.tintColor = highlightColor

                        // send notification to update feed
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)

                        // send follow notification
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        if PFUser.current()?.object(forKey: "ava") != nil {
                            newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        } else {
                            let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                            let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                            newsObj["ava"] = avaFile!
                        }
                        newsObj["to"] = cell.usernameLbl.text!
                        newsObj["owner"] = ""
                        newsObj["uuid"] = ""
                        newsObj["type"] = "follow"
                        newsObj["checked"] = "no"
                        newsObj["firstname"] = PFUser.current()?.object(forKey: "firstname") as! String
                        newsObj["lastname"] = PFUser.current()?.object(forKey: "lastname") as! String
                        newsObj["private"] = PFUser.current()?.object(forKey: "private") as! Bool
                        newsObj.saveEventually()

                    } else {
                        //sender.tintColor = mainFadedColor
                        sender.tintColor = darkGrey

                        // send request notification
                        let requestObj = PFObject(className: "request")
                        requestObj["by"] = PFUser.current()?.username
                        if PFUser.current()?.object(forKey: "ava") != nil {
                            requestObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        } else {
                            let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                            let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                            requestObj["ava"] = avaFile!
                        }
                        requestObj["to"] = cell.usernameLbl.text!
                        requestObj["checked"] = "no"
                        requestObj["firstname"] = PFUser.current()?.object(forKey: "firstname") as! String
                        requestObj["lastname"] = PFUser.current()?.object(forKey: "lastname") as! String

                        requestObj.saveEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })

        } else if sender.tintColor == mainFadedColor {
            // follow requested - delete follow request
            let requestQuery = PFQuery(className: "request")
            requestQuery.whereKey("by", equalTo: PFUser.current()!.username!)
            requestQuery.whereKey("to", equalTo: cell.usernameLbl.text!)
            requestQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    sender.tintColor = lightGrey

                    // send notification to update profileUserVC
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "followingChanged"), object: nil)

                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })

            // delete follow relationship
            let followerQuery = PFQuery(className: "follow")
            followerQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followerQuery.whereKey("following", equalTo: cell.usernameLbl.text!)
            followerQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }


    // PLACE SEARCH

    func loadPlaces() {

        placeTableView.isHidden = true
        placeTableViewIndicatorContainer.isHidden = false
        placeTableViewIndicator.startAnimating()

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

                    // append current user to see own places
                    self.followArray.append(PFUser.current()!.username!)

                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.pagePlaces
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {

                            // clean up
                            self.locationArray.removeAll(keepingCapacity: false)
                            self.addressArray.removeAll(keepingCapacity: false)
                            self.categoryArray.removeAll(keepingCapacity: false)
                            self.usersArray.removeAll(keepingCapacity: false)

                            for object in objects! {

                                let location = object.object(forKey: "location")
                                let address = object.object(forKey: "address")
                                let category = object.object(forKey: "category")
                                let postUser = object.object(forKey: "username")
                                if location != nil && address != nil && category != nil {
                                    if !self.addressArray.contains(address as! String) {

                                        if self.searchBar.text! == "" || (location as! String).lowercased().starts(with: self.searchBar.text!.lowercased()) {
                                            self.addressArray.append(address as! String)
                                            self.locationArray.append(location as! String)
                                            self.categoryArray.append([category as! String])
                                            self.usersArray.append([postUser as! String])
                                        }
                                    } else {
                                        let index = self.addressArray.index(of: address as! String)!
                                        self.categoryArray[index].append(category as! String)
                                        self.usersArray[index].append(postUser as! String)
                                    }
                                }
                            }

                            // reload data
                            self.placeTableView.reloadData()

                            DispatchQueue.main.async {
                                self.placeTableView.isHidden = false
                                self.placeTableViewIndicatorContainer.isHidden = true
                                self.placeTableViewIndicator.stopAnimating()
                            }

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
    func loadMorePlaces() {

        if pagePlaces <= locationArray.count {

            pagePlaces = pagePlaces + 30

            loadPlaces()
        }
    }

    // load data of place once selected
    func loadPlaceInfo(_ location : String, _ address : String, _ categories : [String], _ usernames: [String]) {

        self.placeScrollView.isHidden = true
        self.placeScrollView.setContentOffset(.zero, animated: false)
        placeScrollViewIndicatorContainer.isHidden = false
        placeScrollViewIndicator.startAnimating()

        locationLbl.text = location
        addressLbl.text = address
        PostCategory.selectImgType(calculateCategory(categories), categoryIcon, categoryIconWidth, mainColor)

        var selfPost = true
        for username in usernames {
            if username != PFUser.current()!.username! {
                selfPost = false
            }
        }

        // STEP 1. Find posts related to people who current user is following
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

                    // STEP 2. Find posts made by people appended to followArray with location of placeTitle
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.whereKey("location", equalTo: location)
                    query.whereKey("address", equalTo: address)
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {

                            // clean up
                            self.placeImgArray.removeAll(keepingCapacity: false)
                            self.placeUsernameArray.removeAll(keepingCapacity: false)
                            self.placeFirstnameArray.removeAll(keepingCapacity: false)
                            self.placeAvaArray.removeAll(keepingCapacity: false)
                            self.placeDateArray.removeAll(keepingCapacity: false)
                            self.placeRatingArray.removeAll(keepingCapacity: false)
                            self.placeCommentArray.removeAll(keepingCapacity: false)
                            self.placeUuidArray.removeAll(keepingCapacity: false)

                            // find related objects
                            for object in objects! {

                                if object.object(forKey: "pic") != nil {
                                    self.placeImgArray.append(object.object(forKey: "pic") as! PFFile)
                                }

                                self.placeUsernameArray.append(object.object(forKey: "username") as! String)

                                if object.object(forKey: "firstname") != nil {
                                    self.placeFirstnameArray.append((object.object(forKey: "firstname") as! String).capitalized)
                                } else {
                                    self.placeFirstnameArray.append(object.object(forKey: "username") as! String)
                                }

                                self.placeAvaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.placeDateArray.append(object.createdAt)

                                if object.object(forKey: "rating") != nil {
                                    self.placeRatingArray.append(object.object(forKey: "rating") as! CGFloat)
                                } else {
                                    self.placeRatingArray.append(0.0)
                                }

                                self.placeCommentArray.append(object.object(forKey: "title") as! String)
                                self.placeUuidArray.append(object.object(forKey: "uuid") as! String)
                            }

                            if self.placeUsernameArray.count == 0 && selfPost {

                                // clean up
                                self.placeImgArray.removeAll(keepingCapacity: false)
                                self.placeUsernameArray.removeAll(keepingCapacity: false)
                                self.placeFirstnameArray.removeAll(keepingCapacity: false)
                                self.placeAvaArray.removeAll(keepingCapacity: false)
                                self.placeDateArray.removeAll(keepingCapacity: false)
                                self.placeRatingArray.removeAll(keepingCapacity: false)
                                self.placeCommentArray.removeAll(keepingCapacity: false)
                                self.placeUuidArray.removeAll(keepingCapacity: false)

                                let postQuery = PFQuery(className: "posts")
                                postQuery.whereKey("username", equalTo: PFUser.current()!.username!)
                                postQuery.whereKey("location", equalTo: location)
                                postQuery.whereKey("address", equalTo: address)
                                postQuery.addDescendingOrder("createdAt")
                                postQuery.findObjectsInBackground(block: { (postObjects, error) -> Void in
                                    if error == nil {

                                        // find related objects
                                        for postObject in postObjects! {

                                            self.placeUsernameArray.append(PFUser.current()!.username!)
                                            self.placeFirstnameArray.append((PFUser.current()?.object(forKey: "firstname") as! String).capitalized)
                                            self.placeAvaArray.append(PFUser.current()?.object(forKey: "ava") as! PFFile)

                                            if postObject.object(forKey: "pic") != nil {
                                                self.placeImgArray.append(postObject.object(forKey: "pic") as! PFFile)
                                            }

                                            self.placeDateArray.append(postObject.createdAt)
                                            self.placeCommentArray.append(postObject.object(forKey: "title") as! String)
                                            self.placeUuidArray.append(postObject.object(forKey: "uuid") as! String)

                                            if postObject.object(forKey: "rating") != nil {
                                                self.placeRatingArray.append(postObject.object(forKey: "rating") as! CGFloat)
                                            } else {
                                                self.placeRatingArray.append(0.0)
                                            }
                                        }

                                        self.placeCollectionView.reloadData()
                                        self.placeReviewTableView.reloadData()

                                        self.setPicture(self.placeImgArray.count)
                                        self.setAverageRating(self.placeRatingArray, self.reviewOverlayLeadingSpace, self.reviewBackground)
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                            } else {
                                self.placeCollectionView.reloadData()
                                self.placeReviewTableView.reloadData()

                                self.setPicture(self.placeImgArray.count)
                                self.setAverageRating(self.placeRatingArray, self.reviewOverlayLeadingSpace, self.reviewBackground)

                                DispatchQueue.main.async {
                                    if self.placeUsernameArray.count * 141 > Int(self.placeScrollView.frame.height) {
                                        self.placeReviewTableHeight.constant = self.placeScrollView.frame.height
                                    } else {
                                        self.placeReviewTableHeight.constant = CGFloat(self.placeUsernameArray.count * 141)
                                    }
                                    self.placeScrollView.isHidden = false
                                    self.placeScrollViewIndicatorContainer.isHidden = true
                                    self.placeScrollViewIndicator.stopAnimating()
                                }
                            }
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

    // set the picture view for place
    func setPicture(_ count : Int) {
        if count == 0 {
            placeCollectionView.isHidden = true
            placeCollectionViewHeight.constant = 0
            placeReviewTableViewTopSpace.constant = 0
            singleImg.isHidden = true
        } else if count == 1 {
            placeCollectionViewHeight.constant = 180
            placeReviewTableViewTopSpace.constant = 20
            placeCollectionView.isHidden = true
            singleImg.isHidden = false
            placeImgArray[0].getDataInBackground { (data, error) -> Void in
                self.singleImg.image = UIImage(data: data!)
            }
        } else {
            placeCollectionViewHeight.constant = 180
            placeReviewTableViewTopSpace.constant = 20
            placeCollectionView.isHidden = false
            singleImg.isHidden = true
        }
    }

    // get the average rating of a place
    func setAverageRating(_ ratings : [CGFloat], _ leadingSpace : NSLayoutConstraint!, _ background : UIView!) {
        var total = CGFloat(0)
        for rating in ratings {
            total += rating
        }
        let rating = (ratings.count == 0 ? total : (total / CGFloat(ratings.count)))
        leadingSpace.constant = rating * background.frame.size.width
        Review.colorReview(rating, reviewBackground)
    }

    // calculate the average category
    func calculateCategory(_ categories : [String]) -> String {
        var counts = [String: Int]()
        categories.forEach { counts[$0] = (counts[$0] ?? 0) + 1 }
        if let (value, _) = counts.max(by: {$0.1 < $1.1}) {
            return value
        } else {
            return ""
        }
    }

    // clicked on user
    @IBAction func user_clicked(_ sender: UIButton) {

        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath

        // call cell to call further cell data
        let cell = placeReviewTableView.cellForRow(at: i) as! placeReviewCell

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



    // scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }

        // scroll down for paging
        if scrollView == peopleTableView {
            if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
                self.loadMoreUsers()
            }
        } else if scrollView == placeTableView {
            if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
                self.loadMorePlaces()
            }
        } else if scrollView == self.placeScrollView {
            placeReviewTableView.isScrollEnabled = (self.placeScrollView.contentOffset.y >= 200)
        } else if scrollView == self.placeReviewTableView {
            self.placeReviewTableView.isScrollEnabled = (placeReviewTableView.contentOffset.y > 0)
        }
    }


    // TABLE VIEW CONFIGURATION

    // cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // searching for user
        if tableView == peopleTableView {
            return usernameArray.count

        // searching for place
        } else if tableView == placeTableView {
            return locationArray.count

        // loading place reviews
        } else {
            return placeUsernameArray.count
        }
    }

    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // searching for user
        if tableView == peopleTableView {

            let cell = tableView.dequeueReusableCell(withIdentifier: "Search User Cell") as! searchUserCell

            cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]

            // set profile picture
            avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.avaImg.image = UIImage(data: data!)
                } else {
                    print(error!.localizedDescription)
                }
            }

            // set name
            if lastnameArray[(indexPath as NSIndexPath).row] != "" {
                cell.nameLbl.text = firstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + lastnameArray[(indexPath as NSIndexPath).row].capitalized
            } else {
                cell.nameLbl.text = firstnameArray[(indexPath as NSIndexPath).row].capitalized
            }

            // tint follow button
            if followTypeArray[(indexPath as NSIndexPath).row] == 0 {
                cell.followBtn.tintColor = lightGrey
            } else if followTypeArray[(indexPath as NSIndexPath).row] == 1 {
                //cell.followBtn.tintColor = mainFadedColor
                cell.followBtn.tintColor = darkGrey
            } else {
                cell.followBtn.tintColor = highlightColor
            }

            // assign index of button
            cell.followBtn.layer.setValue(indexPath, forKey: "index")

            return cell

        // searching for place
        } else if tableView == placeTableView {

            let cell = tableView.dequeueReusableCell(withIdentifier: "Search Place Cell") as! searchPlaceCell

            cell.locationLbl.text = locationArray[(indexPath as NSIndexPath).row]
            cell.addressLbl.text = addressArray[(indexPath as NSIndexPath).row]

            return cell

        // loading place reviews
        } else {

            // define cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Place Review Cell", for: indexPath) as! placeReviewCell

            // connect data from server to objects
            cell.uuidLbl.text = placeUuidArray[(indexPath as NSIndexPath).row]
            cell.usernameLbl.text = placeUsernameArray[(indexPath as NSIndexPath).row]
            cell.usernameBtn.setTitle(placeFirstnameArray[(indexPath as NSIndexPath).row], for: .normal)
            placeAvaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.avaImg.setBackgroundImage(UIImage(data: data!), for: .normal)
                } else {
                    print(error!.localizedDescription)
                }
            }

            // set date
            cell.dateLbl.text = placeDateArray[(indexPath as NSIndexPath).row]?.asString(style: .long)

            // set rating
            cell.setRating(placeRatingArray[(indexPath as NSIndexPath).row])

            // set comment
            cell.commentLbl.text = placeCommentArray[(indexPath as NSIndexPath).row]

            if placeCommentArray[(indexPath as NSIndexPath).row] == "" {
                cell.commentLblTopSpace.constant = 0
            } else {
                cell.commentLblTopSpace.constant = 15
            }

            cell.avaImg.layer.setValue(indexPath, forKey: "index")
            cell.usernameBtn.layer.setValue(indexPath, forKey: "index")

            return cell
        }
    }

    // clicked cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // searching for user
        if tableView == peopleTableView {

            let cell = tableView.cellForRow(at: indexPath) as! searchUserCell

            // go to user's profile
            guestname.append(cell.usernameLbl.text!)
            user = cell.usernameLbl.text!
            let profileUser = self.storyboard?.instantiateViewController(withIdentifier: "profileUserVC") as! profileUserVC
            self.navigationController?.pushViewController(profileUser, animated: true)

        // searching for place
        } else if tableView == placeTableView {

            // dismiss keyboard
            searchBar.resignFirstResponder()

            // hide cancel button
            searchBar.showsCancelButton = false

            // reset text
            searchBar.text = ""

            let cell = tableView.cellForRow(at: indexPath) as! searchPlaceCell

            placeTableView.isHidden = true
            placeSelected = true
            placeScrollView.isHidden = false

            loadPlaceInfo(cell.locationLbl.text!, cell.addressLbl.text!, categoryArray[(indexPath as NSIndexPath).row], usersArray[(indexPath as NSIndexPath).row])


        // loading place reviews
        } else {
            // scrolled down
            func scrollViewDidScroll(_ scrollView: UIScrollView) {

                if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                    cancelButton.isEnabled = true
                }

                // scroll down for paging
                if scrollView == peopleTableView {
                    if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
                        self.loadMoreUsers()
                    }
                } else if scrollView == placeTableView {
                    if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
                        self.loadMorePlaces()
                    }
                } else if scrollView == self.placeScrollView {
                    placeReviewTableView.isScrollEnabled = (self.placeScrollView.contentOffset.y >= 200)
                } else if scrollView == self.placeReviewTableView {
                    self.placeReviewTableView.isScrollEnabled = (placeReviewTableView.contentOffset.y > 0)
                }
            }
            // go to post
            postuuid.append(placeUuidArray[(indexPath as NSIndexPath).row])
            let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
            self.navigationController?.pushViewController(post, animated: true)
        }
    }


    // COLLECTION VIEW

    // collection view cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if placeImgArray.count <= 1 {
            return 0
        } else {
            return placeImgArray.count
        }
    }

    // collection view cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Place Img Cell", for: indexPath) as! placeImgCell

        // connect data from server to objects
        placeImgArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.placeImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }

        return cell
    }


    // SEARCH BAR

    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if peopleBtn.titleColor(for: .normal) == mainColor {

            pagePeople = 20
            loadUsers()

        } else if placeBtn.titleColor(for: .normal) == mainColor {

            pagePlaces = 30
            loadPlaces()

        }

        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {

            if peopleBtn.titleColor(for: .normal) == mainColor {

                pagePeople = 20
                loadUsers()

            } else if placeBtn.titleColor(for: .normal) == mainColor {

                pagePlaces = 30
                loadPlaces()

            }
        }
    }

    // tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        // show cancel button
        searchBar.showsCancelButton = true

        if placeBtn.titleColor(for: .normal) == mainColor {

            placeTableView.isHidden = false
            placeScrollView.isHidden = true

            pagePlaces = 30
            loadPlaces()
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

        if peopleBtn.titleColor(for: .normal) == mainColor {

            loadUsers()

        } else if placeBtn.titleColor(for: .normal) == mainColor {

            if placeSelected {
                placeTableView.isHidden = true
                placeScrollView.isHidden = false
            } else {
                placeScrollView.isHidden = true
                loadPlaces()
            }

        }
    }


    // CLICK EVENTS

    // clicked to change type of search
    @IBAction func searchTypeBtn_clicked(_ sender: UIButton) {

        // dismiss keyboard
        searchBar.resignFirstResponder()

        // hide cancel button
        searchBar.showsCancelButton = false

        // reset text
        searchBar.text = ""

        sender.setTitleColor(mainColor, for: .normal)

        if sender.currentTitle == "People" {

            placeBtn.setTitleColor(mediumGrey, for: .normal)

            peopleTableView.isHidden = false
            placeTableView.isHidden = true
            placeScrollView.isHidden = true

            pagePeople = 20
            loadUsers()

        } else if sender.currentTitle == "Place" {

            peopleBtn.setTitleColor(mediumGrey, for: .normal)

            peopleTableView.isHidden = true
            placeTableView.isHidden = false
            placeScrollView.isHidden = true

            pagePlaces = 30
            loadPlaces()

        }
    }

    // back button clicked
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}
