//
//  NewMessage.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/27/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class NewMessage: UIViewController {

    var newMessageTableView: UITableView!
    let newMessageReuseIdentifier = "newMessageReuseIdentifier"
    let cellHeight: CGFloat = 70
    let otherUsers: [OtherUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Add Chat"

        newMessageTableView = UITableView()
        
        view.backgroundColor = .white
    }
    
    func setUpNavigationBarUI() {
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Add Chat"
    }

}
