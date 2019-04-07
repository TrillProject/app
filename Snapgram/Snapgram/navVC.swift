//
//  navVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit

class navVC: UINavigationController {
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color of title at the top in nav controller
<<<<<<< HEAD
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!]
=======
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName: UIFont(name: "SFProDisplay-Regular", size: 20)!]
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        
        // color of buttons in nav controller
        self.navigationBar.tintColor = .black
        
        // color of background of nav controller
        self.navigationBar.barTintColor = .white
        
        // disable translucent
        self.navigationBar.isTranslucent = false
    }
    
    // white status bar function
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return UIStatusBarStyle.lightContent
//    }

}
