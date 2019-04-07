//
//  postEditLocationVC.swift
//  Snapgram
//
<<<<<<< HEAD
//  Created by Anita Onyimah on 02/23/19.
//

import UIKit
import GoogleMaps
import GooglePlaces

class postEditLocationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var resultsArray:[Dictionary<String, AnyObject>] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Edit Location"
        //searchBar.addTarget(self, action: #selector(searchBar.searchPlaceFromGoogle(_:)), for: .editingChanged)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44.0
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let textfield = searchBar.value(forKey: "_searchField") as? UITextField {
            textfield.textColor = darkGrey
            if let backgroundview = textfield.subviews.first {
                backgroundview.layer.cornerRadius = 15
                backgroundview.clipsToBounds = true
            }
        }
        searchPlaceFromGoogle(place:searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
=======
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
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        if let textfield = searchBar.value(forKey: "_searchField") as? UITextField {
            textfield.textColor = darkGrey
            if let backgroundview = textfield.subviews.first {
                backgroundview.layer.cornerRadius = 15
                backgroundview.clipsToBounds = true
            }
        }
<<<<<<< HEAD
           searchPlaceFromGoogle(place:searchBar.text!)
    }
    
    func searchPlaceFromGoogle(place:String){
        
         /* var autoComplete = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(place)&key=AIzaSyDztTkCcayrUSQKU3oKTZt-XM3kEr130dU" */
        
        var strGoogleAPI = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=\(place)&inputtype=textquery&fields=name,formatted_address&key=AIzaSyDztTkCcayrUSQKU3oKTZt-XM3kEr130dU"
        
        strGoogleAPI = strGoogleAPI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlRequest = URLRequest(url: URL(string: strGoogleAPI)!)
        urlRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                if let responseData = data {
                let jsonDict = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                if let dict = jsonDict as? Dictionary<String, AnyObject>{
                    if let results = dict["candidates"] as? [Dictionary<String, AnyObject>] {
                        print("json == \(results)")
                        self.resultsArray.removeAll()
                        for dct in results {
                            self.resultsArray.append(dct)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
             }
            } else {
                //there is error connecting to google api
            }
        }
        task.resume()
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    }
    
    //cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
<<<<<<< HEAD
        return resultsArray.count
=======
        return 0
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Location Cell") as! locationCell
<<<<<<< HEAD
        let place = self.resultsArray[indexPath.row]
        cell.locationTitle.text = "\(place["name"] as! String)"
        cell.addressLbl.text = "\(place["formatted_address"] as! String)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // selected location
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! locationCell
        postLocation = cell.locationTitle.text!
        postAddress = cell.addressLbl.text!
=======
        
        return cell
    }
    
    // selected location
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! locationCell
        
        postLocation = cell.locationTitle.text!
        postAddress = cell.addressLbl.text!
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
