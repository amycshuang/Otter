//
//  DatabaseManager.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/23/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

class DatabaseManager {
    
    static let databaseRef = Database.database().reference()
    static let firestoreRef = Firestore.firestore()
    static let storageRef = Storage.storage().reference()
    
    /// Uploads image to Firebase Storage and generates an url to be uploaded to the user's document in Firestore
    static func uploadUserToFirebase(image: UIImage, uid: String, name: String, username: String, email: String, headerImage: UIImage, completion: @escaping((String) -> Void)) {
        guard let data = image.jpegData(compressionQuality: 0.1) else { return }
        let photoId = UUID().uuidString
        let photoReference = storageRef.child("Profile Pics").child(photoId)
        photoReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            photoReference.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let url = url else { return }
                let imageUrl = url.absoluteString
                User.imageUrl = imageUrl
                
                guard let headerData = headerImage.jpegData(compressionQuality: 0.1) else { return }
                let headerId = UUID().uuidString
                let headerReference = storageRef.child("Header Pics").child(headerId)
                headerReference.putData(headerData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    headerReference.downloadURL { (url, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        guard let headerUrl = url?.absoluteString else { return }
                        User.headerUrl = headerUrl
                        createUser(uid: uid, name: name, username: username, email: email, imageUrl: imageUrl, headerUrl: headerUrl)
                        completion(imageUrl)
                    }
                }
                
            }
        }
    }
    
    /// Creates new user in Firestore
    static func createUser(uid: String, name: String, username: String, email: String, imageUrl: String, headerUrl: String) {
        let searchName = name.lowercased()
        let searchUsername = username.lowercased()
        firestoreRef.collection("Users").document(uid).setData([
            "uid": uid,
            "name": name,
            "username": username,
            "email": email,
            "imageUrl": imageUrl,
            "bio": "",
            "headerUrl": headerUrl,
            "searchName": searchName,
            "searchUsername": searchUsername
            ]) { (error) in
            if error != nil {
                // There was an error in saving user data
                print("There was an error in saving user data")
            }
        }
        createUsernameReference(username: username, uid: uid)
    }
    /// Creates reference of the user's username in Firestore. Reference is used to validate the username and ensure that no two users can select the same username
    static func createUsernameReference(username: String, uid: String) {
        firestoreRef.collection("Usernames").document(username).setData([
            "uid": uid
        ])
    }
    
    /// Gets the information of the current user to populate the User class static variables
    static func getUserInfo() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        firestoreRef.collection("Users").document(currentUserUid).getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                guard let documentSnapshot = document else { return }
                if documentSnapshot.exists {
                    User.init(snapshot: documentSnapshot)
                }
            }
        }
    }
    
    /// Gets all the users that are not the current user.
    static func getUsers(completion: @escaping(([OtherUser]) -> Void)) {
        var otherUsers: [OtherUser] = []
        firestoreRef.collection("Users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                if let currentUserUid = Auth.auth().currentUser?.uid, let userSnapshots = snapshot {
                    for userDocument in userSnapshots.documents {
                        let data = userDocument.data()
                        let userUid = data["uid"] as! String
                        if userUid != currentUserUid {
                            let user = OtherUser(snapshot: userDocument)
                            otherUsers.append(user)
                        }
                    }
                    completion(otherUsers)
                }
            }
        }
    }
    
    /// Uses a uid to return the name and image url associated with that uid in Firestore
    static func getNameAndImage(from uid: String, completion: @escaping (([String: String])-> Void)) {
        firestoreRef.collection("Users").document(uid).getDocument { (document, error) in
            guard let documentSnapshot = document else { return }
            if let error = error {
                print(error.localizedDescription)
            }
            else if documentSnapshot.exists {
                let user = OtherUser(snapshot: documentSnapshot)
                completion([
                    "name": user.name,
                    "imageUrl": user.imageUrl
                ])
            }
        }
    }
    
    /// Gets a singular friend from the inputted uid
    static func getFriend(from uid: String, completion: @escaping ((OtherUser) -> Void)) {
        firestoreRef.collection("Users").document(uid).getDocument { (document, error) in
            guard let documentSnapshot = document else { return }
            if let error = error {
                print(error.localizedDescription)
            }
            else if documentSnapshot.exists {
                let user = OtherUser(snapshot: documentSnapshot)
                completion(user)
            }
        }
    }
    
    /// Updates the user's password
    static func updatePassword(newPassword: String, completion: @escaping ((String) -> Void)) {
        Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .requiresRecentLogin:
                    completion("Re-Log In To Update")
                default:
                    completion("Error Updating Password")
                }
            }
            else {
                completion("Password Updated")
            }
        })
    }
    
    /// Updates the user's email
    static func updateEmail(newEmail: String, completion: @escaping ((String) -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    completion("Email Already In Use")
                case .requiresRecentLogin:
                    completion("Re-Log In To Update")
                default:
                    completion("Error Updating Email")
                }
            }
            else {
                firestoreRef.collection("Users").document(uid).updateData([
                    "email": newEmail
                ])
                completion("Email Updated")
            }
        })
    }
    
    /// Deletes a user's account
    static func deleteAccount(completion: @escaping ((Bool) -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let profileUrl = User.imageUrl else { return }
        Auth.auth().currentUser?.delete(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.deleteFromFirestoreUsers(uid: uid)
                self.deleteFromFirebaseMessages(uid: uid)
                self.deleteImage(from: profileUrl)
                self.deleteFromFirebasePostAndInteraction(uid: uid) { (success) in
                    if success {
                        databaseRef.child("User").child(uid).removeValue()
                    }
                }
                completion(true)
            }
        })
    }
    
    static func deleteFromFirestoreUsers(uid: String) {
        guard let username = User.username else { return }
        firestoreRef.collection("Users").document(uid).delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        firestoreRef.collection("Usernames").document(username).delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    /// Deletes text messages from the user
    static func deleteFromFirebaseMessages(uid: String) {
        let userMessagesRef = databaseRef.child("User-Messages").child(uid)
        userMessagesRef.observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let recipientId = child.key
                let recipientMessagesRef = databaseRef.child("User-Messages").child(recipientId).child(uid)
                recipientMessagesRef.observeSingleEvent(of: .value) { (snap) in
                    for datasnap in snap.children {
                        let child = datasnap as! DataSnapshot
                        let messageId = child.key
                        databaseRef.child("Messages").child(messageId).removeValue()
                    }
                    recipientMessagesRef.removeValue()
                }
            }
            userMessagesRef.removeValue()
        }
    }
    
    /// Deletes the user from Firebase
    static func deleteFromFirebasePostAndInteraction(uid: String, completion: @escaping ((Bool) -> Void)) {
        let userRef = databaseRef.child("User").child(uid)
        let followingRef = userRef.child("Following")
        let followersRef = userRef.child("Followers")
        let userPostsRef = userRef.child("User Posts")
        followingRef.observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let followingId = child.key
                databaseRef.child("User").child(followingId).child("Followers").child(uid).removeValue()
            }
        }
        followersRef.observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let followerId = child.key
                databaseRef.child("User").child(followerId).child("Following").child(uid).removeValue()
            }
        }
        
        userPostsRef.observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                databaseRef.child("Posts").child(postId).removeValue()
            }
        }
        completion(true)
    }
    
    /// Updates the user's profile data from editing their profile
    static func profileUpdate(uid: String, newName: String, newUsername: String, newBio: String, originalUsername: String) {
        firestoreRef.collection("Users").document(uid).updateData([
            "name": newName,
            "username": newUsername,
            "bio": newBio
        ])
        guard let originalUsername = User.username else { return }
        firestoreRef.collection("Usernames").document(newUsername).setData([
            "uid": uid
        ])
        firestoreRef.collection("Usernames").document(originalUsername).delete()
    }
    
    /// Updates the profile picture in Firestore
    static func profilePicUpdate(uid: String, newProfileImage: UIImage) {
        guard let data = newProfileImage.jpegData(compressionQuality: 0.1) else { return }
        let photoId = UUID().uuidString
        let photoReference = storageRef.child("Profile Pics").child(photoId)
        photoReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            photoReference.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let newImageUrl = url?.absoluteString else { return }
                guard let originalUrl = User.imageUrl else { return }
                User.imageUrl = newImageUrl
                firestoreRef.collection("Users").document(uid).updateData([
                    "imageUrl": newImageUrl
                ])
                deleteImage(from: originalUrl)
            }
        }
    }
    
    /// Updates the header picture in Firestore
    static func headerPicUpdate(uid: String, newHeaderImage: UIImage) {
        guard let headerData = newHeaderImage.jpegData(compressionQuality: 0.1) else { return }
        let headerId = UUID().uuidString
        let headerReference = storageRef.child("Header Pics").child(headerId)
        headerReference.putData(headerData, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            headerReference.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let newHeaderUrl = url?.absoluteString else { return }
                guard let originalHeaderUrl = User.headerUrl else { return }
                User.headerUrl = newHeaderUrl
                firestoreRef.collection("Users").document(uid).updateData([
                    "headerUrl": newHeaderUrl
                ])
                deleteImage(from: originalHeaderUrl)
            }
        }
    }
    
    /// Deletes the image from Firestore for a given url
    static func deleteImage(from url: String) {
        let imageStorageRef = Storage.storage().reference(forURL: url)
        imageStorageRef.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Gets the user's image url, name, and username based on uid. Used to initialize post data
    static func getPosterData(uid: String, completion: @escaping (([String: String]) -> Void))  {
        firestoreRef.collection("Users").document(uid).getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                guard let documentSnapshot = document else { return }
                if documentSnapshot.exists {
                    if let snapshotData = documentSnapshot.data() {
                        guard let name = snapshotData["name"] as? String else { return }
                        guard let username = snapshotData["username"] as? String else { return }
                        guard let imageUrl = snapshotData["imageUrl"] as? String else { return }
                        let data = [
                            "name": name,
                            "username": username,
                            "imageUrl": imageUrl
                        ]
                        completion(data)
                    }
                }
            }
        }
    }
    
    /// Searches users in Firestore by name and username
    static func searchUsersByName(name: String, completion: @escaping(([OtherUser]) -> Void)) {
        let searchName = name.lowercased()
        let nameEnd = "\(searchName)z"
        var searchedUsers: [OtherUser] = []
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        firestoreRef.collection("Users").order(by: "searchName").start(at: [searchName]).end(at: [nameEnd]).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                guard let document = snapshot else { return }
                for userDocument in document.documents {
                    let data = userDocument.data()
                    let userUid = data["uid"] as! String
                    if userUid != currentUserUid {
                        let user = OtherUser(snapshot: userDocument)
                        searchedUsers.append(user)
                    }
                    
                }
                firestoreRef.collection("Users").order(by: "searchUsername").start(at: [searchName]).end(at: [nameEnd]).getDocuments { (snapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else {
                        guard let document = snapshot else { return }
                        for userDocument in document.documents {
                            let data = userDocument.data()
                            let userUid = data["uid"] as! String
                            if userUid != currentUserUid {
                                let user = OtherUser(snapshot: userDocument)
                                if !searchedUsers.contains(user) {
                                    searchedUsers.append(user)
                                }
                            }
                        }
                        completion(searchedUsers)
                    }
                }
            }
            
        }
    }
    
    /// Gets the poster's user info when the profile image is tapped
    static func getPosterInfo(posterUid: String, completion: @escaping ((OtherUser) -> Void)) {
        firestoreRef.collection("Users").document(posterUid).getDocument { (document, error) in
            if let document = document, document.exists {
                let poster = OtherUser(snapshot: document)
                completion(poster)
            }
        }
    }
    
}
