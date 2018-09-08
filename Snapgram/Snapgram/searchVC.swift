//
//  searchVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 9/8/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class searchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var peopleBtn: UIButton!
    @IBOutlet weak var placeBtn: UIButton!
    @IBOutlet weak var locationBtn: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var peopleTableView: UITableView! {
        didSet {
            peopleTableView.delegate = self
            peopleTableView.dataSource = self
        }
    }
    
    // arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var firstnameArray = [String]()
    var lastnameArray = [String]()
    var privateArray = [Bool]()
    // 0 = not following, 1 = pending, 2 = following
    var followTypeArray = [Int]()
    
    var acceptedArray = [String]()
    var pendingArray = [String]()
    
    var pagePeople = 20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Search"
        
        searchBar.delegate = self
        
        showView()
        loadUsers()
    }
    
    // display the people search view
    func showView() {
        
        peopleBtn.setTitleColor(darkGrey, for: .normal)
        placeBtn.setTitleColor(lightGrey, for: .normal)
        locationBtn.setTitleColor(lightGrey, for: .normal)
        
        peopleTableView.tableFooterView = UIView()
        peopleTableView.isHidden = false
    }
    
    // SEARCH PEOPLE
    
    func loadUsers() {
        
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
        
        if sender.tintColor == mainColor {
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
                        sender.tintColor = mainColor
                        
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
                        sender.tintColor = mainFadedColor
                        
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
    
    
    // scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        
        // scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            
            if scrollView == peopleTableView {
                self.loadMoreUsers()
            } else {
                
            }
        }
    }
    
    
    // TABLE VIEW CONFIGURATION
    
    // cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // searching for user
        if tableView == peopleTableView {
            return usernameArray.count
        } else {
            return 0
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
                cell.followBtn.tintColor = mainFadedColor
            } else {
                cell.followBtn.tintColor = mainColor
            }
            
            // assign index of button
            cell.followBtn.layer.setValue(indexPath, forKey: "index")
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Search User Cell") as! searchUserCell
            
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
            
        } else {
            
            
        }
    }
    
    
    // SEARCH BAR
    
    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if peopleBtn.titleColor(for: .normal) == darkGrey {
            
            pagePeople = 20
            loadUsers()
            
        } else if placeBtn.titleColor(for: .normal) == darkGrey {
            
        } else if locationBtn.titleColor(for: .normal) == darkGrey {
            
        }
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            
            if peopleBtn.titleColor(for: .normal) == darkGrey {
                
                pagePeople = 20
                loadUsers()
                
            } else if placeBtn.titleColor(for: .normal) == darkGrey {
                
            } else if locationBtn.titleColor(for: .normal) == darkGrey {
                
            }
        }
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
        
        if peopleBtn.titleColor(for: .normal) == darkGrey {
            
            loadUsers()
            
        } else if placeBtn.titleColor(for: .normal) == darkGrey {
            
        } else if locationBtn.titleColor(for: .normal) == darkGrey {
            
        }
    }
    
    
    // CLICK EVENTS
    
    // clicked to change type of search
    @IBAction func searchTypeBtn_clicked(_ sender: UIButton) {
        
        sender.setTitleColor(darkGrey, for: .normal)
        
        if sender.currentTitle == "People" {
            
            placeBtn.setTitleColor(lightGrey, for: .normal)
            locationBtn.setTitleColor(lightGrey, for: .normal)
            
            peopleTableView.isHidden = false
            
        } else if sender.currentTitle == "Place" {
            
            peopleBtn.setTitleColor(lightGrey, for: .normal)
            locationBtn.setTitleColor(lightGrey, for: .normal)
            
            peopleTableView.isHidden = true
            
        } else if sender.currentTitle == "Location" {
            
            peopleBtn.setTitleColor(lightGrey, for: .normal)
            placeBtn.setTitleColor(lightGrey, for: .normal)
            
            peopleTableView.isHidden = true
            
        }
    }
    
    // back button clicked
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
