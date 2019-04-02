//
//  signUpOptionsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/21/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class signUpOptionsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(signUpOptionsVC.back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)

    }
    
    func back(_ recognizer : UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
