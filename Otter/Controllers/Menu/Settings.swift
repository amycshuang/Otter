//
//  Settings.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/25/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

enum Setting: String {
    case updatePassword
    case updateEmail
    case deleteAccount
}


class Settings: UIViewController {
    
    var closeButton: UIBarButtonItem!
    var accountLabel: UILabel!
    var settingsTableView: UITableView!
    let settingsReuseIdentifier = "settingsReuseIdentifier"
    let cellHeight: CGFloat = 45
    let settings: [Setting] = [.updatePassword, .updateEmail, .deleteAccount]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.bluewhite
        setUpNavigationBarUI()
        
        accountLabel = UILabel()
        accountLabel.text = "Account"
        accountLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        view.addSubview(accountLabel)
        
        settingsTableView = UITableView()
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: settingsReuseIdentifier)
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        view.addSubview(settingsTableView)
        
        setUpConstraints()
        
    }
    
    func setUpNavigationBarUI() {
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        self.navigationItem.title = "Settings"
        
        closeButton = UIBarButtonItem(image: UIImage(named: "closeicon"), style: .plain, target: self, action: #selector(closeSettings))
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    func setUpConstraints() {
        
        accountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(30)
            make.height.equalTo(15)
            make.leading.equalTo(view.snp.leading).offset(15)
        }
        
        settingsTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(accountLabel.snp.bottom).offset(10)
            make.height.equalTo(135)
        }
    }
    
    @objc func closeSettings() {
        dismiss(animated: true, completion: nil)
    }

}

extension Settings: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: settingsReuseIdentifier, for: indexPath) as! SettingsTableViewCell
        let setting = settings[indexPath.row]
        cell.configure(settingsOption: setting)
        cell.selectionStyle = .none
        return cell
    }
    
    
}

extension Settings: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingSelected = settings[indexPath.row]
        switch settingSelected {
        case .updatePassword:
            let vc = UpdateAccount(updateProperty: settingSelected)
            self.navigationController?.pushViewController(vc, animated: true)
        case .updateEmail:
            let vc = UpdateAccount(updateProperty: settingSelected)
            self.navigationController?.pushViewController(vc, animated: true)
        case .deleteAccount:
            deleteAccount()
        }
    }
    
    func deleteAccount() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (alertAction) in
            DatabaseManager.deleteAccount { (success) in
            do {
              try Auth.auth().signOut()
            } catch {
                self.alert(message: "Error Deleting Account", title: "Error")
            }
            let rootNavVC = UINavigationController(rootViewController: Welcome())
            self.view.window?.rootViewController = rootNavVC
            self.view.window?.makeKeyAndVisible()
        }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
