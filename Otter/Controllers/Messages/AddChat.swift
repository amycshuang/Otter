//
//  AddChat.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/27/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class AddChat: UIViewController {

    var usersTableView: UITableView!
    let usersReuseIdentifier = "usersReuseIdentifier"
    let cellHeight: CGFloat = 70
    var users: [OtherUser] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchedUsers: [OtherUser] = []
    var searchText = ""
    var noResultsLabel: UILabel!
    var didBeginSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Add Chat"
        
        usersTableView = UITableView()
        usersTableView.separatorStyle = .none
        usersTableView.register(UsersTableViewCell.self, forCellReuseIdentifier: usersReuseIdentifier)
        usersTableView.dataSource = self
        usersTableView.delegate = self
        usersTableView.tableHeaderView = searchController.searchBar
        view.addSubview(usersTableView)
        
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for people"
        definesPresentationContext = true
        
        noResultsLabel = UILabel()
        noResultsLabel.backgroundColor = Constants.blue
        noResultsLabel.font = .systemFont(ofSize: 16)
        noResultsLabel.textAlignment = .center
        noResultsLabel.alpha = 0.7
        noResultsLabel.textColor = .white
        noResultsLabel.layer.cornerRadius = 8
        noResultsLabel.layer.masksToBounds = true
        noResultsLabel.isHidden = true
        noResultsLabel.numberOfLines = 0
        view.addSubview(noResultsLabel)
        
        loadUsers()
        setUpConstraints()
        
    }
    
    func loadUsers() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.databaseRef.child("User").child(uid).child("Following").observeSingleEvent(of: .value) { (snapshot) in
            for datasnapshot in snapshot.children {
                let child = datasnapshot as! DataSnapshot
                let followingId = child.key
                DatabaseManager.firestoreRef.collection("Users").document(followingId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let followingUser = OtherUser(snapshot: document)
                        if followingUser.uid != uid {
                            self.users.append(followingUser)
                            DispatchQueue.main.async {
                                self.usersTableView.reloadData()
                            }
                         }
                     }
                 }
             }
         }
    }
    
    
    
    func setUpConstraints() {
        
        noResultsLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(-80)
            make.height.equalTo(30)
        }
        
        usersTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
    }

}

extension AddChat: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if didBeginSearching {
            return searchedUsers.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: usersReuseIdentifier, for: indexPath) as! UsersTableViewCell
        cell.selectionStyle = .none
        if didBeginSearching {
            let searchedUser = searchedUsers[indexPath.row]
            cell.configure(for: searchedUser)
            return cell
        }
        let user = users[indexPath.row]
        cell.configure(for: user)
        return cell
    }
    
    
}

extension AddChat: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if didBeginSearching {
            let searchedUser = searchedUsers[indexPath.row]
            let vc = Chat(friend: searchedUser)
            navigationController?.popViewController(animated: true)
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let user = users[indexPath.row]
            let vc = Chat(friend: user)
            navigationController?.popViewController(animated: true)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension AddChat: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.searchText = searchText
            didBeginSearching = true
            let filtered = users.filter({$0.searchName.contains(searchText.lowercased()) || $0.searchUsername.contains(searchText.lowercased())})
            self.searchedUsers = filtered
            if searchedUsers.isEmpty {
                noResultsLabel.isHidden = false
                noResultsLabel.text = "No results for \(searchText)"
            }
            else {
                noResultsLabel.isHidden = true
            }
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
        }
        else {
            didBeginSearching = false
            noResultsLabel.isHidden = true
            self.searchedUsers = []
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        if searchText == "" {
            didBeginSearching = false
            noResultsLabel.isHidden = true
            self.searchedUsers = []
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchedUsers = []
        didBeginSearching = false
        noResultsLabel.isHidden = true
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
        }
    }
    
}
