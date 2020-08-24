//
//  Register.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 6/20/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class Register: UIViewController {
    
    var profileImage: UIImageView!
    var chooseImageButton: UIButton!
    var nameTextField: UITextField!
    var userNameTextField: UITextField!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var confirmPasswordTextField: UITextField!
    var backButton: UIButton!
    var registerButton: UIButton!
    var usernameExistsLabel: UILabel!
    var usernameExistsBool: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.blue
        self.navigationController?.navigationBar.isHidden = true
       
        profileImage = UIImageView()
        profileImage.image = UIImage(named: "profileplaceholder")
        profileImage.layer.cornerRadius = 44
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        view.addSubview(profileImage)
        
        chooseImageButton = UIButton()
        chooseImageButton.setTitle("Choose Picture", for: .normal)
        chooseImageButton.setTitleColor(Constants.bluewhite, for: .normal)
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        view.addSubview(chooseImageButton)
        
        nameTextField = UITextField()
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        nameTextField.textColor = .white
        nameTextField.bottomBorder()
        view.addSubview(nameTextField)
        
        userNameTextField = UITextField()
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        userNameTextField.textColor = .white
        userNameTextField.bottomBorder()
        userNameTextField.addTarget(self, action: #selector(checkUsername), for: .editingDidEnd)
        view.addSubview(userNameTextField)
       
        usernameExistsLabel = UILabel()
        usernameExistsLabel.textColor = Constants.red
        usernameExistsLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        view.addSubview(usernameExistsLabel)
        
        emailTextField = UITextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.textColor = .white
        emailTextField.bottomBorder()
        view.addSubview(emailTextField)
       
        passwordTextField = UITextField()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordTextField.textColor = .white
        passwordTextField.isSecureTextEntry = true
        passwordTextField.bottomBorder()
        view.addSubview(passwordTextField)
           
        confirmPasswordTextField = UITextField()
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPasswordTextField.textColor = .white
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.bottomBorder()
        view.addSubview(confirmPasswordTextField)
        
        backButton = UIButton()
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)
        backButton.addTarget(self, action: #selector(popRegisterVC), for: .touchUpInside)
        view.addSubview(backButton)
        
        registerButton = UIButton()
        registerButton.setTitle("Sign Up", for:  .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        registerButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        registerButton.setTitleColor(Constants.blue, for: .normal)
        registerButton.backgroundColor = .white
        registerButton.layer.borderColor = UIColor.white.cgColor
        registerButton.layer.borderWidth = 1
        registerButton.layer.cornerRadius = 8
        view.addSubview(registerButton)
       
        setUpConstraints()
        
    }
    
    @objc func checkUsername(_ textField: UITextField) {
        if userNameTextField.text != "" {
            guard let username = userNameTextField.text else {return}
            let docRef = DatabaseManager.firebaseRef.collection("Usernames").document(username)
            docRef.getDocument { (document, error) in
                guard let document = document else {return}
                if document.exists {
                    // Another account is already associated with this username
                    self.usernameExistsBool = true
                    self.usernameExistsLabel.text = "Username is taken"
                    self.usernameExistsLabel.isHidden = false
                    self.userNameTextField.textColor = Constants.red
                }
                else {
                    // There is no other account associated with this username
                    self.usernameExistsBool = false
                    self.usernameExistsLabel.text = ""
                    self.usernameExistsLabel.isHidden = true
                    self.userNameTextField.textColor = .white
                }
            }
        }
        else {
            self.usernameExistsLabel.isHidden = true
        }
    }
    
    @objc func popRegisterVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func signUp() {
        if let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let username = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            if validateFields(name: name, username: username, email: email, password: password, confirmPassword: confirmPassword) {
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    // Check for errors in creating user
                    if let error = error as NSError? {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .emailAlreadyInUse:
                            self.alert(message: "Email already in use", title: "Invalid Email")
                        case .invalidEmail:
                            self.alert(message: "Please ensure the email is formatted correctly", title: "Invalid Email")
                        default:
                            // There was an error in creating the user
                            self.alert(message: "There was an error in creating your account. Please try again.", title: "Error")
                        }
                    }
                    else {
                        guard let uid = result?.user.uid else { return }
                        // User was created successfully
                        DatabaseManager.createUser(uid: uid, name: name, username: username, email: email)
                        // Transition to Messages view
                        self.transitionToMessages()
                    }
                }
            }
        }
    }
    
    func validateFields(name: String, username: String, email: String, password: String, confirmPassword: String) -> Bool {
            if name == "" || username == "" || email == "" || password == "" || confirmPassword == "" {
                // One or more fields is empty
                alert(message: "Please fill out all fields", title: "Invalid Information")
                return false
            }
            else if !Utilities.isValidPassword(password) {
                // Password does not meet the security requirements
                alert(message: "Please make sure your password is at least 8 characters, contains a special character and a number", title: "Invalid Password")
                return false
            }
            else if password != confirmPassword {
                // Both password fields do not match
                alert(message: "Please make sure your passwords match", title: "Invalid Password Fields")
                return false
            }
            else if usernameExistsBool == true {
                // The username the user has chosen already exists
                alert(message: "Another account is already associated with this username", title: "Invalid Username")
                return false
        }
        // Fields are all valid
        return true
    }
    
    func transitionToMessages() {
        //let rootVC = Messages()
        //view.window?.rootViewController = UINavigationController(rootViewController: rootVC)
        view.window?.rootViewController = TabBar()
        view.window?.makeKeyAndVisible()
    }
    
    // FINISH IMPLEMENTING
    @objc func chooseImage() {
        print("choosing image...")
        presentPhotoActionsheet()
    }
       
    func setUpConstraints() {
        let textHeight: CGFloat = 35
        let verticalPadding: CGFloat = 20
        let width: CGFloat = 60
        let imageSize: CGFloat = 88
        
        profileImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(120)
            make.width.height.equalTo(imageSize)
        }
        
        chooseImageButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(profileImage.snp.bottom).offset(2)
        }
       
        nameTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(chooseImageButton.snp.bottom).offset(verticalPadding+8)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
        
        userNameTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(nameTextField.snp.bottom).offset(verticalPadding)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
        
        usernameExistsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userNameTextField.snp.bottom).offset(3)
            make.left.equalTo(userNameTextField.snp.left)
            make.width.equalTo(200)
            make.height.equalTo(20)
        }
       
        emailTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(userNameTextField.snp.bottom).offset(verticalPadding)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
       
        passwordTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(emailTextField.snp.bottom).offset(verticalPadding)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
       
        confirmPasswordTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(passwordTextField.snp.bottom).offset(verticalPadding)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(10)
            make.top.equalTo(view.snp.top).offset(60)
            make.width.height.equalTo(35)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(2*verticalPadding)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(confirmPasswordTextField.snp.width)
            make.height.equalTo(45)
        }
    }

}

extension Register: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionsheet() {
        let actionSheet = UIAlertController(title: "Choose Profile Picture Source", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePicker(sourceType: .camera)
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.presentImagePicker(sourceType: .photoLibrary)
        }
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        profileImage.image = editedImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
