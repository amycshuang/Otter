//
//  UserProfile.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/25/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class UserProfile: UIViewController {

    var closeButton: UIBarButtonItem!
    var profilePicture: UIImageView!
    var headerView: UIImageView!
    var editProfileButton: UIButton!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
    var dividingLine: UITextField!
    var shortBio: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpNavigationBarUI()
        self.hideKeyboardWhenViewTapped()

        DatabaseManager.getUserInfo()
        
        profilePicture = UIImageView()
        guard let url = User.imageUrl else { return }
        profilePicture.getImage(from: url)
        profilePicture.layer.cornerRadius = 50
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        view.addSubview(profilePicture)
        view.bringSubviewToFront(profilePicture)
        
        headerView = UIImageView()
        guard let headerUrl = User.headerUrl else { return }
        headerView.getImage(from: headerUrl)
        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill
        view.addSubview(headerView)
        view.sendSubviewToBack(headerView)
        
        editProfileButton = UIButton()
        editProfileButton.setTitle("Edit Profile", for: .normal)
        editProfileButton.setTitleColor(Constants.blue, for: .normal)
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.borderColor = Constants.blue.cgColor
        editProfileButton.layer.cornerRadius = 12
        editProfileButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        view.addSubview(editProfileButton)
        
        nameLabel = UILabel()
        nameLabel.text = User.name
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        guard let username = User.username else { return }
        usernameLabel.text = "@\(username)"
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        usernameLabel.textColor = .gray
        view.addSubview(usernameLabel)
        
        dividingLine = UITextField()
        dividingLine.blackBottomBorder()
        view.addSubview(dividingLine)
        
        shortBio = UITextView()
        shortBio.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        shortBio.text = User.bio
        shortBio.textColor = .black
        shortBio.isEditable = false
        shortBio.isUserInteractionEnabled = true
        shortBio.isScrollEnabled = false
        view.addSubview(shortBio)
        
        setUpConstraints()
    }
    
    func setUpNavigationBarUI() {
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        self.navigationItem.title = "Profile"
        
        closeButton = UIBarButtonItem(image: UIImage(named: "closeicon"), style: .plain, target: self, action: #selector(closeProfile))
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc func closeProfile() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func editProfile() {
        let vc = EditProfile()
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromTop
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func setUpConstraints() {
        let imageSize: CGFloat = 100
        let horizontalPadding: CGFloat = 25
        let verticalPadding: CGFloat = 8
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(120)
        }
        
        profilePicture.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(60)
            make.leading.equalTo(view.snp.leading).offset(horizontalPadding)
            make.width.height.equalTo(imageSize)
        }
        
        editProfileButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(profilePicture.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).offset(-horizontalPadding)
            make.width.equalTo(110)
            make.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(profilePicture.snp.leading).offset(10)
            make.top.equalTo(profilePicture.snp.bottom).offset(verticalPadding)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
        }
        
        dividingLine.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.width.equalTo(120)
            make.top.equalTo(usernameLabel.snp.bottom).offset(verticalPadding)
            make.height.equalTo(3)
        }
        
        shortBio.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading).offset(horizontalPadding)
            make.trailing.equalTo(view.snp.trailing).offset(-horizontalPadding)
            make.top.equalTo(dividingLine.snp.bottom).offset(verticalPadding)
            make.height.equalTo(100)
        }
        
    }

}
