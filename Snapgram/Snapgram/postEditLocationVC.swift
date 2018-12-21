//
//  postEditLocationVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/11/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class postEditLocationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Edit Location"
        
        tableView.tableFooterView = UIView()
        
        if let textfield = searchBar.value(forKey: "_searchField") as? UITextField {
            textfield.textColor = darkGrey
            if let backgroundview = textfield.subviews.first {
                backgroundview.layer.cornerRadius = 15
                backgroundview.clipsToBounds = true
            }
        }
    }
    
    //cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Location Cell") as! locationCell
        
        return cell
    }
    
    // selected location
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! locationCell
        
        postLocation = cell.locationTitle.text!
        postAddress = cell.addressLbl.text!
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
