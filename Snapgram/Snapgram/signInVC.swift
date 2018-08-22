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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backgroundShape: UIView!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    @IBOutlet weak var mailBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    
    @IBOutlet weak var signUpBtnBottomSpace: NSLayoutConstraint!
    
    // variable to hold keyboard frame
    private var keyboard = CGRect()
    private var keyboardVisible = false
    private var bottomScrollOffset = CGFloat(0)
    
    private var loginType = 0
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.usernameTxt.frame.height))
        usernameTxt.leftView = paddingView
        usernameTxt.leftViewMode = UITextFieldViewMode.always
        
        usernameTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        let paddingViewPass = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTxt.frame.height))
        passwordTxt.leftView = paddingViewPass
        passwordTxt.leftViewMode = UITextFieldViewMode.always
        
        passwordTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signInVC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(signInVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signInVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        facebookBtn.alpha = 0.5
        
//        backgroundShape.cornerRadius = backgroundShape.frame.size.width / 2
    }
    
    @IBAction func mailBtn_clicked(_ sender: UIButton) {
        sender.alpha = 1.0
        facebookBtn.alpha = 0.5
        loginType = 0
        usernameTxt.text = ""
        passwordTxt.text = ""
    }
    
    @IBAction func facebookBtn_clicked(_ sender: UIButton) {
        sender.alpha = 1.0
        mailBtn.alpha = 0.5
        loginType = 1
        usernameTxt.text = ""
        passwordTxt.text = ""
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
            if !self.keyboardVisible {
                self.signUpBtnBottomSpace.constant = self.signUpBtnBottomSpace.constant + self.keyboard.height
                self.bottomScrollOffset = self.scrollView.contentSize.height + self.keyboard.height - self.scrollView.bounds.size.height
            }
            
            if self.bottomScrollOffset > 0 {
                if self.usernameTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.usernameTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.usernameTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                
                } else if self.passwordTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.passwordTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.passwordTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                }
            } else if self.usernameTxt.isFirstResponder || self.passwordTxt.isFirstResponder {
                self.keyboardVisible = true
            }
            
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.keyboardVisible = false
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.signUpBtnBottomSpace.constant = self.signUpBtnBottomSpace.constant - self.keyboard.height
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
        if loginType == 0 {
            // login with email
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
        } else {
            //login with facebook
        }
    }
    
}
