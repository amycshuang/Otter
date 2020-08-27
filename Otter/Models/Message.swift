//
//  Message.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/24/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    var senderUid: String?
    var recipientUid: String?
    var message: String?
    var time: String?
    var imageUrl: String?
    var imageWidth: Float?
    var imageHeight: Float?
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any] 
        self.senderUid = snapshotValue["senderUid"] as? String
        self.recipientUid = snapshotValue["recipientUid"] as? String
        self.message = snapshotValue["message"] as? String
        self.time = snapshotValue["time"] as? String
        self.imageUrl = snapshotValue["imageUrl"] as? String
        self.imageWidth = snapshotValue["imageWidth"] as? Float
        self.imageHeight = snapshotValue["imageHeight"] as? Float
    }
    
    func getTime() -> String {
        var time: String = ""
        let dateFormatter = DateFormatter()
        let timeSince1970 = Double(self.time!)
        let messageDate = NSDate(timeIntervalSince1970: timeSince1970!)
        if Calendar.current.isDateInToday(messageDate as Date) {
            dateFormatter.dateFormat = "hh:mm a"
            time = dateFormatter.string(from: messageDate as Date)
        }
        else if Calendar.current.isDateInYesterday(messageDate as Date) {
            time = "Yesterday"
        }
        else {
            dateFormatter.dateFormat = "MM/dd/yy"
            time = dateFormatter.string(from: messageDate as Date)
        }
        return time
    }
    
    func getRecipientId() -> String {
        let currentUserUid = Auth.auth().currentUser?.uid
        if senderUid == currentUserUid {
            return recipientUid!
        }
        else {
            return senderUid!
        }
    }
    
    func getMessageHeight() -> CGFloat {
        var messageLabel: UILabel
        if self.senderUid == User.uid {
            messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: Constants.senderMessageLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        }
        else {
            messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: Constants.receiverMessageLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        }
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel.text = self.message
        messageLabel.sizeToFit()
        let messageHeight = messageLabel.frame.height + 30
        return messageHeight
    }
    
    
    
}
