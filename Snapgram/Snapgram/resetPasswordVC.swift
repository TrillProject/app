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

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var backgroundShape: UIView!
    
    // textfield
    @IBOutlet weak var emailTxt: UITextField!
    
    // buttons
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var resetBtnBottomSpace: NSLayoutConstraint!
    
    // variable to hold keyboard frame
    private var keyboard = CGRect()
    private var keyboardVisible = false
    private var bottomScrollOffset = CGFloat(0)
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTxt.frame.height))
        emailTxt.leftView = paddingView
        emailTxt.leftViewMode = UITextFieldViewMode.always
        
        emailTxt.setBottomBorder(color: mainColor, height: 2.0)
        
//        backgroundShape.cornerRadius = backgroundShape.frame.size.width / 2
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(resetPasswordVC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(resetPasswordVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetPasswordVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
                self.resetBtnBottomSpace.constant = self.resetBtnBottomSpace.constant + self.keyboard.height
                self.bottomScrollOffset = self.scrollView.contentSize.height + self.keyboard.height - self.scrollView.bounds.size.height
            }
            
            if self.emailTxt.isFirstResponder {
                if self.bottomScrollOffset > 0 {
                    if self.bottomScrollOffset > self.emailTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.emailTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                }
                self.keyboardVisible = true
            }
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.keyboardVisible = false
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.resetBtnBottomSpace.constant = self.resetBtnBottomSpace.constant - self.keyboard.height
        })
    }
    
    
    // clicked cancel button
    @IBAction func cancelBtn_click(_ sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
