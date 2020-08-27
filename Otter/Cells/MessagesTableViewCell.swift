//
//  MessagesTableViewCell.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/24/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class MessagesTableViewCell: UITableViewCell {
    
    var nameLabel: UILabel!
    var profilePic: UIImageView!
    var recentMessageLabel: UILabel!
    var timeLabel: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        contentView.addSubview(nameLabel)
            
        profilePic = UIImageView()
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        profilePic.layer.cornerRadius = 28
        contentView.addSubview(profilePic)
        
        recentMessageLabel = UILabel()
        recentMessageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        recentMessageLabel.lineBreakMode = .byCharWrapping
        contentView.addSubview(recentMessageLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .gray
        contentView.addSubview(timeLabel)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        let picSize: CGFloat = 56
        let nameLabelHeight: CGFloat = 16
        let messageWidth: CGFloat = self.contentView.frame.width - 30
        
        profilePic.snp.makeConstraints { (make) in
            make.height.width.equalTo(picSize)
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(15)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profilePic.snp.top).offset(8)
            make.leading.equalTo(profilePic.snp.trailing).offset(12)
            make.height.equalTo(nameLabelHeight)
        }
        
        recentMessageLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.width.equalTo(messageWidth)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(contentView.snp.trailing).offset(-15)
            make.bottom.equalTo(nameLabel.snp.bottom)
        }
    }
    
    func configure(for message: Message) {
        let Uid = message.getRecipientId()
        DatabaseManager.getNameAndImage(from: Uid) { (dictionary) in
            DispatchQueue.main.async {
                self.nameLabel.text = dictionary["name"]
                self.profilePic.getImage(from: dictionary["imageUrl"]!)
            }
        }
        if let messageText = message.message {
            recentMessageLabel.text = messageText
        }
        else {
            recentMessageLabel.text = "[Photo]"
        }
        timeLabel.text = message.getTime()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
