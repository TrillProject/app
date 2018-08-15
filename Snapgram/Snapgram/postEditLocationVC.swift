//
//  postEditLocationVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/11/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class postEditLocationVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Edit Location"
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
