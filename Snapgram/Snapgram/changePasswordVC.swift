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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentTxt: UITextField!
    @IBOutlet weak var newTxt: UITextField!
    @IBOutlet weak var repeatTxt: UITextField!
    
    @IBOutlet weak var repeatTxtBottomSpace: NSLayoutConstraint!
    
    // value to hold keyboard frame size
    private var keyboard = CGRect()
    private var keyboardVisible = false
    private var bottomScrollOffset = CGFloat(0)
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Change Password"
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(changePasswordVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changePasswordVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(changePasswordVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        currentTxt.setBottomBorder(color: mainColor, height: 2.0)
        newTxt.setBottomBorder(color: mainColor, height: 2.0)
        repeatTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.currentTxt.frame.height))
        currentTxt.leftView = paddingView
        currentTxt.leftViewMode = UITextFieldViewMode.always
        
        let newPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.newTxt.frame.height))
        newTxt.leftView = newPaddingView
        newTxt.leftViewMode = UITextFieldViewMode.always
        
        let repeatPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.repeatTxt.frame.height))
        repeatTxt.leftView = repeatPaddingView
        repeatTxt.leftViewMode = UITextFieldViewMode.always
    }
    
    @IBAction func saveBtn_clicked(_ sender: UIBarButtonItem) {
        
        if (currentTxt.text!.isEmpty || newTxt.text!.isEmpty || repeatTxt.text!.isEmpty) {
            alert("Fields Empty", message: "Please fill out all fields")
            
        }
        
        PFUser.logInWithUsername(inBackground: PFUser.current()!.email!, password: currentTxt.text!) { (user, error) in
            if error == nil {
                
                if self.newTxt.text != self.repeatTxt.text {
                    self.alert("Passwords Don't Match", message: "Please check that the new password you entered matches in both fields")
                    return
                }
                
                // send data to server
                user!.password = self.newTxt.text
                
                user!.saveInBackground (block: { (success, error) -> Void in
                    if success{
                        
                        print("password changed successfully")
                        
                        self.view.endEditing(true)
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            } else {
                self.alert("Incorrect Current Password", message: "the password you entered is incorrect")
                return
            }
        }
    }
    
    // func to hide keyboard
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    // func when keyboard is shown
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // define keyboard frame size
        keyboard = (((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            if !self.keyboardVisible {
                self.repeatTxtBottomSpace.constant = self.repeatTxtBottomSpace.constant + self.keyboard.height
                self.bottomScrollOffset = self.scrollView.contentSize.height + self.keyboard.height - self.scrollView.bounds.size.height
            }
            
            if self.bottomScrollOffset > 0 {
                if self.currentTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.currentTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.currentTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                    
                } else if self.newTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.newTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.newTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                    
                } else if self.repeatTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.repeatTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.repeatTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                }
            } else if self.currentTxt.isFirstResponder || self.newTxt.isFirstResponder || self.repeatTxt.isFirstResponder {
                self.keyboardVisible = true
            }
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.keyboardVisible = false
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.repeatTxtBottomSpace.constant = self.repeatTxtBottomSpace.constant - self.keyboard.height
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

