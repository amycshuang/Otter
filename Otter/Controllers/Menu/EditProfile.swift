//
//  EditProfile.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/15/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore

class EditProfile: UIViewController {
    
    var cancelButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    
    var profilePicture: UIImageView!
    var headerView: UIImageView!
    var newProfilePicButton: UIButton!
    var newHeaderButton: UIButton!
    var originalProfileImage: UIImage!
    var originalHeaderImage: UIImage!
    var profileImagePicker: UIImagePickerController!
    var headerImagePicker: UIImagePickerController!
    
    var nameLabel: UILabel!
    var newNameTextField: UITextField!
    
    var usernameLabel: UILabel!
    var newUsernameTextField: UITextField!
    var originalUsername: String = ""
    var usernameExistsLabel: UILabel!
    var usernameExistsBool: Bool = false
    
    var bioLabel: UILabel!
    var newBioTextField: UITextField!
    
    var saveMessage: MessagePopup!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Profile"
        view.backgroundColor = .white
        self.hideKeyboardWhenViewTapped()
        setUpNavBar()
        
        profilePicture = UIImageView()
        guard let url = User.imageUrl else { return }
        profilePicture.getImage(from: url)
        originalProfileImage = profilePicture.image
        profilePicture.layer.cornerRadius = 50
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        view.addSubview(profilePicture)
        
        headerView = UIImageView()
        guard let headerUrl = User.headerUrl else { return }
        headerView.getImage(from: headerUrl)
        originalHeaderImage = headerView.image
        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill
        view.addSubview(headerView)
        view.sendSubviewToBack(headerView)
        
        newProfilePicButton = UIButton()
        newProfilePicButton.setTitle("Change Picture", for: .normal)
        newProfilePicButton.setTitleColor(Constants.blue, for: .normal)
        newProfilePicButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        newProfilePicButton.layer.cornerRadius = 12
        newProfilePicButton.addTarget(self, action: #selector(changeProfilePic), for: .touchUpInside)
        view.addSubview(newProfilePicButton)
        
        newHeaderButton = UIButton()
        newHeaderButton.setTitle("Change Header", for: .normal)
        newHeaderButton.setTitleColor(Constants.blue, for: .normal)
        newHeaderButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        newHeaderButton.layer.cornerRadius = 12
        newHeaderButton.addTarget(self, action: #selector(changeHeader), for: .touchUpInside)
        view.addSubview(newHeaderButton)
        
        nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        
        newNameTextField = UITextField()
        newNameTextField.textColor = Constants.blue
        guard let name = User.name else { return }
        newNameTextField.text = name
        newNameTextField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        newNameTextField.grayBottomBorder()
        view.addSubview(newNameTextField)
        
        
        usernameLabel = UILabel()
        usernameLabel.text = "Username"
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        usernameLabel.textColor = .black
        view.addSubview(usernameLabel)
        
        usernameExistsLabel = UILabel()
        usernameExistsLabel.textColor = Constants.red
        usernameExistsLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        view.addSubview(usernameExistsLabel)
        
        newUsernameTextField = UITextField()
        newUsernameTextField.textColor = Constants.blue
        guard let username = User.username else { return }
        newUsernameTextField.text = username
        newUsernameTextField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        newUsernameTextField.grayBottomBorder()
        newUsernameTextField.addTarget(self, action: #selector(checkUsername), for: .editingDidEnd)
        view.addSubview(newUsernameTextField)
        
        bioLabel = UILabel()
        bioLabel.text = "Bio"
        bioLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        bioLabel.textColor = .black
        view.addSubview(bioLabel)
        
        
        newBioTextField = UITextField()
        newBioTextField.textColor = Constants.blue
        guard let bio = User.bio else { return }
        newBioTextField.text = bio
        newBioTextField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        newBioTextField.grayBottomBorder()
        view.addSubview(newBioTextField)
        
        setUpConstraints()
    }
    
    func setUpNavBar() {
        self.navigationItem.hidesBackButton = true
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(popVC))
        self.navigationItem.leftBarButtonItem = cancelButton
    
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewInfo))
        self.navigationItem.rightBarButtonItem = saveButton
    }

    @objc func popVC() {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .reveal
        transition.subtype = .fromBottom
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func saveNewInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let newName = newNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let newUsername = newUsernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let newBio = newBioTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let newProfileImage = profilePicture.image, let newHeaderImage = headerView.image {
            if validateFields(name: newName, username: newUsername, bio: newBio) {
                guard let originalUsername = User.username else { return }
                DatabaseManager.profileUpdate(uid: uid, newName: newName, newUsername: newUsername, newBio: newBio, originalUsername: originalUsername)
                presentMessagePopup()
            }
            if !originalProfileImage.isEqual(newProfileImage) {
                DatabaseManager.profilePicUpdate(uid: uid, newProfileImage: newProfileImage)
                presentMessagePopup()
            }
            if !originalHeaderImage.isEqual(newHeaderImage) {
                DatabaseManager.headerPicUpdate(uid: uid, newHeaderImage: newHeaderImage)
                presentMessagePopup()
            }
            
        }
    }
    
    func presentMessagePopup() {
        saveMessage = MessagePopup()
        saveMessage.text = "Saved! Reload Otter to see changes"
        saveMessage.textColor = .white
        saveMessage.backgroundColor = Constants.blue
        view.addSubview(saveMessage)
        setUpMessageConstraints()
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dismissMessage), userInfo: nil, repeats: false)
    }
    
    func setUpMessageConstraints() {
        saveMessage.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
    }
    
    @objc func dismissMessage() {
        if saveMessage != nil {
            saveMessage.removeFromSuperview()
            popVC()
        }
    }
    
    func validateFields(name: String, username: String, bio: String) -> Bool {
        if name == "" || username == "" {
            alert(message: "Please make sure you have a name and username", title: "Invalid Information")
            return false
        }
        else if usernameExistsBool == true {
            alert(message: "Another account is already associated with this username", title: "Invalid Username")
            return false
        }
        else if name.count > 20 {
            alert(message: "Please choose a shorter name", title: "Invalid Name")
            return false
        }
        else if username.count > 20 {
            alert(message: "Please choose a shorter username", title: "Invalid Username")
            return false
        }
        else if bio.count > 80 {
            alert(message: "Please shorten your bio", title: "Invalid Bio")
            return false
        }
        return true
    }
    
    @objc func changeProfilePic() {
        profileImagePicker = UIImagePickerController()
        profileImagePicker.delegate = self
        profileImagePicker.allowsEditing = true
        self.present(profileImagePicker, animated: true, completion: nil)
    }
    
    @objc func changeHeader() {
        headerImagePicker = UIImagePickerController()
        headerImagePicker.delegate = self
        headerImagePicker.allowsEditing = true
        self.present(headerImagePicker, animated: true, completion: nil)
    }
    
    @objc func checkUsername(_ textField: UITextField) {
        if newUsernameTextField.text != "" {
            guard let username = newUsernameTextField.text else {return}
            let docRef = DatabaseManager.firestoreRef.collection("Usernames").document(username)
            docRef.getDocument { (document, error) in
                guard let document = document else {return}
                if document.exists {
                    DispatchQueue.main.async {
                        // Another account is already associated with this username
                        self.usernameExistsBool = true
                        self.usernameExistsLabel.text = "Username is taken"
                        self.usernameExistsLabel.isHidden = false
                        self.newUsernameTextField.textColor = Constants.red
                    }
                }
                else {
                    DispatchQueue.main.async {
                        // There is no other account associated with this username
                        self.usernameExistsBool = false
                        self.usernameExistsLabel.text = ""
                        self.usernameExistsLabel.isHidden = true
                        self.newUsernameTextField.textColor = .white
                    }
                }
            }
        }
        else {
            self.usernameExistsLabel.isHidden = true
        }
    }
    
    func setUpConstraints() {
        
        let imageSize: CGFloat = 100
        let horizontalPadding: CGFloat = 25
        let textFieldWidth: CGFloat = 230
        
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(120)
        }
        
        profilePicture.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(55)
            make.leading.equalTo(view.snp.leading).offset(horizontalPadding)
            make.width.height.equalTo(imageSize)
        }
        
       
        newProfilePicButton.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.leading.equalTo(profilePicture.snp.trailing).offset(20)
        }
        
        newHeaderButton.snp.makeConstraints { (make) in
            make.top.equalTo(newProfilePicButton.snp.top)
            make.leading.equalTo(newProfilePicButton.snp.trailing).offset(15)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(profilePicture.snp.leading).offset(10)
            make.top.equalTo(profilePicture.snp.bottom).offset(70)
        }
        
        newNameTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.trailing).offset(60)
            make.width.equalTo(textFieldWidth)
            make.bottom.equalTo(nameLabel.snp.bottom)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(30)
        }
        
        newUsernameTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(newNameTextField.snp.leading)
            make.width.equalTo(textFieldWidth)
            make.bottom.equalTo(usernameLabel.snp.bottom)
        }
        
        usernameExistsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newUsernameTextField.snp.bottom).offset(3)
            make.left.equalTo(newUsernameTextField.snp.left)
            make.width.equalTo(200)
            make.height.equalTo(20)
        }
        
        bioLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(usernameLabel.snp.leading)
            make.top.equalTo(usernameLabel.snp.bottom).offset(30)
        }
        
        newBioTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(newUsernameTextField.snp.leading)
            make.bottom.equalTo(bioLabel.snp.bottom)
            make.width.equalTo(textFieldWidth)
        }
    }
}

extension EditProfile: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker == profileImagePicker {
            if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                profilePicture.image = editedImage
            }
            else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                profilePicture.image = originalImage
            }
        }
        else if picker == headerImagePicker {
            if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                headerView.image = editedImage
            }
            else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                headerView.image = originalImage
            }
        }
         picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}
