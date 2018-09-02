//
//  notificationsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/22/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class notificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var notificationsBtn: UIButton!
    @IBOutlet weak var requestsView: UIView!
    @IBOutlet weak var requestsBtn: UIButton!
    
    @IBOutlet weak var notificationsTableView: UITableView! {
        didSet {
            notificationsTableView.dataSource = self
            notificationsTableView.delegate = self
        }
    }
    
    @IBOutlet weak var requestsTableView: UITableView! {
        didSet {
            requestsTableView.dataSource = self
            requestsTableView.delegate = self
        }
    }
    
    @IBOutlet weak var findFriendsIcon: UIButton!
    
    @IBOutlet weak var notificationsHeaderHeight: NSLayoutConstraint!
    
    // arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    var firstnameArray = [String]()
    var lastnameArray = [String]()
    var sectionDateArray = [Date?]()
    var privateArray = [Bool]()
    
    var requestUsernameArray = [String]()
    var requestAvaArray = [PFFile]()
    var requestFirstnameArray = [String]()
    var requestLastnameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Network"
        
        // receive notification from settingsVC
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsVC.reload(_:)), name: NSNotification.Name(rawValue: "privacyChanged"), object: nil)
        
        // receive notification from profileUserVC
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsVC.reloadNotifications(_:)), name: NSNotification.Name(rawValue: "followingUserChanged"), object: nil)
        
        notificationsTableView.tableFooterView = UIView()
        notificationsTableView.separatorInset = UIEdgeInsets.zero
        notificationsTableView.isHidden = false
        
        requestsTableView.tableFooterView = UIView()
        requestsTableView.separatorInset = UIEdgeInsets.zero
        requestsTableView.isHidden = true
        
        let img = findFriendsIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        findFriendsIcon.setImage(img, for: .normal)
        findFriendsIcon.tintColor = darkGrey
        
        showView()
        getNotifications()
        getRequests()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hasNotifications = false
        
        // send notification to tabbar
        NotificationCenter.default.post(name: Notification.Name(rawValue: "checkedNotifications"), object: nil)
        
    }
    
    func showView() {
        if PFUser.current()?.object(forKey: "private") != nil,  PFUser.current()?.object(forKey: "private") as! Bool {
            // profile of current user is private
            notificationsHeaderHeight.constant = 50.0
            notificationsBtn.isHidden = false
            requestsBtn.isHidden = false
        } else {
            // profile of current user is not private
            notificationsHeaderHeight.constant = 0.0
            notificationsBtn.isHidden = true
            requestsBtn.isHidden = true
        }
        
        notificationsBtn.setTitleColor(darkGrey, for: .normal)
        requestsBtn.setTitleColor(lightGrey, for: .normal)
        notificationsTableView.isHidden = false
        requestsTableView.isHidden = true
    }
    
    // get notifications
    func getNotifications() {
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.limit = 30
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                self.firstnameArray.removeAll(keepingCapacity: false)
                self.lastnameArray.removeAll(keepingCapacity: false)
                self.privateArray.removeAll(keepingCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "by") as! String)
                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    self.ownerArray.append(object.object(forKey: "owner") as! String)
                    
                    if object.object(forKey: "firstname") != nil {
                        self.firstnameArray.append(object.object(forKey: "firstname") as! String)
                    } else {
                        self.firstnameArray.append(object.object(forKey: "by") as! String)
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
                    
                    // save notifications as checked
                    object["checked"] = "yes"
                    object.saveEventually()
                }
                
                // reload tableView to show received data
                self.notificationsTableView.reloadData()
            }
        })
    }
    
    
    // get requests
    func getRequests() {
        if PFUser.current()?.object(forKey: "private") != nil, PFUser.current()?.object(forKey: "private") as! Bool {
            let requestQuery = PFQuery(className: "request")
            requestQuery.whereKey("to", equalTo: PFUser.current()!.username!)
            requestQuery.limit = 30
            requestQuery.addDescendingOrder("createdAt")
            requestQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.requestUsernameArray.removeAll(keepingCapacity: false)
                    self.requestAvaArray.removeAll(keepingCapacity: false)
                    self.requestFirstnameArray.removeAll(keepingCapacity: false)
                    self.requestLastnameArray.removeAll(keepingCapacity: false)
                    
                    // found related objects
                    for object in objects! {
                        self.requestUsernameArray.append(object.object(forKey: "by") as! String)
                        self.requestAvaArray.append(object.object(forKey: "ava") as! PFFile)
                        
                        if object.object(forKey: "firstname") != nil {
                            self.requestFirstnameArray.append(object.object(forKey: "firstname") as! String)
                        } else {
                            self.requestFirstnameArray.append(object.object(forKey: "by") as! String)
                        }
                        
                        if object.object(forKey: "lastname") != nil {
                            self.requestLastnameArray.append(object.object(forKey: "lastname") as! String)
                        } else {
                            self.requestLastnameArray.append("")
                        }
                        
                        // save notifications as checked
                        object["checked"] = "yes"
                        object.saveEventually()
                    }
                    
                    // reload tableView to show received data
                    self.requestsTableView.reloadData()
                }
            })
        }
    }
    
    // cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == notificationsTableView {
            return usernameArray.count
        } else {
            return requestUsernameArray.count
        }
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        var sectionCount = 1
//        var currentDate = Date()
//        for item in dateArray {
//            
//        }
//        return sectionCount
//    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // declare cell
        if tableView == notificationsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Notification Cell") as! notificationCell
            
            // connect cell objects with received data from server
            cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]

            avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.avaImg.setImage(UIImage(data: data!), for: .normal)
                } else {
                    print(error!.localizedDescription)
                }
            }
            
            // calculate post date
//            let from = dateArray[(indexPath as NSIndexPath).row]
//            let now = Date()
//            let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
//            let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
//
//            // logic what to show: seconds, minuts, hours, days or weeks
//            if difference.second! <= 0 {
//                cell.dateLbl.text = "now"
//            }
//            if difference.second! > 0 && difference.minute! == 0 {
//                cell.dateLbl.text = "\(difference.second!)s."
//            }
//            if difference.minute! > 0 && difference.hour! == 0 {
//                cell.dateLbl.text = "\(difference.minute!)m."
//            }
//            if difference.hour! > 0 && difference.day! == 0 {
//                cell.dateLbl.text = "\(difference.hour!)h."
//            }
//            if difference.day! > 0 && difference.weekOfMonth! == 0 {
//                cell.dateLbl.text = "\(difference.day!)d."
//            }
//            if difference.weekOfMonth! > 0 {
//                cell.dateLbl.text = "\(difference.weekOfMonth!)w."
//            }
        
            // define info text
            if typeArray[(indexPath as NSIndexPath).row] == "mention" {
                if lastnameArray[(indexPath as NSIndexPath).row] != "" {
                    cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + lastnameArray[(indexPath as NSIndexPath).row].capitalized + " mentioned you"
                } else {
                    cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row] + "  mentioned you"
                }
            }
            if typeArray[(indexPath as NSIndexPath).row] == "comment" {
                if lastnameArray[(indexPath as NSIndexPath).row] != "" {
                    cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + lastnameArray[(indexPath as NSIndexPath).row].capitalized + " commented on your post"
                } else {
                    cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row] + " commented on your post"
                }
            }
            if typeArray[(indexPath as NSIndexPath).row] == "follow" || typeArray[(indexPath as NSIndexPath).row] == "follow accepted" {
                
                if typeArray[(indexPath as NSIndexPath).row] == "follow" {
                    if lastnameArray[(indexPath as NSIndexPath).row] != "" {
                        cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + lastnameArray[(indexPath as NSIndexPath).row].capitalized + " followed you"
                    } else {
                        cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row] + " followed you"
                    }
                } else {
                    if lastnameArray[(indexPath as NSIndexPath).row] != "" {
                        cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + lastnameArray[(indexPath as NSIndexPath).row].capitalized + " accepted your follow request"
                    } else {
                        cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row] + " accepted your follow request"
                    }
                }
                
                cell.followBtn.isHidden = false
                
                // check if following
                let followingQuery = PFQuery(className: "follow")
                followingQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
                followingQuery.whereKey("following", equalTo: usernameArray[(indexPath as NSIndexPath).row])
                followingQuery.countObjectsInBackground (block: { (count, error) -> Void in
                    if error == nil {
                        if count == 0 {
                            cell.followBtn.tintColor = lightGrey
                        } else {
                            followingQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        if object.object(forKey: "accepted") as! Bool == true {
                                            cell.followBtn.tintColor = mainColor
                                        } else {
                                            cell.followBtn.tintColor = mainFadedColor
                                        }
                                    }
                                } else {
                                    print(error!.localizedDescription)
                                }
                            })
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
            if typeArray[(indexPath as NSIndexPath).row] == "like" {
                if lastnameArray[(indexPath as NSIndexPath).row] != "" {
                    cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + lastnameArray[(indexPath as NSIndexPath).row].capitalized + " likes your post"
                } else {
                    cell.infoLbl.text = firstnameArray[(indexPath as NSIndexPath).row] + " likes your post"
                }
            }
        
            // asign index of button
            cell.avaImg.layer.setValue(indexPath, forKey: "index")
            cell.followBtn.layer.setValue(indexPath, forKey: "index")
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Requests Cell") as! requestsCell
            
            // connect cell objects with received data from server
            cell.usernameLbl.text = requestUsernameArray[(indexPath as NSIndexPath).row]
            
            requestAvaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.avaImg.setImage(UIImage(data: data!), for: .normal)
                } else {
                    print(error!.localizedDescription)
                }
            }
            
            if requestLastnameArray[(indexPath as NSIndexPath).row] != "" {
                cell.nameBtn.setTitle(requestFirstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + requestLastnameArray[(indexPath as NSIndexPath).row].capitalized, for: .normal)
            } else {
                cell.nameBtn.setTitle(requestFirstnameArray[(indexPath as NSIndexPath).row].capitalized, for: .normal)
            }
            
            // asign index of buttons
            cell.avaImg.layer.setValue(indexPath, forKey: "index")
            cell.nameBtn.layer.setValue(indexPath, forKey: "index")
            cell.confirmBtn.layer.setValue(indexPath, forKey: "index")
            cell.denyBtn.layer.setValue(indexPath, forKey: "index")
            
            return cell
        }
    }
    
    // view notifications
    @IBAction func notificationsBtn_clicked(_ sender: UIButton) {
        notificationsBtn.setTitleColor(darkGrey, for: .normal)
        requestsBtn.setTitleColor(lightGrey, for: .normal)
        requestsTableView.isHidden = true
        notificationsTableView.isHidden = false
        
        hasNotifications = false
        
        // send notification to tabbar
        NotificationCenter.default.post(name: Notification.Name(rawValue: "checkedNotifications"), object: nil)
    }
    
    // view requests
    @IBAction func requestsBtn_clicked(_ sender: UIButton) {
        notificationsBtn.setTitleColor(lightGrey, for: .normal)
        requestsBtn.setTitleColor(darkGrey, for: .normal)
        notificationsTableView.isHidden = true
        requestsTableView.isHidden = false
        
        // send notification to tabbar
        hasRequests = false
        NotificationCenter.default.post(name: Notification.Name(rawValue: "checkedNotifications"), object: nil)
    }
    
    // clicked ava img : notifications
    @IBAction func avaImg_clicked(_ sender: UIButton) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = notificationsTableView.cellForRow(at: i) as! notificationCell
        
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
    
    // clicked ava img or name button : requests
    @IBAction func requestsAvaImg_clicked(_ sender: UIButton) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = requestsTableView.cellForRow(at: i) as! requestsCell
        
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
    
    // clicked cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == notificationsTableView {
        
            // call cell for calling cell data
            let cell = tableView.cellForRow(at: indexPath) as! notificationCell
            
            // going to @mentioned comments
            if typeArray[(indexPath as NSIndexPath).row] == "mention" {
                
                // send related data to global variable
                commentuuid.append(uuidArray[(indexPath as NSIndexPath).row])
                commentowner.append(ownerArray[(indexPath as NSIndexPath).row])
                
                // go comments
                let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
                self.navigationController?.pushViewController(comment, animated: true)
            }
            
            
            // going to own comments
            if typeArray[(indexPath as NSIndexPath).row] == "comment" {
                
                // send related data to global variable
                commentuuid.append(uuidArray[(indexPath as NSIndexPath).row])
                commentowner.append(ownerArray[(indexPath as NSIndexPath).row])
                
                // go comments
                let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
                self.navigationController?.pushViewController(comment, animated: true)
            }
            
            
            // going to user followed current user
            if typeArray[(indexPath as NSIndexPath).row] == "follow" || typeArray[(indexPath as NSIndexPath).row] == "follow accepted" {
                
                guestname.append(cell.usernameLbl.text!)
                user = cell.usernameLbl.text!
                let profileUser = self.storyboard?.instantiateViewController(withIdentifier: "profileUserVC") as! profileUserVC
                self.navigationController?.pushViewController(profileUser, animated: true)
            }
            
            
            // going to liked post
            if typeArray[(indexPath as NSIndexPath).row] == "like" {
                
                // take post uuid
                postuuid.append(uuidArray[(indexPath as NSIndexPath).row])
                
                // go post
                let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
                self.navigationController?.pushViewController(post, animated: true)
            }
        }
    }
    
    @IBAction func followBtn_clicked(_ sender: UIButton) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = notificationsTableView.cellForRow(at: i) as! notificationCell
        
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
    
    // confirm request button clicked
    @IBAction func confirmBtn_clicked(_ sender: UIButton) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = requestsTableView.cellForRow(at: i) as! requestsCell
        
        // updated follow relationship
        let followerQuery = PFQuery(className: "follow")
        followerQuery.whereKey("following", equalTo: PFUser.current()!.username!)
        followerQuery.whereKey("follower", equalTo: cell.usernameLbl.text!)
        followerQuery.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object["accepted"] = true
                    object.saveInBackground(block: { (success, error) -> Void in
                        if success {
                            // create notification
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
                            newsObj["type"] = "follow accepted"
                            newsObj["checked"] = "no"
                            newsObj["firstname"] = PFUser.current()?.object(forKey: "firstname") as! String
                            newsObj["lastname"] = PFUser.current()?.object(forKey: "lastname") as! String
                            newsObj["private"] = PFUser.current()?.object(forKey: "private") as! Bool
                            newsObj.saveEventually()
                            
                            // delete follower request
                            let requestQuery = PFQuery(className: "request")
                            requestQuery.whereKey("to", equalTo: PFUser.current()!.username!)
                            requestQuery.whereKey("by", equalTo: cell.usernameLbl.text!)
                            requestQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                } else {
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            // fade out cell
                            self.requestUsernameArray.remove(at: (i as NSIndexPath).row)
                            self.requestAvaArray.remove(at: (i as NSIndexPath).row)
                            self.requestFirstnameArray.remove(at: (i as NSIndexPath).row)
                            self.requestLastnameArray.remove(at: (i as NSIndexPath).row)
                            self.requestsTableView.deleteRows(at: [i], with: .fade)
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    // deny request button clicked
    @IBAction func denyBtn_clicked(_ sender: UIButton) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = requestsTableView.cellForRow(at: i) as! requestsCell
        
        // delete follower request
        let requestQuery = PFQuery(className: "request")
        requestQuery.whereKey("to", equalTo: PFUser.current()!.username!)
        requestQuery.whereKey("by", equalTo: cell.usernameLbl.text!)
        requestQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
                
                // fade out cell
                self.requestUsernameArray.remove(at: (i as NSIndexPath).row)
                self.requestAvaArray.remove(at: (i as NSIndexPath).row)
                self.requestFirstnameArray.remove(at: (i as NSIndexPath).row)
                self.requestLastnameArray.remove(at: (i as NSIndexPath).row)
                self.requestsTableView.deleteRows(at: [i], with: .fade)
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
        // delete follower relationship
        let followerQuery = PFQuery(className: "follow")
        followerQuery.whereKey("following", equalTo: PFUser.current()!.username!)
        followerQuery.whereKey("follower", equalTo: cell.usernameLbl.text!)
        followerQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // reload after following user changed
    func reloadNotifications(_ notification:Notification) {
        getNotifications()
    }
    
    // reloading func after received notification
    func reload(_ notification:Notification) {
        showView()
        getRequests()
    }
}
