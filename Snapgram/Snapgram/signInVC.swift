//
//  signInVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


class signInVC: UIViewController {
    
    // textfield
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    // buttons
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    // variable to hold keyboard frame
    var keyboard = CGRect()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alignment
        label.frame = CGRect(x: 20, y: 120, width: self.view.frame.size.width - 40, height: 50)
        
        usernameTxt.frame = CGRect(x: 20, y: label.frame.origin.y + 70, width: self.view.frame.size.width - 40, height: 40)
        usernameTxt.layer.cornerRadius = usernameTxt.frame.size.height/2
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.usernameTxt.frame.height))
        usernameTxt.leftView = paddingView
        usernameTxt.leftViewMode = UITextFieldViewMode.always
        
        passwordTxt.frame = CGRect(x: 20, y: usernameTxt.frame.origin.y + 70, width: self.view.frame.size.width - 40, height: 40)
        passwordTxt.layer.cornerRadius = passwordTxt.frame.size.height/2
        let paddingViewPass = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTxt.frame.height))
        passwordTxt.leftView = paddingViewPass
        passwordTxt.leftViewMode = UITextFieldViewMode.always
        
        forgotBtn.frame = CGRect(x: 20, y: signInBtn.frame.origin.y + 134, width: self.view.frame.size.width - 50, height: 30)
        
        signInBtn.frame = CGRect(x: 20, y: passwordTxt.frame.origin.y + 70, width: self.view.frame.size.width / 3, height: 40)
        signInBtn.layer.cornerRadius = signInBtn.frame.size.height / 2
        
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 3 - 20, y: signInBtn.frame.origin.y, width: self.view.frame.size.width / 3, height: 40)
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.height / 2
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signInVC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(signInVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signInVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    // hide keyboard func
    func hideKeyboard(_ recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // func when keyboard is shown
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // define keyboard frame size
        keyboard = (((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
//            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboard.height / 2
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
//            self.scrollView.contentSize.height = 0
        })
    }
    
    
    // clicked sign in button
    @IBAction func signInBtn_click(_ sender: AnyObject) {
        print("sign in pressed")
        
        // hide keyboard
        self.view.endEditing(true)
        
        // if textfields are empty
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            
            // show alert message
            let alert = UIAlertController(title: "Please", message: "fill in fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        // login functions
        PFUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!) { (user, error) -> Void in
            if error == nil {
                
                // remember user or save in App Memeory did the user login or not
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login function from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            
            } else {
                
                // show alert message
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
}
