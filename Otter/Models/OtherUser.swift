//
//  OtherProfile.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/27/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class OtherUser {
        
    var uid: String
    var name: String
    var username: String
    var email: String
    var imageUrl: String
    var bio: String
    var headerUrl: String
    var searchName: String
    var searchUsername: String
    
    
    init(snapshot: DocumentSnapshot) {
        let snapshotValue = snapshot.data()!
        self.uid = snapshotValue["uid"] as! String
        self.name = snapshotValue["name"] as! String
        self.username = snapshotValue["username"] as! String
        self.email = snapshotValue["email"] as! String
        self.imageUrl = snapshotValue["imageUrl"] as! String
        self.bio = snapshotValue["bio"] as! String
        self.headerUrl = snapshotValue["headerUrl"] as! String
        self.searchName = snapshotValue["searchName"] as! String
        self.searchUsername = snapshotValue["searchUsername"] as! String
        
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        self.uid = snapshotValue["uid"] as! String
        self.name = snapshotValue["name"] as! String
        self.username = snapshotValue["username"] as! String
        self.email = snapshotValue["email"] as! String
        self.imageUrl = snapshotValue["imageUrl"] as! String
        self.bio = snapshotValue["bio"] as! String
        self.headerUrl = snapshotValue["headerUrl"] as! String
        self.searchName = snapshotValue["searchName"] as! String
        self.searchUsername = snapshotValue["searchUsername"] as! String
    }

}

extension OtherUser: Equatable {
    static func == (lhs: OtherUser, rhs: OtherUser) -> Bool {
        return lhs.uid == rhs.uid
    }
}
