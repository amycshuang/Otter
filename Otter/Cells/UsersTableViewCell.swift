//
//  NewMessageTableViewCell.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/28/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class NewMessageTableViewCell: UITableViewCell {

    var profilePic: UIImageView!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profilePic = UIImageView()
        profilePic.contentMode = .scaleAspectFit
        // TODO - COMMENT OUT LATER
        profilePic.layer.borderWidth = 1
        profilePic.layer.cornerRadius = 25
        contentView.addSubview(profilePic)
        
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        contentView.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        usernameLabel.textColor = .gray
        contentView.addSubview(nameLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        let picSize: CGFloat = 50
        let nameLabelHeight: CGFloat = 16
        
        profilePic.snp.makeConstraints { (make) in
            make.height.width.equalTo(picSize)
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(15)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top).offset(12)
            make.leading.equalTo(profilePic.snp.trailing).offset(8)
            make.height.equalTo(nameLabelHeight)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel.snp.leading)
        }
    }
    
    func configure(for user: OtherUser) {
        // TODO - MODIFY LATER
        profilePic.image = UIImage(named: "profileplaceholder")
        nameLabel.text = user.name
        usernameLabel.text = user.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
