//
//  MessagesViewController.swift
//  Snapgram
//
//  Created by Anita Onyimah on 3/14/19.
//  Copyright © 2019 Trill. All rights reserved.
//

/* import UIKit
import Parse

class MessagesViewController: UITableViewController, UIActionSheetDelegate, SelectSingleViewControllerDelegate {
        var messages = [PFObject]()
        @IBOutlet var composeButton: UIBarButtonItem!
        @IBOutlet var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.defaultCenter().addObserver(self, selector: "cleanup", name: NOTIFICATION_USER_LOGGED_OUT, object: nil)
        
        NotificationCenter.defaultCenter().addObserver(self, selector: "loadMessages", name: "reloadMessages", object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "loadMessages", forControlEvents: UIControlEvents.valueChanged)
        self.tableView?.addSubview(self.refreshControl!)
        
        self.emptyView?.isHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() != nil {
            self.loadMessages()
        } else {
            Utilities.loginUser(self)
        }
    }
    
    func loadMessages() {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_USER, equalTo: PFUser.currentUser()!)
        query.includeKey(PF_MESSAGES_LASTUSER)
        query.orderByDescending(PF_MESSAGES_UPDATEDACTION)
        query.findObjectsInBackgroundWithBlock{ (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.messages.removeAll(keepCapacity: false)
                self.messages += objects as! [PFObject]!
                self.tableView.reloadData()
                self.updateEmptyView()
                self.updateTabCounter()
            } else {
                ProgressHUD.showError("Network error")
            }
            self.refreshControl!.endRefreshing()
        }
    }
    
    func updateEmptyView() {
        self.emptyView?.hidden = (self.messages.count != 0)
    }
    
    func updateTabCounter() {
        var total = 0
        for message in self.messages {
            total += message[PF_MESSAGES_COUNTER]!.integerValue
        }
        var item = self.tabBarController!.tabBar.items![1] as! UITabBarItem
        item.badgeValue = (total == 0) ? nil : "\(total)"
    }
    
    // MARK: - User actions
    
    func openChat(groupId: String) {
        self.performSegueWithIdentifier("messagesChatSegue", sender: groupId)
    }
    
    func cleanup() {
        self.messages.removeAll(keepCapacity: false)
        self.tableView.reloadData()
        self.updateTabCounter()
        self.updateEmptyView()
    }
    
    @IBAction func compose(sender: UIBarButtonItem) {
        var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Single recipient")
        actionSheet.showFromTabBar(self.tabBarController!.tabBar)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messagesChatSegue" {
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            let groupId = sender as! String
            chatVC.groupId = groupId
        } else if segue.identifier == "selectSingleSegue" {
            let selectSingleVC = segue.destinationViewController.topViewController as! SelectSingleViewController
            selectSingleVC.delegate = self
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch buttonIndex {
            case 1:
                self.performSegueWithIdentifier("selectSingleSegue", sender: self)
            default:
                return
        }
        }
    }
    
    func didSelectSingleUser(user2: PFUser) {
        let user1 = PFUser.currentUser()!
        let groupId = Messages.startPrivateChat(user1, user2: user2)
        self.openChat(groupId)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("messagesCell") as! MessagesCell
        cell.bindData(self.messages[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        Messages.deleteMessageItem(self.messages[indexPath.row])
        self.messages.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.updateEmptyView()
        self.updateTabCounter()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let message = self.messages[indexPath.row] as PFObject
        self.openChat(message[PF_MESSAGES_GROUPID] as! String)
    }
} */
