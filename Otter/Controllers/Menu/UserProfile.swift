//
//  UserProfile.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/25/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class UserProfile: UIViewController {

    var closeButton: UIBarButtonItem!
    var profilePicture: UIImageView!
    var headerView: UIImageView!
    var editProfileButton: UIButton!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
    var dividingLine: UITextField!
    var shortBio: UITextView!
    
    var followerLabel: UILabel!
    var followingLabel: UILabel!
    
    var segmentedControl: PostSegmentedControl!
    var postsTableView: UITableView!
    var userProfilePostsReuseIdentifier = "userProfilePostsReuseIdentifier"
    var userAndSharedPosts: [Post] = []
    var favoritedPosts: [Post] = []
    
    var timer: Timer?
    var barButtonHidden: Bool!
    
    init(barButtonHidden: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.barButtonHidden = barButtonHidden
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpNavigationBarUI()
        self.hideKeyboardWhenViewTapped()

        DatabaseManager.getUserInfo()
        
        profilePicture = UIImageView()
        guard let url = User.imageUrl else { return }
        profilePicture.getImage(from: url)
        profilePicture.layer.cornerRadius = 50
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        view.addSubview(profilePicture)
        view.bringSubviewToFront(profilePicture)
        
        headerView = UIImageView()
        guard let headerUrl = User.headerUrl else { return }
        headerView.getImage(from: headerUrl)
        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill
        view.addSubview(headerView)
        view.sendSubviewToBack(headerView)
        
        editProfileButton = UIButton()
        editProfileButton.setTitle("Edit Profile", for: .normal)
        editProfileButton.setTitleColor(Constants.blue, for: .normal)
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.borderColor = Constants.blue.cgColor
        editProfileButton.layer.cornerRadius = 12
        editProfileButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        view.addSubview(editProfileButton)
        
        nameLabel = UILabel()
        nameLabel.text = User.name
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        guard let username = User.username else { return }
        usernameLabel.text = "@\(username)"
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        usernameLabel.textColor = .gray
        view.addSubview(usernameLabel)
        
        dividingLine = UITextField()
        dividingLine.blackBottomBorder()
        view.addSubview(dividingLine)
        
        shortBio = UITextView()
        shortBio.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        shortBio.text = User.bio
        shortBio.textColor = .black
        shortBio.isEditable = false
        shortBio.isUserInteractionEnabled = true
        shortBio.isScrollEnabled = false
        view.addSubview(shortBio)
        
        followingLabel = UILabel()
        followingLabel.textColor = .black
        followingLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        followingLabel.text = "\(User.following.count) following"
        view.addSubview(followingLabel)
        
        followerLabel = UILabel()
        followerLabel.textColor = .black
        followerLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        followerLabel.text = "\(User.followers.count) followers"
        view.addSubview(followerLabel)
        
        segmentedControl  = PostSegmentedControl(frame: .zero, buttonTitles: ["Posts & Reposts", "Likes"])
        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped), for: .valueChanged)
        segmentedControl.backgroundColor = .clear
        view.addSubview(segmentedControl)
        
        postsTableView = UITableView()
        postsTableView.register(PostTableViewCell.self, forCellReuseIdentifier: userProfilePostsReuseIdentifier)
        postsTableView.dataSource = self
        postsTableView.delegate = self
        postsTableView.tableFooterView = UIView()
        view.addSubview(postsTableView)
        
        getUserAndSharedPosts()
        getFavoritedPosts()
        
        setUpConstraints()
    }
    
    func setUpNavigationBarUI() {
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        self.navigationItem.title = "Profile"
        
        if !barButtonHidden {
            closeButton = UIBarButtonItem(image: UIImage(named: "closeicon"), style: .plain, target: self, action: #selector(closeProfile))
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    @objc func closeProfile() {
        dismiss(animated: true, completion: nil)
    }
    
    func getFavoritedPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.databaseRef.child("User").child(uid).child("Favorited Posts").observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                DatabaseManager.databaseRef.child("Posts").child(postId).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        let favoritedPost = Post(snapshot: snapshot)
                        self.favoritedPosts.append(favoritedPost)
                        self.reloadPostsTableView()
                    }
                }
            }
        }
    }
    
    func getUserAndSharedPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.databaseRef.child("User").child(uid).child("User Posts").observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let postId = child.key
                DatabaseManager.databaseRef.child("Posts").child(postId).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        let userPost = Post(snapshot: snapshot)
                        self.userAndSharedPosts.append(userPost)
                        self.reloadPostsTableView()
                    }
                }
            }
        }
        DatabaseManager.databaseRef.child("User").child(uid).child("Shared Posts").observeSingleEvent(of: .value) { (snapshot) in
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
    
    @objc func editProfile() {
        let vc = EditProfile()
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromTop
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func segmentedControlTapped() {
        postsTableView.reloadData()
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
        
        editProfileButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(profilePicture.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).offset(-horizontalPadding)
            make.width.equalTo(110)
            make.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(profilePicture.snp.leading).offset(10)
            make.top.equalTo(profilePicture.snp.bottom).offset(verticalPadding)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
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

extension UserProfile: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedIndex == 0 {
            return userAndSharedPosts.count
        }
        return favoritedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post
        let cell = postsTableView.dequeueReusableCell(withIdentifier: userProfilePostsReuseIdentifier, for: indexPath) as! PostTableViewCell
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

extension UserProfile: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedControl.selectedIndex == 0 {
            let post = userAndSharedPosts[indexPath.row]
            return post.getCellHeight()
        }
        let post = favoritedPosts[indexPath.row]
        return post.getCellHeight()
    }
    
}

extension UserProfile: PostActionProtocol {
    
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
            if selectedUser.uid != currentUserUid {
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
