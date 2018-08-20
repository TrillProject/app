//
//  commentVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


var commentuuid = [String]()
var commentowner = [String]()

class commentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // UI objects
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    var refresher = UIRefreshControl()
    
    @IBOutlet weak var mentionsTableView: UITableView! {
        didSet {
            mentionsTableView.dataSource = self
            mentionsTableView.delegate = self
        }
    }
    
    // values for reseting UI to default
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var mentionsArray = [[String]]()
    var dateArray = [Date?]()
    var firstnameArray = [String]()
    var lastnameArray = [String]()
    
    var mentions = [String]()
    private var currentCommentTxt = [Character]()
    
    @IBOutlet weak var commentContainerBottomSpace: NSLayoutConstraint!
    
    var mentionUsernameArray = [String]()
    var mentionAvaArray = [PFFile]()
    var mentionFirstnameArray = [String]()
    var mentionLastnameArray = [String]()
    
    private var isMentioningUser = false
    private var mentioningUser = ""
    private var diffIndex = 0
    private var spacesCount = 0
    
    // variable to hold keyboard frame
    var keyboard = CGRect()
    
    // page size
    var page : Int32 = 15
    

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "Comments"
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "prev"), style: .plain, target: self, action: #selector(commentVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(commentVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // catch notification if the keyboard is shown or hidden
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(commentVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.tableView.isUserInteractionEnabled = true
        self.tableView.addGestureRecognizer(hideTap)
        
        // disable button from the beginning
        sendBtn.isEnabled = false
        
        // call functions
        alignment()
        loadComments()
        
        mentionsTableView.isHidden = true
    }
    
    
    // preload func
    override func viewWillAppear(_ animated: Bool) {

        // hide bottom bar
        self.tabBarController?.tabBar.isHidden = false
        
        // hide custom tabbar button
        tabBarPostButton.isHidden = false
    }
    
    
    // postload func - launches when we about to live current VC
    override func viewWillDisappear(_ animated: Bool) {
        
        // unhide tabbar
        self.tabBarController?.tabBar.isHidden = false
        
        // unhide custom tabbar button
        tabBarPostButton.isHidden = false
    }
    
    
    // func loading when keyboard is shown
    func keyboardWillShow(notification: NSNotification) {
        
        // define keyboard frame size
        keyboard = ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue)!
        
        // move UI up
        UIView.animate (withDuration: 0.4) { () -> Void in
            self.commentContainerBottomSpace.constant = self.commentContainerBottomSpace.constant + self.keyboard.height
        }
    }
    
    
    // func loading when keyboard is hidden
    func keyboardWillHide(_ notification : Notification) {
        
        // move UI down
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.commentContainerBottomSpace.constant = self.commentContainerBottomSpace.constant - self.keyboard.height
            self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        })
    }
    
    
    // alignment function
    func alignment() {
        
        // delegates
        commentTxt.delegate = self
        
        commentTxt.text! = "Write something..."
        commentTxt.textColor = mediumGrey

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == mediumGrey {
            textView.text = ""
            textView.textColor = darkGrey
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write something..."
            textView.textColor = mediumGrey
        }
    }
    
    // while writing something
    func textViewDidChange(_ textView: UITextView) {
        
        // disable button if entered no text
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTxt.text.trimmingCharacters(in: spacing).isEmpty {
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
        
        // + paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            
            // find difference to add
            let difference = textView.contentSize.height - textView.frame.size.height
            
            // redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            // move up tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
        
        // - paragraph
        else if textView.contentSize.height < textView.frame.size.height {
            
            // find difference to deduct
            let difference = textView.frame.size.height - textView.contentSize.height
            
            // redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            // move down tableViwe
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
        
        let newTxt = Array(textView.text!)
        var found = false
        var isLastCharacter = true
        spacesCount = 0
        if currentCommentTxt.count > newTxt.count {
            // deleted a character
            var deletedChar : Character!
            for i in 0 ..< newTxt.count {
                if currentCommentTxt[i] != newTxt[i] {
                    isLastCharacter = false
                    deletedChar = currentCommentTxt[i]
                    diffIndex = i
                }
            }
            if isLastCharacter {
                deletedChar = currentCommentTxt[currentCommentTxt.count - 1]
                diffIndex = currentCommentTxt.count - 1
            }
            
        } else {
            // inserted a character
            var newChar : Character!
            let prevIndex = diffIndex
            for i in 0 ..< currentCommentTxt.count {
                if !found {
                    if currentCommentTxt[i] != newTxt[i] {
                        isLastCharacter = false
                        newChar = newTxt[i]
                        diffIndex = i
                        found = true
                    }
                    if newTxt[i] == " " {
                        spacesCount += 1
                    }
                }
            }
            if isLastCharacter {
                newChar = newTxt[newTxt.count - 1]
                diffIndex = newTxt.count - 1
            }
            if newChar == "@" {
                isMentioningUser = true
                loadUsers(mentioningUser)
                mentionsTableView.isHidden = false
            } else if newChar == " " {
                mentionsTableView.isHidden = true
                self.isMentioningUser = false
                self.mentioningUser = ""
                self.diffIndex = 0
                self.spacesCount = 0
            }
            if isMentioningUser && diffIndex == prevIndex + 1 {
                mentioningUser = mentioningUser + String(newChar!)
                loadUsers(mentioningUser)
            }
        }
        
        
        currentCommentTxt = newTxt
    }
    
    
    // load comments function
    func loadComments() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
            // if comments on the server for current post are more than (page size 15), implement pull to refresh func
            if self.page < count {
                self.refresher.addTarget(self, action: #selector(commentVC.loadMore), for: UIControlEvents.valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            // STEP 2. Request last (page size 15) comments
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    self.firstnameArray.removeAll(keepingCapacity: false)
                    self.lastnameArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.usernameArray.append(object.object(forKey: "username") as! String)
                        self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                        self.commentArray.append(object.object(forKey: "comment") as! String)
                        self.dateArray.append(object.createdAt)
                        
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
                        
                        self.tableView.reloadData()
                        
                        // scroll to bottom
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                    }
                } else {
                    print(error?.localizedDescription)
                }
            })
        })
        
    }
    
    
    // pagination
    func loadMore() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
            // self refresher
            self.refresher.endRefreshing()
            
            // remove refresher if loaded all comments
            if self.page >= count {
                self.refresher.removeFromSuperview()
            }
            
            // STEP 2. Load more comments
            if self.page < count {
                
                // increase page to load 30 as first paging
                self.page = self.page + 15
                
                // request existing comments from the server
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        self.firstnameArray.removeAll(keepingCapacity: false)
                        self.lastnameArray.removeAll(keepingCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.commentArray.append(object.object(forKey: "comment") as! String)
                            self.dateArray.append(object.createdAt)
                            
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
                            
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                })
            }
            
        })
        
    }
    
    
    // clicked send button
    @IBAction func sendBtn_click(_ sender: AnyObject) {
        
        // STEP 1. Add row in tableView
        usernameArray.append(PFUser.current()!.username!)
        avaArray.append(PFUser.current()?.object(forKey: "ava") as! PFFile)
        dateArray.append(Date())
        commentArray.append(commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        mentionsArray.append(mentions)
        firstnameArray.append(PFUser.current()?.object(forKey: "firstname") as! String)
        lastnameArray.append(PFUser.current()?.object(forKey: "lastname") as! String)
        tableView.reloadData()
        
        // STEP 2. Send comment to server
        let commentObj = PFObject(className: "comments")
        commentObj["to"] = commentuuid.last
        commentObj["username"] = PFUser.current()?.username
        commentObj["ava"] = PFUser.current()?.value(forKey: "ava")
        commentObj["firstname"] = PFUser.current()?.value(forKey: "firstname")
        commentObj["lastname"] = PFUser.current()?.value(forKey: "lastname")
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObj["mentions"] = mentions
        commentObj.saveEventually()
        
        // STEP 3. Send #hashtag to server
        let words:[String] = commentTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // define tagged word
        for var word in words {
            
            // save #hasthag in server
            if word.hasPrefix("#") {
                
                // cut symbol
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = commentuuid.last
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = commentTxt.text
                hashtagObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        
        // STEP 4. Send notification as @mention
        var mentionCreated = Bool()
        
//        for var word in words {
//
//            // check @mentions for user
//            if word.hasPrefix("@") {
//
//                // cut symbols
//                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
//                word = word.trimmingCharacters(in: CharacterSet.symbols)
//
//                let newsObj = PFObject(className: "news")
//                newsObj["by"] = PFUser.current()?.username
//                newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
//                newsObj["to"] = word
//                newsObj["owner"] = commentowner.last
//                newsObj["uuid"] = commentuuid.last
//                newsObj["type"] = "mention"
//                newsObj["checked"] = "no"
//                newsObj.saveEventually()
//                mentionCreated = true
//            }
//        }
        
        for word in mentions {
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.current()?.username
            newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
            newsObj["to"] = word
            newsObj["owner"] = commentowner.last
            newsObj["uuid"] = commentuuid.last
            newsObj["type"] = "mention"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
            mentionCreated = true
        }
        
        // STEP 5. Send notification as comment
        if commentowner.last != PFUser.current()?.username && mentionCreated == false {
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.current()?.username
            newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
            newsObj["to"] = commentowner.last
            newsObj["owner"] = commentowner.last
            newsObj["uuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
        
        
        // STEP 6. Reset UI
        sendBtn.isEnabled = false
        commentTxt.text = ""
        self.view.endEditing(true)
        
        // scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        
        mentions.removeAll()
        diffIndex = 0
    }
    
    
    func loadUsers(_ typedUsername : String) {
        let query = PFQuery(className: "_User")
        query.whereKey("firstname", hasPrefix: typedUsername)
        query.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.mentionUsernameArray.removeAll(keepingCapacity: false)
                self.mentionAvaArray.removeAll(keepingCapacity: false)
                self.mentionFirstnameArray.removeAll(keepingCapacity: false)
                self.mentionLastnameArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.mentionUsernameArray.append(object.object(forKey: "username") as! String)
                    
                    if object.object(forKey: "firstname") != nil {
                        self.mentionFirstnameArray.append((object.object(forKey: "firstname") as! String).capitalized)
                    } else {
                        self.mentionFirstnameArray.append((object.object(forKey: "username") as! String).capitalized)
                    }
                    
                    if object.object(forKey: "lastname") != nil {
                        self.mentionLastnameArray.append((object.object(forKey: "lastname") as! String).capitalized)
                    } else {
                        self.mentionLastnameArray.append("")
                    }
                    
                    if object.object(forKey: "ava") == nil {
                        let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                        self.mentionAvaArray.append(avaFile!)
                    } else {
                        self.mentionAvaArray.append(object.object(forKey: "ava") as! PFFile)
                    }
                }
                self.mentionsTableView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    
    // TABLEVIEW
    // cell numb
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return commentArray.count
        } else {
            return mentionUsernameArray.count
        }
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
        
            // declare cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! commentCell
            
            cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]
            if lastnameArray[(indexPath as NSIndexPath).row] == "" {
                cell.usernameBtn.setTitle(usernameArray[(indexPath as NSIndexPath).row], for: UIControlState())
            } else {
                cell.usernameBtn.setTitle(firstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + lastnameArray[(indexPath as NSIndexPath).row].capitalized, for: UIControlState())
            }
            cell.usernameBtn.sizeToFit()
            cell.commentLbl.text = commentArray[(indexPath as NSIndexPath).row]
            cell.commentLbl.sizeToFit()
            avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                cell.avaImg.image = UIImage(data: data!)
            }
            
            // calculate date
            let from = dateArray[(indexPath as NSIndexPath).row]
            let now = Date()
            let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
            let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
            
            if difference.second! <= 0 {
                cell.dateLbl.text = "now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                cell.dateLbl.text = "\(difference.second!)s"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                cell.dateLbl.text = "\(difference.minute!)m"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                cell.dateLbl.text = "\(difference.hour!)h"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                cell.dateLbl.text = "\(difference.day!)d"
            }
            if difference.weekOfMonth! > 0 {
                cell.dateLbl.text = "\(difference.weekOfMonth!)w"
            }
            
            
            // @mention is tapped
            cell.commentLbl.userHandleLinkTapHandler = { label, handle, rang in
                
                let words:[String] = self.commentArray[(indexPath as NSIndexPath).row].components(separatedBy: CharacterSet.whitespacesAndNewlines)
                var mentionIndex = 0
                for i in 0 ..< words.count {
                    if words[i] == handle {
                        mentionIndex = i
                    }
                }
                
                // if tapped on @currentUser go home, else go guest
                if self.mentionsArray[(indexPath as NSIndexPath).row][mentionIndex] == PFUser.current()?.username {
                    user = PFUser.current()!.username!
                    let profile = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! profileVC
                    self.navigationController?.pushViewController(profile, animated: true)
                } else {
                    guestname.append(self.mentionsArray[(indexPath as NSIndexPath).row][mentionIndex])
                    user = self.mentionsArray[(indexPath as NSIndexPath).row][mentionIndex]
                    let profileUser = self.storyboard?.instantiateViewController(withIdentifier: "profileUserVC") as! profileUserVC
                    self.navigationController?.pushViewController(profileUser, animated: true)
                }
            }
            
            // #hashtag is tapped
            cell.commentLbl.hashtagLinkTapHandler = { label, handle, range in
                var mention = handle
                mention = String(handle.suffix(1))
                hashtag.append(mention.lowercased())
                let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
                self.navigationController?.pushViewController(hashvc, animated: true)
            }
            
            
            // assign indexes of buttons
            cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
            
            return cell
        } else {
            let cell = mentionsTableView.dequeueReusableCell(withIdentifier: "Mention Cell", for: indexPath) as! mentionCell
            cell.usernameLbl.text = mentionUsernameArray[(indexPath as NSIndexPath).row]
            cell.nameLbl.text = mentionFirstnameArray[(indexPath as NSIndexPath).row].capitalized + " " + mentionLastnameArray[(indexPath as NSIndexPath).row].capitalized
            mentionAvaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                cell.avaImg.image = UIImage(data: data!)
            }
            return cell
        }
    }
    
    // selected row in table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == mentionsTableView {
            let words:[String] = commentTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            var editedTxt = ""
            var found = false
            var mentionsCount = 0
            for i in 0 ..< words.count {
                if i == spacesCount {
                    editedTxt += "@" + self.mentionFirstnameArray[(indexPath as NSIndexPath).row] + " "
                    found = true
                } else {
                    editedTxt += words[i] + " "
                }
                if !found && words[i].hasPrefix("@") {
                    mentionsCount += 1
                }
            }
            self.commentTxt.text = editedTxt
            self.currentCommentTxt = Array(editedTxt)
            self.mentions.insert(self.mentionUsernameArray[(indexPath as NSIndexPath).row], at: mentionsCount)
            self.mentionsTableView.isHidden = true
            self.isMentioningUser = false
            self.mentioningUser = ""
            self.diffIndex = 0
            self.spacesCount = 0
        }
    }
    
    // clicked username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of current button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! commentCell
        
        // if user tapped on his username go home, else go guest
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
    
    
    // cell editabily
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // swipe cell for actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if tableView == self.tableView {
        
            // call cell for calling further cell data
            let cell = tableView.cellForRow(at: indexPath) as! commentCell
            
            // ACTION 1. Delete
            let delete = UITableViewRowAction(style: .normal, title: "    ") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
                
                // STEP 1. Delete comment from server
                let commentQuery = PFQuery(className: "comments")
                commentQuery.whereKey("to", equalTo: commentuuid.last!)
                commentQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
                commentQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                    if error == nil {
                        // find related objects
                        for object in objects! {
                            object.deleteEventually()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
                // STEP 2. Delete #hashtag from server
                let hashtagQuery = PFQuery(className: "hashtags")
                hashtagQuery.whereKey("to", equalTo: commentuuid.last!)
                hashtagQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
                hashtagQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
                hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                    for object in objects! {
                        object.deleteEventually()
                    }
                })
                
                // STEP 3. Delete notification: mention comment
                let newsQuery = PFQuery(className: "news")
                newsQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
                newsQuery.whereKey("to", equalTo: commentowner.last!)
                newsQuery.whereKey("uuid", equalTo: commentuuid.last!)
                newsQuery.whereKey("type", containedIn: ["comment", "mention"])
                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        for object in objects! {
                            object.deleteEventually()
                        }
                    }
                })
                
                
                // close cell
                tableView.setEditing(false, animated: true)
                
                // STEP 3. Delete comment row from tableView
                self.commentArray.remove(at: (indexPath as NSIndexPath).row)
                self.dateArray.remove(at: (indexPath as NSIndexPath).row)
                self.usernameArray.remove(at: (indexPath as NSIndexPath).row)
                self.avaArray.remove(at: (indexPath as NSIndexPath).row)
                self.firstnameArray.remove(at: (indexPath as NSIndexPath).row)
                self.lastnameArray.remove(at: (indexPath as NSIndexPath).row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // ACTION 2. Mention or address message to someone
            let address = UITableViewRowAction(style: .normal, title: "    ") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
                
                // include username in textView
                self.commentTxt.becomeFirstResponder()
                self.commentTxt.text = "\(self.commentTxt.text + "@" + self.firstnameArray[(indexPath as NSIndexPath).row].capitalized)"
                self.mentions.append(self.usernameArray[(indexPath as NSIndexPath).row])
                
                // enable button
                self.sendBtn.isEnabled = true
                
                // close cell
                tableView.setEditing(false, animated: true)
            }
            
            // ACTION 3. Complain
            let complain = UITableViewRowAction(style: .normal, title: "    ") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
                
                // send complain to server regarding selected comment
                let complainObj = PFObject(className: "complain")
                complainObj["by"] = PFUser.current()?.username
                complainObj["to"] = cell.commentLbl.text
                complainObj["owner"] = cell.usernameBtn.titleLabel?.text
                complainObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        self.alert("Complaint has been made successfully", message: "Thank You! We will consider your complaint")
                    } else {
                        self.alert("Error", message: error!.localizedDescription)
                    }
                })
                
                // close cell
                tableView.setEditing(false, animated: true)
            }
            
            // buttons background
            delete.backgroundColor = redColor
            delete.title = "Delete"
            address.backgroundColor = mediumGrey
            address.title = "Reply"
            complain.backgroundColor = redColor
            complain.title = "Report"
            
            // comment belongs to user
            if cell.usernameLbl.text == PFUser.current()?.username {
                return [delete]
            }
            
            // post belongs to user
            else if commentowner.last == PFUser.current()?.username {
                return [delete]
            }
            
            // post belongs to another user
            else  {
                return [address, complain]
            }
        } else {
            return nil
        }
    }
    
    // func to hide keyboard
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // alert action
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    // go back
    func back(_ sender : UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewController(animated: true)
        
        // clean comment uui from last holding infromation
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        
        // clean comment owner from last holding infromation
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
    }

}
