//
//  Post.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/16/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    var posterUid: String?
    var posterImageUrl: String?
    var posterName: String?
    var posterUsername: String?
    var time: String?
    var text: String?
    var postId: String
    var shared: Bool?
    var favorited: Bool?
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        self.postId = snapshot.key
        self.posterUid = snapshotValue["posterUid"] as? String
        self.time = snapshotValue["time"] as? String
        self.text = snapshotValue["text"] as? String
    }
    
    func getTime() -> String {
        var time: String = ""
        let dateFormatter = DateFormatter()
        if let timeSince1970 = Double(self.time!) {
            let messageDate = NSDate(timeIntervalSince1970: timeSince1970)
            if Calendar.current.isDateInToday(messageDate as Date) {
                let cal = Calendar.current
                let today = Date()
                let date = Date.init(timeIntervalSince1970: timeSince1970)
                let components = cal.dateComponents([.hour], from: date, to: today)
                if let timeElapsed = components.hour {
                    if timeElapsed == 0 {
                        let minuteComponents = cal.dateComponents([.minute], from: date, to: today)
                        if let minutesElapsed = minuteComponents.minute {
                            let timeString = minutesElapsed
                            time = "\(timeString) min"
                        }
                    }
                    else {
                        let timeString = String(timeElapsed)
                        time = "\(timeString)h"
                    }
                }
            }
            else {
                dateFormatter.dateFormat = "MM/dd/yy"
                time = dateFormatter.string(from: messageDate as Date)
            }
        }
        return time
    }
    
    func getCellHeight() -> CGFloat {
        let postLabel = UILabel(frame: CGRect(x: 0, y: 0, width: Constants.postWidth, height: CGFloat.greatestFiniteMagnitude))
        postLabel.numberOfLines = 0
        postLabel.font = .systemFont(ofSize: 16)
        postLabel.text = self.text
        postLabel.sizeToFit()
        let cellHeight = postLabel.frame.height + 82
        return cellHeight
    }
}

extension Post: Equatable {
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.postId == rhs.postId && lhs.posterUid == rhs.posterUid
    }
    
}
