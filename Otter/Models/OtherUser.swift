//
//  OtherProfile.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/27/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation

class OtherProfile {
        
    var uid: String
    var name: String
    var username: String
    var email: String
    var imageUrl: String
    var bio: String
    
    init(uid: String, name: String, username: String, email: String, imageUrl: String, bio: String) {
        self.uid = uid
        self.name = name
        self.username = username
        self.email = email
        self.imageUrl = imageUrl
        self.bio = bio
    }
    
}
