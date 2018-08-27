//
//  tabbarVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


// global variables of icons
var icons = UIScrollView()
var dot = UIView()
var hasNotifications = false
var hasRequests = false

// custom tabbar button
let tabBarPostButton = UIButton()

class tabbarVC: UITabBarController, UITabBarControllerDelegate {
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        // color of item
        self.tabBar.tintColor = mainColor
        
        // color of background
        self.tabBar.barTintColor = UIColor.white
        
        // disable translucent
        self.tabBar.isTranslucent = false
        
        // create total icons
        icons.frame = CGRect(x: self.view.frame.size.width / 5 * 3 + 10, y: self.view.frame.size.height - self.tabBar.frame.size.height * 2 - 3, width: 50, height: 35)
        self.view.addSubview(icons)
        
        // create notification dot
        dot.frame = CGRect(x: self.view.frame.size.width / 5 * 3, y: self.view.frame.size.height - 6, width: 9, height: 9)
        dot.center.x = self.view.frame.size.width / 5 * 3 + (self.view.frame.size.width / 5) / 2
        dot.backgroundColor = redColor
        dot.layer.cornerRadius = dot.frame.size.width / 2
        dot.isHidden = true
        self.view.addSubview(dot)
        
        checkNotifications()
        
        // receive notification from notificationsVC
        NotificationCenter.default.addObserver(self, selector: #selector(tabbarVC.hideDot(_:)), name: NSNotification.Name(rawValue: "checkedNotifications"), object: nil)
        
    }
    
    // check if there are any notifications or requests
    func checkNotifications() {
        let query = PFQuery(className: "news")
        let requestQuery = PFQuery(className: "request")
        if PFUser.current() != nil {
            query.whereKey("to", equalTo: PFUser.current()!.username!)
            query.whereKey("checked", equalTo: "no")
            query.countObjectsInBackground (block: { (count, error) -> Void in
                if error == nil {
                    if count > 0 {
                        hasNotifications = true
                    } else {
                        hasNotifications = false
                    }
                    
                    requestQuery.whereKey("to", equalTo: PFUser.current()!.username!)
                    requestQuery.whereKey("checked", equalTo: "no")
                    requestQuery.countObjectsInBackground (block: { (count, error) -> Void in
                        if error == nil {
                            if count > 0 {
                                hasRequests = true
                            } else {
                                hasRequests = false
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                        
                        if hasNotifications || hasRequests {
                            dot.isHidden = false
                        } else {
                            dot.isHidden = true
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            print("no current user")
        }
    }
    
    func hideDot(_ notification:Notification) {
        if hasNotifications || hasRequests {
            dot.isHidden = false
        } else {
            dot.isHidden = true
        }
    }
    
    
    // clicked upload button (go to upload)
    func upload(_ sender : UIButton) {
        self.selectedIndex = 2
    }
    
    // clicked on profile tab
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController is navVC {
            let firstVC = viewController.childViewControllers[0]
            if firstVC is profileVC{
                user = PFUser.current()!.username!
            }
        }
    }
    
}
