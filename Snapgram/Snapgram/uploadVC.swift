//
//  uploadVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import GooglePlaces


extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

var loadCamera = true

class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FusumaDelegate, UITextViewDelegate {
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        guard case picImg.image = images.first else {
            dismiss(animated: true, completion: nil)
            return
        }
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        print("Image selected")
        picImg.image = image
        selectedImg = image
        
        postLocation = nil
        postComment = nil
        selectedCategory = nil
        selectedTags.removeAll()
        customTags.removeAll()
        postRating = nil
        isPostFavorite = false
    }
    
    
    // value to hold keyboard frame size
    private var keyboard = CGRect()
    private var keyboardVisible = false
    private var bottomScrollOffset = CGFloat(0)
    
    var address = ""

    // UI objects
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var editLocationBtn: UIButton!
    
    
    @IBOutlet weak var categoryOverlayView: UIView!
    @IBOutlet weak var imgOverlayView: UIView!
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var ratingOverlayView: UIView!
    @IBOutlet weak var gradientImg: UIImageView!
    @IBOutlet weak var ratingWord: UILabel!
    @IBOutlet weak var categoryWord: UILabel!
    
    @IBOutlet weak var countryIcon: UIButton!
    @IBOutlet weak var cityIcon: UIButton!
    @IBOutlet weak var restaurantIcon: UIButton!
    @IBOutlet weak var nightlifeIcon: UIButton!
    @IBOutlet weak var artsIcon: UIButton!
    @IBOutlet weak var shopIcon: UIButton!
    @IBOutlet weak var hotelIcon: UIButton!
    
    @IBOutlet var categoryBtns : [UIView]!
    
    @IBOutlet weak var addFavoriteView: UIView!
    
    @IBOutlet weak var hotelIconBottomSpace: NSLayoutConstraint!
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "Post"
        
        // standard UI containt
        picImg.image = UIImage(named: "pbg.jpg")
        
        editLocationBtn.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
        
        titleTxt.delegate = self
        
        // hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // receive notification from postTagsVC
        NotificationCenter.default.addObserver(self, selector: #selector(uploadVC.donePosting(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(uploadVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uploadVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // rating pan gesture
        let ratingPan = UIPanGestureRecognizer(target: self, action: #selector(uploadVC.handleRatingPan(_:)))
        ratingContainerView.addGestureRecognizer(ratingPan)
        
        // select image tap
       // let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImg))
        //picTap.numberOfTapsRequired = 1
        //picImg.isUserInteractionEnabled = true
       // picImg.addGestureRecognizer(picTap)
    }
    
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    /* @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    } */
    
    // preload func
    override func viewWillAppear(_ animated: Bool) {
        if loadCamera {
            let fusuma = FusumaViewController()
            fusuma.delegate = self
            //fusuma.availableModes = [FusumaMode.library, FusumaMode.camera, FusumaMode.video]
            fusuma.availableModes = [FusumaMode.library, FusumaMode.camera]
            //fusuma.allowMultipleSelection = true
            self.present(fusuma, animated: true, completion: nil)
            loadCamera = false
        } else {
            style()
        }
    }

    // hide keyboard function
    func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    // add rating to post
    func handleRatingPan(_ sender : UIPanGestureRecognizer) {
        
        let frameWidth = self.ratingContainerView.frame.size.width
        
        switch sender.state {
        case .began:
            self.ratingWord.text = ""
            self.gradientImg.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
//                self.picImg.alpha = 0.3
                self.imgOverlayView.isHidden = false
                self.ratingWord.isHidden = false
                self.addFavoriteView.isHidden = true
                })
        case .changed:
            let location = sender.location(in: self.ratingContainerView).x
            
            if location <= frameWidth * 0.1 {
                self.ratingWord.text = ratingWords[0]
                if location <= frameWidth * 0.05 {
                    self.ratingContainerView.backgroundColor = gradientColors[0]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[1]
                }
            } else if location > frameWidth * 0.1 && location <= frameWidth * 0.2 {
                self.ratingWord.text = ratingWords[1]
                if location <= frameWidth * 0.15 {
                    self.ratingContainerView.backgroundColor = gradientColors[2]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[3]
                }
            } else if location > frameWidth * 0.2 && location <= frameWidth * 0.3 {
                self.ratingWord.text = ratingWords[2]
                if location <= frameWidth * 0.25 {
                    self.ratingContainerView.backgroundColor = gradientColors[4]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[5]
                }
            } else if location > frameWidth * 0.3 && location <= frameWidth * 0.4 {
                self.ratingWord.text = ratingWords[3]
                if location <= frameWidth * 0.35 {
                    self.ratingContainerView.backgroundColor = gradientColors[6]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[7]
                }
            } else if location > frameWidth * 0.4 && location <= frameWidth * 0.5 {
                self.ratingWord.text = ratingWords[4]
                if location <= frameWidth * 0.45 {
                    self.ratingContainerView.backgroundColor = gradientColors[8]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[9]
                }
            } else if location > frameWidth * 0.5 && location <= frameWidth * 0.6 {
                self.ratingWord.text = ratingWords[5]
                if location <= frameWidth * 0.55 {
                    self.ratingContainerView.backgroundColor = gradientColors[10]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[11]
                }
            } else if location > frameWidth * 0.6 && location <= frameWidth * 0.7 {
                self.ratingWord.text = ratingWords[6]
                if location <= frameWidth * 0.65 {
                    self.ratingContainerView.backgroundColor = gradientColors[12]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[13]
                }
            } else if location > frameWidth * 0.7 && location <= frameWidth * 0.8 {
                self.ratingWord.text = ratingWords[7]
                if location <= frameWidth * 0.75 {
                    self.ratingContainerView.backgroundColor = gradientColors[14]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[15]
                }
            } else if location > frameWidth * 0.8 && location <= frameWidth * 0.9 {
                self.ratingWord.text = ratingWords[8]
                if location <= frameWidth * 0.85 {
                    self.ratingContainerView.backgroundColor = gradientColors[16]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[17]
                }
            } else if location > frameWidth * 0.9 {
                self.ratingWord.text = ratingWords[9]
                if location <= frameWidth * 0.95 {
                    self.ratingContainerView.backgroundColor = gradientColors[18]
                } else {
                    self.ratingContainerView.backgroundColor = gradientColors[19]
                }
            }
            self.ratingOverlayView.frame.origin.x = location
        case .ended:
            postRating = ratingOverlayView.frame.origin.x / ratingContainerView.frame.size.width
            if postRating! > 0.7 && !isPostFavorite {
                UIView.animate(withDuration: 0.3, animations: {
                    self.ratingWord.isHidden = true
                    self.addFavoriteView.isHidden = false
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
//                    self.picImg.alpha = 1.0
                    self.imgOverlayView.isHidden = true
                    self.ratingWord.isHidden = true
                })
            }
        default:
            break
        }
    }
    
    @IBAction func addFavorite(_ sender: UIButton) {
        isPostFavorite = true
        UIView.animate(withDuration: 0.3, animations: {
//            self.picImg.alpha = 1.0
            self.imgOverlayView.isHidden = true
            self.ratingWord.isHidden = true
            self.addFavoriteView.isHidden = true
        })
    }
    
    @IBAction func doNotAddFavorite(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
//            self.picImg.alpha = 1.0
            self.imgOverlayView.isHidden = true
            self.ratingWord.isHidden = true
            self.addFavoriteView.isHidden = true
        })
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
//    func zoomImg() {
//
//        // define frame of zoomed image
//        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
//
//        // frame of unzoomed (small) image
//        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
//
//        // if picture is unzoomed, zoom it
//        if picImg.frame == unzoomed {
//
//            // with animation
//            UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                // resize image frame
//                self.picImg.frame = zoomed
//
//                // hide objects from background
//                self.view.backgroundColor = .black
//                self.titleTxt.alpha = 0
//            })
//
//        // to unzoom
//        } else {
//
//            // with animation
//            UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                // resize image frame
//                self.picImg.frame = unzoomed
//
//                // unhide objects from background
//                self.view.backgroundColor = .white
//                self.titleTxt.alpha = 1
//            })
//        }
//
//    }
    
    
    // style UI objects
    func style() {
        
        if postLocation == nil {
            locationLbl.text! = "Edit Location"
            locationLbl.textColor = mediumGrey
        } else {
            locationLbl.text! = postLocation!
        }
        
        if postComment == nil {
            titleTxt.text! = "Write something..."
            titleTxt.textColor = mediumGrey
        } else {
            titleTxt.text = postComment
            titleTxt.textColor = mainColor
        }
        
        // tint edit location image
        let editImage = UIImage(named: "edit")
        let tintedEditImage = editImage?.withRenderingMode(.alwaysTemplate)
        editLocationBtn.setBackgroundImage(tintedEditImage, for: .normal)
        editLocationBtn.tintColor = mainColor
        
        // tint category icons
        for categoryBtn in categoryBtns {
            tintIcons(categoryBtn as! UIButton)
        }
        
        // rating gradient
        if postRating == nil {
            gradientImg.isHidden = false
            ratingContainerView.backgroundColor = .white
            ratingOverlayView.frame.origin.x = 0
        } else {
            gradientImg.isHidden = true
            ratingOverlayView.frame.origin.x = postRating! * ratingContainerView.frame.size.width
            Review.colorReview(postRating!, ratingContainerView)
        }
        
        mainView.isHidden = false
    }
    
    // tint category icons
    func tintIcons(_ sender : UIButton) {
        let img = sender.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        sender.setImage(img, for: .normal)
        if sender.restorationIdentifier != nil && sender.restorationIdentifier == selectedCategory {
            sender.tintColor = mainColor
        } else {
            sender.tintColor = lightGrey
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is navVC {
            let firstVC = segue.destination.childViewControllers[0]
            if firstVC is postTagsVC {
                
                // if location is not set
                if locationLbl.text == nil || locationLbl.text == "Edit Location" {
                    alert("Invalid Location", message: "Please select a valid location")
                } else {
                    postLocation = locationLbl.text
                }
                
                // assign comment text
                if titleTxt.text == nil || titleTxt.text == "" || titleTxt.text == "Write something..." {
                    alert("Invalid Comment", message: "Please provide a quick comment")
                    //postComment = nil
                } else {
                    /*let myName = (PFUser.current()?.object(forKey: "firstname"))
                    let nameString = String(describing: myName!).capitalizingFirstLetter()
                    //let label = UIFont.boldSystemFont(ofSize: 12)
                    let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)]
                    let attributedName = NSAttributedString(string: nameString, attributes: attributes) */
                    //postComment = attributedName.string + " " + titleTxt.text
                    postComment = titleTxt.text
                }
            
                // if category was not selected
                if selectedCategory == nil {
                    alert("No Category Selected", message: "Please select a category")
                }
                
                // if rating was not added
                if postRating == nil {
                    alert("No Rating Supplied", message: "Please add a rating for your experience")
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == mediumGrey {
            textView.text = ""
            textView.textColor = mainColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write something..."
            textView.textColor = mediumGrey
        }
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.present(fusuma, animated: false, completion: nil)
        fusuma.closeButton.isHidden = false
        loadCamera = false
        mainView.isHidden = true
    }
    
    // MARK: FusumaDelegate Protocol
    /* func fusumaImageSelected(_ image: UIImage) {
        
        print("Image selected")
        picImg.image = image
        selectedImg = image
        
        postLocation = nil
        postComment = nil
        selectedCategory = nil
        selectedTags.removeAll()
        customTags.removeAll()
        postRating = nil
        isPostFavorite = false
        
        // implement second tap for zooming image
//        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
//        zoomTap.numberOfTapsRequired = 1
//        picImg.isUserInteractionEnabled = true
//        picImg.addGestureRecognizer(zoomTap)
    } */
    
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
                /* self.categoryWord.text = ""
                UIView.animate(withDuration: 0.3, animations: {
                    self.categoryOverlayView.isHidden = false
                    self.categoryWord.isHidden = false
                    self.categoryWord.text = selectedCategory
                    print(self.categoryWord.text)
                }) */
                selectedCategory = category.restorationIdentifier
            }
        }
    }
    
    // close camera
    func fusumaClosed() {
        // Go to Feed page
        mainView.isHidden = true
        self.tabBarController?.selectedIndex = 0
        print("Called when the close button is pressed")
        loadCamera = true
    }
    
    // done posting
    func donePosting(_ notification:Notification) {
        print("donePosting")
        self.tabBarController?.selectedIndex = 0
        selectedImg = nil
        postLocation = nil
        postComment = nil
        selectedCategory = nil
        selectedTags.removeAll()
        customTags.removeAll()
        postRating = nil
        isPostFavorite = false
//        self.viewDidLoad()
        mainView.isHidden = true
        loadCamera = true
        print("post added")
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
                self.hotelIconBottomSpace.constant = self.hotelIconBottomSpace.constant + self.keyboard.height - (self.tabBarController?.tabBar.frame.size.height)!
                self.bottomScrollOffset = self.scrollView.contentSize.height + self.keyboard.height - (self.tabBarController?.tabBar.frame.size.height)! - self.scrollView.bounds.size.height

                if self.titleTxt.isFirstResponder && !self.keyboardVisible {
                    if self.bottomScrollOffset > self.titleTxt.frame.origin.y {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.titleTxt.frame.origin.y), animated: true)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.bottomScrollOffset), animated: true)
                    }
                    self.keyboardVisible = true
                }
            }
        })
    }
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {

        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.hotelIconBottomSpace.constant = self.hotelIconBottomSpace.constant - self.keyboard.height + (self.tabBarController?.tabBar.frame.size.height)!
        })
        
        self.keyboardVisible = false
    }
    
    // alert message function
    func alert (_ error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}

extension uploadVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        locationLbl.text = place.name
        postLocation = locationLbl.text
        postAddress = place.formattedAddress
        print(postLocation)
        print(postAddress)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
