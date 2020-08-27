//
//  OtterUserProfile.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/16/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

    
class OtterUserProfile: UIViewController {
    
    var closeButton: UIBarButtonItem!
    
    var profilePicture: UIImageView!
    var headerView: UIImageView!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
    var dividingLine: UITextField!
    var shortBio: UITextView!
    var followButton: UIButton!
    var messageButton: UIButton!
    var followerLabel: UILabel!
    var followingLabel: UILabel!
    var followsYouLabel: UILabel!
    
    var segmentedControl: PostSegmentedControl!
    var postsTableView: UITableView!
    let profilePostsReuseIdentifier = "profilePostsReuseIdentifier"
    var userAndSharedPosts: [Post] = []
    var favoritedPosts: [Post] = []
    
    var user: OtherUser!
    var selectedUserFollowing: [OtherUser] = []
    var selectedUserFollowers: [OtherUser] = []
    var barButtonHidden: Bool!
    
    var timer: Timer?
    
    init(user: OtherUser, barButtonHidden: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.barButtonHidden = barButtonHidden
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setUpNavigationBarUI()
        
        profilePicture = UIImageView()
        profilePicture.getImage(from: user.imageUrl)
        profilePicture.layer.cornerRadius = 50
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        view.addSubview(profilePicture)
        view.bringSubviewToFront(profilePicture)
        
        headerView = UIImageView()
        headerView.getImage(from: user.headerUrl)
        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill
        view.addSubview(headerView)
        view.sendSubviewToBack(headerView)
        
        nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.text = "@\(user.username)"
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        usernameLabel.textColor = .gray
        view.addSubview(usernameLabel)
        
        dividingLine = UITextField()
        dividingLine.blackBottomBorder()
        view.addSubview(dividingLine)
        
        shortBio = UITextView()
        shortBio.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        shortBio.text = user.bio
        shortBio.textColor = .black
        shortBio.isEditable = false
        shortBio.isUserInteractionEnabled = true
        shortBio.isScrollEnabled = false
        view.addSubview(shortBio)
        
        followButton = UIButton()
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(Constants.blue, for: .normal)
        followButton.backgroundColor = .white
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = Constants.blue.cgColor
        followButton.layer.cornerRadius = 12
        followButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
        view.addSubview(followButton)
        
        messageButton = UIButton()
        messageButton.setImage(UIImage(named: "messageusericon"), for: .normal)
        messageButton.layer.borderWidth = 1
        messageButton.layer.borderColor = Constants.blue.cgColor
        messageButton.layer.cornerRadius = 15
        messageButton.isHidden = true
        messageButton.addTarget(self, action: #selector(messageUser), for: .touchUpInside)
        view.addSubview(messageButton)
        
        setFollowButton()

        followingLabel = UILabel()
        followingLabel.textColor = .black
        followingLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        followingLabel.text = "0 following"
        view.addSubview(followingLabel)
        
        followerLabel = UILabel()
        followerLabel.textColor = .black
        followerLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        followerLabel.text = "0 followers"
        view.addSubview(followerLabel)
        
        followsYouLabel = UILabel()
        followsYouLabel.backgroundColor = .lightGray
        followsYouLabel.textColor = .darkGray
        followsYouLabel.text = "Follows you"
        followsYouLabel.font = .systemFont(ofSize: 14)
        followsYouLabel.isHidden = true
        followsYouLabel.textAlignment = .center
        followsYouLabel.layer.cornerRadius = 5
        followsYouLabel.clipsToBounds = true
        view.addSubview(followsYouLabel)
        
        segmentedControl  = PostSegmentedControl(frame: .zero, buttonTitles: ["Posts & Reposts", "Likes"])
        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped), for: .valueChanged)
        segmentedControl.backgroundColor = .clear
        view.addSubview(segmentedControl)
        
        postsTableView = UITableView()
        postsTableView.register(PostTableViewCell.self, forCellReuseIdentifier: profilePostsReuseIdentifier)
        postsTableView.dataSource = self
        postsTableView.delegate = self
        postsTableView.tableFooterView = UIView()
        view.addSubview(postsTableView)
        
        getSelectedUserFollower()
        getSelectedUserFollowing()
        getFavoritedPosts()
        getUserAndSharedPosts()
        setUpConstraints()
    }
    
    func setUpNavigationBarUI() {
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        if !barButtonHidden {
            closeButton = UIBarButtonItem(image: UIImage(named: "closeicon"), style: .plain, target: self, action: #selector(closeProfile))
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    func setFollowButton() {
        if User.following.contains(user) {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = Constants.blue
            followButton.layer.borderWidth = 1
            followButton.layer.borderColor = Constants.blue.cgColor
            messageButton.isHidden = false
        }
        else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(Constants.blue, for: .normal)
            followButton.backgroundColor = .white
            followButton.layer.borderWidth = 1
            followButton.layer.borderColor = Constants.blue.cgColor
            messageButton.isHidden = true
        }
    }
    
    @objc func closeProfile() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func segmentedControlTapped() {
        postsTableView.reloadData()
    }
    
    func getFavoritedPosts() {
        DatabaseManager.databaseRef.child("User").child(user.uid).child("Favorited Posts").observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                DatabaseManager.databaseRef.child("Posts").child(postId).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        let favoritedPost = Post(snapshot: snapshot)
                        if !self.favoritedPosts.contains(favoritedPost) {
                            self.favoritedPosts.append(favoritedPost)
                        }
                        self.reloadPostsTableView()
                    }
                }
            }
        }
    }
    
    func getUserAndSharedPosts() {
        DatabaseManager.databaseRef.child("User").child(user.uid).child("User Posts").observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                DatabaseManager.databaseRef.child("Posts").child(postId).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        let userPost = Post(snapshot: snapshot)
                        if !self.userAndSharedPosts.contains(userPost) {
                            self.userAndSharedPosts.append(userPost)
                        }
                        self.reloadPostsTableView()
                    }
                }
            }
        }
        DatabaseManager.databaseRef.child("User").child(user.uid).child("Shared Posts").observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                DatabaseManager.databaseRef.child("Posts").child(postId).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        let sharedPost = Post(snapshot: snapshot)
                        if !self.userAndSharedPosts.contains(sharedPost) {
                            self.userAndSharedPosts.append(sharedPost)
                        }
                        self.reloadPostsTableView()
                    }
                }
            }
        }
    }
    
    func reloadPostsTableView() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(reloadTableViewWithTimer), userInfo: nil, repeats: false)
    }
    
    @objc func reloadTableViewWithTimer() {
        self.userAndSharedPosts.sort { (post1, post2) -> Bool in
            if let time1 = Double(post1.time!), let time2 = Double(post2.time!) {
                return time1 > time2
            }
            else {
                return true
            }
        }
        
        self.favoritedPosts.sort { (post1, post2) -> Bool in
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
    
    func getSelectedUserFollowing() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let selectedUserUid = user.uid
        DatabaseManager.databaseRef.child("User").child(selectedUserUid).child("Following").observeSingleEvent(of: .value, with: { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let followingId = child.key
                DatabaseManager.firestoreRef.collection("Users").document(followingId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let followingUser = OtherUser(snapshot: document)
                        if followingUser.uid == currentUserUid {
                            self.followsYouLabel.isHidden = false
                        }
                        self.selectedUserFollowing.append(followingUser)
                        self.followingLabel.text = "\(self.selectedUserFollowing.count) following"
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func getSelectedUserFollower() {
        let selectedUserUid = user.uid
        DatabaseManager.databaseRef.child("User").child(selectedUserUid).child("Followers").observeSingleEvent(of: .value, with: { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let followerId = child.key
                DatabaseManager.firestoreRef.collection("Users").document(followerId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let followerUser = OtherUser(snapshot: document)
                        if !self.selectedUserFollowers.contains(followerUser) {
                            self.selectedUserFollowers.append(followerUser)
                        }
                        self.followerLabel.text = "\(self.selectedUserFollowers.count) followers"
                    }
                }
            }
        }, withCancel: nil)
    }

    
    @objc func followAction() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let selectedUserUid = user.uid
        
        let followingRef = DatabaseManager.databaseRef.child("User").child(uid).child("Following").child(selectedUserUid)
        let followerRef = DatabaseManager.databaseRef.child("User").child(selectedUserUid).child("Followers").child(uid)
        
        if !User.following.contains(user) {
            followingRef.updateChildValues([selectedUserUid: 1])
            followerRef.updateChildValues([uid: 1])
            User.following.append(user)
            setFollowButton()
            getSelectedUserFollower()
        }
        else {
            followingRef.removeValue()
            followerRef.removeValue()
            removeFromFollowing(selectedUserUid: selectedUserUid)
            setFollowButton()
            removeFromFollower(currentUserUid: uid)
            followerLabel.text = "\(selectedUserFollowers.count) followers"
        }
    }
    
    func removeFromFollowing(selectedUserUid: String) {
        let filtered = User.following.filter({$0.uid != selectedUserUid})
        User.following = filtered
    }
    
    func removeFromFollower(currentUserUid: String) {
        let filtered = selectedUserFollowers.filter({$0.uid != currentUserUid})
        selectedUserFollowers = filtered
    }
    
    @objc func messageUser() {
        dismiss(animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(switchTabBar), userInfo: nil, repeats: false)
    }
    
    @objc func switchTabBar() {
        if let tabBarController = self.view.window!.rootViewController as? UITabBarController {
            DispatchQueue.main.async {
                tabBarController.selectedIndex = 3
                let messageNavVC = tabBarController.viewControllers![3] as! UINavigationController
                let vc = Chat(friend: self.user)
                messageNavVC.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    func setUpConstraints() {
        let imageSize: CGFloat = 100
        let horizontalPadding: CGFloat = 25
        let verticalPadding: CGFloat = 8
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(120)
        }
        
        profilePicture.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(60)
            make.leading.equalTo(view.snp.leading).offset(horizontalPadding)
            make.width.height.equalTo(imageSize)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(profilePicture.snp.leading).offset(10)
            make.top.equalTo(profilePicture.snp.bottom).offset(verticalPadding)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
        }
        
        followButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(profilePicture.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).offset(-25)
            make.width.equalTo(110)
            make.height.equalTo(30)
        }
        
        messageButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(followButton.snp.centerY)
            make.width.height.equalTo(30)
            make.trailing.equalTo(followButton.snp.leading).offset(-10)
        }
        
        followsYouLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(messageButton.snp.leading).offset(-15)
            make.bottom.equalTo(messageButton.snp.bottom).offset(-5)
            make.height.equalTo(14)
            make.width.equalTo(90)
        }
        
        dividingLine.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.width.equalTo(120)
            make.top.equalTo(usernameLabel.snp.bottom).offset(verticalPadding)
            make.height.equalTo(3)
        }
        
        shortBio.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading).offset(horizontalPadding)
            make.trailing.equalTo(view.snp.trailing).offset(-horizontalPadding)
            make.top.equalTo(dividingLine.snp.bottom).offset(verticalPadding)
            make.height.equalTo(60)
        }
        
        followingLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(shortBio.snp.leading).offset(10)
            make.top.equalTo(shortBio.snp.bottom).offset(5)
            make.height.equalTo(18)
        }
        
        followerLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(followingLabel.snp.trailing).offset(10)
            make.top.equalTo(followingLabel.snp.top)
            make.height.equalTo(18)
        }
        
        segmentedControl.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(followingLabel.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        
        postsTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(segmentedControl.snp.bottom).offset(15)
            make.bottom.equalTo(view.snp.bottom)
        }
        
    }
    
}
extension OtterUserProfile: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedIndex == 0 {
            return userAndSharedPosts.count
        }
        return favoritedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post
        let cell = postsTableView.dequeueReusableCell(withIdentifier: profilePostsReuseIdentifier, for: indexPath) as! PostTableViewCell
        if segmentedControl.selectedIndex == 0 {
            post = userAndSharedPosts[indexPath.row]
        }
        else {
            post = favoritedPosts[indexPath.row]
        }
        cell.postActionDelegate = self
        cell.configure(for: post)
        cell.selectionStyle = .none
        return cell
    }
    
}

extension OtterUserProfile: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedControl.selectedIndex == 0 {
            let post = userAndSharedPosts[indexPath.row]
            return post.getCellHeight()
        }
        let post = favoritedPosts[indexPath.row]
        return post.getCellHeight()
    }
    
}

extension OtterUserProfile: PostActionProtocol {
    
    func presentUserProfile(cell: PostTableViewCell) {
        var post: Post
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        guard let indexPath = postsTableView.indexPath(for: cell) else { return }
        if segmentedControl.selectedIndex == 0 {
            post = userAndSharedPosts[indexPath.row]
        }
        else {
            post = favoritedPosts[indexPath.row]
        }
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
        var post: Post
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let indexPath = postsTableView.indexPath(for: cell) else { return }
        let userFavoritedPosts = User.favoritedPosts
        if segmentedControl.selectedIndex == 0 {
            post = userAndSharedPosts[indexPath.row]
        }
        else {
            post = favoritedPosts[indexPath.row]
        }
        let postId = post.postId
        let databaseRef = DatabaseManager.databaseRef.child("User").child(uid).child("Favorited Posts").child(postId)
        if !userFavoritedPosts.contains(post) {
            databaseRef.updateChildValues([postId: 1])
            User.favoritedPosts.append(post)
        }
        else {
            databaseRef.removeValue()
            removeFavoriteAction(for: postId, array: .favorited)
        }
        self.reloadPostsTableView()
    }
    
    func postShared(cell: PostTableViewCell) {
        var post: Post
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let indexPath = postsTableView.indexPath(for: cell) else { return }
        let sharedPosts = User.sharedPosts
        if segmentedControl.selectedIndex == 0 {
            post = userAndSharedPosts[indexPath.row]
        }
        else {
            post = favoritedPosts[indexPath.row]
        }
        let postId = post.postId
        let databaseRef = DatabaseManager.databaseRef.child("User").child(uid).child("Shared Posts").child(postId)
        if !sharedPosts.contains(post) {
            databaseRef.updateChildValues([postId: 1])
            User.sharedPosts.append(post)
        }
        else {
            databaseRef.removeValue()
            removeFavoriteAction(for: postId, array: .shared)
        }
        self.reloadPostsTableView()
    }
    
    func removeFavoriteAction(for postId: String, array: PostSubarray) {
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

