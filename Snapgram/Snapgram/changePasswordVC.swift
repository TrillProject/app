//
//  changePasswordVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/23/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


class changePasswordVC: UIViewController {

    @IBOutlet weak var currentTxt: UITextField!
    @IBOutlet weak var newTxt: UITextField!
    @IBOutlet weak var repeatTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Change Password"
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.currentTxt.frame.height))
        currentTxt.leftView = paddingView
        currentTxt.leftViewMode = UITextFieldViewMode.always
        
        let newPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.newTxt.frame.height))
        newTxt.leftView = newPaddingView
        newTxt.leftViewMode = UITextFieldViewMode.always
        
        let repeatPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.repeatTxt.frame.height))
        repeatTxt.leftView = repeatPaddingView
        repeatTxt.leftViewMode = UITextFieldViewMode.always
        
        saveBtn.frame.size.width = self.view.frame.size.width / 3
    }

    @IBAction func saveBtn_clicked(_ sender: UIButton) {
        let user = PFUser.current()!
        
        if (currentTxt.text!.isEmpty || newTxt.text!.isEmpty || repeatTxt.text!.isEmpty) {
            alert("Fields Empty", message: "Please fill out all fields")
            
        }
        
        if user.password != currentTxt.text {
            alert("Incorrect Current Password", message: "the password you entered is incorrect")
            return
        }
        
        if newTxt.text != repeatTxt.text {
            alert("Passwords Don't Match", message: "Please check that the new password you entered matches in both fields")
            return
        }
        
        // send data to server
        user.password = currentTxt.text
        
        user.saveInBackground (block: { (success, error) -> Void in
            if success{
                
                // send notification to settingsVC to be reloaded
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // alert message function
    func alert (_ error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}

