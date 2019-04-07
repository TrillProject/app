//
//  filterFriendsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 10/23/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse

var filterFriends = [String]()

class filterFriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var selectLbl: UILabel!

    // arrays to hold server data
    var followArray = [String]()
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var firstnameArray = [String]()
    var lastnameArray = [String]()
    var selectedArray = [Bool]()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Filter Friends"

        // receive notification from profileUserVC
        NotificationCenter.default.addObserver(self, selector: #selector(filterFriendsVC.reloadFriends(_:)), name: NSNotification.Name(rawValue: "followingUserChanged"), object: nil)

        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "prev"), style: .plain, target: self, action: #selector(filterFriendsVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn

        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero

        let checkImage = UIImage(named: "check")
        let tintedCheckImage = checkImage?.withRenderingMode(.alwaysTemplate)
        checkBtn.setImage(tintedCheckImage, for: .normal)
        checkBtn.tintColor = mainColor

        getFriends()
    }

    // go back
    func back(_ sender : UIBarButtonItem) {

        // push back
        self.navigationController?.popViewController(animated: true)
    }

    func getFriends() {
        let followQuery = PFQuery(className: "follow")
        if PFUser.current() != nil {
            followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followQuery.whereKey("accepted", equalTo: true)
            followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {

                    // clean up
                    self.followArray.removeAll(keepingCapacity: false)

                    // find related objects
                    for object in objects! {
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }

                    let query = PFUser.query()
                    query?.whereKey("username", containedIn: self.followArray)
                    query?.addAscendingOrder("firstname")
                    query?.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {

                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.firstnameArray.removeAll(keepingCapacity: false)
                            self.lastnameArray.removeAll(keepingCapacity: false)
                            self.selectedArray.removeAll(keepingCapacity: false)

                            // find related objects in User class of Parse
                            for object in objects! {

                                self.usernameArray.append(object.object(forKey: "username") as! String)

                                if object.object(forKey: "firstname") != nil {
                                    self.firstnameArray.append((object.object(forKey: "firstname") as! String).capitalized)
                                } else {
                                    self.firstnameArray.append((object.object(forKey: "username") as! String).capitalized)
                                }

                                if object.object(forKey: "lastname") != nil {
                                    self.lastnameArray.append((object.object(forKey: "lastname") as! String).capitalized)
                                } else {
                                    self.lastnameArray.append("")
                                }

                                if object.object(forKey: "ava") == nil {
                                    let avaData = UIImageJPEGRepresentation(UIImage(named: "pp")!, 0.5)
                                    let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                                    self.avaArray.append(avaFile!)
                                } else {
                                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                }

                                if filterFriends.contains(object.object(forKey: "username") as! String) {
                                    self.selectedArray.append(true)
                                } else {
                                    self.selectedArray.append(false)
                                }

                                self.tableView.reloadData()
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
    }

    // reload after following user changed
    func reloadFriends(_ notification:Notification) {
        getFriends()
    }


    // TABLEVIEW
    // cell numb
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! friendCell

        cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]

        // place profile picture
        avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            cell.avaImg.setBackgroundImage(UIImage(data: data!), for: .normal)
        }

        cell.usernameBtn.setTitle(firstnameArray[(indexPath as NSIndexPath).row] + " " + lastnameArray[(indexPath as NSIndexPath).row], for: .normal)

        // tint check button
        if selectedArray[(indexPath as NSIndexPath).row] == true {
            cell.checkBtn.tintColor = mainColor
        } else {
            cell.checkBtn.tintColor = lightGrey
        }

        // assign index
        cell.avaImg.layer.setValue(indexPath, forKey: "index")
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.checkBtn.layer.setValue(indexPath, forKey: "index")

        return cell
    }

    @IBAction func usernameBtn_clicked(_ sender: UIButton) {

        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath

        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! friendCell

        // if user tapped on himself go home, else go guest
        if cell.usernameLbl.text == PFUser.current()?.username {
            user = PFUser.current()!.username!
            let profile = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! profileVC
            self.navigationController?.pushViewController(profile, animated: true)
        } else {
            guestname.append(cell.usernameLbl.text!)
            user = cell.usernameLbl.text!
            let profileUser = self.storyboard?.instantiateViewController(withIdentifier: "profileUserVC") as! profileUserVC
            self.navigationController?.pushViewController(profileUser, animated: true)
        }
    }

    @IBAction func checkBtn_clicked(_ sender: UIButton) {

        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath

        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! friendCell

        let selected = selectedArray[(i as NSIndexPath).row]

        if selected {
            cell.checkBtn.tintColor = lightGrey
            selectedArray[(i as NSIndexPath).row] = false

            if let index = filterFriends.index(of: usernameArray[(i as NSIndexPath).row]){
                filterFriends.remove(at: index)
            }
        } else {
            cell.checkBtn.tintColor = mainColor
            selectedArray[(i as NSIndexPath).row] = true
            filterFriends.append(usernameArray[(i as NSIndexPath).row])
        }
    }

    @IBAction func deselectBtn_clicked(_ sender: UIButton) {

        let cells = self.tableView.visibleCells as! Array<friendCell>

        if sender.tintColor == mainColor {

            sender.tintColor = lightGrey

            for i in 0..<selectedArray.count {
                selectedArray[i] = false
            }

            for cell in cells {
                cell.checkBtn.tintColor = lightGrey
            }

            filterFriends.removeAll(keepingCapacity: false)
            selectLbl.text = "SELECT ALL"
        } else {

            sender.tintColor = mainColor

            for i in 0..<selectedArray.count {
                selectedArray[i] = true
            }

            for cell in cells {
                cell.checkBtn.tintColor = mainColor
                filterFriends.append(cell.usernameLbl.text!)
            }

            selectLbl.text = "DESELECT ALL"
        }
    }
}
