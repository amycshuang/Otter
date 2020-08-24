//
//  SearchUser.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/25/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class SearchUser: UIViewController {

    var searchTableView: UITableView!
    let searchReuseIdentifier = "searchReuseIdentifier"
    let cellHeight: CGFloat = 80
    var searchedUsers: [OtherUser] = []
    var noResultsLabel: UILabel!
    var searchText: String = ""
    var didBeginSearching: Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        searchTableView = UITableView()
        searchTableView.separatorStyle = .none
        searchTableView.register(UsersTableViewCell.self, forCellReuseIdentifier: searchReuseIdentifier)
        searchTableView.dataSource = self
        searchTableView.delegate = self
        view.addSubview(searchTableView)
        
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = Constants.blue
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Otter users"
        
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
        
        definesPresentationContext = true
        setUpConstraints()
        
    }
    
    func setUpConstraints() {
        searchTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
        noResultsLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(-80)
            make.height.equalTo(30)
        }
    }

}

extension SearchUser: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchedUsers.isEmpty && didBeginSearching {
            noResultsLabel.isHidden = false
            noResultsLabel.text = "No results for \(searchText)"
        }
        else {
            noResultsLabel.isHidden = true
        }
        return searchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: searchReuseIdentifier, for: indexPath) as! UsersTableViewCell
        let user = searchedUsers[indexPath.row]
        cell.configure(for: user)
        cell.selectionStyle = .none
        return cell
    }
    
    
}

extension SearchUser: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = searchedUsers[indexPath.row]
        let vc = OtterUserProfile(user: user)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: true, completion: nil)
    }
    
}

extension SearchUser: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.searchText = searchText
            didBeginSearching = true
            DatabaseManager.searchUsersByName(name: searchText) { (users) in
                self.searchedUsers = users
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            }
        }
        else {
            didBeginSearching = false
            self.searchedUsers = []
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        if searchText == "" {
            didBeginSearching = false
            self.searchedUsers = []
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchedUsers = []
        noResultsLabel.isHidden = true 
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
    }

    
}
