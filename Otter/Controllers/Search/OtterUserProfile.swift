//
//  OtterUserProfile.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/16/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit

class OtterUserProfile: UIViewController {

    var closeButton: UIBarButtonItem!
    
    var profilePicture: UIImageView!
    var headerView: UIImageView!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
    var dividingLine: UITextField!
    var shortBio: UITextView!
    
    var user: OtherUser!
    
    init(user: OtherUser) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.hideKeyboardWhenViewTapped()
        setUpNavigationBarUI()
        
        profilePicture = UIImageView()
        profilePicture.getImage(from: user.imageUrl)
        profilePicture.layer.cornerRadius = 50
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        view.addSubview(profilePicture)
        view.bringSubviewToFront(profilePicture)
        
        headerView = UIImageView()
        headerView.getImage(from: user.imageUrl)
        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill
        view.addSubview(headerView)
        view.sendSubviewToBack(headerView)
        
        nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.text = "@\(user.username)"
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        usernameLabel.textColor = .gray
        view.addSubview(usernameLabel)
        
        dividingLine = UITextField()
        dividingLine.blackBottomBorder()
        view.addSubview(dividingLine)
        
        shortBio = UITextView()
        shortBio.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        shortBio.text = user.bio
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
        
        closeButton = UIBarButtonItem(image: UIImage(named: "closeicon"), style: .plain, target: self, action: #selector(closeProfile))
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc func closeProfile() {
        dismiss(animated: true, completion: nil)
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
