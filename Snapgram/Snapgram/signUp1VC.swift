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
    
    @IBOutlet weak var fnameTxt: UITextField!
    @IBOutlet weak var lnameTxt: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alignment
        
        fnameTxt.frame = CGRect(x: 20, y: 120, width: self.view.frame.size.width - 40, height: 40)
        fnameTxt.layer.cornerRadius = fnameTxt.frame.size.height / 2
        fnameTxt.clipsToBounds = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.fnameTxt.frame.height))
        fnameTxt.leftView = paddingView
        fnameTxt.leftViewMode = UITextFieldViewMode.always
        
        lnameTxt.frame = CGRect(x: 20, y: fnameTxt.frame.origin.y + 70, width: self.view.frame.size.width - 40, height: 40)
        lnameTxt.layer.cornerRadius = lnameTxt.frame.size.height / 2
        lnameTxt.clipsToBounds = true
        let paddingViewLname = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.lnameTxt.frame.height))
        lnameTxt.leftView = paddingViewLname
        lnameTxt.leftViewMode = UITextFieldViewMode.always
        
        backBtn.frame = CGRect(x: 20, y: lnameTxt.frame.origin.y + 70, width: self.view.frame.size.width / 3, height: 40)
        backBtn.layer.cornerRadius = backBtn.frame.size.height / 2
        backBtn.clipsToBounds = true
        
        nextBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 3 - 20, y: lnameTxt.frame.origin.y + 70, width: self.view.frame.size.width / 3, height: 40)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height / 2
        nextBtn.clipsToBounds = true
        
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
    
}
