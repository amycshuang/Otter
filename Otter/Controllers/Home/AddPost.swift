//
//  AddPost.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/17/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddPost: UIViewController {
    
    var closeButton: UIButton!
    var postButton: UIButton!
    var postTextView: UITextView!
    var characterLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "New Post"
        setUpNavigationBarUI()
        
        postTextView = UITextView()
        postTextView.font = .systemFont(ofSize: 18)
        postTextView.text = "What's happening?"
        postTextView.textColor = Constants.blue
        postTextView.isEditable = true
        postTextView.isScrollEnabled = false
        postTextView.delegate = self
        view.addSubview(postTextView)
        
        setUpConstraints()
    }
    
    func setUpNavigationBarUI() {
        self.navigationController?.navigationBar.barTintColor = Constants.blue
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
         
        closeButton = UIButton()
        closeButton.setImage(UIImage(named: "bluedismissicon"), for: .normal)
        closeButton.clipsToBounds = true
        closeButton.contentMode = .scaleAspectFill
        closeButton.addTarget(self, action: #selector(dismissAddPost), for: .touchUpInside)
        view.addSubview(closeButton)
        
        postButton = UIButton()
        postButton.setTitle("Post", for: .normal)
        postButton.backgroundColor = Constants.bluewhite
        postButton.titleLabel?.textColor = Constants.darkerBlue
        postButton.layer.cornerRadius = 10
        postButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        view.addSubview(postButton)
        
        characterLabel = UILabel()
        characterLabel.textColor = Constants.blue
        characterLabel.text = "150"
        characterLabel.font = .systemFont(ofSize: 18)
        view.addSubview(characterLabel)
     }
    
    @objc func dismissAddPost() {
        dismiss(animated: true, completion: nil)
    }

    @objc func post() {
        guard let posterUid = Auth.auth().currentUser?.uid else { return }
        let time = String(NSDate().timeIntervalSince1970)
        if let text = postTextView.text, text != "" {
            let values: [String: Any] = [
                "posterUid": posterUid,
                "text": text,
                "time": time
            ]
            let databaseRef = DatabaseManager.databaseRef.child("Posts").childByAutoId()
            databaseRef.updateChildValues(values) { (error, reference) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let postId = databaseRef.key else { return }
                let userPostsRef = DatabaseManager.databaseRef.child("User").child(posterUid).child("User Posts")
                userPostsRef.updateChildValues([postId: 1])
                self.dismissAddPost()
            }
        }
    }
    
    func setUpConstraints() {
        let buttonSize: CGFloat = 30
        let verticalPadding: CGFloat = 50
        let horizontalPadding: CGFloat = 20
        
        closeButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(horizontalPadding)
            make.top.equalTo(view.snp.top).offset(verticalPadding)
            make.width.height.equalTo(buttonSize)
        }
        
        postButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(verticalPadding)
            make.trailing.equalTo(view.snp.trailing).offset(-horizontalPadding)
            make.width.equalTo(60)
            make.height.equalTo(buttonSize)
        }
        
        characterLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(postButton.snp.leading).offset(-20)
            make.top.equalTo(postButton)
            make.height.equalTo(buttonSize)
        }
        
        postTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(horizontalPadding)
            make.trailing.equalTo(view.snp.trailing).offset(-horizontalPadding)
            make.height.equalTo(120)
            make.top.equalTo(postButton.snp.bottom).offset(15)
        }
    }

}

extension AddPost: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        if characterCount > 0 {
            postButton.backgroundColor = Constants.blue
            postButton.titleLabel?.textColor = .white
        }
        else {
            postButton.backgroundColor = Constants.bluewhite
            postButton.titleLabel?.textColor = Constants.darkerBlue
        }
        
        if characterCount > 140 {
            characterLabel.textColor = Constants.red
        }
        else {
            characterLabel.textColor = Constants.blue
        }
        characterLabel.text = "\(150 - characterCount)"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Constants.blue {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 150
    }
    
}
