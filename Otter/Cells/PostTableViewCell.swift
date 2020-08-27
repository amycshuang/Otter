//
//  PostTableViewCell.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/16/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class PostTableViewCell: UITableViewCell {
    
    var profilePic: UIImageView!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
    var timeLabel: UILabel!
    var postLabel: UILabel!
    var shareButton: UIButton!
    var favoriteButton: UIButton!
    
    weak var postActionDelegate: PostActionProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profilePic = UIImageView()
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        profilePic.layer.cornerRadius = 25
        contentView.addSubview(profilePic)
        profilePic.isUserInteractionEnabled = true
        let userProfileImageTapped = UITapGestureRecognizer(target: self, action: #selector(presentTappedProfile))
        profilePic.addGestureRecognizer(userProfileImageTapped)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        contentView.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        usernameLabel.textColor = .gray
        contentView.addSubview(usernameLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .gray
        contentView.addSubview(timeLabel)
        
        postLabel = UILabel()
        postLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        postLabel.numberOfLines = 0
        contentView.addSubview(postLabel)
        
        shareButton = UIButton()
        shareButton.setImage(UIImage(named: "shareuncolored"), for: .normal)
        shareButton.addTarget(self, action: #selector(shared), for: .touchUpInside)
        contentView.addSubview(shareButton)
        
        favoriteButton = UIButton()
        favoriteButton.setImage(UIImage(named: "favoriteempty"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(favorited), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        setUpConstraints()
        
    }
    
    @objc func presentTappedProfile() {
        postActionDelegate?.presentUserProfile(cell: self)
    }
    
    @objc func shared() {
        postActionDelegate?.postShared(cell: self)
    }
    
    @objc func favorited() {
        postActionDelegate?.postFavorited(cell: self)
    }
    
    func setUpConstraints() {
        let picSize: CGFloat = 50
        let buttonSize: CGFloat = 24
        let buttonWidth: CGFloat = 23
        let labelHeight: CGFloat = 20
        
        profilePic.snp.makeConstraints { (make) in
            make.height.width.equalTo(picSize)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.top.equalTo(contentView.snp.top).offset(15)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profilePic.snp.top)
            make.left.equalTo(profilePic.snp.right).offset(15)
            make.height.equalTo(labelHeight)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.top)
            make.left.equalTo(nameLabel.snp.right).offset(5)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(usernameLabel.snp.right).offset(5)
            make.bottom.equalTo(nameLabel.snp.bottom).offset(-3)
        }
        
        postLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
            make.width.equalTo(Constants.postWidth)
        }
        
        shareButton.snp.makeConstraints { (make) in
            make.left.equalTo(postLabel.snp.left).offset(10)
            make.top.equalTo(postLabel.snp.bottom).offset(10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
            make.height.equalTo(buttonSize)
            make.width.equalTo(buttonWidth)
        }
        
        favoriteButton.snp.makeConstraints { (make) in
            make.left.equalTo(shareButton.snp.right).offset(40)
            make.top.equalTo(shareButton.snp.top)
            make.width.height.equalTo(buttonSize)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
        
    }
    
    func configure(for post: Post) {
        
        guard let posterUid = post.posterUid else { return }
        timeLabel.text = post.getTime()
        postLabel.text = post.text
        DatabaseManager.getPosterData(uid: posterUid) { (data) in
            if let imageUrl = data["imageUrl"], let name = data["name"], let username = data["username"] {
                self.profilePic.getImage(from: imageUrl)
                self.nameLabel.text = name
                self.usernameLabel.text = "@\(username)"
            }
        }
        
        let favoritedPosts = User.favoritedPosts
        if favoritedPosts.contains(post) {
            favoriteButton.setImage(UIImage(named: "favoritefilled"), for: .normal)
        }
        else {
            favoriteButton.setImage(UIImage(named: "favoriteempty"), for: .normal)
        }
        
        let sharedPosts = User.sharedPosts
        if sharedPosts.contains(post) {
            shareButton.setImage(UIImage(named: "sharecolored"), for: .normal)
        }
        else {
            shareButton.setImage(UIImage(named: "shareuncolored"), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
