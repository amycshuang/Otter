//
//  GlobalPosts.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/18/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class GlobalPosts: UIViewController {
    
    var postsTableView: UITableView!
    var globalPostsReuseIdentifier = "globalPostsReuseIdentifier"
    var posts: [Post] = []
    var timer: Timer?

    var newPostButton: UIButton!
    var oldPostId: String?
    var newPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        DatabaseManager.getUserInfo()
        view.backgroundColor = .white
        
        postsTableView = UITableView()
        postsTableView.register(PostTableViewCell.self, forCellReuseIdentifier: globalPostsReuseIdentifier)
        postsTableView.dataSource = self
        postsTableView.delegate = self
        postsTableView.tableFooterView = UIView()
        view.addSubview(postsTableView)
        
        newPostButton = UIButton()
        newPostButton.setTitle("New Post!", for: .normal)
        newPostButton.backgroundColor = Constants.blue
        newPostButton.titleLabel?.textColor = .white
        newPostButton.titleLabel?.textAlignment = .center
        newPostButton.layer.cornerRadius = 8
        newPostButton.clipsToBounds = true
        newPostButton.isHidden = true
        newPostButton.addTarget(self, action: #selector(scrollToTop), for: .touchUpInside)
        view.addSubview(newPostButton)
        
        getPosts()
        getFavoritedPosts()
        getSharedPosts()
        setUpConstraints()
    }
    
    func setUpNavBar() {
        self.navigationItem.title = "Otter Global"
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    
    func getPosts() {
        DatabaseManager.databaseRef.child("Posts").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let post = Post(snapshot: snapshot)
                self.posts.append(post)
                self.reloadPostsTableView()
                self.listenForPostAddition()
            }
        }, withCancel: nil)
    }
    
    func getFavoritedPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.databaseRef.child("User").child(uid).child("Favorited Posts").observeSingleEvent(of: .value, with: { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                DatabaseManager.databaseRef.child("Posts").child(postId).observeSingleEvent(of: .value, with: { (snap) in
                    if snap.exists() {
                        let favoritedPost = Post(snapshot: snap)
                        if !User.favoritedPosts.contains(favoritedPost) {
                            User.favoritedPosts.append(favoritedPost)
                        }
                        self.reloadPostsTableView()
                    }
                }, withCancel: nil)
            }
        }, withCancel: nil)
        if User.favoritedPosts.count == 0 {
            reloadPostsTableView()
        }
    }
    
    func getSharedPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.databaseRef.child("User").child(uid).child("Shared Posts").observeSingleEvent(of: .value, with: { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                DatabaseManager.databaseRef.child("Posts").child(postId).observeSingleEvent(of: .value, with: { (snap) in
                    if snap.exists() {
                        let sharedPost = Post(snapshot: snap)
                        if !User.sharedPosts.contains(sharedPost) {
                            User.sharedPosts.append(sharedPost)
                        }
                        self.reloadPostsTableView()
                    }
                }, withCancel: nil)
            }
        }, withCancel: nil)
        if User.sharedPosts.count == 0 {
            reloadPostsTableView()
        }
    }

    func listenForPostAddition() {
        let post = posts[0]
        if post.postId != oldPostId && postsTableView.contentOffset.y > 0 {
            self.newPost = true
            self.oldPostId = post.postId
        }
    }
    
    func reloadPostsTableView() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(reloadTableViewWithTimer), userInfo: nil, repeats: false)
    }
    
    @objc func reloadTableViewWithTimer() {
        self.posts.sort { (post1, post2) -> Bool in
            if let time1 = Double(post1.time!), let time2 = Double(post2.time!) {
                return time1 > time2
            }
            else {
                return true
            }
        }
        DispatchQueue.main.async {
            self.postsTableView.reloadData()
        }
    }
    
    @objc func scrollToTop() {
        oldPostId = nil
        newPost = false
        DispatchQueue.main.async {
            self.postsTableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            if self.postsTableView.validIndexPath(indexPath: indexPath) {
                self.postsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func setUpConstraints() {
        
        postsTableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        newPostButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(10)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(110)
            make.height.equalTo(20)
        }
    }

}

extension GlobalPosts: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postsTableView.dequeueReusableCell(withIdentifier: globalPostsReuseIdentifier, for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.postActionDelegate = self
        cell.configure(for: post)
        cell.selectionStyle = .none
        return cell
    }
    
    
}

extension GlobalPosts: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        return post.getCellHeight()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if postsTableView.contentOffset.y > 0 && newPost {
            DispatchQueue.main.async {
                self.newPostButton.isHidden = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.newPostButton.isHidden = true
                self.newPost = false
            }
        }
    }
}

extension GlobalPosts: PostActionProtocol {
    
    func presentUserProfile(cell: PostTableViewCell) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        guard let indexPath = postsTableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.row]
        guard let posterUid = post.posterUid else { return }
        DatabaseManager.getPosterInfo(posterUid: posterUid) { (selectedUser) in
            if selectedUser.uid == currentUserUid {
                let vc = UserProfile(barButtonHidden: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = OtterUserProfile(user: selectedUser, barButtonHidden: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    func postFavorited(cell: PostTableViewCell) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let indexPath = postsTableView.indexPath(for: cell) else { return }
        let favoritedPosts = User.favoritedPosts
        let post = posts[indexPath.row]
        let postId = post.postId
        let databaseRef = DatabaseManager.databaseRef.child("User").child(uid).child("Favorited Posts").child(postId)
        if !favoritedPosts.contains(post) {
            databaseRef.updateChildValues([postId: 1])
        }
        else {
            databaseRef.removeValue()
            remove(for: postId, array: .favorited)
        }
        getFavoritedPosts()
    }

    func postShared(cell: PostTableViewCell) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let indexPath = postsTableView.indexPath(for: cell) else { return }
        let sharedPosts = User.sharedPosts
        let post = posts[indexPath.row]
        let postId = post.postId
        let databaseRef = DatabaseManager.databaseRef.child("User").child(uid).child("Shared Posts").child(postId)
        if !sharedPosts.contains(post) {
            databaseRef.updateChildValues([postId: 1])
        }
        else {
            databaseRef.removeValue()
            remove(for: postId, array: .shared)
        }
        getSharedPosts()
    }
    
    func remove(for postId: String, array: PostSubarray) {
        switch array {
        case .favorited:
            let filtered = User.favoritedPosts.filter({ $0.postId != postId})
            User.favoritedPosts = filtered
        case .shared:
            let filtered = User.sharedPosts.filter({ $0.postId != postId})
            User.sharedPosts = filtered
        }
    }
    
}
