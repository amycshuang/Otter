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
    
    var messagesTableView: UITableView!
    let messagesReuseIdentifier = "messagesReuseIdentifier"
    let cellHeight: CGFloat = 80
    var messages: [Message] = []
    
    weak var delegate: MessagesControllerProtocol?
    
    init(delegate: MessagesControllerProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var profilePicButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "Messages"
        self.navigationController?.navigationBar.isHidden = false
        setUpNavigationBarUI()
        
        messagesTableView = UITableView()
        messagesTableView.register(MessagesTableViewCell.self, forCellReuseIdentifier: messagesReuseIdentifier)
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        view.addSubview(messagesTableView)
        
        let testmessage1 = Message(senderName: "Amy Huang", receiverName: "Someone", message: "Hello World", time: "11:11 AM", profilePicUrl: "https://random.dog/1d4a9a05-1faa-4305-815e-33b06669dbca.JPG")
        let testmessage2 = Message(senderName: "John", receiverName: "Patrick", message: "Yes", time: "12:20 PM", profilePicUrl: "https://random.dog/d25f1923-617b-4176-8388-4a3e040892af.jpg")
        messages = [testmessage1, testmessage2, testmessage1]
        
        setUpConstraints()
    }
    
    func setUpNavigationBarUI() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = Constants.blue
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.view.backgroundColor = .white
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        
        profilePicButton = UIBarButtonItem(image: UIImage(named: "addtocalendarbutton"), style: .plain, target: self, action: #selector(displayMenu))
        profilePicButton.imageInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = profilePicButton
    }
    
    @objc func displayMenu() {
        delegate?.handleMenuToggle(for: nil)
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
        messages.count
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
        let vc = Chat()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
