//
//  UsersTableViewCell.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/28/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class UsersTableViewCell: UITableViewCell {

    var profilePic: UIImageView!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profilePic = UIImageView()
        profilePic.contentMode = .scaleAspectFill
        profilePic.clipsToBounds = true
        profilePic.layer.cornerRadius = 25
        contentView.addSubview(profilePic)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        usernameLabel.textColor = .gray
        contentView.addSubview(usernameLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        let picSize: CGFloat = 50
        let nameLabelHeight: CGFloat = 16
        
        profilePic.snp.makeConstraints { (make) in
            make.height.width.equalTo(picSize)
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(17)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top).offset(12)
            make.leading.equalTo(profilePic.snp.trailing).offset(8)
            make.height.equalTo(nameLabelHeight)
        }

        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
            make.leading.equalTo(nameLabel.snp.leading)
        }
    }
    
    func configure(for user: OtherUser) {
        profilePic.getImage(from: user.imageUrl)
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.username)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
