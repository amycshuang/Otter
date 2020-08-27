//
//  Messages.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/5/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth

class Messages: UIViewController {
    
    var addChatButton: UIBarButtonItem!
    
    var messagesTableView: UITableView!
    let messagesReuseIdentifier = "messagesReuseIdentifier"
    let cellHeight: CGFloat = 80
    var messages: [Message] = []
    var messagesDict: [String: Message] = [:]
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpNavigationBarUI()
        
        messagesTableView = UITableView()
        messagesTableView.register(MessagesTableViewCell.self, forCellReuseIdentifier: messagesReuseIdentifier)
        messagesTableView.separatorStyle = .none
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        view.addSubview(messagesTableView)
        
        DatabaseManager.getUserInfo()
        getUserMessages()
        setUpConstraints()
    }
    
    func setUpNavigationBarUI() {
        self.navigationItem.title = "Messages"
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        
        addChatButton = UIBarButtonItem(image: UIImage(named: "addchaticon"), style: .plain, target: self, action: #selector(addChat))
        addChatButton.imageInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItem = addChatButton
    }
    
    @objc func addChat() {
        let vc = AddChat()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.databaseRef.child("User-Messages").child(uid).observe(.childAdded, with: { (snapshot) in
            let recipientId = snapshot.key
            DatabaseManager.databaseRef.child("User-Messages").child(uid).child(recipientId).observe(.childAdded) { (snapshot) in
                let messageId = snapshot.key
                let messageRef = DatabaseManager.databaseRef.child("Messages").child(messageId)
                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    self.getMessages(snapshot: snapshot)
                }, withCancel: nil)
            }
        }, withCancel: nil)
    }
    
    func getMessages(snapshot: DataSnapshot) {
        let message = Message(snapshot: snapshot)
        self.messagesDict[message.getRecipientId()] = message
        self.reloadMessagesTableView()
    }
    
    func reloadMessagesTableView() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(reloadTableViewWithTimer), userInfo: nil, repeats: false)
    }
    
    @objc func reloadTableViewWithTimer() {
        self.messages = Array(self.messagesDict.values)
        self.messages.sort { (message1, message2) -> Bool in
            if let time1 = Double(message1.time!), let time2 = Double(message2.time!) {
                return time1 > time2
            }
            else {
                return true
            }
        }
        DispatchQueue.main.async {
            self.messagesTableView.reloadData()
        }
    }
    
    func setUpConstraints() {
        
        messagesTableView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
        
    }

}

extension Messages: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: messagesReuseIdentifier, for: indexPath) as! MessagesTableViewCell
        let message = messages[indexPath.row]
        cell.configure(for: message)
        cell.selectionStyle = .none
        return cell
    }
    
}

extension Messages: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let friendId = message.getRecipientId()
        DatabaseManager.getFriend(from: friendId) { (otherUser) in
            DispatchQueue.main.async {
                let friend = otherUser
                let vc = Chat(friend: friend)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message = messages[indexPath.row]
        let friendId = message.getRecipientId()
        if editingStyle == .delete {
            DatabaseManager.databaseRef.child("User-Messages").child(uid).child(friendId).removeValue { (error, ref) in
                if error != nil {
                    guard let errorData = error else { return }
                    print(errorData.localizedDescription)
                    return
                }
                self.messagesDict.removeValue(forKey: friendId)
                self.reloadMessagesTableView()
            }
        }
    }
    
}
