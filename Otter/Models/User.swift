//
//  User.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/20/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import Firebase

class User {
    static var uid: String?
    static var name: String?
    static var username: String?
    static var email: String?
    static var imageUrl: String?
    static var bio: String?
    static var headerUrl: String?
    static var searchName: String?
    static var searchUsername: String?
    static var favoritedPosts: [Post] = []
    static var sharedPosts: [Post] = []
    static var following: [OtherUser] = []
    static var followers: [OtherUser] = []
    
    init(snapshot: DocumentSnapshot) {
        guard let snapshotValue = snapshot.data() else { return }
        User.uid = snapshotValue["uid"] as? String
        User.name = snapshotValue["name"] as? String
        User.username = snapshotValue["username"] as? String 
        User.email = snapshotValue["email"] as? String
        User.imageUrl = snapshotValue["imageUrl"] as? String
        User.bio = snapshotValue["bio"] as? String
        User.headerUrl = snapshotValue["headerUrl"] as? String
        User.searchName = snapshotValue["searchName"] as? String
        User.searchUsername = snapshotValue["searchUsername"] as? String
    }
    
}
