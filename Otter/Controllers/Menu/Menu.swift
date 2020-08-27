//
//  Menu.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/24/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class Menu: UIViewController {
    
    var profilePic: UIImageView!
    var nameLabel: UILabel!
    var userNameLabel: UILabel!
    var logOutButton: UIButton!
    
    var menuTableView: UITableView!
    let menuReuseIdentifier = "menuReuseIdentifier"
    let cellHeight: CGFloat = 50
    var menuItems: [MenuItem] = []
    
    weak var delegate: HomeControllerProtocol?
    init(delegate: HomeControllerProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        DatabaseManager.getUserInfo()
        
        profilePic = UIImageView()
        guard let url = User.imageUrl else { return }
        profilePic.getImage(from: url)
        profilePic.layer.cornerRadius = 40
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        view.addSubview(profilePic)
        
        nameLabel = UILabel()
        nameLabel.text = User.name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        view.addSubview(nameLabel)
        
        userNameLabel = UILabel()
        guard let username = User.username else { return }
        userNameLabel.text = "@\(username)"
        userNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        userNameLabel.textColor = .gray
        view.addSubview(userNameLabel)
        
        menuTableView = UITableView()
        menuTableView.register(MenuTableViewCell.self, forCellReuseIdentifier: menuReuseIdentifier)
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.separatorStyle = .none
        view.addSubview(menuTableView)
        
        logOutButton = UIButton()
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setTitleColor(.black, for: .normal)
        logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        view.addSubview(logOutButton)
        
        setUpMenu()
        setUpConstraints()

    }
    
    @objc func logOut() {
        do {
          try Auth.auth().signOut()
        } catch {
          alert(message: "Sign out error", title: "Error")
        }
        logOutUser()
        let rootVC = Welcome()
        self.view.window?.rootViewController = UINavigationController(rootViewController: rootVC)
        self.view.window?.makeKeyAndVisible()
    }
    
    func logOutUser() {
        User.uid = ""
        User.name = ""
        User.username = ""
        User.email = ""
        User.imageUrl = ""
        User.bio = ""
        User.headerUrl = ""
        User.searchName = ""
        User.searchUsername = ""
        User.favoritedPosts = []
        User.sharedPosts = []
        User.following = []
        User.followers = []
    }
    
    func setUpMenu() {
        let profile = MenuItem(menuItemName: "Profile", menuItemIcon: "profileicon")
        let settings = MenuItem(menuItemName: "Settings", menuItemIcon: "settingsicon")
        menuItems = [profile, settings]
    }
    
    func setUpConstraints() {
        let profilePicSize: CGFloat = 80
        let profileCenterX: CGFloat = (view.frame.width - 100)/2
        
        profilePic.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(80)
            make.centerX.equalTo(profileCenterX)
            make.width.height.equalTo(profilePicSize)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(profilePic.snp.centerX)
            make.top.equalTo(profilePic.snp.bottom).offset(10)
        }
        
        userNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(nameLabel.snp.centerX)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        menuTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading).offset(10)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(userNameLabel.snp.bottom).offset(20)
            make.height.equalTo(100)
        }
        
        logOutButton.snp.makeConstraints { (make) in
            make.leading.equalTo(menuTableView.snp.leading).offset(20)
            make.top.equalTo(menuTableView.snp.bottom).offset(10)
        }
        
    }
    
}

extension Menu: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = menuTableView.dequeueReusableCell(withIdentifier: menuReuseIdentifier, for: indexPath) as! MenuTableViewCell
        let menuItem = menuItems[indexPath.row]
        cell.configure(for: menuItem)
        cell.selectionStyle = .none
        return cell
    }
    
    
}

extension Menu: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItemSelected = menuItems[indexPath.row]
        delegate?.handleMenuToggle(for: menuItemSelected)
    }
    
}

