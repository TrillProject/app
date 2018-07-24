//
//  resetPasswordVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


class resetPasswordVC: UIViewController {

    // textfield
    @IBOutlet weak var emailTxt: UITextField!
    
    // buttons
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alignment
        emailTxt.frame = CGRect(x: 20, y: 190, width: self.view.frame.size.width - 40, height: 40)
        emailTxt.layer.cornerRadius = emailTxt.frame.size.height/2
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTxt.frame.height))
        emailTxt.leftView = paddingView
        emailTxt.leftViewMode = UITextFieldViewMode.always
        
        resetBtn.frame = CGRect(x: 20, y: emailTxt.frame.origin.y + 70, width: self.view.frame.size.width / 3, height: 40)
        resetBtn.layer.cornerRadius = resetBtn.frame.size.height / 2
        
        cancelBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 3 - 20, y: resetBtn.frame.origin.y, width: self.view.frame.size.width / 3, height: 40)
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.height / 2
        
    }
    
    
    // clicked reset button
    @IBAction func resetBtn_click(_ sender: AnyObject) {
        
        // hide keyboard
        self.view.endEditing(true)
        
        // email textfield is empty
        if emailTxt.text!.isEmpty {
            
            // show alert message
            let alert = UIAlertController(title: "Email field", message: "is empty", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        // request for reseting password
        PFUser.requestPasswordResetForEmail(inBackground: emailTxt.text!) { (success, error) -> Void in
            if success {
                
                // show alert message
                let alert = UIAlertController(title: "Email for reseting password", message: "has been sent to texted email", preferredStyle: UIAlertControllerStyle.alert)
                
                // if pressed OK call self.dismiss.. function
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    
    // clicked cancel button
    @IBAction func cancelBtn_click(_ sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
