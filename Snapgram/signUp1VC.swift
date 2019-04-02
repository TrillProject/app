//
//  signUp1VC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/16/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


class signUp1VC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var fnameTxt: UITextField!
    @IBOutlet weak var lnameTxt: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var nextBtnBottomSpace: NSLayoutConstraint!
    
    // variable to hold keyboard frame
    private var keyboard = CGRect()
    private var keyboardVisible = false
    private var bottomScrollOffset = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.fnameTxt.frame.height))
        fnameTxt.leftView = paddingView
        fnameTxt.leftViewMode = UITextFieldViewMode.always
        
        fnameTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        let paddingViewLname = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.lnameTxt.frame.height))
        lnameTxt.leftView = paddingViewLname
        lnameTxt.leftViewMode = UITextFieldViewMode.always
        
        lnameTxt.setBottomBorder(color: mainColor, height: 2.0)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signUp1VC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(signUp1VC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signUp1VC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @IBAction func backBtn_clicked(_ sender: UIButton) {
        
        // hide keyboard
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is signUp2VC {
            
            // dismiss keyboard
            self.view.endEditing(true)
            
            // if fields are empty
            if (fnameTxt.text!.isEmpty || lnameTxt.text!.isEmpty) {
                
                // alert message
                let alert = UIAlertController(title: "Empty Fields", message: "Please fill out all fields", preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                let vc = segue.destination as? signUp2VC
                vc?.firstname = (fnameTxt.text?.lowercased())!
                vc?.lastname = (lnameTxt.text?.lowercased())!
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
                self.nextBtnBottomSpace.constant = self.nextBtnBottomSpace.constant + self.keyboard.height
                self.bottomScrollOffset = self.scrollView.contentSize.height + self.keyboard.height - self.scrollView.bounds.size.height
            }
            
            if self.bottomScrollOffset > 0 {
                if self.fnameTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.fnameTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.fnameTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                    
                } else if self.lnameTxt.isFirstResponder {
                    if self.bottomScrollOffset > self.lnameTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.lnameTxt.frame.origin.y - 20), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                    
                }
            } else if self.fnameTxt.isFirstResponder || self.lnameTxt.isFirstResponder {
                self.keyboardVisible = true
            }
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.keyboardVisible = false
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.nextBtnBottomSpace.constant = self.nextBtnBottomSpace.constant - self.keyboard.height
        })
    }
    
}
