//
//  uploadVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FusumaDelegate, UITextViewDelegate {

    // UI objects
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var editLocationBtn: UIButton!
    @IBOutlet weak var gradientImg: UIImageView!
    
    @IBOutlet weak var countryIcon: UIButton!
    @IBOutlet weak var cityIcon: UIButton!
    @IBOutlet weak var restaurantIcon: UIButton!
    @IBOutlet weak var nightlifeIcon: UIButton!
    @IBOutlet weak var artsIcon: UIButton!
    @IBOutlet weak var shopIcon: UIButton!
    @IBOutlet weak var hotelIcon: UIButton!
    
    @IBOutlet var categoryBtns : [UIView]!
    private var chosenCategory : String!
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // *** CORE LOAD *** //
        // Show Fusuma
        let fusuma = FusumaViewController()
        //        fusumaCropImage = false
        fusuma.delegate = self
        self.present(fusuma, animated: false, completion: nil)
        fusuma.closeButton.isHidden = false
        // *** CORE LOAD END *** //
        
        // title at the top
        self.navigationItem.title = "Post"
        
        // standart UI containt
        picImg.image = UIImage(named: "pbg.jpg")
        
        titleTxt.delegate = self
        
        // hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tap
       // let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImg))
        //picTap.numberOfTapsRequired = 1
        //picImg.isUserInteractionEnabled = true
       // picImg.addGestureRecognizer(picTap)
        
    }
    
    // preload func
    override func viewWillAppear(_ animated: Bool) {
        // call alignment function
        style()
    }

    // hide keyboard function
    func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    
    // func to cal pickerViewController
    //func selectImg() {
    //    let picker = UIImagePickerController()
   //     picker.delegate = self
    //    picker.sourceType = .photoLibrary
    //    picker.allowsEditing = true
    //    present(picker, animated: true, completion: nil)
    //}
    
    /*
    // hold selected image in picImg object and dissmiss PickerController()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // enable publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        // unhide remove button
        removeBtn.isHidden = false
        
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }*/
    
    
    // zooming in / out function
    func zoomImg() {
        
        // define frame of zoomed image
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
        // if picture is unzoomed, zoom it
        if picImg.frame == unzoomed {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = zoomed
                
                // hide objects from background
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
            })
            
        // to unzoom
        } else {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = unzoomed
                
                // unhide objects from background
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
            })
        }
        
    }
    
    
    // style UI objects
    func style() {
        
        titleTxt.text = "Write something..."
        titleTxt.textColor = mediumGrey
        
        // tint edit location image
        let editImage = UIImage(named: "edit")
        let tintedEditImage = editImage?.withRenderingMode(.alwaysTemplate)
        editLocationBtn.setBackgroundImage(tintedEditImage, for: .normal)
        editLocationBtn.tintColor = mediumGrey
        
        // tint category icons
        let countryImg = countryIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        countryIcon.setImage(countryImg, for: .normal)
        countryIcon.tintColor = lightGrey
        let cityImg = cityIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        cityIcon.setImage(cityImg, for: .normal)
        cityIcon.tintColor = lightGrey
        let restaurantImg = restaurantIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        restaurantIcon.setImage(restaurantImg, for: .normal)
        restaurantIcon.tintColor = lightGrey
        let nightlifeImg = nightlifeIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        nightlifeIcon.setImage(nightlifeImg, for: .normal)
        nightlifeIcon.tintColor = lightGrey
        let artsImg = artsIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        artsIcon.setImage(artsImg, for: .normal)
        artsIcon.tintColor = lightGrey
        let shopImg = shopIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        shopIcon.setImage(shopImg, for: .normal)
        shopIcon.tintColor = lightGrey
        let hotelImg = hotelIcon.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        hotelIcon.setImage(hotelImg, for: .normal)
        hotelIcon.tintColor = lightGrey
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is navVC {
            let firstVC = segue.destination.childViewControllers[0]
            if firstVC is postTagsVC {
            
                // if category was not selected
                if chosenCategory == nil {
                    alert("No Category Selected", message: "Please select a category")
                } else {
                    let vc = segue.destination as? postTagsVC
                    vc?.category = chosenCategory!
                }
            }
        }
    }
    
    
    // clicked publish button
//    @IBAction func publishBtn_clicked(_ sender: AnyObject) {
//
//        // dissmiss keyboard
//        self.view.endEditing(true)
//
//        // send data to server to "posts" class in Parse
//        let object = PFObject(className: "posts")
//        object["username"] = PFUser.current()!.username
//        if PFUser.current()?.object(forKey: "firstname") != nil {
//            object["firstname"] = PFUser.current()?.object(forKey: "firstname") as? String
//        } else {
//            object["firstname"] = PFUser.current()!.username
//        }
//        object["ava"] = PFUser.current()!.value(forKey: "ava") as! PFFile
//
//        let uuid = UUID().uuidString
//        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"
//
//        if titleTxt.text.isEmpty {
//            object["title"] = ""
//        } else {
//            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        }
//
//        // send pic to server after converting to FILE and comprassion
//        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
//        let imageFile = PFFile(name: "post.jpg", data: imageData!)
//        object["pic"] = imageFile
//
//
//        // send #hashtag to server
//        let words:[String] = titleTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
//
//        // define taged word
//        for var word in words {
//
//            // save #hasthag in server
//            if word.hasPrefix("#") {
//
//                // cut symbold
//                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
//                word = word.trimmingCharacters(in: CharacterSet.symbols)
//
//                let hashtagObj = PFObject(className: "hashtags")
//                hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
//                hashtagObj["by"] = PFUser.current()?.username
//                hashtagObj["hashtag"] = word.lowercased()
//                hashtagObj["comment"] = titleTxt.text
//                hashtagObj.saveInBackground(block: { (success, error) -> Void in
//                    if success {
//                        print("hashtag \(word) is created")
//                    } else {
//                        print(error!.localizedDescription)
//                    }
//                })
//            }
//        }
//
//
//        // finally save information
//        object.saveInBackground (block: { (success, error) -> Void in
//            if error == nil {
//
//                // send notification with name "uploaded"
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
//
//                // switch to another ViewController at 0 index of tabbar
//                self.tabBarController!.selectedIndex = 0
//
//                // reset everything
//                self.viewDidLoad()
//                self.titleTxt.text = ""
//            }
//        })
//
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == mediumGrey {
            textView.text = ""
            textView.textColor = darkGrey
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write something..."
            textView.textColor = mediumGrey
        }
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.viewDidLoad()
    }
    
    // MARK: FusumaDelegate Protocol
    func fusumaImageSelected(_ image: UIImage) {
        
        print("Image selected")
        picImg.image = image
        
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        print("video completed and output to file: \(fileURL)")
        //self.fileUrlLabel.text = "file output to: \(fileURL.absoluteString)"
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("Called just after dismissed FusumaViewController")
    }
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // select category
    @IBAction func categoryBtn_clicked(_ sender: UIButton) {
        sender.tintColor = mainColor
        for category in categoryBtns {
            if category != sender {
                category.tintColor = lightGrey
            } else {
                chosenCategory = category.restorationIdentifier
            }
        }
    }
    
    // close camera
    func fusumaClosed() {
        // Go to Feed page
        self.tabBarController?.selectedIndex = 0
        print("Called when the close button is pressed")
    }
    
    // alert message function
    func alert (_ error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
}
