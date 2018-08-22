//
//  signUp2VC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/15/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import Foundation

import UIKit
import Parse

class signUp2VC: UIViewController {

    var firstname = ""
    var lastname = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var signUpBtnBottomSpace: NSLayoutConstraint!
    
    // variable to hold keyboard frame
    private var keyboard = CGRect()
    private var keyboardVisible = false
    private var bottomScrollOffset = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTxt.frame.height))
        emailTxt.leftView = paddingView
        emailTxt.leftViewMode = UITextFieldViewMode.always
        emailTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        let paddingViewPass = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTxt.frame.height))
        passwordTxt.leftView = paddingViewPass
        passwordTxt.leftViewMode = UITextFieldViewMode.always
        passwordTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        let paddingViewRepeat = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.repeatPasswordTxt.frame.height))
        repeatPasswordTxt.leftView = paddingViewRepeat
        repeatPasswordTxt.leftViewMode = UITextFieldViewMode.always
        repeatPasswordTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signUp2VC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(signUp2VC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signUp2VC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    // regex restrictions for email textfield
    func validateEmail (_ email : String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{2}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // check if username is already taken
    func validateUsername (_ username : String) {
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                if (objects!.count > 0){
                    self.alert("Invalid Email", message: "There is already an account with the provided email address")
                }
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
    
    @IBAction func signUpBtn_clicked(_ sender: UIButton) {
        
        print("sign up pressed")
        
        // dismiss keyboard
        self.view.endEditing(true)
        
        // if fields are empty
        if (emailTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty) {
            alert("Empty Fields", message: "Please fill out all fields")
            return
        }
        
        // validate that email is not already taken
        validateUsername(emailTxt.text!)
        
        // if incorrect email according to regex
        if !validateEmail(emailTxt.text!) {
            alert("Incorrect Email", message: "Please provide correctly formatted email address")
            return
        }
        
        // if different passwords
        if passwordTxt.text != repeatPasswordTxt.text {
            alert("Passwords Don't Match", message: "Please check that the password you entered matches in both fields")
            return
        }
        
        // send data to server to related columns
        let user = PFUser()
        user.username = emailTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        user["firstname"] = firstname
        user["lastname"] = lastname
        user["private"] = false
        let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        let coverData = UIImagePNGRepresentation(UIImage(named: "transparent")!)
        let coverFile = PFFile(name: "cover.png", data: coverData!)
        user["cover"] = coverFile
        
        // save data in server
        user.signUpInBackground { (success, error) -> Void in
            if success {
                print("registered")
                
                // remember logged user
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login func from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            } else {
                self.alert("Error", message: error!.localizedDescription)
            }
        }
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
                if self.emailTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.emailTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.emailTxt.frame.origin.y - 20), animated: true)
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
                    
                } else if self.repeatPasswordTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.repeatPasswordTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.repeatPasswordTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                }
            } else if self.emailTxt.isFirstResponder || self.passwordTxt.isFirstResponder || self.repeatPasswordTxt.isFirstResponder {
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
    
    @IBAction func backBtn_clicked(_ sender: UIButton) {
        
        // hide keyboard
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
