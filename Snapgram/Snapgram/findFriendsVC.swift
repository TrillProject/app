//
//  findFriendsVC.swift
//  Snapgram
//
//  Created by Aleksandra Kolanko on 8/27/18.
//  Copyright © 2018 Jaksa Tomovic. All rights reserved.
//

import UIKit

class findFriendsVC: UITableViewController {

    @IBOutlet var nextBtns: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Find Friends"
        
        tableView.tableFooterView = UIView()

        for btn in nextBtns {
            tintBtn(btn)
        }
        
    }
    
    func tintBtn(_ button : UIButton) {
        let img = button.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        button.setImage(img, for: .normal)
        button.tintColor = darkGrey
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = mainColor
        header.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)!
        header.textLabel?.frame = header.frame
        header.contentView.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    @IBAction func backBtn_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
