//
//  ChatMessageTableViewCell.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/3/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class ChatMessageTableViewCell: UITableViewCell {

    var chatBubble: UIView!
    var chatMessage: UILabel!
    var friendProfilePic: UIImageView!
    var messageImage: UIImageView!
    let currentUser = User.uid
    
    weak var imageZoomDelegate: ZoomImageProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        chatBubble = UIView()
        chatBubble.layer.cornerRadius = 15
        chatBubble.layer.masksToBounds = true
        chatBubble.backgroundColor = .blue
        contentView.addSubview(chatBubble)
        
        chatMessage = UILabel()
        chatMessage.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        chatMessage.numberOfLines = 0
        chatMessage.textColor = .black
        chatBubble.addSubview(chatMessage)
        
        friendProfilePic = UIImageView()
        friendProfilePic.contentMode = .scaleAspectFill
        friendProfilePic.layer.cornerRadius = 16
        friendProfilePic.clipsToBounds = true
        friendProfilePic.layer.masksToBounds = true
        contentView.addSubview(friendProfilePic)
        
        messageImage = UIImageView()
        messageImage.contentMode = .scaleAspectFill
        messageImage.layer.cornerRadius = 10
        messageImage.clipsToBounds = true
        messageImage.layer.masksToBounds = true
        messageImage.isUserInteractionEnabled = true
        let photoTapped = UITapGestureRecognizer(target: self, action: #selector(zoomPhoto))
        messageImage.addGestureRecognizer(photoTapped)
        contentView.addSubview(messageImage)
    }
    
    @objc func zoomPhoto(photoTap: UITapGestureRecognizer) {
        if let messageImageView = photoTap.view as? UIImageView {
             imageZoomDelegate?.zoomImage(for: messageImageView)
        }
    }
    
    func setUpConstraints(message: Message) {
        
        let profilePicSize: CGFloat = 32
        let messagePadding: CGFloat = 5
        let rightMessagePadding: CGFloat = -15
        let leftMessagePadding: CGFloat = 7
        
        chatBubble.snp.remakeConstraints { (make) in
            make.top.equalTo(contentView.snp.top).offset(messagePadding)
            make.bottom.equalTo(contentView.snp.bottom).offset(-messagePadding)
            if message.senderUid == currentUser {
                make.right.equalTo(contentView.snp.right).offset(rightMessagePadding)
                make.width.lessThanOrEqualTo(250)
            }
            else {
                make.left.equalTo(friendProfilePic.snp.right).offset(leftMessagePadding)
                make.width.lessThanOrEqualTo(220)
            }
        }
    
        chatMessage.snp.makeConstraints { (make) in
            make.left.equalTo(chatBubble.snp.left).offset(2*messagePadding)
            make.top.equalTo(chatBubble.snp.top).offset(2*messagePadding)
            make.right.equalTo(chatBubble.snp.right).offset(-2*messagePadding)
            make.bottom.equalTo(chatBubble.snp.bottom).offset(-2*messagePadding)
        }
        
        messageImage.snp.remakeConstraints { (make) in
            make.top.equalTo(contentView.snp.top).offset(messagePadding)
            make.bottom.equalTo(contentView.snp.bottom).offset(-messagePadding)
            if message.senderUid == currentUser {
                make.right.equalTo(contentView.snp.right).offset(rightMessagePadding)
                
            }
            else {
                make.left.equalTo(friendProfilePic.snp.right).offset(leftMessagePadding)
            }
            if let height = message.imageHeight, let width = message.imageWidth {
                let imageWidth = CGFloat(width/height*200)
                if imageWidth > CGFloat(210) {
                    make.width.equalTo(210)
                }
                else {
                    make.width.equalTo(imageWidth)
                }
            }
        }
        
        friendProfilePic.snp.makeConstraints { (make) in
            make.bottom.equalTo(chatBubble.snp.bottom).offset(-3)
            make.left.equalTo(contentView.snp.left).offset(10)
            make.width.height.equalTo(profilePicSize)
        }
    }
    
    func configure(for message: Message, for friend: OtherUser) {
        if message.senderUid == currentUser {
            chatBubble.backgroundColor = Constants.blue
            chatMessage.textColor = .white
            friendProfilePic.isHidden = true
        }
        else {
            chatBubble.backgroundColor = Constants.bluewhite
            chatMessage.textColor = .black
            friendProfilePic.isHidden = false
            friendProfilePic.getImage(from: friend.imageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            messageImage.getImage(from: messageImageUrl)
            messageImage.isHidden = false
            chatMessage.isHidden = true
            chatBubble.isHidden = true
        }
        else {
            messageImage.isHidden = true
            chatMessage.isHidden = false
            chatBubble.isHidden = false 
        }
        
        if let messageText = message.message {
            chatMessage.text = messageText
        }
        setUpConstraints(message: message)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
