//
//  postTagsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/10/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

class postTagsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var category = ""
    
    @IBOutlet weak var tagsCollectionView: UICollectionView! {
        didSet {
            tagsCollectionView.dataSource = self
            tagsCollectionView.delegate = self
        }
    }
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Post"
        layout.estimatedItemSize = CGSize(width: 100.0, height: 30.0)
        
        print(category)
    }
    
    let tags = ["Lobortis", "Nam", "Fermentum", "Fusce", "Dictum", "Aman", "Eu", "Placerat", "Suscipt", "Neque", "Imperdiet", "Dabibus", "Risus", "Laoreet", "Urna", "Convallius", "Quisque", "Iaculis", "Mattis"]
    
    // cell number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag Cell", for: indexPath) as! tagCell
        cell.tagBtn.setTitle(tags[(indexPath as NSIndexPath).row].uppercased(), for: UIControlState.normal)
        return cell
    }
    
    // clicked on tag
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = tagsCollectionView.cellForItem(at: indexPath) as! tagCell
//        
//    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
