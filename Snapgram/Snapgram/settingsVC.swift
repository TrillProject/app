//
//  settingsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/19/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class settingsVC: UITableViewController {
    
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var privateAccountSwitch: UISwitch!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var deleteAccountBtn: UIButton!
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        
        tableView.tableFooterView = UIView()
        
        // icon colors
        let changePasswordImg = changePasswordBtn.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
        changePasswordBtn.setBackgroundImage(changePasswordImg, for: .normal)
        changePasswordBtn.tintColor = darkGrey
        
        if PFUser.current()?.object(forKey: "private") != nil, PFUser.current()?.object(forKey: "private") as? Bool == true {
            privateAccountSwitch.setOn(true, animated: false)
        } else {
            privateAccountSwitch.setOn(false, animated: false)
        }
    }
    
    // clicked log out
    @IBAction func logout_clicked(_ sender: UIButton) {
        
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil {
                
                // remove logged in user from App memory
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signin = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! signInVC
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
            }
        }
    }
    
    @IBAction func back_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAccount_clicked(_ sender: UIButton) {
        // Declare Alert
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to Delete your account?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button clicked")
            
            PFUser.current()?.deleteInBackground(block: { (success, error) -> Void in
            
                if success {
                    let signin = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! signInVC
                    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = signin
                } else {
                    print(error ?? "Account deletion failed")
                }
            })
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button clicked")
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @IBAction func privateAccount_switched(_ sender: UISwitch) {
        let user = PFUser.current()!
        if sender.isOn {
            user["private"] = true
        } else {
            user["private"] = false
        }
        user.saveInBackground (block: { (success, error) -> Void in
            if success{
               print("account privacy changed successfully")
            } else {
                print(error!.localizedDescription)
            }
        })
    }
}
