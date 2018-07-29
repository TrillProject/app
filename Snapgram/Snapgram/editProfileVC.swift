//
//  editProfileVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 7/25/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class editProfileVC: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var firstnameTxt: UITextField!
    @IBOutlet weak var lastnameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    private var currentPicker = 0
    
    // value to hold keyboard frame size
    var keyboard = CGRect()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Edit Profile"
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(editProfileVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editProfileVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(editProfileVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // tap to choose profile image
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(editProfileVC.loadAvaImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        // tap to choose cover image
        let coverTap = UITapGestureRecognizer(target: self, action: #selector(editProfileVC.loadCoverImg(_:)))
        coverTap.numberOfTapsRequired = 1
        coverImg.isUserInteractionEnabled = true
        coverImg.addGestureRecognizer(coverTap)
        
        // call alignment function
        alignment()
        
        // call information function
        information()
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
            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboard.height / 2
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.contentSize.height = 0
        })
    }
    
    // func to call UIImagePickerController
    @objc func loadAvaImg (_ recognizer : UITapGestureRecognizer) {
        currentPicker = 0
        loadImg(recognizer)
    }
    
    @objc func loadCoverImg (_ recognizer : UITapGestureRecognizer) {
        currentPicker = 1
        loadImg(recognizer)
    }
    
    @objc func loadImg (_ recognizer : UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    // method to finilize our actions with UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if currentPicker == 0 {
            avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
            self.dismiss(animated: true, completion: nil)
        } else if currentPicker == 1 {
            coverImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // alignment function
    func alignment() {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.firstnameTxt.frame.height))
        firstnameTxt.leftView = paddingView
        firstnameTxt.leftViewMode = UITextFieldViewMode.always
        
        let paddingViewLname = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.lastnameTxt.frame.height))
        lastnameTxt.leftView = paddingViewLname
        lastnameTxt.leftViewMode = UITextFieldViewMode.always
        
        let paddingViewEmail = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTxt.frame.height))
        emailTxt.leftView = paddingViewEmail
        emailTxt.leftViewMode = UITextFieldViewMode.always
        
    }
    
    // user information function
    func information() {
        
        // receive profile picture
        if PFUser.current()?.object(forKey: "ava") == nil {
            self.avaImg.image = UIImage(named: "pp")
        } else {
            let ava = PFUser.current()?.object(forKey: "ava") as! PFFile
            ava.getDataInBackground { (data, error) -> Void in
                self.avaImg.image = UIImage(data: data!)
            }
        }
        
        //receive cover photo
        if PFUser.current()?.object(forKey: "cover") == nil {
            self.coverImg.image = UIImage(named: "transparent")
        } else {
            let cover = PFUser.current()?.object(forKey: "cover") as! PFFile
            cover.getDataInBackground { (data, error) -> Void in
                self.coverImg.image = UIImage(data: data!)
            }
        }
        
        // receive text information
        emailTxt.text = PFUser.current()?.username
        firstnameTxt.text = (PFUser.current()?.object(forKey: "firstname") as? String)?.capitalized
        lastnameTxt.text = (PFUser.current()?.object(forKey: "lastname") as? String)?.capitalized
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
        let currentUsername = PFUser.current()!.username!
        if username == currentUsername {
            return
        } else {
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
    }
    
    // alert message function
    func alert (_ error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save_clicked(_ sender: UIBarButtonItem) {
        
        let oldUsername = PFUser.current()!.username!
        
        // if fields are empty
        if (firstnameTxt.text!.isEmpty || lastnameTxt.text!.isEmpty || emailTxt.text!.isEmpty) {
            alert("Empty Fields", message: "Please fill out all fields")
            return
        }
        
        // if username is already taken
        validateUsername(emailTxt.text!)
        
        // if incorrect email according to regex
        if !validateEmail(emailTxt.text!) {
            alert("Incorrect Email", message: "Please provide correctly formatted email address")
            return
        }
        
        // save filled in information
        let user = PFUser.current()!
        user.username = emailTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user["firstname"] = firstnameTxt.text?.lowercased()
        user["lastname"] = lastnameTxt.text?.lowercased()
        
        // send profile picture
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        // send profile picture
        let coverData = UIImagePNGRepresentation(coverImg.image!)
        let coverFile = PFFile(name: "cover.png", data: coverData!)
        user["cover"] = coverFile
        
        // send filled information to server
        user.saveInBackground (block: { (success, error) -> Void in
            if success{
                
                // update follower and news objects if username changed
                let newUsername = PFUser.current()!.username!
                if oldUsername != newUsername {
                    let followQuery = PFQuery(className: "follow")
                    followQuery.whereKey("follower", equalTo: oldUsername)
                    followQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            for object in objects! {
                                object["follower"] = newUsername
                                object.saveInBackground(block: { (success, error) -> Void in
                                    if success {
                                        let newsQuery = PFQuery(className: "news")
                                        newsQuery.whereKey("by", equalTo: oldUsername)
                                        newsQuery.whereKey("to", equalTo: object.object(forKey: "following")!)
                                        newsQuery.findObjectsInBackground(block: { (newsObjects, error) -> Void in
                                            if error == nil {
                                                for newsObject in newsObjects! {
                                                    newsObject["by"] = newUsername
                                                    newsObject.saveInBackground(block: { (success, error) -> Void in
                                                        if !success {
                                                             print(error!.localizedDescription)
                                                        }
                                                    })
                                                }
                                            } else {
                                                print(error!.localizedDescription)
                                            }
                                        })
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                    let followingQuery = PFQuery(className: "follow")
                    followingQuery.whereKey("following", equalTo: oldUsername)
                    followingQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            for object in objects! {
                                object["following"] = newUsername
                                object.saveInBackground(block: { (success, error) -> Void in
                                    if success {
                                        let newsQuery = PFQuery(className: "news")
                                        newsQuery.whereKey("by", equalTo: object.object(forKey: "follower")!)
                                        newsQuery.whereKey("to", equalTo: oldUsername)
                                        newsQuery.findObjectsInBackground(block: { (newsObjects, error) -> Void in
                                            if error == nil {
                                                for newsObject in newsObjects! {
                                                    newsObject["to"] = newUsername
                                                    newsObject.saveInBackground(block: { (success, error) -> Void in
                                                        if !success {
                                                            print(error!.localizedDescription)
                                                        }
                                                    })
                                                }
                                            } else {
                                                print(error!.localizedDescription)
                                            }
                                        })
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
                
                // hide keyboard
                self.view.endEditing(true)
                
                // dismiss editProfileVC
                self.dismiss(animated: true, completion: nil)
                
                // send notification to homeVC to be reloaded
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                
            } else {
                self.alert("Error", message: error!.localizedDescription)
                print(error!.localizedDescription)
            }
        })
    }
    
    // click on back icon
    @IBAction func back_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
