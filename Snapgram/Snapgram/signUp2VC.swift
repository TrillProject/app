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
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alignment
        
        emailTxt.frame = CGRect(x: 20, y: 120, width: self.view.frame.size.width - 40, height: 40)
        emailTxt.layer.cornerRadius = emailTxt.frame.size.height/2
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTxt.frame.height))
        emailTxt.leftView = paddingView
        emailTxt.leftViewMode = UITextFieldViewMode.always
        
        passwordTxt.frame = CGRect(x: 20, y: emailTxt.frame.origin.y + 70, width: self.view.frame.size.width - 40, height: 40)
        passwordTxt.layer.cornerRadius = passwordTxt.frame.size.height/2
        let paddingViewPass = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTxt.frame.height))
        passwordTxt.leftView = paddingViewPass
        passwordTxt.leftViewMode = UITextFieldViewMode.always
        
        repeatPasswordTxt.frame = CGRect(x: 20, y: passwordTxt.frame.origin.y + 70, width: self.view.frame.size.width - 40, height: 40)
        repeatPasswordTxt.layer.cornerRadius = repeatPasswordTxt.frame.size.height/2
        let paddingViewRepeat = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.repeatPasswordTxt.frame.height))
        repeatPasswordTxt.leftView = paddingViewRepeat
        repeatPasswordTxt.leftViewMode = UITextFieldViewMode.always
        
        backBtn.frame = CGRect(x: 20, y: repeatPasswordTxt.frame.origin.y + 70, width: self.view.frame.size.width / 3, height: 40)
        backBtn.layer.cornerRadius = backBtn.frame.size.height / 2
        
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 3 - 20, y: backBtn.frame.origin.y, width: self.view.frame.size.width / 3, height: 40)
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.height / 2
        
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
    
    @IBAction func backBtn_clicked(_ sender: UIButton) {
        
        // hide keyboard
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
